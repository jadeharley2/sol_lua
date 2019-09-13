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
function PANEL:Refresh()
	self:LoadRecipes(self.category)
end
function PANEL:LoadRecipes(category)
	self.category = category
	self.recipelist:ClearItems()
	local temptagfilter = 'handcraft'
	local temp_all_recipes = crafting.recipes--.GetCraftableItems(temptagfilter)

	if category == nil then 
		local loadedCategories = {}
		for resultid,v in SortedPairs(temp_all_recipes) do  
			local ccat = string.split(resultid,'.')[1]
			if ccat and not loadedCategories[ccat] then 
				loadedCategories[ccat] = true 
				local btn = gui.FromTable({
					type="button",
					dock = DOCK_TOP,
					size = {22,22}, 
					text = ccat, 
					OnClick = function(s) 
						self:LoadRecipes(ccat)
						self.recipelist:ScrollToTop()
					end,
				}) 
				self.recipelist:AddItem(btn)
			end
		end
	else
		local btn = gui.FromTable({
			type="button",
			dock = DOCK_TOP,
			size = {22,22}, 
			text = "<<back", 
			OnClick = function(s) 
				self:LoadRecipes()
				self.recipelist:ScrollToTop()
			end,
		}) 
		self.recipelist:AddItem(btn)
		for resultid,v in SortedPairs(temp_all_recipes) do  
			if string.starts(resultid,category..'.') then
				for recipeid,vv in pairs(v) do
					local context = nil
					for kkk,vvv in pairs(vv.input) do
						local nl = (vvv.count or '1') .. ' ' .. (forms.GetName(vvv.item) or vvv.item)
						if context then
							context = context .. ', ' .. nl
						else
							context = nl
						end
					end
					local outcount = ''
					if vv.output.count and vv.output.count>1 then
						outcount = 'x'..tostring(vv.output.count)
					end
					local btn = gui.FromTable({
						dock = DOCK_TOP,
						size = {42,42},
						color = {0.1,0.1,0.1}, 
						subs = {
							{
								texture = forms.GetIcon(resultid) or "textures/gui/icons/unknown.png",
								color = (forms.GetTint(resultid) or {1,1,1}),
								size = {42,42}, 
								dock = DOCK_LEFT
							},
							{
								size = {20,20},
								dock = DOCK_TOP,
								text = (forms.GetName(resultid) or resultid)..' '..outcount,
								type="button",
								formid = resultid, 
								recipeid = recipeid,
								OnClick = function(s) 
									self:Craft(s)
								end,
							},
							{
								size = {16,16},
								dock = DOCK_TOP,
								text = context,  
								textonly = true,
								contextinfo = context,
								textcolor = {1,1,1}
							}
						}
					}) 
					self.recipelist:AddItem(btn)
				end
			end
		end
	end
	self:UpdateLayout()
end
function PANEL:Craft(s)
	--crafting.CanCraft(formid,storage)
	MsgN(crafting.Craft(s.formid,s.recipeid,LocalPlayer().storage)) 
	hook.Call("inventory_update",LocalPlayer())
end