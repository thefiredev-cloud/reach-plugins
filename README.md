# reach-plugins

Three small Lua plugins for [Reach](https://github.com/alexandrosnt/Reach), the open-source SSH client built with Rust and Tauri. They are meant for Reach users who want desktop notifications for SSH sessions and SFTP transfers, and for plugin authors who want working examples to copy.

## What it does

Each plugin is a folder with a `plugin.toml` manifest and a `main.lua` entry file. Reach reads the manifest, grants the permissions you approve, and calls the Lua functions below when the matching event fires.

| Plugin | Behavior | Permissions |
|---|---|---|
| [`session-notifier`](plugins/session-notifier) | Shows a notification when an SSH session connects or disconnects | `notify` |
| [`transfer-logger`](plugins/transfer-logger) | Shows a notification when an SFTP upload or download finishes | `notify` |
| [`fleet-summary`](plugins/fleet-summary) | On load, reports how many SSH sessions are open and lists them as `user@host` | `ssh_list_connections`, `notify` |

### session-notifier

Manifest hooks: `session:connected`, `session:disconnected`.

- `on_init()` writes "session-notifier loaded" to the plugin log.
- `on_session_connected(data)` reads `data.username` and `data.host`, then shows a `success` notification such as `Connected: <user>@<host>`.
- `on_session_disconnected(data)` reads `data.connectionId` and shows an `info` notification such as `Disconnected: <connection-id>`. Reach sends only the connection ID on disconnect, so the host name is not available.

### transfer-logger

Manifest hooks: `sftp:upload_complete`, `sftp:download_complete`.

- `on_init()` writes "transfer-logger loaded" to the plugin log.
- `on_sftp_upload_complete(data)` shows a `success` notification with `data.remotePath`.
- `on_sftp_download_complete(data)` shows a `success` notification with `data.remotePath`. When `data.localPath` is set, the message ends with `-> <local-path>`.

### fleet-summary

Manifest hooks: none. The plugin only uses `on_init()`, which Reach calls when it loads the plugin.

- With no open sessions, it writes "fleet-summary: no open sessions" to the plugin log and shows nothing.
- With one or more open sessions, it calls `reach.ssh.list_connections()` and shows an `info` notification such as `2 open session(s): <user>@<host-a>, <user>@<host-b>`.
- The plugin runs once at load time. It does not update when sessions open or close later.

## Quick start

Reach discovers plugins by scanning its plugins directory for subfolders that contain a `plugin.toml`. Copy the plugin folder into that directory.

1. Clone this repo:

   ```bash
   git clone https://github.com/thefiredev-cloud/reach-plugins.git
   ```

2. Find the plugins directory in Reach under Settings, Plugins. You can change it there.
3. Copy one or more plugin folders into it:

   ```bash
   cp -r reach-plugins/plugins/session-notifier <plugins-dir>/
   ```

4. In Settings, Plugins, enable the plugin and grant the permissions it lists. Reach only gives a plugin the permissions you approve, intersected with what its manifest requests.

Reach clears granted permissions when a plugin's `version` in `plugin.toml` changes, so you must grant them again after an upgrade.

The marketplace installer in Reach takes a zip archive with `plugin.toml` at the archive root. You can build one with `cd plugins/session-notifier && zip -r ../../session-notifier.zip .`.

## Configuration

These plugins have no user settings. Everything they use is in `plugin.toml`:

| Key | Used by | Meaning |
|---|---|---|
| `id` | all | Plugin identifier. Must be unique and match the plugin folder name. |
| `name`, `version`, `description`, `author` | all | Display metadata. Changing `version` resets granted permissions. |
| `entry` | all | Lua file to load. Set to `main.lua` in every plugin here. |
| `permissions` | all | Host APIs the plugin asks for. Values used here: `notify`, `ssh_list_connections`. |
| `hooks` | `session-notifier`, `transfer-logger` | Events to receive. A hook function runs only if its event is listed. |

Reach also supports an optional `hook_timeout_ms` key (default 5000 ms, hard cap 30000 ms). None of these plugins set it.

Hook data, as sent by Reach:

| Event | Lua function | `data` fields |
|---|---|---|
| `session:connected` | `on_session_connected` | `connectionId`, `host`, `username` |
| `session:disconnected` | `on_session_disconnected` | `connectionId` |
| `sftp:upload_complete` | `on_sftp_upload_complete` | `connectionId`, `remotePath` |
| `sftp:download_complete` | `on_sftp_download_complete` | `connectionId`, `remotePath`, `localPath` |

Host APIs the plugins call: `reach.ui.notify(message, level)`, `reach.log.info(message)`, and `reach.ssh.list_connections()`. Notification levels used here are `info` and `success`.

## Project layout

```
plugins/
  fleet-summary/
    plugin.toml
    main.lua
  session-notifier/
    plugin.toml
    main.lua
  transfer-logger/
    plugin.toml
    main.lua
```

## Write your own

Copy a plugin folder, change `id` and `name` in `plugin.toml`, and request only the permissions your code uses. Name each hook function `on_` plus the event name with `:` replaced by `_`, for example `sftp:upload_complete` becomes `on_sftp_upload_complete`.

## Development

There is no test suite, linter, or build step in this repo. The hook names and data fields above were checked against the plugin code in the upstream Reach source. Newer Reach releases may change the plugin API, so test a plugin against your Reach version before relying on it. The plugins were written for the [thefiredev-cloud/Reach](https://github.com/thefiredev-cloud/Reach) fork.

These are seed examples. The [reach-plugins-registry](https://github.com/thefiredev-cloud/reach-plugins-registry) index is empty. This project is not affiliated with the upstream Reach project.

## License

MIT. See [LICENSE](LICENSE).
