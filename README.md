# Reach Plugins

Seed Lua plugins for the Reach SSH client marketplace.

## Why it exists

Reach needed a small, inspectable set of plugins (notify on connect, log transfers, summarize sessions) without bundling them inside the app binary.

## How to run it

There is no daemon. Zip a plugin directory so `plugin.toml` is at the archive root, then drop the zip into the Reach plugins directory or list it in `thefiredev-cloud/reach-plugins-registry`.

```bash
git clone https://github.com/thefiredev-cloud/reach-plugins.git
cd reach-plugins
```

Plugins in this tree:

- `session-notifier` — notify on SSH connect/disconnect (`notify`)
- `transfer-logger` — notify on SFTP transfer completion (`notify`)
- `fleet-summary` — report open SSH sessions on startup (`ssh_list_connections`, `notify`)

## In scope

- Seed plugin source for Reach

## Out of scope

- The Reach application (see `thefiredev-cloud/Reach`)
- A populated public registry (see `reach-plugins-registry`, emptied)

## Production

Not deployed as a service. Consumed by Reach installs.

## Status

Live seed source. Registry index is emptied.
