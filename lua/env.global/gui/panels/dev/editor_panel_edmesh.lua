 
local layout = {
    color = {0,0,0},
    size = {200,200},
    subs = {
		{ name = "header", class = "header_0", 
			text = "Mesh editor", 
		},
		{ name = "oplist", class = "back",
			size = {100,40},
            dock = DOCK_TOP, 
            autosize = {false,true}
		},  
		{ class = "header_0", 
            text = "Layers", 
            subs = {
                {type="button", name = "blayeradd",
                    texture = "textures/gui/panel_icons/new.png",
                    contextinfo = "Add layer",
                    size = {20,20},
                    dock = DOCK_RIGHT,
                    ColorAuto =Vector(0,0.5,0)
                },
                {type="button", name = "brefresh",
                    texture = "textures/gui/panel_icons/refresh.png",
                    contextinfo = "Refresh",
                    size = {20,20},
                    dock = DOCK_RIGHT,
                    ColorAuto =Vector(0,0.5,0)
                }
            }
		},
        { type="list", name = "layerlist", class = "back",
            dock = DOCK_TOP, 
			size = {100,200},
		},
		{ class = "header_0", 
			dock = DOCK_TOP, 
			text = "Post process operations",
            subs = {
                {type="button", name = "bpopadd",
                    texture = "textures/gui/panel_icons/new.png",
                    contextinfo = "Add modifier",
                    size = {20,20},
                    dock = DOCK_RIGHT,
                    ColorAuto =Vector(0,0.5,0)
                } ,
                {type="button", name = "bpoprefresh",
                    texture = "textures/gui/panel_icons/refresh.png",
                    contextinfo = "Refresh",
                    size = {20,20},
                    dock = DOCK_RIGHT,
                    ColorAuto =Vector(0,0.5,0)
                }
            }
        },
        { type="list", name = "postlist", class = "back",
            dock = DOCK_TOP, 
			size = {100,200}
		},
		{ class = "header_0", 
			dock = DOCK_TOP, 
			text = "Operation parameters", 
        },
        {
			size = {100,40},
			dock = DOCK_TOP, 
            color = {0.5,0.5,0.5}, 
            subs = {
                {  class = "bmenu_op", name = "bfrotcc",
                    text = "<=", 
                    contextinfo = "Rotate face counterclockwise"
                },
                { name = "bfrotdi",
                    size = {40,20},
                    text = "0",
                    dock = DOCK_LEFT, 
                    margin = {2,2,2,2},
                    contextinfo = "Current face rotation"
                },
                {  class = "bmenu_op", name = "bfrotcl", 
                    text = "=>", 
                    contextinfo = "Rotate face clockwise"
                },
                {  class = "bmenu_op",name = "bfsall", 
                    text = "<>", 
                    contextinfo = "Select object"
                },
                {  class = "bmenu_op",name = "bundo", 
                    text = "<<", 
                    contextinfo = "Undo last operation"
                },
                { class = "bmenu_op", name = "bredo", 
                    text = ">>", 
                    contextinfo = "Redo last operation"
                },
                { class = "bmenu_op", name = "bkeep", 
                    text = "||", 
                    toggleable = true,
                    contextinfo = "Keep source faces"
                }
            }  
        },
		{ type="list", name = "paramlist", class = "back",
			dock = DOCK_FILL,  
			size = {100,200},  
            items = {
                { type = "property_grid", name = "params",
                    dock = DOCK_TOP,
                    --Object = static.curop,
                }
            }
		},
    }   
}
local static = PANEL.static or {}
PANEL.static = static
static.optypes = static.optypes or {}
function MEAddOPType(name,table)
    static.optypes[name] = table
end

