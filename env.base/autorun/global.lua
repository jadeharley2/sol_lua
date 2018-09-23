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
function stdcomp(a,b)
	--if isuserdata(a) or isuserdata(b) then return true 
	--elseif istable(a) or istable(b) then return tostring(a)<tostring(b) 
	--elseif isnumber(a) and isstring(b) then return tostring(a)<b
	--elseif isstring(a) and isnumber(b) then return a<tostring(b) 
	--else
	if isnumber(a) and isnumber(b) then
		return a<b
	else
		return tostring(a)<tostring(b) 
	end
	--end
end

function TableToString (tbl, indent, maxlevel)
	if not indent then indent = 0 end
	if not maxlevel then maxlevel = 2 end
	if indent > maxlevel then return end
	local st = ""
	for k, v in SortedPairs(tbl,stdcomp) do
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

if SERVER then
	--serverside fix
	MsgInfo = MsgN
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
function isuserdata(arg) return type(arg) == "userdata" end

function UniversalSort(a,b)
	local a_type = type(a)
	local b_type = type(b)
	if(a_type=="string") then 
		if(b_type=="string") then
			return string.lower(a)<string.lower(b)
		else
			return false
		end
	else
		if(b_type=="string") then
			return true
		else
			return b>a
		end
	end
end


function DeclareEnumValue(type,name,id)
	type = string.upper(type)
	local key = string.upper(type.."_"..name)
	_G[key] = id
	debug.AddAPIInfo("/"..type.."_/"..key,id)
	engine.AddDEnumValue(type,name,id)
end

function ConcatFunc(functable)
	return function(...) for k,v in pairs(functable) do v(...) end end
end
function AndFunc(functable)
	return function(...) 
		for k,v in pairs(functable) do 
			if not v(...) then return false end
		end  
		return true
	end
end
function OrFunc(functable)
	return function(...) 
		for k,v in pairs(functable) do 
			if v(...) then return true end 
		end  
		return false
	end
end
