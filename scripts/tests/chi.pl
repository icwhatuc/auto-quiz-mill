#!/usr/bin/perl

use strict;
use warnings;

use CHI;
use feature qw(say);
use FindBin qw($Bin);
use Data::Dumper;

my $cache = CHI->new(
    driver => 'File',
	root_dir => "$Bin/../tmp"
);

my $complex_obj = {
    key1 => [
        "hello",
        "hi"
    ],
    key2 => "Hello, World!"
};

## store something in filesystem cache
# $cache->set( mihir_key => $complex_obj );

my $mihir_val = $cache->get( "mihir_key");
say Dumper $mihir_val;

my $other_val = $cache->get( "bad_key" );
say $other_val;

