
function PANEL:Init()   
	gui.FromTable({  class = "back",   
        size = {200,300},
        dock = DOCK_BOTTOM,
        subs = {
            --{ name = "header", class = "header_0", 
            --    text = "Asset browser", 
            --},
            {type="tree",name = "classtree",
                size = {200,400},
                dock = DOCK_LEFT,
                TableType = 1,
                sortitems = true
            },
            {type="files",name = "dirtree2",
                size = {500,400},
                dock = DOCK_LEFT,
                OnDisplay = on_dt_display,
                OnItemDoubleClick = on_dt_click,
				OnItemClick = select_form 
            },
            {type="files",name = "dirtree3",
                size = {500,400},
                dock = DOCK_LEFT,
				OnDisplay = on_dt_display2,
				OnItemDoubleClick = on_static_spawn,
				--OnItemClick = select_form 
            }
        }
    },self,global_editor_style,self)
	   
 
	local flist = forms.GetList()
	local classlist = json.Read("forms/_meta/formtypedecl_main.json")
	 
	local table = {}
	for k,v in SortedPairs(classlist.types) do
		local g = v.group or "other"
		local st = table[g] or {}
		table[g] = st 
		st[v.name] = {}
	end
	table.world.staticprop = {}
	self.classtree:FromTable(table)
	self.classtree.OnItemClick = function(s,i,t) 
		PREFIX = t:GetText()
		self.dirtree2:SetFormFS(PREFIX) 
		if PREFIX == 'staticprop' then
			self.dirtree2:SetVisible(false)
			self.dirtree3:SetVisible(true)
		else
			self.dirtree2:SetVisible(true)
			self.dirtree3:SetVisible(false)
		end
		self:UpdateLayout()
	end
	  
	self.dirtree2:SetFormFS("prop")  
	self.dirtree2:SetVisible(true)
	self.dirtree3:SetVisible(false)

	--self.pnode:UpdateLayout()
 	--self.pterr:UpdateLayout()

	self:UpdateLayout()
	self.classtree:ScrollToTop()
end 

