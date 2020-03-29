#!/usr/bin/perl -w

use strict;
use warnings;
use HTML::TreeBuilder 5 -weak;
use Data::Dumper;
use URI::Escape;

die "Usage: $0 iplayer_search.pl [SEARCH] [FILE]\n" if @ARGV < 2;

open FILE, ">", "$ARGV[1]" or die $!;

my $bbc_url = 'http://www.bbc.co.uk';
my $iplayer_search_url = $bbc_url.'/iplayer/search?q=';
my $search_string_encoded = uri_escape($ARGV[0]);
my $search_url = $iplayer_search_url.$search_string_encoded;
my $next_page = '';

{ do {
	my $tree = HTML::TreeBuilder->new_from_url($search_url);
	$tree->elementify();
	my $results = $tree->look_down(_tag => 'li', class => 'list-item episode');
	if(!defined $results || $results eq '') {
		last;
	}
	my @episodes = $tree->look_down(_tag => 'li');
	foreach (@episodes) {
		if($_->attr('data-ip-id') =~ /([a-zA-Z0-9_]+)/) {
			print FILE "$1\n";
		}
	}
	my $next_page_elem = $tree->look_down(_tag => 'a', title => qr/\"Next \"/);
	if(!defined $next_page_elem) {
		last;
	}
	$next_page = $next_page_elem->attr('href');
	$next_page =~ s/^\s+|\s+$//g;
	$search_url = $bbc_url.$next_page;
} while(defined $next_page && $next_page ne ''); }

close FILE;

exit 0;
