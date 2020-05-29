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

if [[ -z "$PR_NUMBER" ]]
then
  echo "cannot get PR number from $GITHUB_EVENT_PATH"

  exit 1
else
  KEEP_GIT_TAGS=${INPUT_KEEP_GIT_TAGS:-}
  MATCHES=$(node "$DIR"/index.js)

  if [[ -z "$KEEP_GIT_TAGS" ]]
  then
    echo "Deleting git tags..."

    for TAG_NAME in $(echo "${MATCHES}" | jq -r '.[]'); do
      echo "DELETING GIT TAG: $TAG_NAME"

      git push origin ":$TAG_NAME"
    done
  else
    echo "Keeping git tags"
  fi
fi
