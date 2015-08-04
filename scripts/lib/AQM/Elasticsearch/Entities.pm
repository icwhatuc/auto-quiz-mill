package AQM::Elasticsearch::Entities;

use strict;
use warnings;

use JSON;
use AQM::Config;
use AQM::Elasticsearch;

use constant ELASTIC_ENTITY_TYPE => 'entities';

use Exporter qw(import);
our @EXPORT_OK = qw(saveEntity deleteEntity);

sub saveEntity
{
    my ($id, $entity) = @_;
    my $es = AQM::Elasticsearch->new();
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
    my $es = AQM::Elasticsearch->new();
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};
    $es->delete(
        index => $index,
        type => ELASTIC_ENTITY_TYPE,
        id => $id
    );
}

return 1;


