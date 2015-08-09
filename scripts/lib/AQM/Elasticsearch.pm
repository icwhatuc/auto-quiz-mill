package AQM::Elasticsearch;

use strict;
use warnings;

use Data::Dumper;

use JSON;
use AQM::Config;
use Search::Elasticsearch;

use constant AUTOLOAD_METHOD_MAP => {
    basic_client_methods => [ qw( index search delete ) ],
};

use constant METHOD_TYPE_HANDLERS => {
    basic_client_methods => sub {
        my ($self, $method, %args) = @_;
        return $self->es->$method(
            index => $self->conf_index,
            %args
        );
    },
};

our $METHOD_MAP = _prep_method_map();

sub _prep_method_map
{
    my $glob_map = AUTOLOAD_METHOD_MAP();
    my %map = ();
    foreach my $k (keys %$glob_map)
    {
        my $methods = $glob_map->{$k};
        foreach my $m (@$methods)
        {
            $map{$m} = $k;
        }
    }
    return \%map;
}

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

sub conf_index
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

sub DESTROY {}

our $AUTOLOAD;
sub AUTOLOAD
{
    my ($self, %args) = @_;
    my $called = $AUTOLOAD =~ s/.*:://r;;
    my $method_type = $METHOD_MAP->{$called} or
        die "ERROR: unexpected method call - $called";
    my $handler = METHOD_TYPE_HANDLERS()->{$method_type};
    return $handler->($self, $called, %args);
}

return 1;

