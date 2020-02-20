
hook.Add("prop.variable.load","misc",function (self,j,tags)  
	if tags.item then
		self:AddTag(TAG_STOREABLE) 
	end
	if j.viewdistance then
		--MsgN("mvd",j.viewdistance)
		self.model:SetMaxRenderDistance(j.viewdistance)
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