
function ENT:Init()    
	self:SetSpaceEnabled(true,1)
end


function ENT:PreLoadData(isLoad)  
	local data = self.data
	if not data then
		local type = self:GetParameter(VARTYPE_FORM)  
		if type then
			data = forms.ReadForm(type)
			self.data = data
		end
		if data then
			local modtable = self.modtable
			if modtable then table.Merge(modtable,data,true) end
	
			self[VARTYPE_RADIUS] = data.radius 
            self[VARTYPE_MASS] = data.mass 
            self[VARTYPE_COLOR] = JVector(data.color,Vector(1,1,1))
	
					 
			if isstring(data.name) then
				self:SetName(data.name)
			end
		end	
	end   
end