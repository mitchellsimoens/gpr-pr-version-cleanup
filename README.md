# GitHub PR Version Cleanup

Cleanup alpha releases and git tags created during the lifecycle of a pull request. This should be used in conjunction
with the [mitchellsimoens/gpr-pr-version-bump](https://github.com/mitchellsimoens/gpr-pr-version-bump) action. This
workflow is expected to run when a pull request is merged (any means like squashing) or closed.

## Usage

An example workflow would be:

```yaml
name: PR Version Cleanup

on:
  pull_request:
    types: [closed]

jobs:
  test:
    name: Cleanup PR Versions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Delete Releases
        uses: mitchellsimoens/gpr-pr-version-cleanup@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

The follow are the inputs this action accepts:

| Name                | Required | Description                          |
|---------------------|----------|--------------------------------------|
| keep_git_tags       | No       | Set to skip deleting git tags        |
| skip_npm_unpublish  | No       | Set to skip running npm publish      |
| skip_release_remove | No       | Set to skip removing GitHub releases |

### `keep_git_tags`

If git tags that were created for the pull request should be kept, set this to `true`:

```yaml
name: PR Version Cleanup

on:
  pull_request:
    types: [closed]

jobs:
  test:
    name: Cleanup PR Versions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Delete Releases
        uses: mitchellsimoens/gpr-pr-version-cleanup@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          keep_git_tags: true
```

Be warned though, depending on your project the number of git tags could grow quite a lot.

### `skip_npm_unpublish`

If the versions that were published to the npm registry (doesn't have to be the npmjs.com registry, could be GitHub's),
set this to `true`:

```yaml
name: PR Version Cleanup

on:
  pull_request:
    types: [closed]

jobs:
  test:
    name: Cleanup PR Versions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Delete Releases
        uses: mitchellsimoens/gpr-pr-version-cleanup@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          skip_npm_unpublish: true
```

There are limitations to when you can run the `npm unpublish`.

- For the npmjs.com registry, `npm unpublish` can only be run within 72 hours of when the version was published.
- For GitHub Package Registry, `npm unpublish` cannot be run for public repositories; only private repositories can
unpublish. This is a GitHub imposed "limitation".

### `skip_release_remove`

If you wish to keep the GitHub releases, set this to `true`:

```yaml
name: PR Version Cleanup

on:
  pull_request:
    types: [closed]

jobs:
  test:
    name: Cleanup PR Versions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Delete Releases
        uses: mitchellsimoens/gpr-pr-version-cleanup@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          skip_release_remove: true
```
