#!/usr/bin/perl

use strict;
use warnings;

use feature qw(say);

use Getopt::Std;
use JSON;
use File::Slurp;
use Data::Dumper;
use FindBin qw($Bin);
use lib "$Bin/../../scripts/lib";
use AQM::Elasticsearch;

our ($opt_h, $opt_m, $opt_d);
die qq{
    Usage: $0 -m MAPPING [-d]
        -m mapping name (expecting elastic/mappings/MAPPING.json file)
        -d delete the mapping and then add (currently not supported)
} if (!getopts('hm:d') || @ARGV || !$opt_m || $opt_h);

my $mapping = $opt_m;
my $delete_flag = $opt_d;
my $mapping_file = "$Bin/$mapping.json";
my $mapping_def = from_json(read_file($mapping_file));
my $es = AQM::Elasticsearch->new();
$es->updateMapping($mapping => $mapping_def);

