# camera

Mirrors whether any camera on the Mac is in use to an `input_boolean` helper.
Default interval: 5 seconds.

Use it for an "on a call" light, muting speakers or do-not-disturb.

## Requirements

The Xcode Command Line Tools (`xcode-select --install`). `make install`
compiles the native helper with `swiftc` when this agent is selected.

## Home Assistant helper

```yaml
input_boolean:
  mac_camera_in_use:
    name: Mac Camera In Use
```

## Configuration

| Key | Example | |
| --- | --- | --- |
| `CAMERA_ENTITY` | `input_boolean.mac_camera_in_use` | |
| `RESYNC_MINUTES` | `10` | Optional. Re-send the state at least this often |

## How it works

`src/camera-in-use.swift` asks CoreMediaIO whether any camera device is
running in any process. It never opens the camera, so it needs no camera
permission.

The script calls `input_boolean.turn_on` or `turn_off` only when the state
changes, or when the last report is older than `RESYNC_MINUTES`. The resync
corrects a value changed in Home Assistant or lost while it was down.

Home Assistant accepts an action for an entity that does not exist yet, so a
missing helper is not reported as an error. Create the helper first, or wait
for the next resync after creating it.

## Example

```yaml
triggers:
  - trigger: state
    entity_id: input_boolean.mac_camera_in_use
    to: "on"
actions:
  - action: light.turn_on
    target:
      entity_id: light.on_air
```
