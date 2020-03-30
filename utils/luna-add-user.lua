local bcrypt = require("bcrypt")
local drv = require("luasql.postgres")
local env = drv.postgres()
io.stdout:write("Database Username: ")
local un = io.stdin:read()
io.stdout:write("Database password: ")
local pw = io.stdin:read()
io.stdout:write("Connecting...")
local db, err = env:connect("luna", un, pw)
io.stdout:write("\27[13D")
if (db) then
	print("Connection successful!")
else
	print("Connection error: "..err)
	os.exit(1)
end
print("Making a default user with superuser permissions and a white name...")
local user = arg[1]
local pwhash = bcrypt.digest(arg[2], 10)
local h = io.popen("uuidgen", "r")
local uuid = h:read("*a"):gsub("[\n\r]+", "")
h:close()
local res, err = db:execute(string.format("INSERT INTO users(name, pass, perms, color, uuid) VALUES ('%s', '%s', 32767, 'FFFFFF', '%s')", user, pwhash, uuid))
if not res then
	print(err)
	os.exit(1)
end
db:close()
print("New user created!")
print("UUID", uuid)