package AQM::Elasticsearch;

use strict;
use warnings;

use Search::Elasticsearch;

use constant ELASTIC_INDEX => 'auto-quiz-mill';
use constant ELASTIC_ENTITY_TYPE => 'entities';

use Exporter qw(import);
our @EXPORT_OK = qw(saveEntity deleteEntity);

# get es handle
our $es;
sub _getesh
{
    return $es if $es;
    $es = Search::Elasticsearch->new(
        nodes => ['https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io'],  
    );
    return $es;
}

sub saveEntity
{
    my ($id, $entity) = @_;
    my $es = _getesh();
    $es->index(
        index => ELASTIC_INDEX,
        type => ELASTIC_ENTITY_TYPE,
        id => $id,
        body => $entity
    );
}

sub deleteEntity
{
    my ($id) = @_;
    $es->delete(
        index => ELASTIC_INDEX,
        type => ELASTIC_ENTITY_TYPE,
        id => $id
    );
}

return 1;

