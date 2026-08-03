-- Fleet Summary: on load, report the number of open SSH connections.

function on_init()
	local conns = reach.ssh.list_connections()
	local n = #conns
	if n == 0 then
		reach.log.info("fleet-summary: no open sessions")
		return
	end
	local hosts = {}
	for _, c in ipairs(conns) do
		table.insert(hosts, (c.username or "?") .. "@" .. (c.host or "?"))
	end
	reach.ui.notify(n .. " open session(s): " .. table.concat(hosts, ", "), "info")
end
