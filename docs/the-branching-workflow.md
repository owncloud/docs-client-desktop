# The Branching Workflow

Only three branches are maintained at any one time; these are `master` and two for the current Client Desktop release. Any change to the documentation is made in a branch based off of `master`. Once the branch's PR is approved and merged, the PR is backported to the branch for the **current** Desktop release and the **former** release but only if it applies to it.

When a new ownCloud major or minor Desktop version is released, a new branch is created to track the changes for that release. The branch for the oldest release freezes, take off the active maintained branch list is no longer maintained.
