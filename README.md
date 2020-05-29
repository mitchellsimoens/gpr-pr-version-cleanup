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

If you only want to delete the releases and keep the git tags, you can give the action an input:

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
