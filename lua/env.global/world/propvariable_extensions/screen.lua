
hook.Add("prop.variable.load","screen",function (self,j,tags)  
	 
    if j.screen then
        local rmodel = self.model 
        if rmodel then
            local matname = j.screen.material
            local modmaterial = j.screen.modmaterial or {}
            local size = j.screen.size or {256,256}
            local root =  j.screen.root or {size = size, text = "TEXT"}
            local intrf = self:RequireComponent(CTYPE_INTERFACE)
            local panels = gui.FromTable(root)
            panels:UpdateLayout()
            intrf:SetRoot(panels)
            local rt =  CreateRenderTarget(size[1],size[2],"")
            self.rt =rt
            modmaterial.g_MeshTexture_e =rt
            intrf:SetRenderTarget(0,rt )

            ModModelMaterials(rmodel,modmaterial,false) 
            intrf:RequestDraw()
            if j.screen.update_rate == 'frametime' then
                local pt = CurTime()
                self:Hook(EVENT_GLOBAL_PREDRAW,"screen",function()
                    local ct = CurTime()
                    panels:UpdateAnimations(ct-pt)
                    panels:UpdateLayout()
                    intrf:RequestDraw()
                    pt = ct
                end)
            end
        end
	end
end)
 