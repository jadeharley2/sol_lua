
PANEL.basetype = "button"
local t_aanchor = LoadTexture("gui/nodes/aanchor.png")
local t_banchor = LoadTexture("gui/nodes/banchor.png")
local t_canchor = LoadTexture("gui/nodes/canchor.png")
function PANEL:Init() 
	self.base.Init(self) 
	self:SetSize(8,8)
	self:SetTexture(t_aanchor)
	self.base.SetColorAuto(self, Vector(0.7,0.7,0.7),0.2)
	self.to = Set()
end
function PANEL:GetTypeColor(type)  
	MsgN("typecolor ",type)
	if type=="float" or type=="single" or type == "double" then
		return Vector(0.3,0.7,0.2)--green
	elseif type=="int" or type=="int32" or type=="int16" or type=="int64" then 
		return Vector(0.2,0.7,0.7)--cyan
	elseif type=="signal" then 
		return Vector(0.7,0.7,0.7)--white
	elseif type=="boolean" then 
		return Vector(0.7,0.2,0.2)--red
	elseif type=="string" then 
		return Vector(0.7,0.2,0.7)--magenta   
	elseif type=="scriptednode" or type=="snode" or type=="scomplexobject" then 
		return Vector(0.2,0.2,0.7)--blue  
	elseif type=="vector2" then 
		return Vector(0.7,0.4,0.2)  
	elseif type=="vector3" then 
		return Vector(0.7,0.7,0.2)--yellow  
	elseif type=="vector4" then 
		return Vector(0.7,0.7,0.9)   
	elseif type=="quaternion" then 
		return Vector(0.5,0.5,0.7)--light blue  
	elseif type=="matrix" then 
		return Vector(0.7,0.5,0.2)--orange  
	else
		return Vector(0.2,0.2,0.2)--dark gray
	end
end
function PANEL:Attach(node,id,name,type)
	self.editor = node.editor
	self.node = node
	self.id = id
	self.name = name
	self.type = type
	
	self.bcolor = self:GetTypeColor(type)
	
	self:SetColorAuto(self.bcolor,0.2)
	local ps = node:GetSize()
	if(id<0) then
		self:SetPos(-ps.x+10,0)--self:AlignTo(node,ALIGN_LEFT,ALIGN_LEFT)
	else
		self:SetPos(ps.x-10,0)--self:AlignTo(node,ALIGN_RIGHT,ALIGN_RIGHT)
	end
	local sp = self:GetPos()
	self:SetPos(sp.x,math.abs(id)*-20+80)
	node:Add(self)
end
function PANEL:MouseUp(id) 
	if CURRENT_SELECTED_ANCHOR and CURRENT_SELECTED_ANCHOR ~= self then
		self:CreateLink(self,CURRENT_SELECTED_ANCHOR) 
		CURRENT_SELECTED_ANCHOR = false
	end
