#!perl

use strict;
use warnings;
use inc::Module::Install;

name 'MasonX-Component-Test';
all_from 'lib/MasonX/Component/Test.pm';

requires 'MasonX::Component' => 0;

mason_component;

WriteAll;
