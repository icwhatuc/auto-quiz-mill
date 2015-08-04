package Wikidata::Entity;

use strict;
use warnings;

use Data::Dumper;
use Wikidata::API qw(getEntityNameByID);

use constant IGNORE_QUALIFIERS_FOR_PROP => {
    map { $_ => 1 } (
        "instance of",
    )
};

sub new
{
    my ($class, $entity_data, $opts) = @_;
    
    my $self = _preprocess($entity_data, $opts);
    $self->{rawdata} = $entity_data;
    
    bless $self, $class;
    
    return $self;
}

sub _preprocess
{
    my ($rawdata, $opts) = @_;
    my %data = ();
    
    $data{id} = $rawdata->{id};
    $data{name} = $rawdata->{labels}->{en}->{value};
    $data{description} = $rawdata->{descriptions}->{en}->{value};
    
    $data{views_last_month} = $rawdata->{views_last_month};
    $data{incoming_links} = $rawdata->{incoming_links};
    $data{incoming_links_count} = $rawdata->{incoming_links_count};
    $data{img_url} = $rawdata->{img_url};
    
    # url
    my $url_identifier = $data{name};
    $url_identifier =~ s{ }{_}g;
    $data{entity_url} = sprintf("https://en.wikipedia.org/wiki/%s", $url_identifier);

    if(
        (my $propsref = $opts->{props_ref}->{properties}) 
        && (my $entity_processor = $opts->{entity_processor})
    ){
        my @entity_props_list = ();
        foreach my $prop (keys %{$rawdata->{claims}})
        {
            my $prop_value = [];
            my $prop_name = $propsref->{$prop};
            my $prop_details = $rawdata->{claims}->{$prop};
            # $prop_details = [ $prop_details ] if(ref $prop_details ne 'ARRAY');
           
            next if !$prop_name; # TODO: Do something about getting a more updated props list?

            push(@entity_props_list, "$prop:$prop_name");

            foreach my $detail (@$prop_details)
            {
                my $qualifiers;
                my $value = $detail->{mainsnak}->{datavalue};
                my $valuetype = $detail->{mainsnak}->{datatype};
                my $qdetails = $detail->{qualifiers};

                if($valuetype && $valuetype eq 'wikibase-item')
                {
                    if($value->{type} eq 'wikibase-entityid')
                    {
                        $value = &$entity_processor(
                            "Q" . $value->{value}->{"numeric-id"}, 
                            { additional_data => 1 }
                        );
                    }
                    else 
                    {
                        warn 'WARNING: Unexpected wikibase-item datavalue - ' . Dumper $value;
                    }
                }
                elsif($valuetype && $valuetype eq 'time')
                {
                    $value = $value->{value}->{time};
                }
                else
                {
                    $value = $value->{value};
                }

                ## handle qualifier
                if($qdetails && !IGNORE_QUALIFIERS_FOR_PROP()->{$prop_name})
                {
                    $qualifiers = {};

                    foreach my $qprop (keys %$qdetails)
                    {
                        my $qpropname = $propsref->{$qprop};
                        my $qpropvalues = $qdetails->{$qprop};
                        my @qvals = ();

                        foreach my $qpval (@$qpropvalues)
                        {
                            my $qproptype = $qpval->{datatype} or next;
                            if($qproptype eq 'time')
                            {
                                push(@qvals, $qpval->{datavalue}->{value}->{time});
                            }
                            elsif($qproptype eq 'string')
                            {
                                push(@qvals, $qpval->{datavalue}->{value});
                            }
                            elsif($qproptype eq 'globe-coordinate')
                            {
                                push(@qvals, {
                                    latitude => $qpval->{datavalue}->{value}->{latitude},
                                    longitude => $qpval->{datavalue}->{value}->{longitude}
                                });
                            }
                            else
                            {
                                # warn "ERROR: unexpected qualifier prop value of type = $qproptype";
                            }
                        }
                        
                        $qualifiers->{$qpropname} = scalar @qvals == 1 ? $qvals[0] : \@qvals;
                    }
                }

                push(@$prop_value, $qualifiers ? { $value => $qualifiers } : $value);
            }

            if(scalar @$prop_value)
            {
                $prop_value = scalar @$prop_value == 1 ? $prop_value->[0] : $prop_value;
                # $data{$prop} = $prop_value;
                $data{$prop_name} = $prop_value;
            }
        }

        $data{props_list} = \@entity_props_list;
    }

    return \%data;
}

sub id
{
    my $self = shift;
    return $self->{id};
}

sub name
{
    my $self = shift;
    return $self->{name};
}

sub description
{
    my $self = shift;
    return $self->{description};
}

sub img
{
    my $self = shift;
    return $self->{img};
}

sub get
{
    my ($self, $prop) = @_;
    return $self->{$prop};
}

sub viewsLastMonth
{
    my $self = shift;
    return $self->{views_last_month};
}

sub hashref
{
    my $self = shift;
    my %data = %$self;
    delete $data{rawdata};
    return \%data;
}

return 1;

