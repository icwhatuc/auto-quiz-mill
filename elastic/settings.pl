#!/usr/bin/perl

use strict;
use warnings;

use feature qw(say);

use JSON;
use File::Slurp;
use Data::Dumper;
use FindBin qw($Bin);
use lib "$Bin/../scripts/lib";
use AQM::Elasticsearch;

my $settings_file = "$Bin/settings.json";
my $settings = from_json(read_file($settings_file));
my $index = (keys %$settings)[0];
$settings = $settings->{$index}->{settings};

AQM::Elasticsearch::updateIndexSettings($settings);

