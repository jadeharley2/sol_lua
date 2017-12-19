local meta = {}

function meta:DoRender(renderResult)
	renderResult = renderResult or {stageIndex = 1}
	local stageResult = {
		id = renderResult.stageIndex,
		name = self.name
	}
	local timer = debug.Timer(true)
	self:Render(stageResult)
	timer:Stop()
	stageResult.timer = timer
	renderResult[renderResult.stageIndex] = stageResult
	renderResult.stageIndex = renderResult.stageIndex + 1
	for k,v in pairs(self.next or {}) do
		v:DoRender(renderResult)
	end
	return renderResult
end
meta.__index = meta
--meta.__newindex = meta

function Stage(sname)
	local s = {name = sname}
	setmetatable(s,meta) 
	return s
end


local stest = Stage("first")
function stest:Render(stageResult)
	MsgN("render one")
	MsgN("render two")
	MsgN("render three")
	MsgN("this is "..tostring(stageResult.stageIndex).." stage")
	MsgN()
end
 
local stest2 = Stage("second")
function stest2:Render(stageResult)
	--MsgN("render 1")
	--MsgN("render 2")
	--MsgN("render 3")
	--MsgN("this is "..tostring(stageResult.stageIndex).." stage")
	--MsgN()
	MsgN("render FFFF") 
	MsgN("render FFFF") 
	MsgN("render FFFF") 
	MsgN("render FFFF") 
end

local stest3 = Stage("third")
function stest3:Render(stageResult) 
	MsgN2("render FFFF") 
	MsgN2("render FFFF") 
	MsgN2("render FFFF") 
	MsgN2("render FFFF") 
end

stest.next = { stest2 }
stest2.next = { stest3 }
MsgN("meta")
PrintTable(meta)
MsgN("A")
PrintTable(stest)
MsgN("B")
PrintTable(stest2)

MsgN("process")
local result = stest:DoRender()

MsgN("result")
PrintTable(result)

 