
function PANEL:Init()
	self:SetSize(128,128)  
	self:UpdateLayout()
end
local defstyle = {
    text = {
        dock = DOCK_TOP,
		textcolor = {0,0,0},
		textonly = true,
		text = "text",
		textalignment = ALIGN_TOPLEFT,
		multiline=true,
		lineheight = 20,
		linespacing = 5,
		autowrap = true, 
       -- autosize={false,true},
    }
}
function  PANEL:Resize()
    if self.mdtext then
        self:Clear()
        self:SetPage()
    end
end
function PANEL:ParseLine(line,parent,dock)
    local boldcolor = self.bold or "red"
    local italiccolor = self.italic or "blue"
    line = cstring.trimstart(line) 
    dock = dock or DOCK_LEFT
    --line = cstring.replace()

    --if string.find(line,'|') then
    --    local sb = cstring.split(line,'|')
    --    local sub = gui.FromTable({ 
    --        textonly = true,
    --        autosize={false,true},
    --        dock = DOCK_TOP
    --    },nil,defstyle)
    --    for k,v in ipairs(sb) do
    --        self.SetMarkdown(sub,v)
    --    end
    --    self:Add(sub)
    if self.curtable and parent==self and 
        (not cstring.find(line,"|") or string.starts(line,'|>>')) then
        if self.curtable_borders then
            self.curtable:Add(gui.FromTable({ 
                color = {0,0,0},
                size ={1,1},
                dock = DOCK_TOP
            },nil,defstyle))
        end
        self.curtable = nil
        self.curtable_borders = nil
    end

    if string.starts(line,":--:") then
        parent.palign =  ALIGN_CENTER
        parent.pdock = DOCK_LEFT
        line = cstring.trimstart( cstring.sub(line,5))
    end
    if string.starts(line,"--:") then
        parent.palign = ALIGN_TOPRIGHT
        parent.pdock = DOCK_RIGHT
        line = cstring.trimstart( cstring.sub(line,4))
    end
    if string.starts(line,":--") then
        parent.palign =  ALIGN_TOPLEFT
        parent.pdock = DOCK_LEFT
        line = cstring.trimstart( cstring.sub(line,4))
    end

    line = cstring.regreplace(line,'(\\*{2})(.+?)\\1','\a['..boldcolor..']$2\a[clear]')
    line = cstring.regreplace(line,'(\\*)(.+?)\\1','\a['..italiccolor..']$2\a[clear]')

    if string.starts(line,'|>>') then --flushright single line
        local sb = cstring.trimstart( cstring.sub(line,4))
        local sub = gui.FromTable({ 
            textonly = true,
            size ={1,1},
            dock = DOCK_TOP
        },nil,defstyle)
        parent:Add(sub)
        self:UpdateLayout()
        local sels = self:GetSize()
        local seps = sub:GetPos()
        local sub2 = gui.FromTable({ 
            textonly = true,
            size ={sels.x/2,10},
            autosize={false,true}, 
            pos = {sels.x/2,seps.y},

        },nil,defstyle)
        parent:Remove(sub)
        parent:Add(sub2)

        self:ParseLine(sb,sub2,DOCK_RIGHT)
        
    elseif cstring.find(line,"|") and parent == self then --table
        local parts = cstring.split(line,'|')
        --PrintTable(parts)
        self:UpdateLayout()
        local colcount = 0
        local newparts = {}
        for k,v in ipairs(parts) do
            if cstring.trim(v) ~="" then 
                newparts[#newparts+1] = v
                colcount = colcount + 1
            end
        end
        if(colcount==#parts-2)then 
            self.curtable_borders = true
        end
        parts = newparts
        if colcount>1 then
            local curtable = self.curtable
            if not curtable then 
                curtable = gui.FromTable({
                    textonly = true,
                    size = {20,20}, 
                    dock = DOCK_TOP, 
                    autosize = {false,true},
                },nil,defstyle)
                if self.curtable_borders then 
                    gui.FromTable({ 
                        subs = {
                            {color = {0,0,0},size ={1,1},dock = DOCK_LEFT},
                            {color = {0,0,0},size ={1,1},dock = DOCK_RIGHT},
                            {color = {0,0,0},size ={1,1},dock = DOCK_TOP},
                        }
                    },curtable,defstyle)
                end
                self.curtable = curtable
                parent:Add(curtable)
                self:UpdateLayout()
            else
                curtable:Add(gui.FromTable({ 
                    color = {0,0,0},
                    size ={1,1},
                    dock = DOCK_TOP
                },nil,defstyle))
            end

            local row = gui.FromTable({
                textonly = true,
                size = {20,20}, 
                dock = DOCK_TOP, 
            },nil,defstyle)
            curtable:Add(row)
            local lwidth = curtable:GetSize().x/colcount - colcount*1
            local subcells = {}
            for k,v in ipairs(parts) do
               -- if k>1 and k<=colcount+1 then 
                    local cell = gui.FromTable({  
                        --class = "text",
                        textonly = true,
                        dock = DOCK_LEFT,
                        size = {lwidth,20}, 
                        --autosize = {false,true}
                        --text =cstring.trim(v)
                    },nil,defstyle)
                    row:Add(cell)  
                    local subcell = gui.FromTable({   
                        textonly = true,
                        dock = DOCK_TOP,
                        size = {lwidth,20}, 
                        autosize = {false,true} 
                    },nil,defstyle)
                    cell:Add(subcell) 
 
                    if k<colcount and self.curtable_borders then
                        row:Add(gui.FromTable({ 
                            color = {0,0,0},
                            size ={1,1},
                            dock = DOCK_LEFT
                        },nil,defstyle))
                    end
                    self:ParseLine(cstring.trim(v),subcell)
                    subcells[#subcells+1] = subcell 
             --   end
            end
            row:UpdateLayout()
            local minY = 20
            for k,v in pairs(subcells) do
                minY = math.max(minY,v:GetSize().y)
            end
            local rs = row:GetSize()
            row:SetSize(rs.x,minY)

        end
    elseif string.starts(line,'# ') then
        local sb = cstring.sub(line,3)
        parent:Add(gui.FromTable({ 
            class = "text",
            text = cstring.trimend(sb), 
            lineheight = 30, 
            size = {30,30}
        },nil,defstyle))
    elseif string.starts(line,'## ') then
        local sb = cstring.sub(line,4)
        parent:Add(gui.FromTable({ 
            class = "text",
            text = cstring.trimend(sb), 
            lineheight = 25, 
            size = {25,25}
        },nil,defstyle))
    elseif string.starts(line,'### ') then
        local sb = cstring.sub(line,5)
        parent:Add(gui.FromTable({ 
            class = "text",
            text = cstring.trimend(sb), 
            lineheight = 22, 
            size = {22,22}
        },nil,defstyle))
    elseif string.starts(line,'>') then
        local sb = cstring.sub(line,2)
        local sub2 = gui.FromTable({
            textonly = true,
            size = {20,20},
            autosize = {false,true},
            dock = DOCK_TOP,
            subs = {
                {
                    dock = DOCK_LEFT,
                    size = {5,30},
                    color = {0.5,0.5,0.5},
                    margin = {0,0,10,0}
                }
            }
        },nil,defstyle)
        parent:Add(sub2)
 
        self:ParseLine(sb,sub2)

    elseif string.starts(line,'---') then
        --local sb = cstring.sub(line,4)
        parent:Add(gui.FromTable({ 
            size = {20,0.5}, 
            dock = DOCK_TOP, 
            color = {0,0,0}
        },nil,defstyle))
    elseif string.starts(line,'===') then
        --local sb = cstring.sub(line,4)
        parent:Add(gui.FromTable({ 
            size = {20,2}, 
            dock = DOCK_TOP, 
            color = {0,0,0}
        },nil,defstyle))
    elseif string.starts(line,'!') then
        local matches = cstring.matches(line,'!\\[([\\s\\S]*?)\\]\\(([\\s\\S]*?)\\)')
        --PrintTable(matches)
        if matches and matches[1] then
            local image = matches[1][3] 
            local sx,sy = unpack(cstring.split(matches[1][2],','))
            local size = {20,20}
            if sx and sy then
                size = {tonumber(sx),tonumber(sy)}
            end
            --MsgN(image)
            if parent.palign == ALIGN_CENTER then
                parent:Add(gui.FromTable({ 
                    size = size,  
                    dock = DOCK_TOP, 
                    textonly = true,
                    subs = {
                        { 
                            size = size, 
                            texture = image, 
                        }
                    } 
                },nil,defstyle))
            else
                parent:Add(gui.FromTable({ 
                    size = size,  
                    dock = DOCK_TOP, 
                    textonly = true,
                    subs = {
                        { 
                            size = size, 
                            texture = image,
                            dock = parent.pdock or dock or DOCK_LEFT,  
                        }
                    } 
                },nil,defstyle))
            end
        end
    elseif line=='' then
        parent:Add(gui.FromTable({
            size = {20,5}, 
            dock = DOCK_TOP, 
            textonly = true,
        },nil,defstyle))
    elseif string.starts(line,'$$') then
        local sb = cstring.sub(line,3)
        parent:Add(gui.FromTable({
            class = "text",
            text = cstring.trimend(sb), 
            lineheight = 20,  
            size = {20,20},
            autosize = {false,true},
            textalignment = parent.palign or ALIGN_TOPLEFT
        },nil,defstyle))
    else
     -- local cline = parent.cline
     -- if not cline then
     --     cline = gui.FromTable({
     --         textonly = true,
     --         size = {20,20},
     --         minsize = {20,20},
     --         autosize = {false,true},
     --         dock = DOCK_TOP,
     --     },nil,defstyle)
     --     parent.cline = cline
     --     parent:Add(cline)
     -- end
        parent:Add(gui.FromTable({
            class = "text",
            text = cstring.trimend(line), 
            lineheight = 20,  
            size = {20,20}, 
            textalignment = parent.palign or ALIGN_TOPLEFT
        },nil,defstyle))
    end
end
function PANEL:SetMarkdown(text,page) 
    text = text or self.mdtext
    text = cstring.replace(text,'\r','')
    pages = cstring.split(text,"<NEWPAGE>")
    self.mdtext = text
    self.mdpages = pages
    self.mdmaxpages = #pages
    self.mdpage = math.Clamp(page or 1,0,#pages)
     
    self:SetPage()
end 
---zero based page selector
function PANEL:SetPage(pagenum)
    self:Clear()
    pagenum = pagenum or self.mdpage
    self.mdpage = math.Clamp(pagenum or 0,0,self.mdmaxpages-1)
    --MsgN("MDPAGE",self.mdpage)
    local text = pages[self.mdpage+1]

    self.palign =  ALIGN_TOPLEFT
    self.pdock = DOCK_LEFT
    local lines = cstring.split(text,"\n")
    for k,line in ipairs(lines) do
        self:ParseLine(line,self)
    end
    self:UpdateLayout()
end
function PANEL:GetPage()
    return self.mdpage or 1
end

function PANEL:GetPageCount()
    return self.mdmaxpages
end
 
 