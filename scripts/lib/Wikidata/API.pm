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
use LWP::Simple;
use POSIX qw(strftime);

use lib "..";
use Wikidata::Entity;

use Exporter qw(import);

use constant IMG_SIZE => 300;

our @EXPORT_OK = qw(
    getTopEntity
    getTopEntityID
    getTopEntityName
    getEntities
    getEntityByID
    getEntityNameByID
);

our $mw = {};
our $props;

my $cache = CHI->new(
    driver => 'File',
    root_dir => "$Bin/../../tmp/"
);

sub _getmwh
{
    my $url = shift || "https://www.wikidata.org/w/api.php";

    return $mw->{$url} if($mw->{$url});
    $mw->{$url} = MediaWiki::API->new({ 
        api_url => $url,
        use_http_get => 1,
        on_error => \&_error_handler
    });
    return $mw->{$url};
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

# TODO: should attempt to cache these results
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
    my $topResultId = getTopEntityID($query);
    my $entity = $topResultId ? getEntityByID($topResultId, $opts) : undef;
    return $entity;
}

sub getEntityByID
{
    my ($id, $opts) = @_;

    my ($entity_raw, $entity_name);
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
        $entity_name = $entity_raw->{labels}->{en}->{value};

        if(!$opts->{additional_data})
        {
            ## image
            $entity_raw->{img} = getImage($entity_name);

            ## get popularity
            $entity_raw->{views_last_month} = getViewsLastMonth($entity_name);
            $entity_raw->{incoming_links} = getIncomingLinks($entity_name);
            $entity_raw->{incoming_links_count} = scalar @{$entity_raw->{incoming_links}} if $entity_raw->{incoming_links};
        }

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
    my ($id, $opts) = @_;
    $opts = $opts || {};
    my $entity = getEntityByID($id, {rawdata => 1, %$opts});
    return $entity->{labels}->{en}->{value};
}

sub _getDefaultParams
{
    return {
        utf8 => 1,
        formatversion => 2,
    };
}

sub getViewsLastMonth
{
    my $entity_name = shift;
    my $views;
    my @time = localtime(time);
    my ($year, $month) = ($time[5], $time[4]);
    $year += 1900;
    $month = $month > 0 ? $month: 12; # last month (0 indexed)
    my $url_date_portion = sprintf("%d%02d", $year, $month);
    my $url = sprintf("http://stats.grok.se/json/en/%s/%s", $url_date_portion, $entity_name);
    my $json = get($url);

    if(defined $json)
    {
        my $views_data = decode_json($json);
        $views += $_ foreach (values %{$views_data->{daily_views}});
    }
    
    return $views;
}

sub getIncomingLinks
{
    my $entity_name = shift;
    my @incoming_links = ();
    
    my $mwh = _getmwh("https://en.wikipedia.org/w/api.php");
    my %params = (
        action => 'query',
        list => 'backlinks',
        bltitle => $entity_name,
        blfilterredir => 'nonredirects',
        blnamespace => 0,
        bllimit => 500,
        continue => ''
    );
    my ($continue, $blcontinue) = (1, undef);
    while($continue)
    {
        my $curr_params = {
            %params
        };
        $curr_params->{blcontinue} = $blcontinue if $blcontinue;

        
        my $mwresp = $mwh->api($curr_params);
        
        push(@incoming_links, { id => ("Q" . $_->{pageid}), name => $_->{title} })
            foreach (@{$mwresp->{query}->{backlinks}});
        
        if($mwresp->{continue})
        {
            $blcontinue = $mwresp->{continue}->{blcontinue};
        }
        else
        {
            $continue = 0;
        }
    }
    
    return \@incoming_links;
}

sub getImage
{
    my ($entity_name, $size, $prevent_recursion) = @_;
    
    my $mwh = _getmwh("https://en.wikipedia.org/w/api.php");
    $size ||= IMG_SIZE;
    my %params = (
        action => 'query',
        titles => $entity_name,
        prop => 'pageimages',
        pithumbsize => $size,
    );

    my $mwresp = $mwh->api(\%params);
    
    my $pages = $mwresp->{query}->{pages};
    my $pageid = (keys %$pages)[0];
    my $thumbnail = $pages->{$pageid}->{thumbnail} or return undef;
    
    if($thumbnail->{width} < IMG_SIZE && !$prevent_recursion)
    {
        $size = int($thumbnail->{height} / $thumbnail->{width} * $size + 0.99);
        return getImage($entity_name, $size, 1);
    }

    return $thumbnail->{source};
}

1;

