package AQM::Elasticsearch;

use strict;
use warnings;

use JSON;
use AQM::Config;
use Search::Elasticsearch;

use constant ELASTIC_ENTITY_TYPE => 'entities';

use Exporter qw(import);
our @EXPORT_OK = qw(saveEntity deleteEntity);

# get es handle
our $es;
sub _getesh
{
    return $es if $es;
    my $nodes = $AQM::Config::core{ELASTICSEARCH}{nodes};
    $es = Search::Elasticsearch->new(
        nodes => $nodes,  
    );
    return $es;
}

sub updateIndexSettings
{
    my ($settings) = @_;
    my $es = _getesh();
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};

    $es->indices->close(index => $index);
    $es->indices->put_settings(
        index => $index,
        body => $settings
    );
    $es->indices->open(index => $index);
}

sub updateMapping
{
    my ($name, $mapping) = @_;
    my $es = _getesh();
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};

    $es->indices->put_mapping(
        index => $index,
        type => $name,
        body => $mapping
    );
}

sub saveEntity
{
    my ($id, $entity) = @_;
    my $es = _getesh();
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};
    
    $es->index(
        index => $index,
        type => ELASTIC_ENTITY_TYPE,
        id => $id,
        body => $entity
    );
}

sub deleteEntity
{
    my ($id) = @_;
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};
    $es->delete(
        index => $index,
        type => ELASTIC_ENTITY_TYPE,
        id => $id
    );
}

return 1;

