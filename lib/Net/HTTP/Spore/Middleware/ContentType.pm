package Net::HTTP::Spore::Middleware::ContentType;

use strict;
use warnings;

use base qw/Net::HTTP::Spore::Middleware/;

sub call {
    my ($self, $request) = @_;

    if ($request->env->{'sporex.content_type'}) {
        $request->header('Content-Type') = $request->env->{'sporex.content_type'};
    }
}

1;
