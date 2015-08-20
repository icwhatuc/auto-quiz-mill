#!/usr/bin/perl

use strict;
use warnings;

use feature qw(say);
use CHI;
use Data::Dumper;
use FindBin qw($Bin);
use Getopt::Std;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Wikidata::API qw(getTopEntity);
use AQM::Elasticsearch::Entities qw(saveEntity);

our($opt_g, $opt_h, $opt_n, $opt_t);

my $cache = CHI->new(
    driver => 'File',
    root_dir => "$Bin/../tmp/"
);

die q{
    Usage: store_entities.pl -[ghnt]
        -h this help
        -g google search trends
        -n new york times top article topics
        -t twitter trends
} if(!getopts('ghnt') || $opt_h || (!$opt_g && !$opt_n && !$opt_t));

## call each script get a list
my @topics = ();
my @entities = ();

if($opt_n)
{
    my $nytimes_topics;
    if (defined $cache->get( "nyt")) {
        $nytimes_topics = $cache->get("nyt");    
    }
    else {
        $nytimes_topics = `$Bin/extract_ny_times_trending_entities.pl`;
        $cache->set("nyt" => $nytimes_topics, {expires_in => "1 day"});
    }
    push(@topics, split("\n", $nytimes_topics));
}

if($opt_g)
{
    my $googletrends_topics;
    if (defined $cache->get("googletrends")) {
        $googletrends_topics = $cache->get("googletrends");
    }
    else {
        $googletrends_topics = `$Bin/googleTrendKeyWords.py`;
        $cache->set("googletrends" => $googletrends_topics, {expires_in => "30 days"});
    }
    push(@topics, split("\n", $googletrends_topics));
}

if($opt_t)
{
    my $twittertrends_topics;
    if (defined $cache->get("twittertrends")) {
        $twittertrends_topics = $cache->get("twittertrends");
    }
    else {
        $twittertrends_topics = `$Bin/twitterTrends.py`;
        $cache->set("twittertrends" => $twittertrends_topics, {expires_in => "4 hours"});
    }
    push(@topics, split("\n", $twittertrends_topics));
}

@topics = sort @topics; # unnecessary - just convenience

## search each for a corresponding wikidata entity
foreach my $topic (@topics)
{
    my $query = _preprocess($topic);
    my $entity = getTopEntity($query);

    if($entity)
    {
        my $entity_id = $entity->id;
        my $entity_name = $entity->name;
        my $entity_rep = $entity->hashref;
        saveEntity($entity_id, $entity_rep);

        say "SAVED $entity_id => $entity_name (inspired by '$topic')"
    }
    else
    {
        warn "$topic NOT FOUND";
    }
}

## store in elasticsearch

sub _preprocess
{
    my $topic = shift;
    if($topic =~ m{#([A-Z][a-z]+)+})
    {
        $topic =~ s{#}{};
        $topic =~ s{([A-Z][a-z]+|\d+)}{$1 }g;
    }
    return $topic;
}

