local config = require("lapis.config")
local toml = require("toml")
local _config = io.open("/opt/Neo-Luna/config.toml", "r")
local cfg = toml.parse(_config:read("*a"))
_config:close()

config("development", {
  postgres = {
    host = cfg.database.server,
    user = cfg.database.user,
    password = cfg.database.password,
    database = cfg.database.dbname
  },
  secret = cfg.auth.secret,
  hmac_digest="sha256",
  session_name=cfg.auth.name
})

config("production", {
  postgres = {
    host = cfg.database.server,
    user = cfg.database.user,
    password = cfg.database.password,
    database = cfg.database.dbname
  },
  port = 8080,
  num_workers=4,
  code_cache="on",
  secret = cfg.auth.secret,
  hmac_digest="sha256",
  session_name=cfg.auth.name
})
return cfg