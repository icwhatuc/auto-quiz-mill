package Wikidata::Entity;

use strict;
use warnings;

use Data::Dumper;
use Wikidata::API qw(getEntityNameByID);

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
    
    if(
        (my $propsref = $opts->{props_ref}->{properties}) 
        && (my $entity_processor = $opts->{entity_processor})
    ){
        foreach my $prop (keys %{$rawdata->{claims}})
        {
            my $prop_value = [];
            my $prop_name = $propsref->{$prop};
            my $prop_details = $rawdata->{claims}->{$prop};
            # $prop_details = [ $prop_details ] if(ref $prop_details ne 'ARRAY');
            
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
                        $value = &$entity_processor("Q" . $value->{value}->{"numeric-id"});
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
                if($qdetails)
                {
                    $qualifiers = {};

                    foreach my $qprop (keys %$qdetails)
                    {
                        my $qpropname = $propsref->{$qprop};
                        my $qpropvalues = $qdetails->{$qprop};
                        my @qvals = ();

                        foreach my $qpval (@$qpropvalues)
                        {
                            my $qproptype = $qpval->{datatype};
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

sub get
{
    my ($self, $prop) = @_;
    return $self->{$prop};
}

sub hashref
{
    my $self = shift;
    my %data = %$self;
    delete $data{rawdata};
    return \%data;
}

return 1;

