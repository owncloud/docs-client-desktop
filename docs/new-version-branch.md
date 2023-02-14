# Create a New Version Branch for Desktop

When doing a new release for the Desktop Client like `3.x`, a new version branch must be created based on `master`. It is necessary to do this in four steps. Please set the new and former version numbers accordingly

**Step 1: Create and configure the new `3.x` branch**

1.  Create a new `3.x` branch based on latest `origin/master`
2.  Copy the `.drone.star` file from the _former_ `3.x-1` branch
    (it contains the correct branch specific setup rules and replaces the current one coming from master)
3.  In `.drone.star` set `latest_version` to `3.x` (on top in section `def main(ctx)`)
4.  In `site.yml` adjust all `-version` keys according the new and former releases
    (in section `asciidoc.attributes`)
5.  In `antora.yml` change the version from `next` to `3.x`
6.  Run a build by entering `yarn antora-local`. No errors should occur
7.  Commit the changes and push the new `3.x` branch. **DO NOT CREATE A PR!** (check if the push succeeded, check branch protection rules)

**Step 2: Configure the master branch to use the new `3.x` branch**

9.  Create a new `changes_necessary_for_3.x` branch based on latest `origin/master`
10. In `.drone.star` set `latest_version` to `3.x` (on top in section `def main(ctx)`)
11. In `site.yml` in section `asciidoc.attributes`, adjust all `-version` keys related to this repo according the new and former releases. Note if those attributes exist in other content sources, they must be set to the identical value to create consistent test builds.
12. No changes in `antora.yml` but check if the version is set to `next`
13. Run a build by entering `yarn antora-local`. No errors should occur
14. Commit changes and push it
15. Create a Pull Request. When CI is green, all is done correctly. Merge the PR to master.

**Step 3: Set the correct Desktop build branches in the docs repo**

16. In `site.yml` of [docs](https://github.com/owncloud/docs/blob/master/site.yml) adjust the last **two** branches at `url: https://github.com/owncloud/docs-client-desktop.git` accordingly
    (in section `content.sources.url.branches`)
17. In `site.yml` of [docs](https://github.com/owncloud/docs/blob/master/site.yml) adjust all `-version` keys in section `attributes` related to this repo according the new and former releases.

**Step 4: Protection and Renaming**

18. Go to the settings of this repository and change the protection of the branch list (Settings > Branches) so that
    the `3.x` branch gets protected and the `3.x-2` branch is no longer protected.
19. Rename the `3.x-2` branch to `x_archived_3.x-2`

**Text Suggestion for Step 2**

The following text is a copy/paste suggestion for the PR in step 2, replace the branch numbers accordingly:
```
These are the changes necessary to finalize the creation of the 3.x branch.

The 3.x branch is already pushed and prepared and is included in the branch protection rules.

When 3.x (Desktop) is finally out, the 3.x-2 branch can be archived, see step 4 in https://github.com/owncloud/docs-client-desktop/blob/master/docs/new-version-branch.md

Note, that the 3.x branch in this repo is already created, but the `latest` pointer on the web will be set to it automatically when the tag in Desktop is set. This means, that in the docs homepage, `latest` will point to 3.x-1 until the tag in Desktop is set accordingly. When merging this PR, 3.x-2 will be dropped from the web but is available via pdf as usual.

Note, this PR must be merged before the 3.x tag in Desktop is set to avoid a 404 for `latest`.

Note that a PR in docs must be made to announce the 3.x branch. The docs PR must be merged AFTER this PR is merged to avoid a CI error in docs.

Before merging this PR, we should take care that 3.x-2 has all changes necessary merged as post
merging the 3.x-2 pdf is fixed.

@michaelstingl @HanaGemela fyi

@mmattel @EParzefall @phil-davis
Post merging this, we need to backport all relevant changes to 3.x
```
