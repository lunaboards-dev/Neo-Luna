local escapes = {
	[">"] = "&gt;",
	["<"] = "&lt;",
--	["&"] = "&amp;",
	["\1"] = "" --Because we use this internally for escaping
}

local function proc(post)
	local text = post.post
	for find, rep in pairs(escapes) do
		text = text:gsub(find, rep)
	end
	post.post = text
end

return proc