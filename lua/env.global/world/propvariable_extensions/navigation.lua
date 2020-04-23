hook.Add("prop.variable.load","navigation",function (self,j,tags)  
	local n = j.navigation
    if n then
        local nav = self:AddComponent(CTYPE_NAVIGATION)  

        if(n.navmesh)then
            local world = matrix.Scaling(j.scale or 1)
            if j.rotation then world = world * matrix.Rotation(-JVector(j.rotation)) end
            nav:AddOBJ(n.navmesh,world)
        end
        nav:Generate()
        self.nav = nav
	end 
end)