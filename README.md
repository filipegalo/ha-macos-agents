# ha-macos-agents

Small launchd agents that report what a Mac is doing to
[Home Assistant](https://www.home-assistant.io/) through its REST API.

They are plain shell scripts plus one tiny native helper, for machines where
installing the Home Assistant Companion app is not an option.

| Agent | Runs every | Writes | Use it for |
| --- | --- | --- | --- |
| `ha-activity` | 60 s | Time of the last keyboard or mouse input to an `input_datetime` | Keep something on while you are at the computer, and turn it off a while after you stop |
| `ha-camera` | 5 s | Whether any camera is in use to an `input_boolean` | An "on a call" light, muting speakers, do-not-disturb |

## How it behaves

- **Failure means stale, not stuck.** A Mac that sleeps, leaves the network or
  stops the agent just stops reporting. Write automations so an old
  `ha-activity` timestamp means "not in use".
- **No secrets on disk.** The token is read from the login Keychain on every
  run. The config file holds only the URL and entity IDs.
- **Camera detection never opens the camera.** `camera-in-use` asks CoreMediaIO
  whether any camera device is running in any process. It needs no camera
  permission and no Node.js. `ha-camera` only calls Home Assistant when the
  state changes, plus a periodic resync.

## Requirements

- macOS with the Xcode Command Line Tools (`xcode-select --install`) for
  `swiftc`.
- Home Assistant reachable from the Mac over HTTPS.

## Setup

1. **Create the helpers in Home Assistant.** In Settings → Devices & services →
   Helpers, or in YAML:

   ```yaml
   input_datetime:
     mac_last_input:
       name: Mac Last Input
       has_date: true
       has_time: true

   input_boolean:
     mac_camera_in_use:
       name: Mac Camera In Use
   ```

2. **Create a token.** Go to Profile → Security → Long-lived access tokens.
   Consider creating it for a dedicated non-admin user.

3. **Configure, store the token, install:**

   ```bash
   make config        # creates ~/.config/ha-macos-agents/config; edit it
   make token         # prompts for the token and stores it in the Keychain
   make install       # compiles the camera helper and starts both agents
   make status
   ```

   To install only some agents, set `AGENTS`: `make install AGENTS=activity:60`.
   The installed plists point at this checkout, so keep it where it is or run
   `make install` again after moving it.

`make token` reads the token with the shell, not `security -w`. The
interactive `security` prompt silently cuts input at 128 characters, which is
shorter than a Home Assistant token. Pasting the token as a command argument
works but leaves it in your shell history.

## Example automation

Skip a night-time power cutoff while the Mac has had input in the last ten
minutes:

```yaml
conditions:
  - condition: template
    value_template: >
      {% set last = state_attr('input_datetime.mac_last_input', 'timestamp') %}
      {{ last is none or now().timestamp() - last > 600 }}
```

## Files

| Path | Purpose |
| --- | --- |
| `bin/ha-*` | One script per agent |
| `lib/ha.sh` | Config loading, Keychain token, `ha_call` |
| `src/camera-in-use.swift` | Native camera-in-use detector, built to `build/` |
| `launchd/agent.plist.in` | launchd template filled in by `make install` |
| `config.example` | Configuration template |

Logs are written to `~/Library/Logs/ha-macos-agents/<agent>.log`.

## Adding an agent

Add `bin/ha-<name>` that sources `lib/ha.sh`, reads its entity from the
config with `require_var`, and calls `ha_call DOMAIN SERVICE JSON`. Then add
`<name>:<interval>` to `AGENTS` in the `Makefile`.

## Uninstall

```bash
make uninstall
security delete-generic-password -a "$USER" -s ha-macos-agents
rm -rf ~/.config/ha-macos-agents ~/Library/Caches/ha-macos-agents ~/Library/Logs/ha-macos-agents
```

## License

MIT
