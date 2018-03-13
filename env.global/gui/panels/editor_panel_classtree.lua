



function PANEL:Init() 
	self:SetColor(Vector(0,0,0))
	self:SetSize(600,600) 
	
	
	local infopanel = panel.Create()
	infopanel:SetColor(Vector(0,0,0))
	infopanel:SetTextColor(Vector(1,1,1))
	infopanel:SetSize(600,300)
	infopanel:Dock(DOCK_BOTTOM)
	self:Add(infopanel)
	local infopanel_header = panel.Create()
	infopanel_header:SetColor(Vector(0.1,0.1,0.1))
	infopanel_header:SetTextColor(Vector(1,1,1))
	infopanel_header:SetText("Header")
	infopanel_header:SetSize(600,20) 
	infopanel_header:Dock(DOCK_TOP)
	infopanel:Add(infopanel_header)
	local infopanel_text = panel.Create()
	infopanel_text:SetColor(Vector(0,0,0))
	infopanel_text:SetTextColor(Vector(0.8,0.8,0.8))
	infopanel_text:SetSize(600,20) 
	infopanel_text:Dock(DOCK_FILL)
	infopanel:Add(infopanel_text)
	
	
	
	local dirtree = panel.Create("tree")
	dirtree:SetSize(600,600)
	dirtree:Dock(DOCK_FILL)
	self:Add(dirtree)
	
	self.dirtree = dirtree
	local reg = debug.getregistry()
	local api = debug.GetAPIInfo()
	
	
	local function ParseVal(prefix,key,value,tab)
		if isstring(key) and not string.starts(key,"_") then 
			local info = prefix[key]-- debug.GetAPIInfo(prefix..key)
			if info and istable(info) then
				local argstr = "" 
				if info._arguments then
					for k,v in pairs(info._arguments) do
						local vname = v._name
						if vname then vname = vname..":"..v._valuetype else vname = v._valuetype  end
						if argstr ~= "" then 
							argstr = argstr..", "..vname
						else
							argstr = vname
						end
					end
				end
				local poststr = ""
				if info._returns then
					for k,v in pairs(info._returns) do
						local vname = v._name
						if vname then vname = vname..":"..v._valuetype else vname = v._valuetype  end
						if poststr ~= "" then 
							poststr = poststr..", "..vname
						else
							poststr =" : "..vname
						end
					end
				end
				info._name = key
				tab[#tab+1] = {key.."("..argstr..")"..poststr,tag=info}
			elseif isfunction(value) or isuserdata(value) then
				local n = {key.."()"}
				tab[#tab+1] = n 
			else 
				local n = {key}
				tab[#tab+1] = n 
			end
		end
	end
	
	local rtb1 = {"module"} 
	for k,v in SortedPairs(reg._LOADED,UniversalSort) do
		if isstring(k) and not string.starts(k,"_") then
			local rtl = {k}
			if istable(v) then
				local pinfo = api[k] or {}-- debug.GetAPIInfo("/"..k) or  {}
				for kk,vv in SortedPairs(v,UniversalSort) do
					ParseVal(pinfo,kk,vv,rtl) 
				end
			end
			rtb1[#rtb1+1] = rtl 
		end
	end 
	
	local rtb2 = {"class"}
	for k,v in SortedPairs(reg,UniversalSort) do
		if isstring(k) and not string.starts(k,"_") then
			local rtl = {k}
			if istable(v) then
				local pinfo = api[k] or {}--  debug.GetAPIInfo("/"..k) or  {}
				for kk,vv in SortedPairs(v,UniversalSort) do
					ParseVal(pinfo,kk,vv,rtl) 
				end
			end
			rtb2[#rtb2+1] = rtl 
		end
	end
	
	
	local rtb3 = {"userclass"}
	
	local ent_et = {"Entity"}
	local ent_table = {}
	for k,v in pairs(ents.GetTypeList()) do ent_table[v] = ents.GetType(v) end
	for k,v in SortedPairs(ent_table,UniversalSort) do
		local rtl = {k}  
		local pinfo = (api.userclass.Entity or {})[k] or {}--debug.GetAPIInfo("/userclass/Entity/"..k) or  {}
		for kk,vv in SortedPairs(v,UniversalSort) do  
			ParseVal(pinfo,kk,vv,rtl)
		end
		ent_et[#ent_et+1] = rtl  
	end
	rtb3[#rtb3+1] = ent_et
	
	local panel_et = {"Panel"}
	local panel_table = {}
	for k,v in pairs(panel.GetTypeList()) do panel_table[v] = panel.GetType(v) end
	for k,v in SortedPairs(panel_table,UniversalSort) do
		local rtl = {k}  
		local pinfo = (api.userclass.Panel or {})[k] or {}--debug.GetAPIInfo("/userclass/Panel/"..k) or  {}
		for kk,vv in SortedPairs(v,UniversalSort) do  
			ParseVal(pinfo,kk,vv,rtl)
		end
		panel_et[#panel_et+1] = rtl  
	end
	rtb3[#rtb3+1] = panel_et
	
	
	for k,v in SortedPairs(reg._USERCLASS,UniversalSort) do 
		local rtl = {k} 
		local pinfo = (api.userclass or {})[k] or {}-- debug.GetAPIInfo("/userclass/"..k) or  {}
		for kk,vv in SortedPairs(v.meta,UniversalSort) do 
			--local rtf = {kk}
			ParseVal(pinfo,kk,vv,rtl)
			--for kk,vv in SortedPairs(v,UniversalSort) do
			--	ParseVal(kk,vv,rtl)
			--end
			--rtl[#rtl+1] = rtf  
		end
		rtb3[#rtb3+1] = rtl  
	end 
	
	local rtb4 = {"enum"}
	local enumlist = {}
	for k,v in pairs(api) do
		if v._type == "enum" then
			enumlist[k] = v
		end
	end
	for k,v in SortedPairs(enumlist) do 
		local rtl = {k}  
		local vtbl = {}
		for kk,vv in pairs(v) do
				--key = string.len(key)
			--if isnumber(vv) then
				local tfc = tonumber(vv)
				if tfc then
					vtbl[tonumber(vv)] = tostring(vv).." = "..kk
					--MsgN( tostring(vv).." = "..kk)
				end
			--end
		end
		for kk,vv in SortedPairs(vtbl,UniversalSort) do  
			rtl[#rtl+1] = {vv} 
			
		end
		rtb4[#rtb4+1] = rtl  
	end 
	
	
	
	--PrintTable(rtb)
	dirtree:SetTableType(2) 
	dirtree:FromTable({"*",rtb1,rtb2,rtb3,rtb4})
	dirtree.root:SetSize(600,dirtree.root:GetSize().x)
	dirtree.grid:SetColor(Vector(0.1,0.1,0.1))
	
	dirtree.OnItemClick = function(tree,element)
		infopanel_text:Clear()
		if element and element.tag then
			infopanel_header:SetText(element.tag._type .." ".. element.tag._name)
			if element.tag._arguments then
				local tth = panel.Create()
				tth:SetColor(Vector(0,0,0))
				tth:SetTextColor(Vector(0.8,0.8,0.8))
				tth:SetText("Arguments:")
				tth:SetSize(600,20) 
				tth:Dock(DOCK_TOP)
				infopanel_text:Add(tth)
				for k,v in pairs(element.tag._arguments) do 
					local vname = v._name
					if vname then vname = "  "..vname..":"..v._valuetype else vname = "  "..v._valuetype  end
					if v._description then
						vname = vname.." - "..v._description
					end
					local l = panel.Create()
					l:SetColor(Vector(0,0,0))
					l:SetTextColor(Vector(0.8,0.8,0.8))
					l:SetText(vname)
					l:SetSize(600,20) 
					l:Dock(DOCK_TOP)
					infopanel_text:Add(l)
				end
			end
			if element.tag._returns then
				local splitter = panel.Create()
				splitter:SetColor(Vector(0.1,0.1,0.1)) 
				splitter:SetSize(600,5) 
				splitter:Dock(DOCK_TOP)
				infopanel_text:Add(splitter)
				
				local tth = panel.Create()
				tth:SetColor(Vector(0,0,0))
				tth:SetTextColor(Vector(0.8,0.8,0.8))
				tth:SetText("Returns:")
				tth:SetSize(600,20) 
				tth:Dock(DOCK_TOP)
				infopanel_text:Add(tth)
				for k,v in pairs(element.tag._returns) do 
					local vname = v._name
					if vname then vname = "  "..vname..":"..v._valuetype else vname = "  "..v._valuetype  end
					if v._description then
						vname = vname.." - "..v._description
					end
					local l = panel.Create()
					l:SetColor(Vector(0,0,0))
					l:SetTextColor(Vector(0.8,0.8,0.8))
					l:SetText(vname)
					l:SetSize(600,20) 
					l:Dock(DOCK_TOP)
					infopanel_text:Add(l)
				end
			end
			if element.tag._description then
				local splitter = panel.Create()
				splitter:SetColor(Vector(0.1,0.1,0.1)) 
				splitter:SetSize(600,5) 
				splitter:Dock(DOCK_TOP)
				infopanel_text:Add(splitter)
				
				local tth = panel.Create()
				tth:SetColor(Vector(0,0,0))
				tth:SetTextColor(Vector(0.8,0.8,0.8))
				tth:SetText(element.tag._description)
				tth:SetSize(600,20) 
				tth:Dock(DOCK_TOP)
				infopanel_text:Add(tth)
			end
			infopanel_text:UpdateLayout()
		else
			infopanel_header:SetText("") 
		end
	end
	
	
	
end 

  