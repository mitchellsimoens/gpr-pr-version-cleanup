#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PR_NUMBER=$(cat "$GITHUB_EVENT_PATH" | jq '.number')

function yesOrNo() {
  local input=${1:-}

  [ -z "$input" ] && echo "Yes" || echo "No"
}

if [[ -z "$PR_NUMBER" ]]
then
  echo "cannot get PR number from $GITHUB_EVENT_PATH"

  exit 1
else
  KEEP_GIT_TAGS=${INPUT_KEEP_GIT_TAGS:-}
  SKIP_NPM_UNPUBLISH=${INPUT_SKIP_NPM_UNPUBLISH:-}
  MATCHES=$(node "$DIR"/index.js)

  echo "Delete git tags: $(yesOrNo "$KEEP_GIT_TAGS")"
  echo "Will npm unpublish: $(yesOrNo "$SKIP_NPM_UNPUBLISH")"

  echo

  for TAG_NAME in $(echo "${MATCHES}" | jq -r '.[]'); do
    if [[ -z "$KEEP_GIT_TAGS" ]]
    then
      echo "DELETING GIT TAG: $TAG_NAME"

      git push origin ":$TAG_NAME"
    fi

    if [[ -z "$SKIP_NPM_UNPUBLISH" ]]
    then
      echo "UNPUBLISHING NPM VERSION: $TAG_NAME"

      npm unpublish "$TAG_NAME"
    fi
  done
fi
