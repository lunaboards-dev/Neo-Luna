local db = require("lapis.db")
local bcrypt = require("bcrypt")
local utils = require("utils")
local function handler(req)
	local query = db.select("* FROM users WHERE name=?", req.params.user)
	if (#query > 0) then
		if (bcrypt.verify(req.params.pass, query[1].pass)) then
			req.session.current_user = query[1].uuid
			req.session.token = utils.get_token()
			utils.update_tokens(query[1].uuid, req.session.token)
		end
	end
	return {
		redirect_to = req:build_url("/", {
			status = 301
		})
    }
end
return handler