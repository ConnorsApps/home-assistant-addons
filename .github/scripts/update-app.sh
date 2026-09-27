#!/usr/bin/env bash
# Bump an app to its upstream's newest release: SOURCE_VERSION in the
# Dockerfile, version in config.yaml, and a CHANGELOG entry. Prints the commit
# message, or nothing when the app is current or the image isn't published yet.
set -euo pipefail

app=${1:?usage: update-app.sh <app>}
dockerfile=${app}/Dockerfile
config=${app}/config.yaml
changelog=${app}/CHANGELOG.md
semver='[0-9]\+\.[0-9]\+\.[0-9]\+'

# Parsed as publish.yml does.
read_version() { sed -n 's/^version: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "${config}" | head -1; }
read_source() { sed -n 's/^ARG SOURCE_VERSION=//p' "${dockerfile}" | head -1; }

url=$(sed -n 's/^url: *//p' "${config}" | head -1)
current=$(read_source)
version=$(read_version)
if ! grep -qx "${semver}" <<< "${current}" || ! grep -qx "${semver}" <<< "${version}"; then
    echo "${app}: want X.Y.Z for SOURCE_VERSION and version, got '${current}' and '${version}'" >&2
    exit 1
fi
if [ "$(head -2 "${changelog}")" != "# Changelog" ]; then
    echo "${app}: ${changelog} must start with '# Changelog' and a blank line" >&2
    exit 1
fi

# "<version> <tag>" per release tag (vX.Y.Z or X.Y.Z), oldest first. Other
# tags, such as chart releases, don't match.
releases=$(git ls-remote --tags --refs "${url}" |
    sed -n "s|.*refs/tags/\(v\{0,1\}\)\(${semver}\)\$|\2 \1\2|p" | sort -V)
if [ -z "${releases}" ]; then
    echo "${app}: no release tags at ${url}" >&2
    exit 1
fi
read -r latest tag <<< "$(tail -1 <<< "${releases}")"
[ "$(printf '%s\n' "${latest}" "${current}" | sort -V | tail -1)" != "${current}" ] || exit 0

image=$(sed -n "s/^FROM \(.*\)\${SOURCE_VERSION}\(.*\) AS source\$/\1${latest}\2/p" "${dockerfile}")
if [ -z "${image}" ]; then
    echo "${app}: ${dockerfile} has no 'FROM <image>:\${SOURCE_VERSION} AS source'" >&2
    exit 1
fi
# The tag lands before its image is built; a later run picks it up.
if ! docker buildx imagetools inspect "${image}" > /dev/null 2>&1; then
    echo "::warning::${app}: ${tag} is tagged but ${image} isn't published yet; skipping." >&2
    exit 0
fi

# Match upstream when possible, but never reuse or go below a published version.
IFS=. read -r major minor patch <<< "${version}"
next=$(printf '%s\n' "${latest}" "${major}.${minor}.$((patch + 1))" | sort -V | tail -1)

sed -i "s/^ARG SOURCE_VERSION=.*/ARG SOURCE_VERSION=${latest}/" "${dockerfile}"
sed -i "s/^version: .*/version: \"${next}\"/" "${config}"
if [ "$(read_source)" != "${latest}" ] || [ "$(read_version)" != "${next}" ]; then
    echo "${app}: could not rewrite SOURCE_VERSION or version" >&2
    exit 1
fi

old_tag=$(awk -v v="${current}" '$1 == v { print $2; exit }' <<< "${releases}")
if [ -n "${old_tag}" ]; then
    link="${url}/compare/${old_tag}...${tag}"
else
    link="${url}/releases/tag/${tag}"
fi
{
    head -2 "${changelog}"
    printf '## %s\n\n- %s %s ([changes](%s)).\n\n' "${next}" "${url##*/}" "${latest}" "${link}"
    tail -n +3 "${changelog}"
} > "${changelog}.new"
mv "${changelog}.new" "${changelog}"

echo "Update ${app} to ${latest}"
