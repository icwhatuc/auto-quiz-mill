#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

use FindBin qw($Bin);
use lib "$Bin/../lib";

use AQM::Elasticsearch qw(saveEntity);
use AQM::Elasticsearch qw(deleteEntity);
use Data::Dumper;

my $entity = {
    name => "q666",
    difficulty => 666,
    question_text => "What is the word for someone who is afraid of 13?",
    junk => "THIS IS JUNK"
};

say Dumper (saveEntity("test", 5, $entity));

say Dumper (deleteEntity("test", 6));
