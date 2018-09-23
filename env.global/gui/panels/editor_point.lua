
 
local t_aanchor = LoadTexture("gui/nodes/aanchor.png")
local t_banchor = LoadTexture("gui/nodes/banchor.png")
local t_canchor = LoadTexture("gui/nodes/canchor.png")
function PANEL:Init() 
	--self.base.Init(self)
	self.edpt = true
	
	self:SetSize(8,8)
	self:SetTexture(t_aanchor)
	
	self:SetColor(Vector(83,164,255)/255)
	self:SetUseGlobalScale(true)
	
end 
function PANEL:Load() 
end
function PANEL:ToData() 
	local pos = self:GetPos() 
	local p = self:GetParent()
	local j = {id = self.id,pos = {pos.x,pos.y}} 
	if p.id then
		j.parent = p.id
	end
	return j
end
function PANEL:FromData(data,mapping,posoffset,blocknext) 
	if data.pos then self:SetPos(data.pos[1]+posoffset.x,data.pos[2]+posoffset.y) end
	self.id = data.id
	local e = self.editor.editor 
	if data.parent then
		local parent = e.named[mapping(data.parent)]
		MsgN("par",data.parent,parent)
		if parent then
			self:GetParent():Remove(self)
			parent:Add(self)
		end 
	end
	
	self:SetAnchors(ALIGN_TOPLEFT)
end 
 
function PANEL:Select(selector) 
	self:SetColor(Vector(83,255,164)/255)
	self.selector = selector
end
function PANEL:Deselect() 
	self:SetColor(Vector(83,164,255)/255)
	self.selector = nil
end 

function PANEL:SetColor(c)
	PANEL.base.SetColor(self,c) 
end 
 
function PANEL:MouseDown(id)
	if id == 1 then
		local sel = self.selector
		if sel then
			panel.start_drag(sel:GetSelected(),1,true,20)
		else
			if panel.start_drag(self,1,function() self:SetCanRaiseMouseEvents(true) end,20) then 
				local p = self:GetParent()
				if p then 
					p:Remove(self)
					p:Add(self)
				end
				self:SetCanRaiseMouseEvents(false)
			end			
		end 
	elseif id == 2 then
		--self:Select()
		self.editor.selector:Select({self})
	elseif id == 3 then
		panel.start_drag(self.editor,3) 
	end
end
function PANEL:OnDropped(onto) 
	self:SetCanRaiseMouseEvents(true)
	if onto then
		local p = self:GetParent()
		if onto ~= p then
			if p then p:Remove(self) end
			onto:Add(self)
			for k,v in pairs(self.anchors) do
				v:UpdateVarLink()
			end
		end
	end
end 