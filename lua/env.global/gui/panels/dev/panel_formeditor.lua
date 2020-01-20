local style = {
    submenu = {
        states = {
            idle    = {color = {0,0,0},textColor={1,1,1}},
            hover   = {color = {0.3,0.3,0.3}},
            pressed = {color = {1,1,1},textColor={0,0,0}},
        }, 
        stat = "idle",
        color = {0,0,0}, 
        textcolor = {1,1,1},
    }
}
local layout = {
    color = {36/255,22/255,116/255},
    size = {400,300},
    subs = {
        {type="panel",  -- class = "submenu",
            visible = true, 
            size = {400,300},
            color =  {36/255,22/255,116/255},
            dock = DOCK_LEFT, 
            margin = {2,2,2,2},
            subs= { 
                {type="floatcontainer",name = "formtypelist",   
                    margin = {2,2,2,2},
                    visible = true, 
                    size = {200,200}, 
                    dock = DOCK_TOP,
                    color = {0,0,0}, 
                    textonly=true, 
                    Floater = {type="panel",
                        scrollbars = 1,
                        color = {0,0,0}, 
                        size = {200,200}, 
                        autosize={false,true}
                    },
                },  
                { name = "actions",
                    size = {600,300},
                    margin = {2,2,2,2},
                    dock = DOCK_BOTTOM,
                    color = {0,0,0}, 
                },
                {type="floatcontainer",name = "formlist",   
                    margin = {2,2,2,2},
                    visible = true, 
                    size = {600,300}, 
                    dock = DOCK_FILL,
                    color = {0,0,0}, 
                    textonly=true,  
                    Floater = {type="panel",
                        scrollbars = 1,
                        color = {0,0,0}, 
                        size = {200,200}, 
                        autosize={false,true}
                    },
                }, 
            }
        }, 
    }
}
function PANEL:Init()
	local nt = {}
    gui.FromTable(layout,self,{},nt,"menu")

	nt.formtypelist.inner:SetColor(Vector(0,0,0))
    nt.formlist.inner:SetColor(Vector(0,0,0))
     
	self.formlist = nt.formlist 
    self.formtypelist = nt.formtypelist
    self.actions = nt.actions
	self:LoadFormTypeList(nt.formtypelist.floater,nt.formtypelist)
	 
	
	self:UpdateLayout() 
end

function PANEL:LoadFormTypeList(lst,lsf)
	lst:Clear()
	local testlist = forms.GetList()

	for k,v in SortedPairs(testlist,stdcomp) do
		lst:Add(gui.FromTable({ type="button", class = "submenu", 
			size = {16,16},
			
			text = v,
            dock = DOCK_TOP,  
            group = "items",
            toggleable = true,
			OnClick = function(s)
				--local path = forms.GetForm('character',k)
				--self:LoadForm(path) 
				self:LoadFormList(self.formlist.floater,self.formlist,v)
				self:UpdateLayout() 
			end
		},nil,style)) 
	end
end
function PANEL:LoadFormList(lst,lsf,typ)
	lst:Clear()
	local testlist = forms.GetList(typ)

	for k,v in SortedPairs(testlist,stdcomp) do
		lst:Add(gui.FromTable({ type="button",   class = "submenu", 
			size = {16,16}, 
			text = k,
			dock = DOCK_TOP,  
            group = "items",
            toggleable = true,
			OnClick = function(s)
				local path = typ..'.'..k--forms.GetForm(typ,k)
				self:SetForm(path)
				--lsf:SetScroll(0)
			end
		},nil,style)) 
    end
    debug.Delayed(100,function()
        self.formlist:Scroll(-999999)
    end)
	self:UpdateLayout() 
end
function PANEL:SetForm(formid) 
    local p = self.actions
    p:Clear()
    p:Add(gui.FromTable({
        text = forms.GetName(formid),
        textcolor = {1,1,1},
        textonly = true,
        size = {20,20},
        dock = DOCK_TOP
    }))
    p:UpdateLayout()

    local parent = GetCamera():GetParent()
    if EDFORM_LASTENT and IsValidEnt(EDFORM_LASTENT) then
        GetCamera():SetParent(formeditor.space)
        EDFORM_LASTENT:Despawn()
        EDFORM_LASTENT=false
    end
    local f = forms.Spawn(formid,parent)
    if f then
        EDFORM_LASTENT = f
        local szp = f:GetSizepower()
        local sqsq =  math.sqrt(szp)
        global_controller.zoom =sqsq
        global_controller.mode = "restricted"
        global_controller.zoom_div = 10000/sqsq
        global_controller.zoom_max = sqsq*1000
        MsgN("SS",szp)
        --f:SetScale(Vector(1,1,1)*0.1)
    end
end
EDFORM_LASTENT = false