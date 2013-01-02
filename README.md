# Git JIRA Extension

If you follow the philosophy of "one git branch per JIRA issue" (we'll call them "JIRA branches"), then this git extension will make your life much easier. This extension can:

- Make all commits in those JIRA branches include the JIRA reference ID;
- Automatically synchronize JIRA status with creation or merge of a JIRA branch

To make this work, you'll need:

- JIRA API access
- A JIRA CLI JAR
- This script

## Setting up JIRA to allow API access

You need to be able to administer JIRA and allow it to [accept remote API calls](http://confluence.atlassian.com/display/JIRA/Configuring+JIRA+Options).

You can create a special user with very limited permissions (e.g., `cli-api` or `cli-api-user` if you want one API user per user), in a new group called `api-users`, if you want, or just give API permissions to your regular users. Note that this requires a full "OnDemand" account.

If following the advice above, edit the “Permission Scheme” of the project to which you want to allow access and grant the following permissions to the `api-users` group:

- Browse Projects: required for everything
- Assign Issues: required for starting and merging branches
- Resolve Issue: required for starting and merging branches

## Getting the JIRA CLI JAR

[Download it](https://bobswift.atlassian.net/wiki/download/attachments/16285777/jira-cli-3.1.0-distribution.zip?api=v2) or just run this extension for the first time to download it and install into `~/bin/jira-cli`. (You can configure its location during configuration below.)

## Installing the extension

Make sure that the `git-jira` script is in your path, then you can simply execute the plugin with:

    git jira <command>

Placing it in `~/bin` and adding that to your path is probably a good choice.

## Configuring the extension

Upon first execution via `git jira`, if no suitable configuration variables are found in your global git configuration, then the script will prompt you for location to your hosted JIRA installation, your username, password, and a bevy of other options. **This is all configured per project/git repository.**

Additionally, the extension will install a custom `prepare-commit-msg` hook in your `.git/hooks` directory.

### Options

JIRA CLI JAR location
: Specify the location to your JIRA CLI JAR script. This is, of course, necessary for interfacing with JIRA.

JIRA installation URL
: Specify the full URL to your JIRA installation.

JIRA username
: Specify your username for accessing JIRA. *Note that this must be an "OnDemand" username, not one authenticated via a third-party service like Google.*

JIRA password
: Specify your JIRA password.

JIRA issue prefix
: Specify the issue prefix for the repository in which you are working. This allows you to omit the prefix when issuing commands, e.g. `git jira start 71` instead of `git jira start ABC-71`.

Repository URL
: Specify the URL prefix to use for reference individual commits. The hash of individual commits will be appended to this URL and linked in the JIRA issue when promoting the issue.
:For example, on Beanstalk, this might be of the form `https://company.beanstalkapp.com/repository-a/changesets/`.
:On GitHub this might look like `https://github.com/user/repository-a/commit/`.

Target merge branch
: Specify the branch you'd like to merge your issue branches back into when you promote a ticket. This is typically `master` unless you do the majority of your development on a separate development branch.

## Usage

After configuration, there are really only two commands you need to know, `git jira start <issue-id>` and `git jira promote`. Assume that the JIRA issue prefix is set to `ABC`.

### Creating an issue branch using `git jira start`

    git jira start 71

This executes the following:

1. Creates a new git branch called `ABC-71`.
2. Checks out this new branch.
3. Advances the workflow for the JIRA issue named `ABC-71` to "In Progress".

### Committing on your issue branch

When you execute a `git commit`, the message will look similar to below:

    #ABC-71 -
    #
    # This branch is associated with the following JIRA issue:
    #   [ABC-71] Fix Bug Associated With Recursion
    # View this issue at https://company.jira.com/browse/ABC-71
    ...

*Note that while it is slightly inconvenient to start the JIRA line with a comment, it is necessary because it allows you to cancel the commit by exiting without saving. If we had started the commit file with a non-commented line, git would still commit the file if you left the commit message unedited since it would contain an non-commented line. This is not what users expect, so you must manually uncomment the JIRA line on every commit if you want to keep it in the commit message.*

### Promoting the issue and merging back when finished

When you're finished with the changes to your ticket and want to merge them back to your target merge branch and update the JIRA ticket, while on the issue branch:

    git jira promote
    
or if not on the issue branch:

    git jira promote ABC-71
    
This executes the following:

1. Opens your editor to provide any additional comments that apply to the issue as a whole (versus an individual commit), such as testing instructions.
2. Rebases the branch based on your target merge branch.
3. Switches to your target merge branch.
4. Merges the issue branch (e.g., `ABC-71`) into your target merge branch.
5. Promotes the issue in JIRA via the "Promote" workflow step.
6. Adds a comment to the JIRA issue with a list of your commits and your additional message.
7. Optionally deletes your issue branch from your local repository.

## Addenda

### Customizing the commit message

You can override the start line of the commit messages with the `jira.commit.template` git configuration option:

    git config jira.commit.template '%i: %t'

where

- `%i` represents the issue key
- `%t` represents the issue title

The default template is simple:

    %i -

### What happens if... ?

If the hook fails to connect to JIRA or the issue does not exist, you will get a comment in the commit file warning you about it.

If the branch name does not match the JIRA key grammar, the hook  will not even try to look it up in JIRA, saving time for master commits.

If the JIRA issue can be resolved from JIRA, it will be cached in `.git/jira.cache` so that future commits on the branch are faster.

## Roadmap

- Automatically prepending the issue key to your commit message without it appearing in the editor (allowing use of the `-m` command-line option when committing)
- Streamlining some other areas of the `prepare-commit-msg` hook
