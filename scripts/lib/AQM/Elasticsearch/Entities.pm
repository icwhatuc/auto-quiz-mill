package AQM::Elasticsearch::Entities;

use strict;
use warnings;

use JSON;
use AQM::Config;
use AQM::Elasticsearch;

use constant ELASTIC_ENTITY_TYPE => 'entities';

use Exporter qw(import);
our @EXPORT_OK = qw(saveEntity deleteEntity getEntitiesOfType);

sub saveEntity
{
    my ($id, $entity) = @_;
    my $es = AQM::Elasticsearch->new();
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};
    
    $es->index(
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
        type => ELASTIC_ENTITY_TYPE,
        id => $id
    );
}

sub getEntitiesOfType
{
    my ($type) = @_;
    my $es = AQM::Elasticsearch->new();
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};
    my $results = $es->search(
        body => {
            query => {
                term => { "instance of" => $type }
            },
            _source => [ 'name' ],
            sort => [
                { "incoming_links_count" => { order => "desc" } },
                # { "views_last_month" => { order => "desc" } },
            ],
            size => 999_999,
        }
    );
    return $results;
}

return 1;


