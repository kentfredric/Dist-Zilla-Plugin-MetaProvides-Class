use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;
use Test::DZil qw( simple_ini );
use Test::Moose;
use Dist::Zilla::Util::Test::KENTNL 1.003002 qw( dztest );

my $test = dztest();
$test->add_file(
  'dist.ini',
  simple_ini(
    ['GatherDir'],    #
    [ 'MetaProvides::Class' => { inherit_version => 0, inherit_missing => 1 } ],    #
  )
);
$test->add_file( 'lib/DZ2mx.pm', <<'EOF');
# ABSTRACT: turns baubles into trinkets

use MooseX::Declare;

class DZ2::Mx {

}

class DZ2::Mk {

}

1;
EOF

$test->build_ok;
my $plugin;

is(
  exception {
    $plugin = $test->builder->plugin_named('MetaProvides::Class');
  },
  undef,
  'Found MetaProvides::Class'
);

isa_ok( $plugin, 'Dist::Zilla::Plugin::MetaProvides::Class' );
meta_ok( $plugin, 'Plugin is mooseified' );
does_ok( $plugin, 'Dist::Zilla::Role::MetaProvider::Provider', 'does the Provider Role' );
does_ok( $plugin, 'Dist::Zilla::Role::Plugin', 'does the Plugin Role' );
has_attribute_ok( $plugin, 'inherit_version' );
has_attribute_ok( $plugin, 'inherit_missing' );
has_attribute_ok( $plugin, 'meta_noindex' );
is( $plugin->meta_noindex, '1', "meta_noindex default is 1" );
is_deeply(
  $plugin->metadata,
  {
    provides => {
      'DZ2::Mx' => { file => 'lib/DZ2mx.pm', 'version' => '0.001' },
      'DZ2::Mk' => { file => 'lib/DZ2mx.pm', 'version' => '0.001' },
    }
  },
  'provides data is right'
);
isa_ok( [ $plugin->provides ]->[0], 'Dist::Zilla::MetaProvides::ProvideRecord' );

done_testing;
