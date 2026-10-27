#!/usr/bin/env bash
# Set a cask to a new release: version, sha256, style, audit, commit.
#
#   scripts/bump-cask.sh <token> <version> <dmg path or url> [--push]
#
#   token    agent-caffeine or attention-awareness
#   version  1.0.1,15 or 1.0.1-15 (version and build). 1.0.1 alone works when
#            the dmg is named <token>-1.0.1-15.dmg: the build comes from there.
#   dmg      the released dmg, as a file or as its url. It is only hashed.
#   --push   push the commit to origin. Without it nothing leaves this Mac.
#
# The audit downloads the dmg from the url in the cask, so run this after the
# release is uploaded. A failed style check or audit puts the cask back.

set -euo pipefail

cd "$(dirname "$0")/.."
TAP_DIR=$(pwd -P)

PUSH=0
ARGS=()
for arg in "$@"
do
  case "${arg}" in
    --push) PUSH=1 ;;
    -*)
      echo "unknown option: ${arg}" >&2
      exit 2
      ;;
    *) ARGS+=("${arg}") ;;
  esac
done
if [[ "${#ARGS[@]}" -ne 3 ]]
then
  echo "usage: scripts/bump-cask.sh <token> <version> <dmg path or url> [--push]" >&2
  exit 2
fi
TOKEN="${ARGS[0]}"
VERSION_ARG="${ARGS[1]}"
DMG="${ARGS[2]}"

CASK="Casks/${TOKEN}.rb"
if [[ ! -f "${CASK}" ]]
then
  echo "error: no cask ${CASK}" >&2
  exit 1
fi
CASK_CHANGES=$(git status --porcelain -- "${CASK}")
if [[ -n "${CASK_CHANGES}" ]]
then
  echo "error: ${CASK} has changes that are not committed." >&2
  exit 1
fi

case "${VERSION_ARG}" in
  *,*)
    VERSION="${VERSION_ARG%%,*}"
    BUILD="${VERSION_ARG#*,}"
    ;;
  *-*)
    VERSION="${VERSION_ARG%%-*}"
    BUILD="${VERSION_ARG#*-}"
    ;;
  *)
    VERSION="${VERSION_ARG}"
    NAME=$(basename "${DMG%%\?*}")
    BUILD=$(printf '%s' "${NAME}" | sed -nE "s/^${TOKEN}-${VERSION}-([0-9]+)\.dmg$/\1/p")
    ;;
esac
if ! printf '%s' "${VERSION}" | grep -qE '^[0-9]+(\.[0-9]+){1,2}$'
then
  echo "error: '${VERSION}' is not a version like 1.2.3" >&2
  exit 1
fi
if ! printf '%s' "${BUILD}" | grep -qE '^[0-9]+$'
then
  echo "error: no build number. give the version as ${VERSION},<build>." >&2
  exit 1
fi
CASK_VERSION="${VERSION},${BUILD}"

WORK=$(mktemp -d)
LINK=""
TRUSTED=""
DONE=0
cleanup() {
  rm -rf "${WORK}"
  if [[ -n "${TRUSTED}" ]]; then brew untrust --cask "${TRUSTED}" >/dev/null || true; fi
  if [[ -n "${LINK}" ]] && [[ -L "${LINK}" ]]; then rm -f "${LINK}"; fi
  if [[ "${DONE}" = 0 ]]; then git checkout -q -- "${CASK}" 2>/dev/null || true; fi
}
trap cleanup EXIT

case "${DMG}" in
  http://* | https://*)
    echo "==> download ${DMG}"
    curl -fsSL -o "${WORK}/release.dmg" "${DMG}"
    DMG_FILE="${WORK}/release.dmg"
    ;;
  *)
    DMG_FILE="${DMG}"
    if [[ ! -f "${DMG_FILE}" ]]
    then
      echo "error: no file ${DMG_FILE}" >&2
      exit 1
    fi
    ;;
esac
SHA=$(/usr/bin/shasum -a 256 "${DMG_FILE}" | cut -d' ' -f1)

