package Kwiki::BreadCrumbs;
use strict;
use warnings;
use Kwiki::Plugin '-Base', '-XXX';
use mixin 'Kwiki::Installer';
our $VERSION = '0.10';

const class_id => 'bread_crumbs';
const class_title => 'Bread Crumbs';

field trail => [];

sub init {
    return unless $self->is_in_cgi;
    super;
    my $bread_crumbs = $self->hub->cookie->jar->{bread_crumbs} || [];
    if ($self->hub->action eq 'display') {
        my $page_id = $self->pages->current->id;
        @$bread_crumbs = grep { $_ ne $page_id } @$bread_crumbs;
        unshift @$bread_crumbs, $page_id;
    }
    splice @$bread_crumbs, 10;
    $self->trail($bread_crumbs);
    $self->hub->cookie->jar->{bread_crumbs} = $bread_crumbs;
}

sub register {
    my $registry = shift;
    $registry->add(status => 'bread_crumbs',
                   template => 'bread_crumbs.html',
                   show_if_preference => 'show_bread_crumbs',
                  );
    $registry->add(preference => $self->show_bread_crumbs);
}

sub show_bread_crumbs {
    my $p = $self->new_preference('show_bread_crumbs');
    $p->query('Show How Many Bread Crumbs?');
    $p->type('pulldown');
    my $choices = [
        0 => 0,
        4 => 4,
        6 => 6,
        8 => 8,
        10 => 10,
    ];
    $p->choices($choices);
    $p->default(0);
    return $p;
}

sub html {
    my @trail = @{$self->trail};
    splice @trail, $self->preferences->show_bread_crumbs->value;
    my $script_name = $self->config->script_name;
    "<hr />" . join ' &lt; ',
    map {
        qq{<a href="$script_name?$_">$_</a>\n}
    } @trail;
}

1;

__DATA__

=head1 NAME 

Kwiki::BreadCrumbs - Kwiki Bread Crumbs Plugin

=head1 SYNOPSIS

Show a trail of the last 5 pages viewed.

=head1 DESCRIPTION

=head1 AUTHOR

Brian Ingerson <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
__template/tt2/bread_crumbs.html__
<style>
div#bread_crumb_trail {
    font-size: small;
}
</style>
<div id="bread_crumb_trail">
[% hub.load_class('bread_crumbs').html %]
</div>
