#!/usr/bin/perl

use strict;
use warnings;

use feature qw(say);
use Data::Dumper;

use JSON;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Wikidata::API qw(
    getTopEntityID
    getEntityNameByID
    getTopEntity
);

say to_json(getTopEntity($ARGV[0] || "einstein")->hashref, {utf8 => 1, pretty => 1});
# say getTopEntityID("einstein");
# say getEntityNameByID("Q937");


