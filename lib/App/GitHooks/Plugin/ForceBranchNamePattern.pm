package App::GitHooks::Plugin::ForceBranchNamePattern;

use strict;
use warnings;

use base 'App::GitHooks::Plugin';

# External dependencies.
use Log::Any qw($log);

# Internal dependencies.
use App::GitHooks::Constants qw( :PLUGIN_RETURN_CODES );

# Uncomment to see debug information.
#use Log::Any::Adapter ('Stderr');


=head1 NAME

App::GitHooks::Plugin::ForceBranchNamePattern - Require branch names to match a given pattern before they can be pushed to the origin.


=head1 DESCRIPTION

For example, if you define in your .githooksrc file the following:

	[ForceBranchNamePattern]
	branch_name_pattern = /^[a-zA-Z0-9]+$/

Then a branch named C<TestBranch> can be pushed to the origin, but not one
named C<test_branch>.

A practical use of this plugin is making Puppet environment out of git
branches, since Puppet environment names must be strictly alphanumeric.


=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';


=head1 MINIMUM GIT VERSION

This plugin relies on the pre-push hook, which is only available as of git
v1.8.2.


=head1 CONFIGURATION OPTIONS

This plugin supports the following options in the
C<[ForceBranchNamePattern]> section of your C<.githooksrc> file.

	[ForceBranchNamePattern]
	branch_name_pattern = /^[a-zA-Z0-9]+$/


=head2 branch_name_pattern

A regular expression that will be used to check branch names before allowing
you to push them to the origin.

	# Require alphanumeric branches only.
	branch_name_pattern = /^[a-zA-Z0-9]+$/

	# Require branches to start with a JIRA ticket ID followed by an underscore.
	branch_name_pattern = /^DEV-\d+_/

	# Require branches to start with a JIRA ticket ID followed by an underscore,
	# but they can have an optional user prefix.
	branch_name_pattern = /^(?:[^\/]\/)DEV-\d+_/


=head1 METHODS

=head2 run_pre_push()

Code to execute as part of the pre-push hook.

  my $plugin_return_code = App::GitHooks::Plugin::ForceBranchNamePattern->run_pre_push(
		app   => $app,
		stdin => $stdin,
	);

Arguments:

=over 4

=item * $app I<(mandatory)>

An C<App::GitHooks> object.

=item * $stdin I<(mandatory)>

The content provided by git on stdin, corresponding to a list of references
being pushed.

=back

=cut

sub run_pre_push
{
	my ( $class, %args ) = @_;
	my $app = delete( $args{'app'} );
	my $stdin = delete( $args{'stdin'} );

	$log->info( 'Entering ForceBranchNamePattern.' );
}


=head1 FUNCTIONS


=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/guillaumeaubert/App-GitHooks-Plugin-ForceBranchNamePattern/issues/new>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc App::GitHooks::Plugin::ForceBranchNamePattern


You can also look for information at:

=over

=item * GitHub's request tracker

L<https://github.com/guillaumeaubert/App-GitHooks-Plugin-RequireTicketID/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/app-githooks-plugin-forcebranchnamepattern>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/app-githooks-plugin-forcebranchnamepattern>

=item * MetaCPAN

L<https://metacpan.org/release/App-GitHooks-Plugin-RequireTicketID>

=back


=head1 AUTHOR

L<Guillaume Aubert|https://metacpan.org/author/AUBERTG>,
C<< <aubertg at cpan.org> >>.


=head1 COPYRIGHT & LICENSE

Copyright 2015 Guillaume Aubert.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/

=cut

1;
