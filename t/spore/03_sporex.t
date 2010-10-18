use strict;
use warnings;

use Test::More;
use Net::HTTP::Spore;

plan tests => 4;

my $content_api = {foo => 1};
open my $fh, '<', File::Spec->catfile('t','specs','content.tgz');
my $content_tgz = <$fh>;
close $fh;

my $mock_server = {
    '/bin' => sub {
        my $req = shift;
        is $req->header('Content-Type'), 'application/zip';
        $req->new_response([200, ['Content-Type', 'text/plain'], 'ok']);
    },
    '/api' => sub {
        my $req = shift;
        is_deeply JSON::decode_json($req->body), $content_api;
        is $req->header('Content-Type'), 'application/json;';
        $req->new_response([200, ['Content-Type', 'text/plain'], 'ok']);
    },
};

my $api_desc = {
    name => 'test',
    methods => {
        post_bin => {
            method => 'POST',
            path => '/bin',
        },
        post_json => {
            method => 'POST',
            path => '/api',
        }
    },
};

ok my $client = Net::HTTP::Spore->new_from_string(JSON::encode_json($api_desc), base_url=>'http://localhost');

$client->enable_if(sub{$_[0]->path =~ m!^/api!}, 'Format::JSON');
$client->enable('ContentType');

$client->enable('Mock', tests => $mock_server);

$client->post_bin(payload => $content_tgz, sporex => {'content_type' => 'application/zip'});
$client->post_json(payload => $content_api);

