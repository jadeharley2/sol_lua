 

function ENT:Init()   
	local volume = self:AddComponent(CTYPE_VOLUME) 
	volume:SetRenderGroup(RENDERGROUP_DEEPSPACE) 
	--volume:SetBlendMode(BLEND_ADD)--BLEND_ADD 
	--volume:SetRasterizerMode(RASTER_NODETPHSOLID) 
	--volume:SetDepthStencillMode(DEPTH_DISABLED)  
	--self:SetSpaceEnabled(false)
end
 