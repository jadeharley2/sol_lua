
 

local layout = {
    color = {0,0,0},
    size = {200,200},
    subs = {
		--{ name = "header",  class = "header_0",  
		--	text = "Node materials", 
		--},
		{ name = "nodename",
			size = {100,16},
			dock = DOCK_TOP,
			--textalignment = ALIGN_CENTER,
			text = "",
			color = {0.1,0.1,0.1}, 
			textcolor = {1,1,1}
		}, 
		{type="list", name = "matcontainer", class = "back",  
			size = {200,200},
            dock = DOCK_FILL, 
        }
    }   
}

function PANEL:Init()  

	gui.FromTable(layout,self,global_editor_style,self) 
	
	hook.Add("editor_select","node_mats",function(node)
		self:SelectNode(node)
	end)
	hook.Add("editor_deselect","node_mats",function()
		self:SelectNode(nil)
	end)
end 
 
function PANEL:RefreshPanel() 
	if self.cnode then
		self:SelectNode(self.cnode)
	end  
end
local textsize = 24
local style = {
	btitle = { type = "button",
		dock=DOCK_RIGHT,
		size = {20,textsize},
		margin = {1,1,1,1},
		textcolor = {1,0.3,0.3},
		ColorAuto = Vector(0,0,0),
		textalignment = ALIGN_CENTER,
	},
	bgroup = { type="group",  
		dock=DOCK_TOP,
		_sub_header = {
			color = {0,0,0},
			size = {20,textsize},
			textcolor = {0.3,0.9,0.7}
		} 
	},
	cgroup = { type="group",  
		dock=DOCK_TOP,
		_sub_header = {
			color = {0.2,0.1,0},
			textcolor = {0.9,0.6,0.3},
			size = {20,textsize},
			textalignment = ALIGN_LEFT
		} 
	}
}

function PANEL:SelectNode(node) 
	self.cnode = node
	
	self.nodename:SetText(tostring(node))
	local peditor = self.matcontainer--self.peditor
	peditor:ClearItems()
	
	
	
	if node then
	 
		local model = node:GetComponent(CTYPE_MODEL)
		if model then
			local mats = model:GetMaterials()
			local mc = self.matcontainer

			for k,v in pairs(mats) do
				local grp = gui.FromTable({ class = "bgroup",
					size = {40,40},
					dock = DOCK_TOP,
					Title = file.GetFileNameWE(v),
					contextinfo = v
				},nil,style)
				peditor:AddItem(grp)
				local con = grp.contents
				
				local props = GetMaterialProperties(v) 
				if props then 
					for k,v in SortedPairs(props) do
						con:Add(gui.FromTable({  
							dock=DOCK_TOP,
							size = {20,16},
							margin = {1,1,1,1}, 
							text = k
						},nil,style))
						con:Add(gui.FromTable({  
							dock=DOCK_TOP,
							size = {20,16},
							margin = {1,1,1,1},
							color = {0.7,0.7,0.7}, 
							text = tostring(v),
							textalignment = ALIGN_RIGHT
						},nil,style))
					end
				end
			end

		end
		self:UpdateLayout()
		peditor:ScrollToTop()
	end
end
 
 
