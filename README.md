# ha-macos-agents

Small launchd agents that report what a Mac is doing to
[Home Assistant](https://www.home-assistant.io/), for machines where the
Companion app is not an option. Plain shell scripts, a token kept in the
Keychain, and nothing else to install.

| Agent | Reports | Docs |
| --- | --- | --- |
| `activity` | Time of the last keyboard or mouse input | [docs/activity.md](docs/activity.md) |
| `camera` | Whether any camera is in use | [docs/camera.md](docs/camera.md) |

## Quick start

1. Create the helper for each agent you want in Home Assistant (see its doc),
   and a long-lived access token (Profile → Security).
2. Configure and install:

   ```bash
   make config     # creates ~/.config/ha-macos-agents/config; edit it
   make token      # stores the token in the login Keychain
   make install    # or pick agents: make install AGENTS=activity:60
   make status
   ```

`AGENTS` lists `name:seconds` pairs, the agents to install and how often each
runs. See [docs/setup.md](docs/setup.md) for configuration, logs and
uninstalling, and [docs/development.md](docs/development.md) to add an agent.

## License

[MIT](LICENSE)
