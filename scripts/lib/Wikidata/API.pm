package Wikidata::API;

use strict;
use warnings;

use Data::Dumper;
use MediaWiki::API;  # cpan module

# docs available here: https://github.com/icwhatuc/auto-quiz-mill/wiki/Wikidata

use Exporter qw(import);

our @EXPORT_OK = qw(
    getTopEntity
    getTopEntityName
    getEntities
    getEntityByID
    getEntityNameByID
    
    _getClosestMatchID
);
our $mw;

sub _getmwh
{
    return $mw if($mw);

    $mw = MediaWiki::API->new({ 
        api_url => "https://www.wikidata.org/w/api.php",
        use_http_get => 1
    });
    # $mw->login({
    #     lgname => 'auto-quiz-mill',
    #     lgpassword => 'cooper2013'
    # }) || die "ERROR: Could not login to access wikidata";
    
    return $mw;
}

sub getTopEntity
{
    my ($query, $opts) = @_;
    my $mwh = _getmwh();
    my $topResultId = _getClosestMatchID($query, $opts);
    my $entity = getEntityByID($topResultId, $opts);
}

sub getTopEntityName
{
}

sub getEntities
{
}

sub getEntityByID
{
}

sub getEntityNameByID
{
}

sub _getDefaultParams
{
    return {
        utf8 => 1,
        formatversion => 2,
        continue => '',
        language => 'en'
    };
}

sub _getClosestMatchID
{
    my ($query, $opts) = @_;
    my $mwh = _getmwh();
    my $default_params = _getDefaultParams();
    my %params = (
        %$default_params,
        ($opts ? %$opts : ()),
        action => 'wbsearchentities',
        search => $query,
        limit => 1
    );
    my $mwresp = $mwh->api(\%params);
    return $mwresp->{search}->[0]->{id};
}

return 1;

