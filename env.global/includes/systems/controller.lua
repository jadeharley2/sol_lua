--AddCSLuaFile()

--AbilitiesList =  {}--AbilitiesList or
local CONTROLLER = {}

--props:
--name
  

--
--funcs:
--self:Init(ent) - returns if effect can be applied
--self:UnInit(ent)
--self:MouseWheel()
--self:MouseDown()
--self:KeyDown(key)
--self:Update()
 

local con_class = DefineClass("Controller","OBJ","lua/env.global/world/controllers/",CONTROLLER)
    
function Controller(type) 
	return con_class:Create(type)
end 
    






local controllers = {}
global_controller = global_controller or false

function AddController(name,obj)
	controllers[name] = obj 
end
   
--function ScanControllers() 
--	local tempobj = OBJ   
--	for k,v in pairs(file.GetFiles("lua/env.global/world/controllers/","lua")) do
--		OBJ = {}   
--		include(v)   
--		OBJ.name = string.lower( file.GetFileNameWE(v))
--		AddController(OBJ.name,OBJ) 
--	end
--	OBJ = tempobj      
--end                        
                               
function SetController(name)   
	if name then                
		local ts = Controller(name)--controllers[name]
		if ts then    
			local prev = global_controller   
			if prev and prev ~=0 then 
				prev:UnInit()       
				if prev.Update then hook.Remove("main.predraw", "controller") end
				if prev.MouseWheel then hook.Remove("input.mousewheel", "controller" ) end 
				if prev.MouseDown then hook.Remove("input.mousedown", "controller") end
				if prev.KeyDown then hook.Remove("input.keydown", "controller" ) end
			end      
			
			local result = ts:Init()
			if result ~= false then
				if ts.Update then hook.Add("main.predraw", "controller", function() 
					ts:Update()  
					hook.Call("main.postcontroller")
				end) end   
				if ts.MouseWheel then hook.Add("input.mousewheel", "controller", function() ts:MouseWheel() end) end
				if ts.MouseDown then hook.Add("input.mousedown", "controller", function() ts:MouseDown() end) end
				if ts.KeyDown then hook.Add("input.keydown", "controller", function() ts:KeyDown() end) end
				            
				global_controller = ts
				MsgN("Controller changed to ",  ts._name)
			else                         
				MsgN("Controller change to ",  ts._name, " is failed, revert initiated.") 
				
				local result = prev:Init() 
				if result ~= false then
					if prev.Update then hook.Add("main.predraw", "controller", function() 
						prev:Update()  
						hook.Call("main.postcontroller")
					end) end
					if prev.MouseWheel then hook.Add("input.mousewheel", "controller", function() prev:MouseWheel() end) end
					if prev.MouseDown then hook.Add("input.mousedown", "controller", function() prev:MouseDown() end) end 
					if prev.KeyDown then hook.Add("input.keydown", "controller", function() prev:KeyDown() end) end              
					                
					global_controller = prev 
				end     
			end  
		end    
	else                                      
		if global_controller and global_controller ~=0 then
			global_controller:UnInit()
			if global_controller.Update then hook.Remove("main.predraw", "controller") end
			if global_controller.MouseWheel then hook.Remove("input.mousewheel", "controller" ) end
			if global_controller.MouseDown then hook.Remove("input.mousedown", "controller") end
			if global_controller.KeyDown then hook.Remove("input.keydown", "controller" ) end
		end
	end 
end  
   

function GetCurrentController()
	return global_controller
end

--ScanControllers()
 
if global_controller then
	SetController(global_controller.name)
end    

console.AddCmd("setcontroller",SetController)
 
--hook.Add("script.reload","controller", function(filename) 
--	if string.starts(filename,"env.global/world/controllers/") then 
--		local type = string.lower( file.GetFileNameWE(filename))
--		 
--		local tempobj = OBJ   
--		OBJ = {}   
--		include(filename)   
--		OBJ.name = string.lower( file.GetFileNameWE(filename))
--		AddController(OBJ.name,OBJ)  
--		OBJ = tempobj 
--		
--		return true
--	end
--end)