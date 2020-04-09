dialogue = dialogue or {}
function dialogue.LoadAll()
    local list = {}
    for k,v in pairs(forms.GetList('conversation')) do
         MsgN(k,'-',v)
        list[k] =dialogue.Load(forms.ReadForm('conversation.'..k))
    end
    dialogue.list = list
 
end
function dialogue.Load(data)
    local nodes = {}
    for k,v in pairs(data) do
        local data = {}
        local coms = cstring.unescape(v.body):split('\n')
        nodes[v.title] = coms
        --if v.title=='START' then
--
        --else
        --    --dialogue.Parse(coms)
        --end
    end
    return nodes
end
function dialogue.Spacecount(line)
    if line==nil then MsgN(debug.traceback()) error("empty line") end
    local spacecount = 0
    for x = 1, cstring.len(line) do
        local c = cstring.sub(line,x,1) 
        if c==' ' then
            spacecount = spacecount + 1 
        else
            break 
        end
    end 
    return spacecount
end
MsgN(dialogue.Spacecount("  x"))
function dialogue.LineSearch(lines,pattern,indent,index)
    local i = index
    local linecount = #lines
    while i<=linecount do
        local line = cstring.trimend(lines[i])
        local spacecount = dialogue.Spacecount(line)
        if spacecount==indent*4 then 
            line = cstring.sub(line,indent*4)
        end
        if string.starts(line,pattern) then
            return i
        end
        i = i + 1 
    end
    return nil 
end
 
