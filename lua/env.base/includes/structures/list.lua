
local list_meta = DEFINE_METATABLE("List")

--[[
	list:{
		c - count
		m - maxcount
		l - last
		f - first
		item:{
			n - next
			p - previous
			v - value
		}
	}
]]

function list_meta:Add(val)
	if self.m and self.m <= self.c then return false end
	local last = self.l 
	local new = {p = last,v = val}
	if last then last.n = new end
	self.c = self.c + 1
	self.l = new
	if not self.f then self.f = new end
	return true 
end
function list_meta:AddRange(tab)
	for k,v in SortedPairs(tab) do
		self:Add(v)
	end
end
--local function trd(tab)
--	if tab then return tab.v else return nil end
--end

function list_meta:Remove(val,firstonly)
	firstonly = firstonly or true
	local cur = self.f
	local isremoved = false
	while cur do
		--MsgN("cur is ",cur.v)
		if cur.v == val then
			if cur.p then
				--MsgN("prev is not nil, set ",trd(cur.p)," (prev).next to ", trd(cur.n))
				cur.p.n = cur.n
			else
				--MsgN("prev is nil, set FIRST to next ", trd(cur.n)) 
				self.f = cur.n
			end
			if cur.n then
				--MsgN("next is not nil, set ",trd(cur.n)," (next).prev to ", trd(cur.p)) 
				cur.n.p = cur.p
			else
				--MsgN("next is nil, set LAST to prev ", trd(cur.p)) 
				self.l = cur.p
			end
			self.c = self.c - 1
			if firstonly then return true end
			isremoved = true
		end
		cur = cur.n
	end
	return isremoved 
end

function list_meta:RemoveAll(val)
	return self:Remove(val,false) 
end

function list_meta:Contains(val)
	local cur = self.f 
	while cur do
		if cur.v == val then return true end
		cur = cur.n
	end
	return false
end

function list_meta:Clear()
	self.c = 0
	self.f = nil
	self.l = nil
end

function list_meta:First()
	if self.f then return self.f.v end
end

function list_meta:Last()
	if self.l then return self.l.v end
end

function list_meta:At(id) 
	if id > self.c then return nil end 
	if id < self.c/2 then --forward
		local c = 1
		local cur = self.f 
		while c < id do
			cur = cur.n
			c = c + 1 
		end
		return cur.v
	else --backward
		local c = self.c
		local cur = self.l 
		while c > id do
			cur = cur.p
			c = c - 1 
		end
		return cur.v
	end
end

function list_meta:ToTable()
	local t = {}
	local c = 1
	local cur = self.f 
	while cur do
		t[c] = cur.v
		c = c + 1 
		cur = cur.n
	end
	return t
end

function list_meta:ToReversedTable()
	local t = {}
	local c = 1
	local cur = self.l 
	while cur do
		t[c] = cur.v
		c = c + 1 
		cur = cur.p
	end
	return t
end

function list_meta:Count(val)
	if val then
		local c = 0
		local cur = self.f 
		while cur do
			if cur.v == val then c = c + 1 end
			cur = cur.n
		end
		return c
	else
		return self.c
	end
end
function list_meta:Select(func) 
	local tt = {}
	for k,v in list(self) do
		if v then
			if func(v) then
				tt[#tt+1] = v
			end
		end
	end
	return tt
end

function list_meta:MaxCount()
	return self.m
end

function list_meta:SetMaxCount(maxc)
	self.m = maxc
end

list_meta.__index = list_meta


-- iterator
function list(l) 
	return function(t,current,...) 
		local n = current.n
		if n then  
			return n , n.v
		else
			return nil
		end
	end, l, {n = l.f}
end

function List(...)
	local u = {c=0}  
	setmetatable(u,list_meta)
	for k,v in pairs({...}) do
		u:Add(v)
	end
	return u
end