function PANEL:Init()  
    static.panel = self
    gui.FromTable(layout,self,global_editor_style,self)  
    self:UpdateLayout()
    self.mode = false 
 
    
    self.blayeradd.OnClick = function(s)
        self:AddLayer()
        self:RefreshLayers()
    end
    self.brefresh.OnClick = function(s)
        self:RefreshLayers()
    end
    
    self.params.OnUpdate = function () 
        local c = static.curedit.model
        if static.cur_pop then 
            c:SetPostOperation(static.cur_pid, static.cur_poptype , json.ToJson( static.cur_pop ))
            c:BuildModel()
        elseif static.curop then
            c:Cancel()
            c:Operate(static.coptype,json.ToJson(static.curop))
        end
    end

    self.bfrotcl.OnClick = function(s)
        local crot = static.curop._face_rotate or 0
        static.curop._face_rotate = crot - 1
        local c = static.curedit.model
        c:Cancel()
        c:Operate(static.coptype,json.ToJson(static.curop))
        self.bfrotdi:SetText(tostring(crot - 1))
    end
    self.bfrotcc.OnClick = function(s)
        local crot = static.curop._face_rotate or 0
        static.curop._face_rotate = crot + 1
        local c = static.curedit.model
        c:Cancel()
        c:Operate(static.coptype,json.ToJson(static.curop))
        self.bfrotdi:SetText(tostring(crot + 1))
    end
    self.bfsall.OnClick =function(s)
        local c = static.curedit.model
        c:SelectObject()  
    end

    self.bundo.OnClick =function(s)
        local c = static.curedit.model
        c:Undo()  
    end
    self.bredo.OnClick =function(s)
        local c = static.curedit.model
        c:Redo()  
    end

    self.bpopadd.OnClick = function (s)
        self:AddPostOp()
    end
    self.bpoprefresh.OnClick = function(s)
        self:RefreshPostOps()
    end

    self:PopulateOperations()
    self:RefreshLayers()
end  
function PANEL:AddLayer()
    local c = GetCamera()
    local p = c:GetParent()
    local trace = GetCameraPhysTrace(c)
    if trace and trace.Hit then
        local pos = trace.Position
        local x = SpawnPE(p,pos) 
        if x then
            x:SetName(table.Random({"a","b","c","d","e","f","g","x","y","z","t"}))
            --worldeditor.Select(x)
        end
    else
        local x = SpawnPE(p,Vector(0,0,0)) 
        x:SetName(table.Random({"a","b","c","d","e","f","g","x","y","z","t"}))
    end
end 
function PANEL:RefreshLayers()
    local c = GetCamera()
    local p = c:GetParent()
    local l = self.layerlist
    l:ClearItems()
    for k,v in pairs(p:GetChildren()) do
        if v:GetClass()=='prop_editable' then
            l:AddItem(gui.FromTable({
                type="button",
                size = {32,32},
                text = v:GetName(),
                dock = DOCK_TOP,
                ent = v,
                group = "f",
                toggleable = true,
                OnClick = function (s)
                    self:SelectMesh(s.ent)
                end,
                subs = {
                    {type="button",
                        texture = "textures/gui/panel_icons/delete.png",
                        contextinfo = "Delete layer",
                        size = {32,32},
                        dock = DOCK_RIGHT,
                        ColorAuto =Vector(1,0,0),
                        OnClick = function (s)
                            s:GetParent().ent:Despawn()
                            self:RefreshLayers()
                        end
                    },
                    {type="button",
                        texture = "textures/gui/panel_icons/save.png",
                        contextinfo = "Save layer",
                        size = {32,32},
                        dock = DOCK_RIGHT,
                        ColorAuto =Vector(0,1,1),
                        OnClick = function (s)
                            local e = s:GetParent().ent
                            SaveFileDialog("models/dynmesh", ".json",function(path) 
                                e.model:Save(path)
                                MsgInfo("Saved!")
                            end) 
                        end
                    }, 
                    {type="button",
                        texture = "textures/gui/panel_icons/load.png",
                        contextinfo = "Load layer",
                        size = {32,32},
                        dock = DOCK_RIGHT,
                        ColorAuto =Vector(0,1,1),
                        OnClick = function (s) 
                            local e = s:GetParent().ent
                            OpenFileDialog("models/dynmesh", ".json",function(path)  
                                e:SetModelPath(path)
                            end) 
                        end
                    }
                }
            }))
        end
    end
end
function PANEL:SetMode(mode)
    static.cur_pop = false
    static.enabledposupdate = false
    static.mode = mode
    local opt = static.optypes[mode]
    static.curopt = opt
    if opt then 
        if opt.place then
            static.enabledposupdate = true
            self:InitOp(mode)
        end
    end
    for k,v in pairs(self.boplist)do 
        if v.mode~=mode then
            v:SetState("idle")
        end
    end
end
function PANEL:AddPostOp()
    local c = static.curedit.model
    if c and static.mode then
        local pop = { }
        local opt = static.optypes[static.mode]
        if opt then 
            for k,v in pairs(opt.params) do
                if(v.default~=nil) then
                    pop[k] = v.default
                end
            end
            c:SetPostOperation((self.maxpostid or 0) + 1,static.mode,json.ToJson(pop))
            self:RefreshPostOps()
            c:BuildModel()
        end
    end
