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
    module_name   => 'Test::Mojo::Pg',
    dist_name     => 'Test::Mojo::Pg',
    dist_version  => '4.1',
    dist_author   => 'RICHE',
    dist_abstract => 'Tear down and bring up databases with Mojo::Pg',
);

$build->create_build_script();
