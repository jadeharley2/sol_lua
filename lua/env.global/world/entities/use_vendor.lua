
 
--ENT.usetype = "button"
ENT.info = "vendor"
ENT._interact = {
	open={
		text="open",
		action = function (self, user)
			self:Press(user)
		end
	},
}

function ENT:Init()   
	local model = self:AddComponent(CTYPE_MODEL)  
	local coll = self:AddComponent(CTYPE_STATICCOLLISION)  
	self.model = model 
	self.coll = coll 
	self:SetSpaceEnabled(false)  
	
end
function ENT:Load()
	local modelval = self:GetParameter(VARTYPE_MODEL)
	local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
	if modelval then 
		self:SetModel(modelval,modelscale)
	else
		MsgN("no model specified for button model at spawn time")
	end  
	self:SetMode(self.mode or "char")
end  
function ENT:Spawn()  
	local modelcom = self.modelcom
	if not modelcom then
		local modelval = self:GetParameter(VARTYPE_MODEL)
		local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
		if modelval then 
			self:SetModel(modelval,modelscale)
		else
			error("no model specified for button model at spawn time")
		end
	end 
	self:AddTag(TAG_USEABLE) 
	self:SetMode(self.mode or "char")
end

 
function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale)  
	
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	--model:SetRenderOrder(1)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	 
	self.coll:SetShapeFromModel(matrix.Scaling(scale) ) 
	
	self.modelcom = true
end 

function ENT:SetMode(mode)  
	if mode == "char" then
		local current_charv = false
		local dfunc = function(button,user) 
			if CLIENT and user == LocalPlayer() then
				if current_charv then
					current_charv:Close()
					current_charv=false
					SHOWINV = false
				else
					current_charv = panel.Create("window_formviewer") 
					local givefunc = function(LP,itemname)
						LP:SendEvent(EVENT_CHANGE_CHARACTER,itemname) 
						current_charv:Close()
						current_charv=false
						SHOWINV = false
					end
					current_charv:Setup("character",givefunc)
					current_charv.OnClose = function()
						current_charv=false
						SHOWINV = false
					end
					current_charv:Show()
					SHOWINV = true
				end
			end
		end 
		self.OnPress = dfunc
		self.info = "character morpher"
	elseif mode == "ability" then 
		local current_abv = false
		local dfunc = function(button,user) 
			if CLIENT and user == LocalPlayer() then
				if current_abv then
					current_abv:Close()
					current_abv=false
					SHOWINV = false
				else
					current_abv = panel.Create("window_formviewer") 
					local givefunc = function(LP,itemname) 
						LP:SendEvent(EVENT_GIVE_ABILITY,itemname)
						--MsgN("add ab: ",ab)
						--PrintTable(LP.abilities)
					end
					current_abv:Setup("ability",givefunc)
					current_abv.OnClose = function()
						current_abv=false
						SHOWINV = false
					end
					current_abv:Show()
					SHOWINV = true
				end
			end
		end
		self.OnPress = dfunc
		self.info = "ability teacher"
	elseif mode == "item" then
		local current_wepv = false
		local dfunc = function(button,user) 
			if CLIENT and user == LocalPlayer() then
				if current_wepv then
					current_wepv:Close()
					current_wepv=false
					SHOWINV = false
				else
					current_wepv = panel.Create("window_formviewer") 
					local givefunc = function(LP,itemname)
						--LP:Give(itemname) 
						LP:SendEvent(EVENT_GIVE_ITEM,"apparel."..itemname)
						MsgN("Give ",LP," <= ",itemname)
					end
					current_wepv:Setup("apparel",givefunc)
					current_wepv.OnClose = function()
						current_wepv=false
						SHOWINV = false
					end
					current_wepv:Show()
					SHOWINV = true
				end
			end
		end
		self.OnPress = dfunc
		self.info = "item spawner"
	elseif mode == "tool" then
		local current_wepv = false
		local dfunc = function(button,user) 
			if CLIENT and user == LocalPlayer() then
				if current_wepv then
					current_wepv:Close()
					current_wepv=false
					SHOWINV = false
				else
					current_wepv = panel.Create("window_formviewer") 
					local givefunc = function(LP,itemname)
						--LP:Give(itemname) 
						LP:SendEvent(EVENT_GIVE_ITEM,"tool."..itemname)
						MsgN("Give ",LP," <= ",itemname)
					end
					current_wepv:Setup("tool",givefunc)
					current_wepv.OnClose = function()
						current_wepv=false
						SHOWINV = false
					end
					current_wepv:Show()
					SHOWINV = true
				end
			end
		end
		self.OnPress = dfunc
		self.info = "tool spawner"
	end
end

function ENT:Press(user) 
	local act = self.OnPress 
	if act then act(self,user) end
	if CLIENT then
		self:EmitSound("events/lamp-switch.ogg",1)
	end
end

ENT._typeevents = {
	[EVENT_USE] = {networked = true, f = ENT.Press},
}