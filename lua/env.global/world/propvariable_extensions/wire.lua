util_static = util_static or {}
function util_static.gateop(self,f,k,v)
	local wireio = self.wireio
    if wireio then 
        wireio:SetOutput("out", self.gate_op(wireio.inputs))
	end
end

function util_static.indicatorop(self,f,k,v)
	local wi = self.wireindicator
    if wi then 
        MsgN("SADASDAS",v,wi.material_index,wi.material_off)
        if v==0 then
            self.model:SetMaterial(wi.material_off,wi.material_index)
        else
            self.model:SetMaterial(wi.material_on,wi.material_index)
        end
	end
end

local function notn(a)
    return a==0 
end
local function andn(a,b)
    return not (a==0 or b==0) 
end
local function orn(a,b)
    return not (a==0 and b==0)  
end
local function tn(b)
    if b then return 1 else return 0 end
end
local gate_operations = {
    add =  { i ={'a','b'}, f = function(ix) return (ix.a.v or 0)+(ix.b.v or 0) end},
    sub =  { i ={'a','b'}, f = function(ix) return (ix.a.v or 0)-(ix.b.v or 0) end},
    mul =  { i ={'a','b'}, f = function(ix) return (ix.a.v or 0)*(ix.b.v or 0) end},
    div =  { i ={'a','b'}, f = function(ix) return (ix.a.v or 0)/(ix.b.v or 0) end},
    
    _not =  { i ={'a'}, f = function(ix) return tn(notn(ix.a.v or 0)) end},
    _and =  { i ={'a','b'}, f = function(ix) return tn(andn(ix.a.v or 0,ix.b.v or 0)) end},
    _or =   { i ={'a','b'}, f = function(ix) return tn(orn(ix.a.v or 0,ix.b.v or 0)) end},
    xor =   { i ={'a','b'}, f = function(ix) local a,b =  (ix.a.v or 0),(ix.b.v or 0) return tn(orn(a,b) and (notn(a) or notn(b))) end},
    _eq =   { i ={'a','b'}, f = function(ix) return tn((ix.a.v or 0) == (ix.b.v or 0)) end},
    _neq =  { i ={'a','b'}, f = function(ix) return tn((ix.a.v or 0) ~= (ix.b.v or 0)) end},
}

hook.Add("prop.variable.load","wire",function (self,j,tags)  
	 
    if j.wiregate then
        local gtype = j.wiregate
        if gtype then
            local gop = gate_operations[gtype]
            if gop then
                local gfn = function(...) util_static.gateop(...) end
                local wio = self:RequireComponent(CTYPE_WIREIO)
                self.wireio = wio 
                self.usetype = "wire gate: "..gtype 
                for k,v in pairs(gop.i) do  
                    wio:AddInput(v,gfn) 
                    wio.inputs[v].v = 0
                end
                wio:AddOutput("out")
                self.gate_op = gop.f 
            end
        end
    end
    if j.wireindicator then
        self.wireindicator = j.wireindicator
        local wio = self:RequireComponent(CTYPE_WIREIO)
        wio:AddInput("in",function(...) util_static.indicatorop(...) end)  
    end
end)
