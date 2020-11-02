

--input: file path
--output: displayed thumbnail image

function PANEL:Init()
    self:SetSize(32,32) 
    self:SetCanRaiseMouseEvents(false)
end

function PANEL:SetForm(formid,usecontext,entdata) 
    if not isstring(formid) then return end 
    if isjson(entdata) then  
        RenderThumbnail(formid,function(tex) 
            if tex then
                self:SetTexture(tex)
                if usecontext then 	usecontext.contextinfo = {"image",tex} end 
            else
                self:SetForm(formid,usecontext,nil) --fallback to form icon
            end
        end)
        return 
    end
    if self._prefericons then
        local icon = forms.GetIcon(formid)
        if icon then
            self:SetTexture(icon)
            local data = forms.LoadForm(formid) 
            local tint = data:Read("tint") or data:Read("/parameters/tint")
            if tint then
                self:SetColor(JVector(tint))
            end 
            return nil
        end
    end 
	local fn = 'textures/thumb/'..formid..'.png'
	if file.Exists(fn) then
		local t = LoadTexture(fn)
		self:SetTexture(t)
		if usecontext then  usecontext.contextinfo = {"image",t} end
    else 
        local icon = forms.GetIcon(formid)
        if icon then
            self:SetTexture(icon)
            local data = forms.LoadForm(formid) 
            local tint = data:Read("tint") or data:Read("/parameters/tint")
            if tint then
                self:SetColor(JVector(tint))
            end 
        else
            if forms.HasTag(formid,"nopreview") then
                
            else
                RenderThumbnail(formid,function(tex) 
                    if tex then
                        self:SetTexture(tex)
                        if usecontext then 	usecontext.contextinfo = {"image",tex} end

                        tex:Save('data/textures/thumb/'..formid..'.png')
                    else
                        self:SetTextOnly(true) 
                    end
                end)
            end
        end
	end 
end

FormThumbnailRender = PANEL.SetForm

function PANEL:SetPath(path,usecontext)
    if file.Exists(path) then
        local ext = file.GetExtension(path)
        if ext =='.png' or ext == '.dds' or ext == '.jpg' then 
            local tex = LoadTexture(path,true)
            self:SetTexture(tex)
            if usecontext then usecontext.contextinfo = {"image",tex} end 
        else
            RenderThumbnail(path,function(tex) 
                if tex then
                    self:SetTexture(tex)
                    if usecontext then usecontext.contextinfo = {"image",tex} end 
                else
                    self:SetTextOnly(true) 
                end
            end) 
        end
    end

    --[[
    local aparts = string.split(data,'/')
    --if aparts[1]=='prop' then
        local type = string.join('.',table.Skip(aparts,1))
        if forms.GetForm(aparts[1]..'.'..type) then
            local pnl = panel.Create()
            pnl:SetSize(32,32)
            pnl:Dock(DOCK_RIGHT)
            pnl:SetCanRaiseMouseEvents(false)
            item:Add(pnl)
            local formid = aparts[1]..'.'..type
            local fn = 'textures/thumb/'..formid..'.png'
            if true and file.Exists(fn) then
                local t = LoadTexture(fn)
                pnl:SetTexture(t)
                item.contextinfo = {"image",t}
            else 
                RenderThumbnail(formid,function(tex) 
                    pnl:SetTexture(tex)
                    item.contextinfo = {"image",tex}
    
                    tex:Save('data/textures/thumb/'..formid..'.png')
                end)
            end
        end
    --end
    ]]
end
