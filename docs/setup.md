# Setup

## Requirements

- macOS, with Home Assistant reachable from it over HTTPS.
- The camera agent also needs the Xcode Command Line Tools.

## Configuration

`make config` copies [`config.example`](../config.example) to
`~/.config/ha-macos-agents/config`. Set `HA_URL`, plus the keys for the agents
you install, listed in each agent's doc. Set `HA_AGENTS_CONFIG` to use another
path.

The config holds no secrets. The token lives in the login Keychain, under the
service named by `HA_KEYCHAIN_SERVICE` (default `ha-macos-agents`), and is read
on every run.

## Token

Create a long-lived access token in Home Assistant under Profile → Security,
ideally for a dedicated non-admin user. Then run `make token` and paste it.

Use `make token` rather than `security add-generic-password -w`. The
interactive `security` prompt silently cuts input at 128 characters, shorter
than a Home Assistant token. Passing the token as an argument leaves it in
your shell history, and a trailing newline makes `security` return it
hex-encoded.

## Choosing agents

`AGENTS` lists `name:seconds` pairs and works with `install`, `uninstall` and
`status`. Leave it out to act on every agent.

```bash
make install AGENTS=activity:60
make install AGENTS="activity:120 camera:5"
make uninstall AGENTS=camera:5
```

`make install` writes one plist per agent to `~/Library/LaunchAgents`,
pointing at this checkout. After moving the checkout, run `make install` again.

## Logs and status

`make status` shows each agent's last exit code and recent errors. Logs are in
`~/Library/Logs/ha-macos-agents/<agent>.log`. A `503` right after Home
Assistant restarts is expected and clears on the next run.

## Uninstall

```bash
make uninstall
security delete-generic-password -a "$USER" -s ha-macos-agents
rm -rf ~/.config/ha-macos-agents ~/Library/Caches/ha-macos-agents ~/Library/Logs/ha-macos-agents
```
