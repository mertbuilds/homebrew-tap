# vinenastudio tap

Homebrew casks for the Mac apps of [Vinena Studio](https://vinena.studio).

## Install

```sh
brew install --cask vinenastudio/tap/agent-caffeine
```

Or add the tap once, then install by name:

```sh
brew tap vinenastudio/tap
brew install --cask agent-caffeine
```

This tap moved from `mertbuilds/tap` on 2026-10-25. If you ran `brew tap mertbuilds/tap`, it keeps working through GitHub's redirect.

## Casks

| Cask | App | Needs |
| --- | --- | --- |
| `agent-caffeine` | [Agent Caffeine](https://caffeinagent.com) keeps your Mac awake while AI coding agents work. Paid, with a 7 day trial. | macOS 13 or later |
| `attention-awareness` | [attention awareness](https://attentionawareness.com) supervises your iPhone so that blocked apps and websites stay blocked. Discontinued on 2026-10-27: it still installs and updates itself, and [Wax](https://waxmac.com/?utm_source=github&utm_medium=referral&utm_campaign=homebrew-tap) replaces it. | macOS 14 or later, Apple Silicon |

The apps are signed and notarized, and they update themselves. To let
Homebrew update them too, run `brew upgrade --greedy`.

## Uninstall

```sh
brew uninstall --cask agent-caffeine
brew uninstall --zap --cask agent-caffeine
```

The first command removes the app. The second one also moves its settings
and data to the Trash.

Agent Caffeine can write hooks and skills into the folders of your agents
(for example `~/.claude`). Homebrew does not touch those folders. Remove the
hooks and skills in the settings of Agent Caffeine before you uninstall it.

## For maintainers

`scripts/bump-cask.sh <token> <version> <dmg path or url> [--push]` sets a
cask to a new release. It writes the version and the sha256, runs
`brew style` and `brew audit`, and commits. It pushes only with `--push`.

```sh
scripts/bump-cask.sh agent-caffeine 1.0.1,15 https://caffeinagent.com/mac/agent-caffeine-1.0.1-15.dmg
```
