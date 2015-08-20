#!/usr/bin/perl

use strict;
use warnings;

use CHI;
use FindBin qw($Bin);
use Data::Dumper;
use LWP::Simple;
use JSON qw(from_json);
use Getopt::Std;
use List::MoreUtils qw(uniq);

my $cache = CHI->new(
    driver => 'File',
    root_dir => "$Bin/../tmp/"
);

our ($opt_d, $opt_o, $opt_g, $opt_p, $opt_h);

die q{
    Usage: ./extract_ny_ties_trending_entities.pl -dgoph
        -d subject descriptors facet
        -g geographic facet
        -o organization facet
        -p person facet
} if(!getopts("dghop") || $opt_h);

my $all_mode = !$opt_d && !$opt_o && !$opt_g && !$opt_p;
my $data;

# caching done in store_entities.pl
#if (defined $cache->get( "nyt" )) {
#    $data = $cache->get( "nyt");
#}
#else {
    my $url = 'http://api.nytimes.com/svc/topstories/v1/home.json?api-key=091882e61861f420060b35097b4419a2:1:72021160';
    $data = from_json(get($url));
#    $cache->set( "nyt" => $data, {expires_in => "1 day"} );
#}

my (@subjects, @geographies, @organizations, @persons);

foreach my $r (@{$data->{results}})
{
    push(@subjects, @{$r->{des_facet}}) if $r->{des_facet};
    push(@geographies, map {processLocationName($_)} @{$r->{geo_facet}}) if $r->{geo_facet};
    push(@organizations, @{$r->{org_facet}}) if $r->{org_facet};
    push(@persons, map {processPersonName($_)} @{$r->{per_facet}}) if $r->{per_facet};
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

sub processPersonName
{
    my $name = shift;
    if($name =~ m{^(?<last>.+?), (?<first_middle>.+?)$})
    {
        $name = join(' ', $+{first_middle}, $+{last});
    }
    return $name;
}

sub processLocationName
{
    my $name = shift;
    if($name =~ m{^(?<place>.+?) \(.+\)$}) # Staten Island (NYC)
    {
        $name = $+{place};
    }
    return $name;
}

