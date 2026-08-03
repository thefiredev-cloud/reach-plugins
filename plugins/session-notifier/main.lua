-- Session Notifier: notify on SSH session connect/disconnect.

function on_init()
	reach.log.info("session-notifier loaded")
end

function on_session_connected(data)
	local user = data.username or "?"
	local host = data.host or "?"
	reach.ui.notify("Connected: " .. user .. "@" .. host, "success")
	reach.log.info("session connected: " .. user .. "@" .. host)
end

function on_session_disconnected(data)
	local id = data.connectionId or "?"
	reach.ui.notify("Disconnected: " .. id, "info")
	reach.log.info("session disconnected: " .. id)
end
