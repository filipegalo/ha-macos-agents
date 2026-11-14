# AGENTS.md

Rules for coding agents in this repository. `CLAUDE.md` is a symlink to this
file; edit this one.

## Public repository

Everything committed here is public. Keep the repository generic: write
`homeassistant.example.com`, `input_boolean.mac_camera_in_use` and `$HOME`
in code, docs and examples. Real URLs, entity IDs, usernames, addresses and
tokens belong only in the user's `~/.config/ha-macos-agents/config` and login
Keychain, which live outside the repository.

## Agent design

- Report raw facts (a timestamp, on/off) and leave thresholds to Home
  Assistant automations.
- Fail **stale**: a sleeping Mac, a network error or a stopped agent leaves the
  last value to age. A failure must never hold a state that keeps something
  switched on.
- Read the token with `ha_token` from `lib/ha.sh` on every run; keep it out of
  files, arguments that land in logs, and plists.

To add an agent, follow `docs/development.md`.

## Documentation is part of the change

Each agent has one page, `docs/<name>.md`, and one README table row. When you
change an agent's behaviour, configuration keys or helper type, update its
page in the same change. Setup, token, logs and uninstall live in
`docs/setup.md`; keep the README to the overview and quick start.

## Before you finish

Run `make check`. CI runs it on a macOS runner, builds the camera helper and
must pass before a pull request can merge.

## Commits and pull requests

- `main` is protected: work on a branch and open a pull request. CI must pass.
- Commits are signed with the maintainer's SSH key, configured in this
  checkout's `.git/config`. Commit with the configured identity; leave
  `user.*`, `gpg.*` and `commit.gpgsign` untouched.

## Releases

Releases are cut by the maintainer, by pushing a signed tag:

```bash
git tag -s vX.Y.Z -m vX.Y.Z && git push origin vX.Y.Z
```

`.github/workflows/release.yml` then publishes the GitHub release with notes
generated from merged pull requests. Use semantic versioning: a new agent or
configuration key is a minor bump, a fix is a patch. Tag only when the
maintainer asks.
