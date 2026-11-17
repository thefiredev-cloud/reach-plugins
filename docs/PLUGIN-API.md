# Reach plugin API notes

Matches the plugin source in Reach at commit [`5c2ab55`](https://github.com/alexandrosnt/Reach/tree/5c2ab5512a0eb18ec14a01398705ae4b532fe354/src-tauri/src/plugin). Reach's published plugin docs describe an older API.

## Hooks

A hook function is named `on_` plus the event name with `:` replaced by `_`. Reach passes one table, `data`.

| Event | Lua function | `data` fields | Fired by |
|---|---|---|---|
| `session:connected` | `on_session_connected` | `connectionId`, `host`, `username` | the connect command |
| `session:disconnected` | `on_session_disconnected` | `connectionId` | the disconnect command |
| `sftp:upload_complete` | `on_sftp_upload_complete` | `connectionId`, `remotePath` | a finished upload |
| `sftp:download_complete` | `on_sftp_download_complete` | `connectionId`, `remotePath`, `localPath` | a finished download |
| `tunnel:started` | `on_tunnel_started` | `tunnelId`, `localPort` | starting a tunnel |
| `tunnel:stopped` | `on_tunnel_stopped` | `tunnelId` | stopping a tunnel |

Reach also defines `vault:unlocked` and `vault:locked` but does not fire them. Besides hooks, Reach calls `on_init()` on load and `on_unload()` on unload if they exist.

## Host functions and permissions

`reach.log.info`, `reach.log.warn` and `reach.log.error` are always available and write to the Reach log. Everything else needs the permission in the second column.

| Function | Permission |
|---|---|
| `reach.ssh.exec(connection_id, command)` | `ssh_exec` |
| `reach.ssh.list_connections()`, returns a list of `{id, host, port, username}` | `ssh_list_connections` |
| `reach.sftp.list(connection_id, path)`, `reach.sftp.read(connection_id, path)`, `reach.sftp.write(connection_id, path, content)` | `sftp_list`, `sftp_read`, `sftp_write` |
| `reach.vault.list()` | `vault_read` |
| `reach.http.get(url)`, `reach.http.post(url, json_body)` | `http` |
| `reach.ui.notify(message, level)` | `notify` |
| `reach.ui.render(elements)` | `ui` |

Two more permissions exist: `vault_write`, which adds no function today, and `tunnel_manage`, whose `reach.tunnel.list()` returns an empty table in the current source.

Notification levels: `error` and `warning` change the toast style. Any other value, including the `success` these plugins use, shows as an info toast.

Sandbox limits: `io`, `loadfile`, `dofile` and `os.execute`, `os.exit`, `os.remove`, `os.rename`, `os.tmpname`, `os.getenv` are removed. A VM gets 64 MB of memory, and a run is aborted after 10 million interpreter interrupts. `reach.http` requests time out after 30 seconds.

## Write your own

Copy a plugin folder, change `id` (and rename the folder to match) and `name` in `plugin.toml`, and request only the permissions your code uses. Add each event you handle to `hooks`.

To publish through the Reach marketplace, zip the plugin with `plugin.toml` at the archive root:

```bash
cd plugins/session-notifier && zip -r ../../session-notifier.zip .
```

The marketplace installs only plugins listed in a registry index. Each entry needs a `downloadUrl` and the zip's hex SHA-256, which Reach checks before it extracts anything. Reach's default registry, [alexandrosnt/reach-plugins-registry](https://github.com/alexandrosnt/reach-plugins-registry), currently lists no plugins, and neither does [thefiredev-cloud/reach-plugins-registry](https://github.com/thefiredev-cloud/reach-plugins-registry).


## Permissions after an upgrade

Reach stores the plugin's `version` when it saves a permission grant. If `version` in `plugin.toml` differs on the next load, Reach clears the grant. The plugin then loads with only `reach.log`, and calls to `reach.ui.notify` or `reach.ssh` fail. Turn the plugin off and on in the Plugins sidebar panel to grant the manifest permissions again. The panel's own discover button also loads new plugins with no permissions, which is why step 4 uses the Settings button.

