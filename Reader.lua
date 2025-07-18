local FLOAT_PRECISION = 24

local bit_band = bit32.band
local bit_bor = bit32.bor
local bit_lshift = bit32.lshift
local bit_btest = bit32.btest

local buffer_fromstring = buffer.fromstring
local buffer_len = buffer.len
local buffer_readu8 = buffer.readu8
local buffer_readi8 = buffer.readi8
local buffer_readu32 = buffer.readu32
local buffer_readi32 = buffer.readi32
local buffer_readf32 = buffer.readf32
local buffer_readf64 = buffer.readf64
local buffer_readstring = buffer.readstring

local string_char = string.char
local string_format = string.format
local tonumber = tonumber

local Reader = {}

function Reader.new(bytecode)
	local stream = buffer_fromstring(bytecode)
	local cursor = 0
	local self = {}

	function self:len()
		return buffer_len(stream)
	end

	function self:nextByte()
		local b = buffer_readu8(stream, cursor)
		cursor = cursor + 1
		return b
	end

	function self:nextSignedByte()
		local b = buffer_readi8(stream, cursor)
		cursor = cursor + 1
		return b
	end

	function self:nextBytes(count)
		local t = {}
		for i = 1, count do
			t[i] = self:nextByte()
		end
		return t
	end

	function self:nextChar()
		return string_char(self:nextByte())
	end

	function self:nextUInt32()
		local val = buffer_readu32(stream, cursor)
		cursor = cursor + 4
		return val
	end

	function self:nextInt32()
		local val = buffer_readi32(stream, cursor)
		cursor = cursor + 4
		return val
	end

	function self:nextFloat()
		local val = buffer_readf32(stream, cursor)
		cursor = cursor + 4
		return tonumber(string_format("%." .. FLOAT_PRECISION .. "f", val))
	end

	function self:nextDouble()
		local val = buffer_readf64(stream, cursor)
		cursor = cursor + 8
		return val
	end

	function self:nextVarInt()
		local result = 0
		for i = 0, 4 do
			local b = self:nextByte()
			result = bit_bor(result, bit_lshift(bit_band(b, 0x7F), i * 7))
			if not bit_btest(b, 0x80) then break end
		end
		return result
	end

	function self:nextString(len)
		len = len or self:nextVarInt()
		if len == 0 then
			return ""
		end
		local str = buffer_readstring(stream, cursor, len)
		cursor = cursor + len
		return str
	end

	return self
end

function Reader:Set(p)
	FLOAT_PRECISION = p
end

return Reader
