# Development

## Layout

| Path | Purpose |
| --- | --- |
| `bin/ha-<name>` | One script per agent |
| `lib/ha.sh` | Config loading, Keychain token, `ha_call` |
| `src/` | Native helpers, compiled to `build/` |
| `launchd/agent.plist.in` | launchd template filled in by `make install` |
| `config.example` | Configuration template |
| `docs/<name>.md` | One page per agent |

## Adding an agent

1. Add `bin/ha-<name>`. Source `lib/ha.sh`, read the entity with
   `require_var NAME_ENTITY`, and report with `ha_call DOMAIN SERVICE JSON`.
2. Add its keys to `config.example`.
3. Add `<name>:<seconds>` to the default `AGENTS` in the `Makefile`.
4. Add `docs/<name>.md` (helper, configuration, how it works, example) and a
   row in the README table.

Prefer reporting raw facts, such as a timestamp, over a decision like "idle",
so thresholds stay in Home Assistant. Design for failure to leave a value
stale, never stuck in a state that keeps something switched on.

## Checks

```bash
make check    # bash -n, plus shellcheck when installed
```
