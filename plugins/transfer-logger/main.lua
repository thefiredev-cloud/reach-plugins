-- Transfer Logger: notify on completed SFTP transfers.

function on_init()
	reach.log.info("transfer-logger loaded")
end

function on_sftp_upload_complete(data)
	local path = data.remotePath or "?"
	reach.ui.notify("Upload complete: " .. path, "success")
end

function on_sftp_download_complete(data)
	local path = data.remotePath or "?"
	local local_path = data.localPath or ""
	local msg = "Download complete: " .. path
	if local_path ~= "" then
		msg = msg .. " -> " .. local_path
	end
	reach.ui.notify(msg, "success")
end