end
function PANEL:SwapPostOps(id1,id2)
    local c = static.curedit.model
    if c then
        local data1 = c:GetPostOperation(id1)
        local data2 = c:GetPostOperation(id2) 
        if data1 and data2 then
            local t1 = data1:Read('type')
            local t2 = data2:Read('type')
            if t1 and t2 then
                c:SetPostOperation(id1,t2,data2)
                c:SetPostOperation(id2,t1,data1)
                c:BuildModel()
            end
        end
    end
end
function PANEL:RefreshPostOps()
    local c = static.curedit.model
    local ops = self.postlist
    ops:ClearItems() 
    local maxid = 0
    for k,ID in pairs(c:GetPostOpIndices()) do 
        maxid = math.max(ID,maxid)

        local data = json.FromJson(c:GetPostOperation(ID))

        local optype = data.type or "unknown"

        ops:AddItem(gui.FromTable({
            type="button",
            size = {32,32},
            text = tostring(ID).." op ",
            dock = DOCK_TOP,
            index = ID,
            group = "f",
            toggleable = true,
            OnClick = function (s)
                --self:SelectMesh(s.ent)
                static.cur_pid = s.index
                static.cur_pop = data
                static.cur_poptype = optype
                self.params:SetObject(static.cur_pop)
            end,
            subs = {
                {type="button",
                    texture = "textures/gui/panel_icons/delete.png",
                    contextinfo = "Delete op",
                    size = {32,32},
                    dock = DOCK_RIGHT,
                    ColorAuto =Vector(1,0,0),
                    OnClick = function (s)
                        c:RemovePostOperation(s:GetParent().index)
                        c:BuildModel()
                        self:RefreshPostOps()
                    end
                },
                {
                    textonly = true,
                    size = {16,32},
                    dock = DOCK_RIGHT,
                    subs = { 
                        {type="button",
                            texture = "textures/gui/panel_icons/play.png",
                            rotation = 90,
                            contextinfo = "Raise",
                            size = {16,16},
                            dock = DOCK_TOP,
                            ColorAuto =Vector(0,0,1),
                            OnClick = function (s) 
                                local cid = s:GetParent():GetParent().index
                                self:SwapPostOps(cid,cid-1)
                                self:RefreshPostOps()
                            end
                        },
                        {type="button",
                            texture = "textures/gui/panel_icons/play.png",
                            rotation = -90,
                            contextinfo = "Lower",
                            size = {16,16},
                            dock = DOCK_FILL,
                            ColorAuto =Vector(0,0,1),
                            OnClick = function (s) 
                                local cid = s:GetParent():GetParent().index
                                self:SwapPostOps(cid,cid+1)
                                self:RefreshPostOps()
                            end
                        },
                    }
                }, 
                { 
                    size = {40,40},
                    dock = DOCK_RIGHT,
                    texture = static.optypes[optype].icon,
                    contextinfo = optype,
                }
            }
        }))
    end 
    self.maxpostid = maxid
end

function PANEL:AppendRow(parent)
    local row = gui.FromTable({ 
        size = {40,40},
        textonly = true,
        dock = DOCK_TOP
    })
    parent:Add(row)
    return row
