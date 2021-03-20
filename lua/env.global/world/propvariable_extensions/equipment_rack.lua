
local function ContainerUse(self,user)
	if not self.isopened then
		self.user = user
		self:EmitSound(".physics_rustle_cloth",1) --("events/storage-open.ogg",1)
		if CLIENT and LocalPlayer() == user then  
			actor_panels.OpenCharacterInfo(self,ALIGN_RIGHT,nil) 
			actor_panels.OpenInventory(user,ALIGN_BOTTOM,nil)
			actor_panels.OpenCharacterInfo(user,ALIGN_LEFT,nil) 
			hook.Add("actor_panels.closed","container_closed",function()
				hook.Remove("actor_panels.closed","container_closed")
				self.user = nil
				self.isopened = false
				self:EmitSound(".physics_rustle_cloth",1) --("events/storage-close.ogg",1)
			end)
			--OpenInventoryWindow(self)  
		end 
		self.isopened = true
	else
		if self.user == user then
			self.user = nil
			self:EmitSound(".physics_rustle_cloth",1) --("events/storage-close.ogg",1)
			if CLIENT and LocalPlayer() == user then 
				actor_panels.CloseAll()
				--CloseInventoryWindow(self) 
			end
			self.isopened = false
		end
	end
end

local function GiveItem(self, formid, count,silent)  
    local item = forms.GetItem(formid)
    if item then
        local eq = self.equipment  
        if eq and item:Read("/parameters/luaenttype")  == 'item_apparel' then
            eq:Equip(item) 
        end 
    end  
end

hook.Add("prop.variable.load","container",function (self,j,tags)   
    if j.equipment then
        local e = j.equipment
        local equipment = self:RequireComponent(CTYPE_EQUIPMENT) 
        local model = self.model or self:RequireComponent(CTYPE_MODEL)  
 
        if not e.nopad then
            local padmodel = self.padmodel or self:AddComponent(CTYPE_MODEL)  
            padmodel:SetRenderGroup(RENDERGROUP_LOCAL)
            padmodel:SetBlendMode(BLEND_OPAQUE) 
            padmodel:SetRasterizerMode(RASTER_DETPHSOLID) 
            padmodel:SetDepthStencillMode(DEPTH_ENABLED)  
            padmodel:SetBrightness(1)
            padmodel:SetFadeBounds(0,9e20,0)  
            padmodel:SetModel("models/apparel/pad.stmd")
            padmodel:SetMatrix(matrix.Scaling(0.03)*matrix.Rotation(180,0,0))  
            self.padmodel = padmodel
    
            if(padmodel:HasCollision()) then
                local padcoll = self:RequireComponent(CTYPE_STATICCOLLISION) 
                self.padcoll = padcoll
                padcoll:SetShapeFromModel(matrix.Scaling(0.03)*matrix.Rotation(180,0,0),padmodel)--matrix.Scaling(scale/0.75 )  ) 
            end
        end

        model:SetDynamic(true) 
        if not e.nopad then
            model:SetBBOX(Vector(-20,-20,0),Vector(20,20,80))
        end
        model:SetMatrix(model:GetMatrix() * matrix.Translation(Vector(0,0,-0.03)))  
        self:SetUpdating(true,1000) 
        self:Delayed("setanim",300,function()
            model:SetAnimation(e.pose or "idle",true) 
            model:SetPlaybackRate(0.00001) 
            
            self:Delayed("freeze",100,function() 
                model:SetPlaybackRate(0)  
                self:SetUpdating(false) 
            end)
        end)
        self.equipment = equipment
        if e.slots then
            for k,v in pairs(e.slots) do
                equipment:AddSlot(v)
            end
        end
        if e.parts then
            local bpath = e.basedir  
            local bpr = self.spparts or {}
            local sz = self:GetSizepower()
            for k,v in pairs(e.parts) do 
                local bp = SpawnBP(bpath..v..".stmd",self,0.03,nil,sz) 
                bp:SetName(k)
                bpr[k] = bp
            end
            self.spparts = bpr
        end
        self.species = {bodyparts = {groups = e.groups}}
        if e.materials then
            local bmatdir = e.basedir 
            for k,v in pairs(e.materials) do
                local keys = k:split(':') 
                local bpart = keys[1] 
                local id = tonumber( keys[2])
                if id==nil and bpart == 'mat' then
                    local newmat = LoadMaterial(v)--dynmateial.LoadDynMaterial(v,bmatdir)
                    for partname,part in pairs(self.spparts) do
                        for matid,matname in pairs(part.model:GetMaterials()) do
                            if string.find(matname,keys[2]) then
                                part.model:SetMaterial(newmat,matid-1)
                            end
                        end
                    end

                else
                    local part = self.spparts[bpart]
                    if bpart == "root" then part = self end 
                    if part then  
                        local mat = dynmateial.LoadDynMaterial(v,bmatdir)
                        part.model:SetMaterial(mat,id)
                    end
                end
                 
            end 
        end
        if e.items then
            for k,v in pairs(e.items) do
                local item = forms.GetItem(v)
                if item then
                    equipment:Equip(item)  
                end
            end
        end
		self.info = "Equipment stand"
        
		self:AddInteraction("equipment",
        {text="equipment",action= function (self,user)
            ContainerUse(self,user)
        end})
        if not isfunction(self.Give) then
            self.Give = GiveItem
        end
	end
end)