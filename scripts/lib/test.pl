#!/usr/bin/perl

use strict;
use warnings;

use MediaWiki::Simple qw(_getClosestMatchID);

warn _getClosestMatchID($ARGV[0] || "Einstein");

