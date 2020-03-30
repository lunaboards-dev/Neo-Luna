local log = io.open("../logs/access.log")
local cjdns = 0
local ipv4 = 0
local total = 0
local ips = {}
for line in log:lines() do
	if not line:match("/img") and not line:match("/thumbs") then
		if line:match("192.168.1.68") then
			cjdns = cjdns+1
		else
			ipv4 = ipv4 + 1
		end
		total = total + 1
	end
end
print("cjdns", (cjdns/total)*100)
print("clearnet", (ipv4/total)*100)