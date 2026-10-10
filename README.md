# reach-plugins

Three example Lua plugins for [Reach](https://github.com/alexandrosnt/Reach), the open-source SSH client built with Rust and Tauri. Two of them show in-app notifications when SSH sessions connect or disconnect and when SFTP transfers finish. The third lists your open sessions. They are for Reach users who want those notifications and for plugin authors who want small working examples to copy.

Maturity: version 1.0.0 seed examples with no tests and no CI. Reach labels its plugin system beta, so the API can change. The hook names, manifest keys, permissions and host functions below match the plugin source in Reach at commit [`5c2ab55`](https://github.com/alexandrosnt/Reach/tree/5c2ab5512a0eb18ec14a01398705ae4b532fe354/src-tauri/src/plugin) (upstream `main`) and the [thefiredev-cloud/Reach](https://github.com/thefiredev-cloud/Reach) fork. Reach's published docs page for plugins describes an older API and does not match the source.

## What it does

Each plugin is a folder with a `plugin.toml` manifest and a `main.lua` entry file. Reach runs `main.lua` in a sandboxed Luau VM and calls the Lua functions below when the matching event fires.

| Plugin | Behavior | Permissions |
|---|---|---|
| [`session-notifier`](plugins/session-notifier) | Notifies when an SSH session connects or disconnects | `notify` |
| [`transfer-logger`](plugins/transfer-logger) | Notifies when an SFTP upload or download finishes | `notify` |
| [`fleet-summary`](plugins/fleet-summary) | On load, lists the open SSH sessions as `user@host` | `ssh_list_connections`, `notify` |

What they do not do:

- They do not send operating system notifications. `reach.ui.notify` becomes a toast inside the Reach window.
- They have no user settings and store nothing.
- `fleet-summary` runs once, when the plugin loads. It does not follow sessions that open or close later.
- None of them are listed in a plugin marketplace.

### session-notifier

Manifest hooks: `session:connected`, `session:disconnected`.

- `on_init()` writes "session-notifier loaded" to the Reach log.
- `on_session_connected(data)` reads `data.username` and `data.host`, shows a notification such as `Connected: <user>@<host>`, and logs it.
- `on_session_disconnected(data)` reads `data.connectionId`, shows `Disconnected: <connection-id>`, and logs it. Reach sends only the connection ID on disconnect, so the host name is not available.

### transfer-logger

Manifest hooks: `sftp:upload_complete`, `sftp:download_complete`.

- `on_init()` writes "transfer-logger loaded" to the Reach log.
- `on_sftp_upload_complete(data)` shows `Upload complete: <remote-path>`.
- `on_sftp_download_complete(data)` shows `Download complete: <remote-path>`. When `data.localPath` is not empty, the message ends with `-> <local-path>`.

Reach fires these hooks only for uploads and downloads that finish without error.

### fleet-summary

Manifest hooks: none. The plugin only defines `on_init()`, which Reach calls when it loads the plugin: at Reach startup, when you enable the plugin, and on reload.

- With no open sessions it writes "fleet-summary: no open sessions" to the Reach log and shows nothing. That is the usual case at startup.
- With open sessions it calls `reach.ssh.list_connections()` and shows a notification such as `2 open session(s): <user>@<host-a>, <user>@<host-b>`.

Reach calls `on_init` as a plain synchronous call, not inside the async runner it uses for hooks. A host call that has to wait can fail there with `attempt to yield across metamethod/C-call boundary`, and the plugin then shows status Error. `reach.ssh.list_connections()` waits if Reach is using its SSH state at that moment. Plugin code that needs a host call to wait belongs in a hook function.

## Requirements

- A Reach build that has the plugin system (Settings > Plugins).
- Nothing else. The plugins use no network access and no external Lua libraries.

## Install

Reach scans its plugins directory for subfolders that contain a `plugin.toml`. The subfolder name must equal the `id` in that file.

1. Clone this repo:

   ```bash
   git clone https://github.com/thefiredev-cloud/reach-plugins.git
   ```

2. Open Settings > Plugins in Reach. The Plugins Directory field shows the path. By default it is a `plugins` folder inside Reach's app data directory.
3. Copy one or more plugin folders into that directory:

   ```bash
   cp -r reach-plugins/plugins/session-notifier <plugins-dir>/
   ```

4. In Settings > Plugins, select Discover Plugins, or restart Reach. Reach enables a newly found plugin and grants it every permission its `plugin.toml` lists. It shows no per-permission prompt, so read the manifest before you copy a plugin in.
5. Open the Plugins section of the Reach sidebar. The notification listener lives in that panel, so toasts from plugins appear only while it is open.

The Browse button next to the Plugins Directory field changes the directory for the running session. The source does not save the new path, so Reach returns to the default after a restart.

### Permissions after an upgrade

Reach stores the plugin's `version` when it saves a permission grant. If `version` in `plugin.toml` differs on the next load, Reach clears the grant. The plugin then loads with only `reach.log`, and calls to `reach.ui.notify` or `reach.ssh` fail. Turn the plugin off and on in the Plugins sidebar panel to grant the manifest permissions again. The panel's own discover button also loads new plugins with no permissions, which is why step 4 uses the Settings button.

## Configuration

These plugins read no settings. Everything they use is in `plugin.toml`:

| Key | Used by | Meaning |
|---|---|---|
| `id` | all | Plugin identifier. Must match the plugin folder name. |
| `name`, `version`, `description`, `author` | all | Display metadata. Changing `version` clears the stored permission grant. |
| `entry` | all | Lua file to load. Defaults to `main.lua`. |
| `permissions` | all | Host APIs the plugin asks for. Used here: `notify`, `ssh_list_connections`. |
| `hooks` | `session-notifier`, `transfer-logger` | Events to receive. A hook function runs only if its event is listed. |

Reach also accepts an optional `hook_timeout_ms` (default 5000, hard cap 30000). None of these plugins set it. A hook that errors or times out sets the plugin's status to Error and shows a toast.

## Reach plugin API

### Hooks

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

### Host functions and permissions

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

## Development

There is no test suite, linter or build step. To change a plugin, edit its files in the Reach plugins directory and select Reload All in Settings > Plugins. Test against your Reach version before relying on a plugin. This project is not affiliated with the upstream Reach project.

## License

MIT. See [LICENSE](LICENSE).
