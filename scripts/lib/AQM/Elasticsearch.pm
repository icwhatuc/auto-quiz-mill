package AQM::Elasticsearch;

use strict;
use warnings;

use JSON;
use AQM::Config;
use Search::Elasticsearch;

# get es handle
sub new
{
    my $class = shift;
    my $nodes = $AQM::Config::core{ELASTICSEARCH}{nodes};
    my $index = $AQM::Config::core{ELASTICSEARCH}{index};
    my $es = Search::Elasticsearch->new(
        nodes => $nodes,  
    );
    my $self = { _es => $es, _index => $index };
    bless($self, $class);
    return $self;
}

sub es
{
    my ($self, $h) = @_;
    return ($self->{_es} = $h ? $h : $self->{_es});
}

sub index
{
    my ($self, $idx) = @_;
    return ($self->{_index} = $idx ? $idx : $self->{_index});
}

sub updateIndexSettings
{
    my ($self, $settings) = @_;
    my $es = $self->es;
    my $index = $self->index;

    $es->indices->close(index => $index);
    $es->indices->put_settings(
        index => $index,
        body => $settings
    );
    $es->indices->open(index => $index);
}

sub updateMapping
{
    my ($self, $name, $mapping) = @_;
    my $es = $self->es;
    my $index = $self->index;

    $es->indices->put_mapping(
        index => $index,
        type => $name,
        body => $mapping
    );
}

sub AUTOLOAD
{
    ### TODO: define
}

return 1;