end
function PANEL:PopulateOperations()
    local ops = self.oplist
    ops:Clear()
    local set_mode = function(s)
        self:SetMode(s.mode)
    end 
    local cop = static.mode
    local toc = 1
    local row = self:AppendRow(ops)
    local oplist = {}
    local opx = gui.FromTable({ class = "bmenutoggle", texture = "textures/gui/panel_icons/cancel.png", name = "bt_none",
        contextinfo='None',
        group = 'op', mode = false,
        OnClick = set_mode 
    },nil,global_editor_style)
    oplist[#oplist+1] = opx
    row:Add(opx);
    for k,v in pairs(static.optypes) do
        local opx = gui.FromTable({ class = "bmenutoggle", texture = v.icon, name = "bt_none",
            contextinfo=v.name,
            group = 'op', mode = k,
            OnClick = set_mode,
        },nil,global_editor_style)
        oplist[#oplist+1] = opx
        row:Add(opx);
        toc = toc + 1
        if toc>6 then
            row = self:AppendRow(ops)
            toc = 0
        end
    end
    for k,v in pairs(oplist)do
        if v.mode==cop then
            v:SetState("pressed")
        end
    end
    self.boplist = oplist
    ops:UpdateLayout()
end
function PANEL:SelectMesh(ent)
	static.curedit = ent
    self:RefreshPostOps()
end
function PANEL:InitOp(mode) 
    local opt = static.optypes[mode]
    if opt and static.coptype ~= mode  then
        --MsgN("INIT1")
        static.coptype = mode 
        static.curop = { }
        for k,v in pairs(opt.params) do
            if(v.default~=nil) then
                static.curop[k] = v.default
            end
        end
        
        self.params:SetObject(static.curop)
    end
end
function PANEL:UpdateOp(updatemode) 
    if static.mode then
        local opt = static.optypes[static.mode]
        if opt and static.curop then
            local cam = GetCamera()
             
            if updatemode then
                local tr = GetMousePhysTrace(cam)
                opt.place(static.curedit.model,cam,tr,static.curop)
            elseif opt.operate then
                local mpos =  (ViewportGetMousePos()+Vector(0,0,0.1))
                local wdir = cam:Unproject(mpos):Normalized()
                opt.operate(static.curedit.model,cam,wdir,static.curop)
            end
            self:UpdateParams()
        end
    end
end  
function PANEL:UpdateParams()
    
    self.params:UpdateValues()
    self.bfrotdi:SetText(tostring(static.curop._face_rotate or 0))
end
     
function PANEL:Apply()

    if static.coptype then
        local c = static.curedit.model
        
        c:Apply()

        -- save parameters
        for k,v in pairs(static.curop) do
            --MsgN("set def",k,v)
            local vartab = static.curopt.params[k]
            if vartab then vartab.default = v end
        end
        static.optypes[static.coptype] = static.curopt
        --PrintTable( static.curopt,3)


        static.coptype = nil 
        static.curop = {}
    end
end

hook.Add("input.mousedown","testaselect",function() 
	if not static.curedit then return  end
	local c = static.curedit.model
    --MsgN(c,"C")
    
    local mouseavailable = ( not input.MouseIsHoveringAboveGui()  or panel.GetTopElement().isviewport)


	if c and input.leftMouseButton() and mouseavailable then
		local cam = GetCamera()

        local mpos =  (ViewportGetMousePos()+Vector(0,0,0.1))
        local wdir = cam:Unproject(mpos):Normalized()
 
        local dragtimer = 0
        if static.curopt and static.curopt.operate then
            hook.Add(EVENT_GLOBAL_PREDRAW, "edmesh.drag", function()
                dragtimer = dragtimer + 1
                
                if(not input.leftMouseButton()) then 
                    hook.Remove(EVENT_GLOBAL_PREDRAW,"edmesh.drag")  
                end
                
                local mpos2 =  (ViewportGetMousePos()+Vector(0,0,0.1))
                if(static.mode and dragtimer>2 and (mpos:Distance(mpos2)>0.01)) then 
                    if not static.enabledposupdate then
                        static.panel:InitOp(static.mode)
                    else
                        static.enabledposupdate = false
                    end
                    c:StartVNPDrag(cam,wdir) 
                    hook.Remove(EVENT_GLOBAL_PREDRAW,"edmesh.drag")  
                    static.enabledragupdate = true
                end
            end)   
        end
        c:Cancel() 
        c:SelectFace(cam,wdir,input.KeyPressed(KEYS_SHIFTKEY))  
        if static.curopt then
            c:Operate(static.coptype,json.ToJson(static.curop))
            
            if static.curopt.applyonclick then
                static.panel:InitOp(static.mode)
                static.panel:UpdateOp()   
                c:Cancel() 
                c:Operate(static.coptype,json.ToJson(static.curop))
            end
        end
	end 

end)
hook.Add("input.mouseup","testaselect",function()
	if not static.curedit then return  end
	local c = static.curedit.model
	if c then 
		rmode = false
    end
    static.enabledragupdate = false 
end)
hook.Add("input.keydown","testaselcet",function(key)
	if not static.curedit then return  end
	local c = static.curedit.model
	if c then
        if key == KEYS_ENTER then
            
            static.panel:Apply()
        elseif key == KEYS_X then 
		end
	end
end)
hook.Add(EVENT_GLOBAL_UPDATE,"testaselcet",function()
	if not static.curedit then return  end
	local c = static.curedit.model
    if c and static.curop  then 
        if static.enabledposupdate then 
            static.panel:UpdateOp(true)  
            c:Cancel()
            c:Operate(static.coptype,json.ToJson(static.curop))
        end

        if static.enabledragupdate then
            static.panel:UpdateOp() 
            c:Cancel()
            c:Operate(static.coptype,json.ToJson(static.curop))
        end
	end
end)
 