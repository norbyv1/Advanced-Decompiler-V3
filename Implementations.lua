local _ENV = (getgenv or getfenv)()

local Implementations = {}

local str_find = string.find
local str_rep = string.rep
local tostr = tostring
local type = type

function Implementations.toBoolean(n)
	return n ~= 0
end

function Implementations.toEscapedString(s)
	if type(s) ~= "string" then
		return tostr(s)
	end

	local hasDouble = str_find(s, '"', 1, true)
	local hasSingle = str_find(s, "'", 1, true)

	if hasDouble and hasSingle then
		return "[[" .. s .. "]]"
	elseif hasDouble then
		return "'" .. s .. "'"
	else
		return '"' .. s .. '"'
	end
end

function Implementations.formatIndexString(s)
	if type(s) == "string" and str_find(s, "^[%a_][%w_]*$") then
		return "." .. s
	end
	return "[" .. Implementations.toEscapedString(s) .. "]"
end

function Implementations.padLeft(x, char, padding)
	x = tostr(x)
	local diff = padding - #x
	if diff > 0 then
		return str_rep(char, diff) .. x
	end
	return x
end

function Implementations.padRight(x, char, padding)
	x = tostr(x)
	local diff = padding - #x
	if diff > 0 then
		return x .. str_rep(char, diff)
	end
	return x
end

function Implementations.isGlobal(s)
	return _ENV[s] ~= nil
end

return Implementations
