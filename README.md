# Reach Plugins

Seed plugins for the [Reach](https://github.com/alexandrosnt/Reach) marketplace.
Registry index: [thefiredev-cloud/reach-plugins-registry](https://github.com/thefiredev-cloud/reach-plugins-registry).

## Plugins

| Plugin | What it does | Permissions |
|---|---|---|
| session-notifier | Notification on SSH connect/disconnect | notify |
| transfer-logger | Notification on SFTP transfer completion | notify |
| fleet-summary | Reports open SSH sessions on startup | ssh_list_connections, notify |

## Install from source

Zip a plugin directory so `plugin.toml` sits at the archive root, then drop
the zip into your Reach plugins dir or list it in a registry `plugins.json`.
