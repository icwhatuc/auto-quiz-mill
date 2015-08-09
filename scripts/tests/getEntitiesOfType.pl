#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use FindBin qw($Bin);

use lib "$Bin/../lib";
use AQM::Elasticsearch::Entities qw(getEntitiesOfType);

# Search for all entities that are people
my $results = getEntitiesOfType($ARGV[0] || "human");

foreach my $r (@{$results->{hits}->{hits}})
{
    my $name = $r->{_source}->{name};
    print "$name\n";
}