end
function PANEL:BeginLink(dir)
	local ed = self.editor
	local dot = panel.Create()
	dot:SetSize(10,10)
	dot:SetColor(Vector(1,0,0))
	dot:SetPos(ed:GetLocalCursorPos())
	dot:SetVisible(false)
	dot:SetCanRaiseMouseEvents(false)
	ed:Add(dot)
	
	local curvlayer = self.editor.curvelayer
	local curve = panel.Create("curve")
	curve:SetSize(2,2) 
	if dir then
		curve.from = dot
		curve.to = self 
	else
		curve.from = self
		curve.to = dot 
	end
	curve.bend = 200
	curve:SetColor(self.bcolor)
	curve:SetEndColor(self.bcolor)
	curvlayer:Add(curve)
	
	cuup[#cuup+1] = curve
	GUI_CURVE_UPDATE()
	
	CURRENT_SELECTED_ANCHOR = self
	panel.start_drag(dot,1,function(n)
		ed:Remove(dot)
		curvlayer:Remove(curve) 
		for k,v in pairs(cuup) do 
			if v == curve then
				cuup[k] = nil 
			end
		end
		debug.Delayed(100,function()
			CURRENT_SELECTED_ANCHOR = false
		end)
	end)
end
function PANEL:OnClick(id)
	if CURRENT_SELECTED_ANCHOR and CURRENT_SELECTED_ANCHOR ~= self then
		
		
		self:CreateLink(self,CURRENT_SELECTED_ANCHOR) 
		CURRENT_SELECTED_ANCHOR = false
	else
		  
		local from = self.from
		 
		
		if from then
			self:RemoveLink(from, self)
			from:BeginLink()
		else
			if self.id>0 then
				self:BeginLink()
			else
				self:BeginLink(-1)
			--self.base.SetColorAuto(self,Vector(0.7,0.5,0.2),0.2)
				--CURRENT_SELECTED_ANCHOR = self
			end
		end  
	end
end
function PANEL:OnRightClick()
	MsgN("rclc")
end
function PANEL:GetValue()
	MsgN("GET ",self.name," : ",self.value)
	return self.value
end
function PANEL:SetValue(val)
	MsgN("SET ",self.node.name.."."..self.name," : ",val)
	self.value = val
end
function PANEL:CreateLink(a,b)
	if a == b then return end
	if not a or not b then return end
	if not a.node or not b.node then return end
	if a.node == b.node then return end
	
	local from = a 
	local to = b 
	 
	if a.id<0 then
		from = b
		to = a
	end
	
	if to.from then 
		self:RemoveLink(to.from,to)
	end
	
	if from.type == "signal" then
		if from.type ~= to.type then return end
		if from.to:Count()>0 then
			from:UnlinkAll()
		end
	end
	
	MsgN("CreateLink",from.node.id,":",from.id," => ",to.node.id,":",to.id)
	
	
	
	to.node.inputs[-to.id] = from
	--from.to = to
	to.from = from
	from.to:Add(to)
	
	to.base.SetColorAuto(to,to.bcolor,0.2)
	from.base.SetColorAuto(from,from.bcolor,0.2)

	local curve = panel.Create("curve")
	curve:SetSize(2,2)
	
	
	curve.from = from
	curve.to = to 
	curve.bend = 200
	from.editor.curvelayer:Add(curve)
	curve:SetColor(from.bcolor)--Vector(83,164,255)/255) 
	curve:SetEndColor(to.bcolor)
	
	to.curve = curve
	
	cuup[#cuup+1] = curve
	GUI_CURVE_UPDATE()
	
	
	from:SetTexture(t_banchor)
	to:SetTexture(t_banchor)
end
function PANEL:RemoveLink(a,b)

	local from = a 
	local to = b 
	
	if a.id<0 then
		from = b
		to = a
	end
	MsgN("RemoveLink",from.node.id,":",from.id," => ",to.node.id,":",to.id)
	
	to.node.inputs[-to.id] = nil
	from.to:Remove(to)
	to.from = nil
	
	local curve = to.curve
	for k,v in pairs(cuup) do 
		if v == curve then
			cuup[k] = nil
			from.editor.curvelayer:Remove(curve)
		end
	end
	
	PrintTable(from.to:ToTable())
	if(from.to:Count()==0)then
		from:SetTexture(t_aanchor)
	end
	to:SetTexture(t_aanchor)
end

function PANEL:UnlinkAll()
	if self.id<0 then
		if self.from then
			self:RemoveLink(self.from,self)
		end
		self.from = nil
	else
		for k,v in pairs(self.to:ToTable()) do
			self:RemoveLink(self,v)
		end
		self.to:Clear()
	end 
end


function PANEL:UpdateVarLink() 
	MsgN("UpdateVarLink",self.id<0 , self.node , not self.from )
	if self.id<0 and self.node and not self.from then
		local p = self.node:GetParent()
		if p and p.nodegroup and self.name == "self" then 
			MsgN("UpdateVarLink2",sarg ) 
				self:SetTexture(t_canchor) 
				return  
		end
		self:SetTexture(t_aanchor) 
	end 
end