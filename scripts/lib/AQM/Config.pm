package AQM::Config;

use strict;
use warnings;

use Data::Dumper;
use Sys::Hostname;
use Cwd;

our %core = (
    ELASTICSEARCH => {
        nodes => [
            'https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io'
        ],
        index => 'auto-quiz-mill'
    }
);

our %overrides = (
    '/home/mihir/auto-quiz-mill' => {
        ELASTICSEARCH => {
            nodes => [
                'https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io'
            ],
            index => 'auto-quiz-mill'
        }
    }
);

load();

sub load
{
    my $cwd = getcwd;
    my ($envdir) = ($cwd =~ m{^(/[^/]+/[^/]+/[^/]+)});
    my $envhost = hostname;
    my $envkey = $envhost eq 'localhost' ? $envdir : "$envhost:$envdir";
    my $override = $overrides{$envkey} or return;
    $core{$_} = $override->{$_} foreach (keys %$override);
}

1;

