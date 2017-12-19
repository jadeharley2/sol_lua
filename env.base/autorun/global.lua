local tsort = table.sort
local tinsert = table.insert
local srep = string.rep

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end
table.HasValue = table.contains

function SortedPairs (t, f)
	local a = {}
	for n in pairs(t) do tinsert(a, n) end
		tsort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end
local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
end

function TableToString (tbl, indent, maxlevel)
	if not indent then indent = 0 end
	if not maxlevel then maxlevel = 2 end
	if indent > maxlevel then return end
	local st = ""
	for k, v in SortedPairs(tbl) do
		formatting = srep("  ", indent) ..  tostring(k) .. ": "
		if type(v) == "table" then
			if v ~= tbl then
				st = st .. formatting .. "\r\n"
				st = st .. (TableToString(v, indent+1,maxlevel) or "")
			else
				st = st .. formatting .. tostring(v) .. "\r\n"
			end
		else
			st = st .. formatting .. tostring(v) .. "\r\n"
		end
	end
	return st
end

function PrintTable(tbl, maxlevel)
	MsgN(TableToString(tbl,0,maxlevel))
end

function SaveTable(fname,tbl,maxlevel)
	file.Write(fname,TableToString(tbl,0,maxlevel))
end

function FindMetaTable(name)
	return debug.getregistry()[name]
end
--function include(name)
--	if file.Exists(name) then MsgN( "including "..name) return dofile(name) end
--	local ndf = currentRunDirectory ..'/'.. name
--	if file.Exists(ndf) then MsgN( "including "..ndf) return dofile(ndf)end 
--end

function Msg(...)
	local str = ""
	local tbl = {...}
	for k=1,#tbl do
		str = str..tostring(tbl[k]).." "
	end 
	_msg(str)
end
function MsgN(...)
	local str = ""
	local tbl = {...}
	for k=1,#tbl do
		str = str..tostring(tbl[k]).." "
	end 
	_msg(str)--.."\r\n"
end
function MsgN2(...)
	local str = ""
	local tbl = {...}
	for k=1,#tbl do
		str = str..tostring(tbl[k]).." "
	end 
	debug2.Msg(str)--.."\r\n"
end

function ErrorNoHalt(...)
	MsgN("Lua warning: ",...)
	MsgN(debug.traceback())
end

function isnil(arg) return type(arg) == "nil" end
function istable(arg) return type(arg) == "table" end
function isstring(arg) return type(arg) == "string" end
function isnumber(arg) return type(arg) == "number" end
function isboolean(arg) return type(arg) == "boolean" end
function isfunction(arg) return type(arg) == "function" end

