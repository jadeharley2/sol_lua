--UndoManager
local META = DEFINE_METATABLE("UndoManager")
--[[
undo actrion record:
{
	undoAction=function,
	redoAction=function,
	tag=any
}
]]

function META:Add(a,b,...)
	self.history_down:Clear()
	self.history_up:Push({a,b,{...}})
end
function META:Undo(count)
	count = count or 1
	for k=1,count do
		local next = self.history_up:Pop()
		if next then
		Msg("NEXT!")
			PrintTable(next)
			next[1](unpack(next[3]))
			self.history_down:Push(next)
		else
			return k-1
		end
	end
	return count
end
function META:Redo(count)
	count = count or 1
	for k=1,count do
		local next = self.history_down:Pop()
		if next then
			next[2](unpack(next[3]))
			self.history_up:Push(next)
		else
			return k-1 
		end
	end
	return count
end
function META:Clear()
	self.history_up:Clear()
	self.history_down:Clear()
end


META.__index = META
debug.getregistry().UndoManager = META

function UndoManager(maxlen)
	maxlen = maxlen or 50
	local m = {
		history_up = Stack(maxlen),--undos
		history_down = Stack(maxlen),--redos
	}
	setmetatable(m,META)
	return m
end