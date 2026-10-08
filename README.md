# mertbuilds tap

Homebrew casks for the Mac apps of [mertbuilds](https://mertbuilds.com).

## Install

```sh
brew install --cask mertbuilds/tap/agent-caffeine
brew install --cask mertbuilds/tap/attention-awareness
```

Or add the tap once, then install by name:

```sh
brew tap mertbuilds/tap
brew install --cask agent-caffeine
```

## Casks

| Cask | App | Needs |
| --- | --- | --- |
| `agent-caffeine` | [Agent Caffeine](https://caffeinagent.com) keeps your Mac awake while AI coding agents work. Paid, with a 7 day trial. | macOS 13 or later |
| `attention-awareness` | [attention awareness](https://attentionawareness.com) supervises your iPhone so that blocked apps and websites stay blocked. Free and open source. | macOS 14 or later, Apple Silicon |

Both apps are signed and notarized, and both update themselves. To let
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
