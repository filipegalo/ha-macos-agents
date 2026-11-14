# activity

Writes the time of the Mac's last keyboard or mouse input to an
`input_datetime` helper. Default interval: 60 seconds.

Use it to keep something on while you are at the computer and turn it off a
while after you stop.

## Home Assistant helper

```yaml
input_datetime:
  mac_last_input:
    name: Mac Last Input
    has_date: true
    has_time: true
```

## Configuration

| Key | Example |
| --- | --- |
| `ACTIVITY_ENTITY` | `input_datetime.mac_last_input` |

## How it works

The script reads `HIDIdleTime` from `ioreg`, subtracts it from the current
time and calls `input_datetime.set_datetime`. It reports a timestamp, not
"active" or "idle", so the idle threshold lives in your automation.

A Mac that sleeps, leaves the network or stops the agent just stops reporting,
and the timestamp ages. Treat an old value as "not in use", never the other
way round, and a failure can never keep something switched on.

## Example

Skip an automation while the Mac has had input in the last ten minutes:

```yaml
conditions:
  - condition: template
    value_template: >
      {% set last = state_attr('input_datetime.mac_last_input', 'timestamp') %}
      {{ last is none or now().timestamp() - last > 600 }}
```

If the automation should resume on its own when you stop, give it a trigger
that re-checks, for example `time_pattern` every minute.
