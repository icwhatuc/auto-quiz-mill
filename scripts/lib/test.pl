#!/usr/bin/perl

use strict;
use warnings;

use Wikidata::API qw(_getClosestMatchID);

warn _getClosestMatchID($ARGV[0] || "Einstein");

