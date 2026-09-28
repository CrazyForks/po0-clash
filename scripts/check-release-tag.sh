#!/usr/bin/env bash
# Fail unless a release tag equals v<pubspec version without +build>, the
# version the app compares against when it checks for updates.
set -euo pipefail
cd "$(dirname "$0")/.."

tag="${1:?usage: check-release-tag.sh <tag>}"
version="$(sed -n 's/^version: *\([^+[:space:]]*\).*/\1/p' pubspec.yaml)"

if [ -z "$version" ]; then
  echo "cannot read the version from pubspec.yaml" >&2
  exit 1
fi
expected="v${version}"
if [ "$tag" != "$expected" ]; then
  echo "tag $tag does not match $expected; bump the pubspec version or retag" >&2
  exit 1
fi
echo "tag $tag matches the app version"
