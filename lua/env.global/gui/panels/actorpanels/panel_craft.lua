local layout = {
	color = {0,0,0},
	subs = {
		{ type = "list", name = "recipelist",
			color = {0,0,0},
			dock = DOCK_FILL
		}
	}
}
function PANEL:Init() 
	gui.FromTable(layout,self,{},self) 


	self:LoadRecipes()
end  
function PANEL:LoadRecipes()
	local temptagfilter = 'handcraft'
	local temp_all_recipes = crafting.GetCraftableItems(temptagfilter)
	for k,v in pairs(temp_all_recipes) do 
		local btn = gui.FromTable({
			type="button",
			text = v,
			dock = DOCK_TOP,
			size = {32,32},
			formid = v,
			OnClick = function(s) 
				self:Craft(s)
			end
		}) 
		self.recipelist:AddItem(btn)
	end
	self:UpdateLayout()
end
function PANEL:Craft(s)
	--crafting.CanCraft(formid,storage)
	MsgN(crafting.Craft(s.formid,nil,LocalPlayer().storage)) 
end