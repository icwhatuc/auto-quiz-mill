#!/usr/bin/perl

use strict;
use warnings;

use feature qw(say);
use Data::Dumper;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use AQM::Config;

my $es_index = $AQM::Config::core{ELASTICSEARCH}{index};
say "Elasticsearch index : " . Dumper $es_index; 

