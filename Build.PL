#! /usr/bin/env perl
#

use utf8;
use strict;
use warnings;
use Module::Build;
use File::Basename 'dirname';
use Cwd 'abs_path';
use Env;

my $build = Module::Build->new(
  configure_requires => {
    'Module::Build' => 0.42,
  },
  module_name   => 'Test::Mojo::Pg',
  dist_name     => 'Test-Mojo-Pg',
  dist_version  => '0.3',
  dist_author   => 'RICHE',
  dist_abstract => 'Tear down and bring up databases with Mojo::Pg',
  requires => {
    'Mojo::Base'     => 0,
    'Mojo::Pg'       => 0,
    'File::Basename' => 0,
  },
);

$build->create_build_script();
