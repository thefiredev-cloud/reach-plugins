# reach-plugins

Three small Lua plugins for [Reach](https://github.com/alexandrosnt/Reach), the open-source SSH client built with Rust and Tauri.

## Plugins

| Plugin | What it does | Permissions |
|---|---|---|
| [`session-notifier`](plugins/session-notifier) | Shows a notification when an SSH session connects or disconnects | `notify` |
| [`transfer-logger`](plugins/transfer-logger) | Shows a notification when an SFTP transfer finishes | `notify` |
| [`fleet-summary`](plugins/fleet-summary) | On startup, reports how many SSH sessions are open and lists their hosts | `ssh_list_connections`, `notify` |

Each plugin is a folder with a `plugin.toml` manifest (id, version, entry file, permissions) and a `main.lua` entry point that calls the `reach.ui`, `reach.log`, and `reach.ssh` APIs.

## Requirements

A Reach build with plugin support. The plugins were written against the plugin API in the [thefiredev-cloud/Reach](https://github.com/thefiredev-cloud/Reach) fork; newer upstream Reach releases may change that API.

## Install

Zip a plugin folder so that `plugin.toml` sits at the root of the archive, then place it in the Reach plugins directory:

```bash
git clone https://github.com/thefiredev-cloud/reach-plugins.git
cd reach-plugins/plugins/session-notifier
zip -r ../../session-notifier.zip .
```

The plugins directory is shown, and can be changed, in Reach under Settings, Plugins.

## Write your own

Copy a plugin folder, change `id` and `name` in `plugin.toml`, and request only the permissions you use. Hooks used here: `on_init`, `on_session_connected(data)`, `on_session_disconnected(data)`, `on_sftp_upload_complete`, and `on_sftp_download_complete`.

## Status

Seed examples. There is no published registry listing: [reach-plugins-registry](https://github.com/thefiredev-cloud/reach-plugins-registry) is an empty index. Not affiliated with the Reach upstream project.

## License

MIT. See [LICENSE](LICENSE).
