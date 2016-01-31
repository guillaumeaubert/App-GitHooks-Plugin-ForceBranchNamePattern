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
	branch_name_pattern = /^(?:[^\/]+\/)?DEV-\d+_/


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

	my $config = $app->get_config();
	my $repository = $app->get_repository();

	# Check if we have a branch name pattern specified in the config. If not,
	# skip this plugin.
	my $branch_name_pattern = $config->get_regex( 'ForceBranchNamePattern', 'branch_name_pattern' );
	if ( !defined( $branch_name_pattern ) )
	{
		$log->infof("No 'branch_name_pattern' specified in the [ForceBranchNamePattern] section of the config, skipping plugin.");
		return $PLUGIN_RETURN_SKIPPED;
	}

	# Check if we are pushing any branches.
	my @branch_names = get_pushed_branch_names( $app, $stdin );
	$log->infof(
		"Found %s branch(es) to push: %s",
		scalar( @branch_names ),
		join( ', ', @branch_names ),
	);
	return $PLUGIN_RETURN_SKIPPED
		if ( scalar( @branch_names ) == 0 );

	# Check if the branch names match the pattern.
	my @incorrect_branch_names = ();
	foreach my $branch_name ( @branch_names )
	{
		if ( $branch_name =~ $branch_name_pattern )
		{
			$log->infof( 'Branch %s matches the required pattern.', $branch_name );
		}
		else
		{
			$log->infof( 'Branch %s does not match the required pattern.', $branch_name );
			push( @incorrect_branch_names, $branch_name );
		}
	}

	if ( scalar( @incorrect_branch_names ) != 0 )
	{
		my $error = sprintf(
			"The following %s %s not match the pattern enforced by the git hooks configuration file: %s.\n" .
			"Branches must match the following pattern: %s.",
			scalar( @incorrect_branch_names ) == 1 ? 'branch' : 'branches',
			scalar( @incorrect_branch_names ) == 1 ? 'does' : 'do',
			join( ', ', @incorrect_branch_names ),
			"/$branch_name_pattern/",
		);
		$log->errorf( 'Reporting error back to the hook handler! %s', $error );
		die "$error\n";
	}

	return $PLUGIN_RETURN_PASSED;
}


=head1 FUNCTIONS

=head2 get_pushed_branch_names()

Retrieve a list of the branches being pushed with C<git push>.

	my $tags = App::GitHooks::Plugin::ForceBranchNamePattern::get_pushed_branch_names(
		$app,
		$stdin,
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

sub get_pushed_branch_names
{
	my ( $app, $stdin ) = @_;
	my $config = $app->get_config();

	# Analyze each reference being pushed.
	my $branches = {};
	foreach my $line ( @$stdin )
	{
		chomp( $line );
		$log->debugf( 'Parse STDIN line >%s<.', $line );

		# Extract the branch information.
		my ( $branch ) = ( $line =~ /^refs\/heads\/(\S+)\b/x );
		next if !defined( $branch );
		$log->infof( "Found branch '%s'.", $branch );
		$branches->{ $branch } = 1;
	}

	return keys %$branches;
}


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

L<https://github.com/guillaumeaubert/App-GitHooks-Plugin-ForceBranchNamePattern/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/app-githooks-plugin-forcebranchnamepattern>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/app-githooks-plugin-forcebranchnamepattern>

=item * MetaCPAN

L<https://metacpan.org/release/App-GitHooks-Plugin-ForceBranchNamePattern>

=back


=head1 AUTHOR

L<Guillaume Aubert|https://metacpan.org/author/AUBERTG>,
C<< <aubertg at cpan.org> >>.


=head1 COPYRIGHT & LICENSE

Copyright 2015-2016 Guillaume Aubert.

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
