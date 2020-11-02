global_marker_list = global_marker_list or {}

function ENT:Init()   
    self.model = self:RequireComponent(CTYPE_MODEL) 
    self:AddTag(TAG_EDITOR_NODE)
end 
function ENT:Spawn() 
	local m = self:GetParameter(VARTYPE_MODEL) or "models/editor/marker_res.stmd"
    local modelscale = self:GetParameter(VARTYPE_MODELSCALE) or 1
    
	self:SetModel(m,modelscale)
 
    self.marker_type = "res"
    --global_marker_list[self] = true
end
--function ENT:Despawn()
--    global_marker_list[self] = nil 
--end

function ENT:SetModel(mdl,scale) 
	scale = scale or 1
	local model = self.model
	local world = matrix.Scaling(scale)* matrix.Rotation(-90,0,0)
	  
	self:SetParameter(VARTYPE_MODEL,mdl)
	self:SetParameter(VARTYPE_MODELSCALE,scale)
	
	model:SetRenderGroup(RENDERGROUP_LOCAL)
	model:SetModel(mdl)   
	model:SetBlendMode(BLEND_OPAQUE) 
	model:SetRasterizerMode(RASTER_DETPHSOLID) 
	model:SetDepthStencillMode(DEPTH_ENABLED)  
	model:SetBrightness(1)
	model:SetFadeBounds(0,9e20,0)  
	model:SetMatrix(world)
	  
end 

--hook.Add("editor.world.open", "marker_show", function()
--    for k,v in pairs(global_marker_list) do
--        if IsValidEnt(k) then
--            k.model:Enable(true)
--        end
--    end
--end)
--hook.Add("editor.world.close", "marker_hide", function()
--    for k,v in pairs(global_marker_list) do
--        if IsValidEnt(k) then
--            k.model:Enable(false)
--        end
--    end
--end)


hook.Add("editor.world.open", "marker_show", function()
    render.GlobalRenderParameters():RemoveTag(TAG_EDITOR_NODE)
end)
hook.Add("editor.world.close", "marker_hide", function()
    render.GlobalRenderParameters():AddTag(TAG_EDITOR_NODE)
end)