echo "==> ${TOKEN} ${CASK_VERSION}, sha256 ${SHA}"
sed -i '' -E \
  -e "s/^  version \"[^\"]*\"$/  version \"${CASK_VERSION}\"/" \
  -e "s/^  sha256 \"[0-9a-f]{64}\"$/  sha256 \"${SHA}\"/" \
  "${CASK}"
if ! grep -qF "  version \"${CASK_VERSION}\"" "${CASK}" || ! grep -qF "  sha256 \"${SHA}\"" "${CASK}"
then
  echo "error: could not set version and sha256 in ${CASK}" >&2
  exit 1
fi

# From 1.0.2 the app bundle is named Agent Caffeine.app and holds the command
# line tool agent-caffeine. 1.0.0 and 1.0.1 are agent caffeine.app without the
# tool, so the first bump that reaches 1.0.2 renames the app stanza and adds
# the binary stanza.
if [[ "${TOKEN}" = "agent-caffeine" ]] && grep -q '^  app "agent caffeine\.app"$' "${CASK}"
then
  OLDEST=$(printf '%s\n%s\n' "1.0.2" "${VERSION}" | sort -V | head -1)
  if [[ "${OLDEST}" = "1.0.2" ]]
  then
    echo "==> rename the app stanza and add the binary stanza"
    sed -i '' -E 's|^  app "agent caffeine\.app"$|  app "Agent Caffeine.app"\
  binary "#{appdir}/Agent Caffeine.app/Contents/MacOS/agent-caffeine"|' "${CASK}"
    if ! grep -qF '  app "Agent Caffeine.app"' "${CASK}" ||
       ! grep -qF '  binary "#{appdir}/Agent Caffeine.app/Contents/MacOS/agent-caffeine"' "${CASK}"
    then
      echo "error: could not set the app and binary stanzas in ${CASK}" >&2
      exit 1
    fi
  fi
fi

if git diff --quiet -- "${CASK}"
then
  DONE=1
  echo "${CASK} is already at ${CASK_VERSION}. nothing to commit."
  exit 0
fi

# brew checks a cask only inside a tap. This folder is linked as a tap with a
# second name for the checks, so they run on these files and not on the clone
# that `brew tap vinenastudio/tap` made. The link goes away when the script ends.
export HOMEBREW_NO_AUTO_UPDATE=1
CHECK_TAP="vinenastudio/tap-bump-check"
LINK="$(brew --repository)/Library/Taps/vinenastudio/homebrew-tap-bump-check"
if [[ -e "${LINK}" ]] || [[ -L "${LINK}" ]]
then
  if [[ ! -L "${LINK}" ]]
  then
    echo "error: ${LINK} is in the way and is not a link." >&2
    LINK=""
    exit 1
  fi
  rm -f "${LINK}"
fi
mkdir -p "$(dirname "${LINK}")"
ln -s "${TAP_DIR}" "${LINK}"

echo "==> brew style"
brew style "${CHECK_TAP}"
echo "==> brew audit"
# Homebrew 7 loads casks from a non-official tap only when they are trusted.
# Trust the check cask for the audit and untrust it after, because trust.json
# stays on the runner. A cask that was trusted before stays trusted.
if ! brew trust --json=v1 | grep -qF "\"${CHECK_TAP}/${TOKEN}\""
then
  brew trust --cask "${CHECK_TAP}/${TOKEN}" >/dev/null
  TRUSTED="${CHECK_TAP}/${TOKEN}"
fi
brew audit --cask --strict --online "${CHECK_TAP}/${TOKEN}"

if [[ -n "${TRUSTED}" ]]
then
  brew untrust --cask "${TRUSTED}" >/dev/null
  TRUSTED=""
fi
rm -f "${LINK}"
LINK=""

git add -- "${CASK}"
git commit -q -m "${TOKEN} ${VERSION}" -- "${CASK}"
DONE=1
COMMIT=$(git log -1 --format='%h %s')
echo "==> committed: ${COMMIT}"

if [[ "${PUSH}" = 1 ]]
then
  echo "==> push"
  git push origin HEAD
else
  echo "    not pushed. run with --push, or: git -C \"${TAP_DIR}\" push origin main"
fi
