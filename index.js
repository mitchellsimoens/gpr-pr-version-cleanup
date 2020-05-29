const { Octokit } = require('@octokit/rest');
const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN,
});
const [ owner, repo ] = process.env.GITHUB_REPOSITORY.split('/');

const matched_releases = [];
const matched_tags = [];
const VERSION_RE = /^.+\.(\d+)-.+$/;

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

    return Promise
      .all(
        matched_releases.map(release_id => octokit.repos.deleteRelease({ owner, repo, release_id }))
      )
      .then(() => matched_tags);
  })
  .then(ret => console.log(JSON.stringify(ret)), console.log);
