const { Octokit } = require('@octokit/rest');
const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN,
});
const [ owner, repo ] = process.env.GITHUB_REPOSITORY.split('/');
const [ , , pr ] = process.argv;

const matched_releases = [];
const matched_tags = [];
const VERSION_RE = new RegExp(`^.+\.${pr}-.+$`);
const TRUE_RE = /^\s*true\s*$/i;

const removeReleases = TRUE_RE.test(process.env.INPUT_SKIP_RELEASE_REMOVE);

Promise
  .all([
    octokit.paginate('GET /repos/:owner/:repo/releases', { owner, repo }),
    octokit.paginate('GET /repos/:owner/:repo/tags', { owner, repo }),
  ])
  .then(([ releases, tags ]) => {
    releases.forEach(release => {
      const { id, tag_name } = release;
      const idx = tag_name.search(VERSION_RE);

      if (idx !== -1) {
        matched_releases.push(id);
      }
    });

    tags.forEach(tag => {
      const idx = tag.name.search(VERSION_RE);

      if (idx !== -1) {
        matched_tags.push(tag.name);
      }
    });

    if (!removeReleases) {
      return matched_tags;
    }

    return Promise
      .all(
        matched_releases.map(release_id => octokit.repos.deleteRelease({ owner, repo, release_id }))
      )
      .then(() => matched_tags);
  })
  .then(ret => console.log(JSON.stringify(ret)), console.log);
