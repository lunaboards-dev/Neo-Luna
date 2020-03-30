rawset(_G, "_LUNAVER", "2.0.0-beta")
local lapis = require("lapis")
local config = require("lapis.config")
local utils = require("utils")
math.randomseed(os.time())
local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

app:before_filter(utils.verify_token)
app:before_filter(utils.ip_check)
app:get("/", require("boards"))
app:get("/login", require("login"))
app:get("/adm/:com", require("admin"))
app:post("/adm/:com", require("admin"))
app:post("/login", require("auth"))
app:get("/all/", require("allboard"))
app:get("/:board/", require("board"))
app:get("/:board/post", require("post"))
app:post("/:board/post", require("newpost"))
app:get("/:board/:id", require("thread"))
app:post("/:board/:id", require("threadpost"))

function app:handle_error(err, trace)
	self.err = err
	self.trace = trace
	self.luna_ver = _LUNAVER
	self.ip = self.req.headers["X-Real-IP"] or self.req.remote_addr
	self.path = self.req.parsed_url.path
	self.hostaddr = self.req.headers.host
	self.method = self.req.cmd_mth
	local error_hexes = {
		"b00b1e5",
		"f00f",
		"01134",
		"deadbeef",
		"deadbabe",
		"2321",
		"00f",
		"b16b00b5",
		"aaaaaaaa",
		"0d15ea5e",
		"g"
	}
	self.title_hex = error_hexes[math.random(1, #error_hexes)]
    return { render = "error" }
end

return app
