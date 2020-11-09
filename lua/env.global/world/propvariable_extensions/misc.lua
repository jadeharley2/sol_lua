
hook.Add("prop.variable.load","misc",function (self,j,tags)  
	
	--if tags.item then
	--	self:AddTag(TAG_STOREABLE) 
	--	--self.info = "button"
	--	self._interact = {
	--		pickup={
	--			text="pick up",
	--			action = function (self, user)
	--				self:Press(user)
	--			end
	--		},
	--	} 
	--end
	--if j.viewdistance then
	--	--MsgN("mvd",j.viewdistance)
	--	self.model:SetMaxRenderDistance(j.viewdistance)
	--end
	if j.field then
		if j.field.type=='space' then
			local mul = j.field.strength or 1
			local size = j.field.size or 1
			mul = math.max(0,mul or 1) 
		
			self:SetSizepower(mul)
			self:SetScale(Vector(1,1,1) * (size/mul)) 
			if j.field.isopen then
				self:SetSpaceEnabled(true,2)
			end
			if j.field.phys then
				local physspace = self:RequireComponent(CTYPE_PHYSSPACE)
				local g = j.field.phys.gravity
				self.physspace = physspace
				if g then
					physspace:SetGravity(JVector(g))
				end
			end
		end
	end
	if j.ent_tags then
		for k,v in pairs(j.ent_tags) do
			self:AddTag(v)
		end
	end 

	if j.components then
		for k,v in pairs(j.components) do
			local com = self:RequireComponent(v.type)
			if v.variable then
				self[v.variable] = com
			end
		end
	end
	if j.sizepower then 
		self:SetSizepower(j.sizepower)
	end
end)


hook.Add('item_features','propv.button',function(formid,data,addfeature) 
    if data.variables and data.variables.mountpoints then
        addfeature("mount",{1,1,1},'textures/gui/features/mount.png')  
	end
end) 

hook.Add('item_features','propv.book',function(formid,data,addfeature) 
    if data.lines or data.text then
        addfeature("readable",{1,1,1},'textures/gui/features/readable.png')  
	end
end) 