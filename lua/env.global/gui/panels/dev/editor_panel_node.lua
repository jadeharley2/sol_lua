
local layout = {
	color = {0,0,0},
	size = {200,200},
	subs = {
		{ name = "header",
			size = {100,20},
			dock = DOCK_TOP,
			textalignment = ALIGN_CENTER,
			text = "World outliner",
			color = {0.3,0.6,0.9},
			subs = {
				{type='button', name = "refcom",
					size = {20,20},
					dock = DOCK_RIGHT,
					ColorAuto = Vector(0,0.2,0.3),
					texture = "textures/gui/panel_icons/refresh.png",
				}
			}
		},
		{ name = "header",
			size = {100,16},
			dock = DOCK_TOP,
			textalignment = ALIGN_CENTER,
			text = "Hierarchy",
			color = {0.3,0.9,0.7}, 
		},
		{ type = "list",name = "hierarchy",
			size = {200,200},
			dock = DOCK_TOP,
			itemheight = 16
		},
		{ name = "header",
			size = {100,16},
			dock = DOCK_TOP,
			textalignment = ALIGN_CENTER,
			text = "Nodes",
			color = {0.3,0.9,0.7}, 
		},
		{ name = "action_panel",
			size = {200,200},
			dock = DOCK_BOTTOM,  
			color = {0,0,0}, 
			subs = {
				{type='button', name = "bnodeadd",
					size = {20,20},
					dock = DOCK_TOP,
					ColorAuto = Vector(0,0.2,0.3)*2,
					text = "AddNode"
				}
			}
		},
		{ name = "header",
			size = {100,16},
			dock = DOCK_BOTTOM,
			textalignment = ALIGN_CENTER,
			text = "Actions",
			color = {0.3,0.9,0.7}, 
		},
		{ type = "tree",name = "nodetree",
			dock = DOCK_FILL,
			itemheight = 16
		},
	}
} 

function PANEL:Init() 
	gui.FromTable(layout,self,{},self) 
	self.refcom.OnClick = function() self:UpdateCnodes() end  
	self:UpdateCnodes() 
	self:UpdateHierarchy() 
end 
function PANEL:SelectNode(node) 
	self:UpdateCnodes(node) 
	self:UpdateHierarchy(node) 
end

function PANEL:UpdateHierarchy(cnode)
	local cnode = cnode or GetCamera() --TEMP
	self.hierarchy:ClearItems()
	for k,v in pairs(cnode:GetHierarchy()) do
		self.hierarchy:AddItem(gui.FromTable({
			type = "button",
			size = {16,16},
			text = tostring(v),
			OnClick = function() 
				worldeditor:Select(v)
			end
		}))
	end
	self:UpdateLayout()
	self.hierarchy:ScrollToTop()
end
function PANEL:UpdateCnodes(root) 
	local nodetree = self.nodetree
	local rtb = {"types"}
	
	root = root or GetCamera():GetParent()
	local chp = root:GetChildren()
	  
	local tb2 = {"<<parent>>",OnClick=function(b) 
		local ct = CurTime()
		if b.lastclc and b.lastclc>(ct-0.5) then
			if root:GetParent() then
				self:UpdateCnodes(root:GetParent())
			end
		else
			b.lastclc = ct 
			worldeditor:Select(root)
		end
	end}  
	rtb[#rtb+1] = tb2

	for k,v in SortedPairs(chp) do 
		if v then
			local hide = (v.editor and v.editor.hide) or v:HasTag(320230)
			if not hide then
				local onclick = function(b) 
					local ct = CurTime()
					if b.lastclc and b.lastclc>(ct-0.5) then
						self:UpdateCnodes(v)
					else
						b.lastclc = ct 
						worldeditor:Select(v)
					end
				end 
				local cc = '['..#v:GetChildren()..'] '

				local tb2 = {cc..tostring(v),OnClick=onclick}  
				rtb[#rtb+1] = tb2
			end
		end
	end
	nodetree:SetTableType(2)
	
	nodetree:FromTable(rtb)
	nodetree:SetSize(430,400) 
	self:UpdateLayout()
	nodetree:ScrollToTop()
end
