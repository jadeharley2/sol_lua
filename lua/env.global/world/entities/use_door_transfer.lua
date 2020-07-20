
  


ENT.info = "Door"
ENT._interact = {
	open={text="enter",action= function (self,user)
		self:Press(user)
	end},
}
--target format:
--[[

    uid:formid:doorname:displayname
    uid - unique space identifier
    formid - space prefab formid
    doorname - target exit door name
    displayname - text displayed 
]]

function ENT:Init()  
	local phys = self:RequireComponent(CTYPE_STATICCOLLISION)  
	local model = self:RequireComponent(CTYPE_MODEL)  
	self.model = model
	self.phys = phys
    self:SetSpaceEnabled(false)  
    self:AddNativeEventListener(EVENT_ENTER,"redirect",self.EnterBy)
end 
function ENT:SetupData(data)
	if isstring(data.target) then 
		self[VARTYPE_TARGET] = data.target
    end 
    if data.targets then
        self.targets = data.targets
    end
    if data.model then
        self[VARTYPE_MODEL] = data.model
    end
    if data.modelscale then
        self[VARTYPE_MODELSCALE] = data.modelscale
    end
    if data.offset then
        self.offset = JVector(data.offset)
    end 
    if data.title then
        self.title = data.title
    end 
end
function ENT:Load() 
    
    if not self.loaded then
        self:SetupModel() 
        self:SetupStaticCollision()  
        
        local target = self.targets or self[VARTYPE_TARGET]
        if target then
            self:SetTarget(target)
        end
        self.loaded = true 
    end
end 
function ENT:Spawn()  
    if not self.loaded then
        self:SetupModel() 
        self:SetupStaticCollision()  
        
        local target = self.targets or self[VARTYPE_TARGET]
        if target then
            self:SetTarget(target)
        end
        self.loaded = true 
    end
end
function ENT:SetModel(mdl)
	self:SetParameter(VARTYPE_MODEL,mdl) 
end
function ENT:SetModelScale(scale) 
	self:SetParameter(VARTYPE_MODELSCALE,scale)
end
function ENT:EnterBy(eid, user) 
    self:Delayed("transfer_delay",300,function()
        self:Transer(user,self)
    end)
end
function ENT:SetTarget(target)
    if target then
        if isstring(target) then 
            self[VARTYPE_TARGET] = target
            local uid,form,door,display = unpack(cstring.split(target,":"))
            self.info = display
            --MsgN("target",uid,form,door,display)
        elseif istable(target) then
            self.info = self.title or "Select destination"
            self.target = target
            self._interact = {}
            for k,v in ipairs(target) do
                local uid,form,door,display = unpack(cstring.split(v,":"))
                local id = "open_"..tostring(k)
                self:AddInteraction(id,{
                    text=display,
                    action = function (self, user)
                        self:Press(user,v)
                    end
                })
            end
        end
	end
end
function ENT:Press(user,target)  
    target = target or self[VARTYPE_TARGET] 
	if target then 
        local uid,form,door,display = unpack(cstring.split(target,":"))
        MsgN(uid,'|',form,'|',door,'|',display)
        if form=="" and forms.HasForm('anchor',uid) then
            engine.SendToAnchor(user,uid)
        elseif uid ~=nil and cstring.len(uid)>0 and form~=nil then
            local ent = nodeloader.Create(form,nil,uid,self:GetTop())
            if IsValidEnt(ent) then
                local door = ent:GetByName(door,false,true)
                if IsValidEnt(door) then
                    self:Transer(user,door)
                end
            end
        else
            local selfworld = self:GetTop() 
            local doore = selfworld:GetByName(door,false,true)
            MsgN(">>",door,doore)
            if IsValidEnt(doore) then
                self:Transer(user,doore)
            end
        end
    elseif self.sound_open then
        self:EmitSound(self.sound_open,1)
	end
end

function ENT:Transer(user,target,incoming)
	 
	local ct = CurTime()
	local slastuse = self.lastuse or 0
	local tlastuse = target.lastuse or 0
	if incoming or (slastuse+4<ct and tlastuse+4<ct) then 
        if self and IsValidEnt(self) and not incoming then
            stateevents.Call(self, "open") 
        end
         
        local upar = user:GetParent()
        local tpar = target:GetParent()
        local sz = tpar:GetSizepower()
        local offset = (  target.offset or Vector(0,0.2,-1)) --/sz
        local loffset = offset:TransformN( tpar:GetLocalSpace(target))--/sz
        
        MsgN("door open from ",upar," to ",tpar)
        user:SetParent(tpar)
        user:SetPos(target:GetPos()+loffset)--Vector(0,1/sz,0)+target:Forward()/sz)  
        
        --local yaw_diff =
        user:CopyAng(target)
        user:TRotateAroundAxis(Vector(0,1,0),math.pi/2)
    -- user:SetAng(target:GetAng())
        MsgN("door transfer of ",user," to ",tpar)
        
        self.lastuse = ct
        target.lastuse = ct
        
        if target and IsValidEnt(target) then
            stateevents.Call(target, "close") 
        end
        MsgN("door closed from ",upar," to ",tpar) 
	end
end
 
ENT.editor = {
	name = "Transfer Door",
	properties = {
		target = {text = "target door",type="parameter",valtype="string",key=VARTYPE_TARGET,reload=true}, 
	 
		
	},  
	
}