package Wikidata::API;

# docs available here: https://github.com/icwhatuc/auto-quiz-mill/wiki/Wikidata

use strict;
use warnings;

use CHI;
use FindBin qw($Bin);
use Data::Dumper;
use MediaWiki::API;  # cpan module
use File::Slurp qw(read_file);
use File::Basename;
use JSON;

use lib "..";
use Wikidata::Entity;

use Exporter qw(import);

our @EXPORT_OK = qw(
    getTopEntity
    getTopEntityID
    getTopEntityName
    getEntities
    getEntityByID
    getEntityNameByID
);
our $mw;
our $props;

my $cache = CHI->new(
    driver => 'File',
    root_dir => "$Bin/../../tmp/"
);

sub _getmwh
{
    return $mw if($mw);
    $mw = MediaWiki::API->new({ 
        api_url => "https://www.wikidata.org/w/api.php",
        use_http_get => 1,
        on_error => \&_error_handler
    });
    return $mw;
}

sub _error_handler
{
    my $err_code = $mw->{error}->{code};
    my $err_string = $err_code == 3 ? "API ERROR" : "";
    die "ERROR: MediaWiki::API encountered an error " . Dumper {
        error_code => $mw->{error}->{code},
        error_desc => $err_string,
        ua_resp_code    => $mw->{response}->code,
        ua_resp_msg     => $mw->{response}->message,
        us_resp_content => $mw->{response}->decoded_content
    };
}

# TODO: _getprops can be better... don't load in a file
# just reproduce the work of wikidata-properties-dumper here!
sub _getprops
{
    return $props if ($props);
    my $props_file = dirname(__FILE__) . "/properties-en.json";
    $props = from_json(read_file($props_file));
    return $props;
}

sub getTopEntityBasics
{
    my ($query) = @_;
    my $mwh = _getmwh();
    my $default_params = _getDefaultParams();
    my %params = (
        %$default_params,
        action => 'wbsearchentities',
        search => $query,
        limit => 1,
        language => 'en',
        continue => 0
    );
    my $mwresp = $mwh->api(\%params);
    return $mwresp->{search}->[0];
}

sub getTopEntityID
{
    my ($query) = @_;
    my $result = getTopEntityBasics($query);
    return $result->{id};
}

sub getTopEntityName
{
    my ($query) = @_;
    my $result = getTopEntityBasics($query);
    return $result->{name};
}

sub getTopEntityDescription
{
    my ($query) = @_;
    my $result = getTopEntityBasics($query);
    return $result->{description};
}

sub getTopEntity
{
    my ($query, $opts) = @_;
    my $mwh = _getmwh();
    my $topResultId = getTopEntityID($query);
    my $entity = $topResultId ? getEntityByID($topResultId, $opts) : undef;
    return $entity;
}

sub getEntities
{
}

sub getEntityByID
{
    my ($id, $opts) = @_;

    my $entity_raw;
    # reference mapping ids to property names
    my $props = !$opts->{rawdata} ? _getprops() : undef;
    
    if(defined $cache->get( $id )) {
        $entity_raw = $cache->get( $id );
    }
    else {
        my $mwh = _getmwh();
        my $default_params = _getDefaultParams();
        my %params = (
            %$default_params,
            action => 'wbgetentities',
            ids => $id,
            languages => 'en'
        );
        
        my $mwresp = $mwh->api(\%params);
        $entity_raw = $mwresp->{entities}->{$id};
        $cache->set( $id => $entity_raw, {expires_in => "1 week"} );
    }
    
    return $opts->{rawdata} ? 
        $entity_raw : 
        Wikidata::Entity->new($entity_raw, 
            {props_ref => $props, entity_processor => \&getEntityNameByID}
        )
    ;
}

sub getEntityNameByID
{
    my ($id) = @_;
    my $entity = getEntityByID($id, {rawdata => 1});
    return $entity->{labels}->{en}->{value};
}

sub _getDefaultParams
{
    return {
        utf8 => 1,
        formatversion => 2,
    };
}

return 1;

