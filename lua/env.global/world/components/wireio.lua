--Component?
DeclareEnumValue("event","WIRE_SIGNAL",	111234) --EVENT_WIRE_SIGNAL

component.uid = DeclareEnumValue("CTYPE","WIREIO", 1315)
component.editor = {
	name = "WireIO",
	properties = { 
	},
	
}

component._typeevents = { 
	[EVENT_WIRE_SIGNAL]={networked=true,f = function(self,from,key,value)
		local node = self:GetNode()
		inp = self.inputs[key]
		if inp and inp.f then
			inp.f(node,from,key,value)
		end   
	end}, 
} 

function component:Init()
	self.inputs = {}
	self.outputs = {}
end
--function component.ReceiveEvent(self,from,key,value)
--	local node = self:GetNode()
--	inp = self.inputs[key]
--	if inp and inp.f then
--		inp.f(node,from,key,value)
--	end 
--end
function component:OnAttach(node)
	self.inputs = {}
	self.outputs = {}
	node.wireio = self
	node._comevents = node._comevents or {}
	node._comevents[self.uid] = self 
	--node:AddEventListener(EVENT_WIRE_SIGNAL,"a",self.ReceiveEvent)
end
function component:OnDetach(node)
	node.wireio = nil
	node._comevents = node._comevents or {}
	node._comevents[self.uid] = nil
end
 
--function component:LinkOutputTo(node,outname,inname)
--	local w = node.wireio
--	if w then
--		local out = self.outputs[outname]
--		local ins = w.inputs[inname]
--		if ins and out then --and ins.type == out.type then 
--			out.targets[node] = outname
--		end
--	end
--end
--func(thisnode,fromnode,inputname,inputvalue)
function component:AddInput(name,func)
	self.inputs[name] = {f=func}
end 
function component:AddOutput(name)
	self.outputs[name] = {targets={}}
end 
function component:SetOutput(name,value)
	if self.outputs then
		local out = self.outputs[name]
		if out then
			out.v = value
			for k,v in pairs(out.targets) do
				v[1]:SendEvent(EVENT_WIRE_SIGNAL,nil,v[2],value)
			end
		end
	end
end

function WireLink(from,fname,to,tname) 
	local fw = from.wireio
	local tw = to.wireio
	if fw and tw then
		local out = fw.outputs[fname]
		local ins = tw.inputs[tname]
		if ins and out then --and ins.type == out.type then 
			if ins.target then
				WireUnLink(to,tname)
			end
			out.targets[to:GetSeed()] = {to,tname}
			ins.target = out
			--MsgN("wirelink! ",from,fname,to,".",tname)
			--PrintTable(tw)
			--MsgN("---")
			--PrintTable(fw)
		end
	end
end
function WireUnLink(to,tname)  
	local tw = to.wireio
	if tw then 
		local ins = tw.inputs[tname]
		if ins and ins.target then   
			ins.target.targets[to:GetSeed()] = nil
			ins.target = nil
			--MsgN("wireunlink! ",to,".",tname)
			--PrintTable(tw) 
		end
	end
end
