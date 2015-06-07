#!/usr/bin/perl

use strict;
use warnings;

use feature qw(say);
use Data::Dumper;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Wikidata::API qw(
    getTopEntityID
    getEntityNameByID
    getTopEntity
);

say Dumper getTopEntity($ARGV[0] || "einstein")->hashref;
# say getTopEntityID("einstein");
# say getEntityNameByID("Q937");


