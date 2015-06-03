#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use LWP::Simple;
use JSON qw(from_json);
use Getopt::Std;
use List::MoreUtils qw(uniq);

our ($opt_d, $opt_o, $opt_g, $opt_p, $opt_h);

die q{
    Usage: ./extract_ny_ties_trending_entities.pl -dgoph
        -d subject descriptors facet
        -g geographic facet
        -o organization facet
        -p person facet
} if(!getopts("dghop") || $opt_h);

my $all_mode = !$opt_d && !$opt_o && !$opt_g && !$opt_p;
my $url = 'http://api.nytimes.com/svc/topstories/v1/home.json?api-key=091882e61861f420060b35097b4419a2:1:72021160';
my $data = from_json(get($url));

my (@subjects, @geographies, @organizations, @persons);

foreach my $r (@{$data->{results}})
{
    push(@subjects, @{$r->{des_facet}}) if $r->{des_facet};
    push(@geographies, @{$r->{geo_facet}}) if $r->{geo_facet};
    push(@organizations, @{$r->{org_facet}}) if $r->{org_facet};
    push(@persons, @{$r->{per_facet}}) if $r->{per_facet};
}

my @facets = ();
if($all_mode)
{
    push(@facets, @subjects, @geographies, @organizations, @persons);
}

if($opt_d) {
    push(@facets, @subjects)
}
if($opt_g) {
    push(@facets, @geographies);
}
if($opt_o) {
    push(@facets, @organizations);
}
if($opt_p) {
    push(@facets, @persons);
}

print "$_\n" foreach (sort {lc $a cmp lc $b} (uniq(@facets)));

