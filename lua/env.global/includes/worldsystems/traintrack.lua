

track = track or {} 

local ttnode_meta = DEFINE_METATABLE("TrackNode")

function ttnode_meta:GetNext(prevnode)
    for k,v in pairs(self._links) do
        if k~=prevnode then return k end
    end
    return nil 
end

function ttnode_meta:GetAll()

end
function ttnode_meta:Link(to)
    self._links[to] = true
    to._links[self] = true
    return to
end

function ttnode_meta:__tostring()
    return tostring(self.node) ..':('.. tostring(self.pos)..')'
end
ttnode_meta.__index = ttnode_meta


function TrackNode(node, pos, links)
    local n = setmetatable({_links = {},pos = pos, node = node},ttnode_meta)
    if links then
        for k,v in pairs(links) do
            v:Link(n)
        end
    end
    return n
end

function Track(nodes) 
end

local y = 0.008014

function TestTrack(lp,loop)
    local cp = LocalPlayer():GetParent()
    local last = nil
    local first = nil
    for k,v in pairs(lp) do
        local nod =  TrackNode(cp, v)
        if not first then first = nod end
        if last then
            last:Link(nod)
        end
        last = nod
    end 
    if loop then
        last:Link(first)
    end
    return last
end

function TestTrain(modl,scale)
    local cp = LocalPlayer():GetParent()
    return SpawnTr(cp,modl,Vector(0,0,0),Vector(0,0,0),113,scale) 
end
function TestCT(track,off)
    local bg1 =  TestTrain("forms/levels/train/bogie.dnmd",1.7)  
    local bg2 =  TestTrain("forms/levels/train/bogie.dnmd",1.7)    
    local cab =  TestTrain("forms/levels/train/carriage_nowheels.dnmd",1)
     
    bg1:SetTrack(track,off)     
    bg2:SetTrack(track,off+16)        
    cab:SetBogies(bg1,bg2)  
    return cab
end

function chamfer(line,amount)
    amount = amount or 0.2
    local newline = {}
    local p1 = nil
    local p2 = nil 
    for k,v in pairs(line) do
        if p1 and p2 then
            local d1 = p1-p2
            local d2 = v - p1
            local d3 = v-p2
            local npA = p2 + d3/2
            local np = p2 +(npA - p2)*amount  

            newline[#newline+1] = np
            newline[#newline+1] = p2 + d1/2
           -- newline[#newline+1] = p1 + d2/2
        elseif p1 then
            newline[#newline+1] = p2
        end
        p2 = p1
        p1 = v

    end
    newline[#newline+1] = p1
    return newline
end
            
local llp = {
    Vector(0,y,0),
    Vector(0.01,y,0),
    Vector(0.02,y,0.01),  
    Vector(0.03,y,0.02), 
    Vector(0.04,y,0.05),
    Vector(0.1,y,0.1),
    Vector(0.1,y,0.15),
    Vector(0.04,y,0.18),
    Vector(0,y,0.1),
    Vector(0.02,y,0.05), 
    Vector(0.1,y,0.03),
    Vector(0.12,y,0.1),
} 
llp  = chamfer(llp,0.1)
llp  = chamfer(llp,0.1)
--
TTRACK=TestTrack(llp) 
--TTRAIN1 = TestCT(TTRACK,102)      
--TTRAIN2 = TestCT(TTRACK,0)  
--TTRAIN3 = TestCT(TTRACK,44)  
--TTRAIN2.motor = 0.01
--TTRAIN1.motor = 0.5      
--ccex =  TestTrain("forms/levels/train/bogie.dnmd",1.7)      
--ccex:SetTrack(TTRACK,100)   
--ccex.speed =-1  
           
--TTRAIN2:Link('all',TTRAIN2.bogie_A,TTRAIN1.bogie_B,5) 
--TTRAIN2:Link('all',TTRAIN3.bogie_A,TTRAIN2.bogie_B,5) 
local lpcp = LocalPlayer():GetParent()
debug.ShapeCreate(3334,lpcp,Vector(1,0,0),3,llp)


function TestTrack2(cp,lp,loop) 
    local cpp = cp:GetComponent(CTYPE_PATH) or cp:AddComponent(CTYPE_PATH)
    if cpp then
        cpp:Clear() 
        local last = nil
        local first = nil
        for k,v in pairs(lp) do
            local nod = cpp:Add(v)
            if not first then first = nod end
            if last then
                cpp:Link(last,nod)
            end
            last = nod
        end 
        if loop then
            cpp:Link(last,first)
        end
        return cpp
    end 
end   

clst = clst or {}
for k,v in pairs(clst) do
    if IsValidEnt(v) then
        if v.Despawn then v:Despawn() end
        if v.RemAll then v:RemAll() end
    end
end
clst= {}

local track = TestTrack2(lpcp,llp,false)
function CrtBogie(off)
    local ccex =  TestTrain("forms/levels/train/bogie.dnmd",1.7)      
    ccex:SetTrack2(track,1,2,off)  
    clst[#clst+1] = ccex  
    return ccex
end 
function CrtCar()
    local cab =  TestTrain("forms/levels/train/carriage_nowheels.dnmd",1)    
    clst[#clst+1] = cab  
    return cab
end 
local ba = CrtBogie(0)
local bb = CrtBogie(1) 
local car = CrtCar() 
car:SetBogies(ba,bb)  
bb.pathfollow:SetBehind(ba.pathfollow,15)
--ba.pathfollow:Link(bb.pathfollow,15)

 
--local ba2 = CrtBogie(3)
--local bb2 = CrtBogie(4) 
--local car2 = CrtCar() 
--car2:SetBogies(ba2,bb2)  
--bb2.pathfollow:Link(ba2.pathfollow,15)
--ba2.pathfollow:Link(bb2.pathfollow,15)
--
--
--local ba3 = CrtBogie(5)
--local bb3 = CrtBogie(6) 
--local car3 = CrtCar() 
--car3:SetBogies(ba3,bb3)  
--bb3.pathfollow:Link(ba3.pathfollow,15)
--ba3.pathfollow:Link(bb3.pathfollow,15)
--
--bb.pathfollow:Link(ba2.pathfollow,5)
--ba2.pathfollow:Link(bb.pathfollow,5)
--
--bb2.pathfollow:Link(ba3.pathfollow,5) 
--ba3.pathfollow:Link(bb2.pathfollow,5)

--bb3.pathfollow:SetMotor(4)  
bb.pathfollow:SetMotor(1)
       