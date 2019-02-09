
function SpawnDynroad(ent,seed) 

	local e = ents.Create("dyn_road")
	e:SetSeed(seed) 
	e:SetParent(ent)  
	e:Spawn()  
	return e 
end

 

function ENT:Init()   
	local model = self:AddComponent(CTYPE_MODEL)  
    self.model = model 
    self:SetSizepower(1)
    self:SetSpaceEnabled(false) 
    
    local s = self
    self:Hook("editor.world.open","update",function() 
        s:SetUpdating(true,300) 
    end)
    self:Hook("editor.world.close","update",function() 
        s:SetUpdating(false) 
    end)
end 
function ENT:Spawn()   
    self:LoadModelData()
    self:UpdateModel(true)   
end 
function ENT:Load()
    self:LoadModelData()
    self:UpdateModel(true)   
end
function ENT:LoadModelData()
    local mdata = self:GetParameter(VARTYPE_MODELDATA,nil)
    if mdata then
        mdata = json.FromJson(mdata)
        if mdata.points then
            local slp = {}
            for k,v in pairs(mdata.points) do
                slp[k] = Vector(v[1],v[2],v[3])
            end
            self.points =slp
        end
    end
end
function ENT:Despawn()  
	self:DDFreeAll() 
end
function ENT:Think()
    self:UpdateModel()    
end
	 
function ENT:UpdateModel(forced) 
     
    --MsgN("updtest?")
    local pts = {{0,0,0}} 
    --for k,v in pairs(self.nodes or {}) do
    --    if v then
    --        pts[#pts+1] = VectorJ(self:GetLocalCoordinates(v))
    --    end
    --end 
    local oldhash = self.pthash
    local newhash = 0
    local ct = self.net

    if ct then
        local points = {} 
        local points_save = {} 
        for k=1, 100 do 
            if ct then 
                local apos = ct:GetPos()
                local pos = self:GetLocalCoordinates(ct)
                local cc = VectorJ(pos)
                pts[#pts+1] = cc
                points[#points+1] = apos
                points_save[#points_save+1] = VectorJ(apos)
                newhash=newhash+cc[1]+cc[2]+cc[3] 
            else break end
            ct = ct.next
        end
        self.points = points
        self:SetParameter(VARTYPE_MODELDATA,json.ToJson({points = points_save, loop = (self.pathloop or false)}))
    else
        if not oldhash or forced then
            if not self.points then return false 
            else
                MsgN("getrf")
                local parp = self:GetLocalSpace(self:GetParent())
                for k,v in pairs(self.points) do
                    local cc = VectorJ( v:TransformC(parp))
                    pts[#pts+1] =  cc
                    newhash=newhash+cc[1]+cc[2]+cc[3]
                end
            end
        else
            return false
        end
    end

    if oldhash~=newhash or forced then
        local model = self.model
        local modelpath = self:GetParameter(VARTYPE_MODEL) or "forms/levels/hvil/fence.dnmd"
        local modelkey = "base"
        if self.data then
            modelkey = self.data.modelkey or modelkey
        end
        local world = matrix.Scaling(1)  
        MsgN("refr")
        local jm = {operations={ 
                {type="line", out = "base",
                    points = pts,
                    loop = (self.pathloop or false)
                },
                {type="structure", out = "rez",
                    path =  modelpath,--"models/dyntest/test_roadgen.dnmd",
                    from = { [modelkey] = "base"},
                    world = { ang = {-90,0,0},sca={1,1,1}},
                }
            },
            matpath = {"textures/tile/mat/","textures/debug/","models/dyntest/mat"}
        }
        
    -- PrintTable(jm)

        local bld = procedural.Builder()
        bld:BuildModel("@tempname",json.ToJson(jm),"") --+tostring(self:GetSeed())

        
        
        model:SetRenderGroup(RENDERGROUP_LOCAL)
        model:SetModel("@tempname")   
        model:SetBlendMode(BLEND_OPAQUE) 
        model:SetRasterizerMode(RASTER_DETPHSOLID) 
        model:SetDepthStencillMode(DEPTH_ENABLED)  
        model:SetBrightness(1)
        model:SetFadeBounds(0,9e20,0)  
        model:SetMatrix(world)
        
        
        self.pthash = newhash
    end
end  

hook.Add("EditorNodeCopy","dynroad",function(old,new)
    if old and old.rnod then 
        new.prev = old.prev
        new.next = old

        local pre = old.prev
        if pre then
            pre.next = new
        end

        old.prev = new 

    end

end)

 

ENT.editor = {
	name = "Dynamic road",
	properties = {
        editMode = {text = "toggle Edit Mode",type="action",action = function(ent)  
            local spo = ent:GetPos()
            local spp = ent:GetParent()
            
            if ent.net then
                local ee = ent.net
                while ee do
                    local next = ee.next
                    ee:Despawn()
                    ee = next 
                end
                ent.net = nil
            else
                if ent.points then
                    local daf = false
                    local fd = false
                    for k,v in pairs(ent.points ) do
                        local ee = SpawnSO("primitives/sphere.stmd",spp,v,0.8)
                        ee.rnod = true
                        if daf then daf.next = ee ee.prev = daf end
                        if not fd then fd = ee end
                        daf = ee
                    end 
                    ent.net = fd
                end
            end 
        end},
        closePath = {text = "toggle path loop",type="action",action = function(ent)  
            ent.pathloop = not (ent.pathloop or false)
            ent:UpdateModel(true)   
        end},
	},  
	onSpawn =  function(ent) --in editor spawn
        local spo = ent:GetPos()
        local spp = ent:GetParent()
        local daf = false
        --local fd = false
        local pts = {}
        for k=1,2 do 
            pts[k+1] = spo+Vector(k*0.01,0,0)
            --local ee = SpawnSO("primitives/sphere.stmd",spp,spo+Vector(k*0.01,0,0),0.8)
           -- ee.rnod = true
           -- if daf then daf.next = ee ee.prev = daf end
           -- if not fd then fd = ee end
            --daf = ee
        end
        --ent.net = fd
        ent.points = pts
        ent:UpdateModel()   
        ent:SetUpdating(true,300) 
    end--,
    --onUpdate = function(ent)  
    --    ent:UpdateModel()   
    --end
}