local dialmeta = DEFINE_METATABLE("dial")
function dialmeta:Run(input)
    local options = self.options
    local i = 1
    local dialselect = false
    if input and options then
        local option = options[input]
        if option then
            if isstring(option) then
                self.cnode = self.data[option]
                if not self.cnode then
                    error("unknown node name:"..option)
                end
            else
                i = option
                --dialselect=true
            end
        else
            error("unknown dialogue option:"..input)
        end 
    end
    --MsgN("con", self.cnode,i)
    local node = self.cnode or self.data.start
    if not node then
        error("no node")
    end 
    local lines = node
    local linecount = #lines
    local indent =  dialogue.Spacecount(lines[i])/4 
    if self.cline then
        i = self.cline 
        indent = self.cindent
        self.cline  = nil
        MsgN("CL",i)
    end
    dialselect=i<(self.dialend or 0)
    local options = {}
    local collecting_options = false
    while i<=linecount do
        local line = cstring.trimend(lines[i])
        local spacecount = dialogue.Spacecount(line)
        if spacecount==indent*4 then 
            --MsgN("LINE:",line,spacecount)
            line = cstring.sub(line,spacecount+1)
            --MsgN("XLINE:",line)
 
            if string.starts(line,'<<if')  then  
                local condition =cstring.replace(string.sub(line,5,-3),'$',"")
                
                if load("return "..condition,'dialogue condition',"t",self.env)() then
                    indent = indent + 1
                else
                    local idn = dialogue.LineSearch(lines,"<<else>>",indent,i+1)
                    if idn then
                        i = idn 
                        indent = indent + 1
                    else
                        local idn = dialogue.LineSearch(lines,"<<end>>",indent,i+1)
                        if idn then
                            i = idn  
                        else
                            error("open if statement at "..i)
                        end
                    end
                end
            elseif string.starts(line,'<<exit>>')  then 
                break
            elseif string.starts(line,'<<')  then--luarun
                local action =cstring.replace( string.sub(line,3,-3),'$','')
                --MsgN("act:",action)
                load(action,'dialogue action',"t",self.env)()   
            elseif string.starts(line,'->') then--dialogue option
                options[cstring.trim(cstring.sub(line,3))] = i+1
                collecting_options = true
                --indent = indent + 1
            elseif string.starts(line,'[[') then--dialogue link
                local blink = string.sub(line,3,-3)
                local left,right = unpack(string.split(blink,'|'))
                if right==nil then
                    self.cnode = self.data[left]
                    return self:Run() 
                else
                    options[cstring.trim(left)] = right
                    collecting_options = true
                end

            elseif string.find(line,':') then--phrase
                if collecting_options then 
                    self.dialend = i
                    break 
                end 
                if string.starts(line,'|')  then--random  
                    local toptions = {} 
                    while line and string.starts(line,'|') or string.starts(line,' ') and i<=linecount do 
                        line = cstring.sub(lines[i],spacecount+1)
                        if string.starts(line,'|') then
                            toptions[#toptions+1] = {cstring.sub(line,2),i}
                        elseif  not line or not string.starts(line,' ') then
                            i = i - 1 
                            break   
                        end
                        i = i + 1 
                    end
                    PrintTable(toptions)
                    local option = table.Random(toptions)
                    self:Say(option[1])
                    self.dialend = i
                    i = option[2]
                    indent = indent + 1 
                else 
                    self:Say(line) 
                end
                if self.breakonsay or true then 
                    if i<linecount then
                        self.cline = i+1
                        self.cindent = indent
                        self.cnode = node 
                        self.options = {}
                        return "CONT" 
                    end
                end
            elseif cstring.trim(line)=='' then
                if collecting_options then 
                    self.dialend = i
                    break 
                end
            end 
        elseif spacecount<indent*4 then
            --MsgN("unindent",indent,"to",spacecount/4)
            if collecting_options then 
                self.dialend = i
                break 
            end
            indent = spacecount/4
            if dialselect then
                i = self.dialend-1
            end
        end
        i = i + 1
    end
    self.options = options
    return options
end
function dialmeta:Say(line)
    local actor, line = unpack(string.split(self:SetupWithVars(line),":"))
    if string.starts(actor,'$') then
        actor = self.env[string.sub(actor,2)] or 'ERROR'
    end
    --MsgN(actor..': '..line)   
    if self.OnSay then self.OnSay(actor,line) end
end
function dialmeta:Continue()
    self:Run(nil,self.cline or 0)
end
function dialmeta:SetupWithVars(text)
    for k,v in pairs(cstring.matches(text,'{\\$([\\s\\S]*?)}')) do
        local key = v[2]
        local value = tostring(self.env[key])
        text = cstring.replace(text,"{$"..key.."}",value)
    end
    return text
end
function dialmeta:Set(key,value)
    self.env[key] = value
end
dialmeta.__index = dialmeta
dialmeta.__newindex = nil
function dialogue.New(formid)
    local data = dialogue.list[formid]
    if data then
        local d = {env={},data = data}
        setmetatable(d,dialmeta)
        --PrintTable(data)
        return d
    else
        error("unknown dialogue id: "..formid)
    end
end
function dialogue.NewFromData(data)
    local d = {env={},data = data}
    setmetatable(d,dialmeta)
    return d
end 
 

dialogue.LoadAll()
local dial = {
    start = {
        "someone:hi!",
        "other:h!",
        "|other:anything?",
        "|other:here?",
        "|other:or?",  
        "<<if not zag>>",
        "    other:zag zag",
        "<<else>>",
        "    other:what?",
        "    <<MsgN('umad?')>>",
        "<<end>>",
        "->go nafig",
        "    other:he he", 
        "->umad",
        "    other:no u", 
        "    [[nou]]", 
        "->huh?",
        "    other:wuu", 
        "    [[wuuu|madness]]",
        "other: bye!"
    },
    madness = {
        "other: ya mad!",
        "another: hah!"
    },
    nou = {
        "other: ahahahha!", 
        "[[wat ur doin?|madness]]", 
        "[[oh god|start]]"
    }
} 
--dialmeta.cnode = nil
--dialmeta.dialend = nil
--dialmeta.options = nil   
---local d = dialogue.NewFromData(dial)
-----PrintTable(dialmeta) 
---MsgN("---") 
---PrintTable(d:Run()) 
---MsgN(">>")
-------PrintTable(d:Run('go nafig'))
---PrintTable(d:Run('umad'))
---MsgN(">>")
---PrintTable(d:Run('oh god'))

console.AddCmd("cdial",function (arg)
    DIAL = dialogue.New( arg)
    DIAL:Set("player",'Anneke')
    DIAL:Set("self",'ARA')
    DIAL:Set("met",function(who)
        return true
    end)
    local rez = DIAL:Run()
    local rr = ""
    for k,v in pairs(rez) do
        rr = rr .. k .. " "
    end
    MsgN(rr)
end)
console.AddCmd("cdial_say",function (a,b,c,d,e,f)
    if DIAL then
        local rez = DIAL:Run(string.join(' ',{a,b,c,d,e,f}))
        local rr = ""
        for k,v in pairs(rez) do
            rr = rr .. k .. " "
        end
        MsgN(rr)
    else
        MsgN("no dialogue!")
    end
end) 