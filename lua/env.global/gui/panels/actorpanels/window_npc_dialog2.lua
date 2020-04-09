PANEL.basetype = "menu_dialog"

function PANEL:Init()
	--PrintTable(self)
	self.fixedsize = true
	self.base.Init(self,"title",200,800)
end 
function PANEL:Start(npc,title) 
	self.npc = npc
	local bcol = Vector(83,164,255)/255
	local pcol = Vector(0,0,0)
	if not self.bclose then
		local bclose = panel.Create("button")
		bclose:SetText("Close")
		bclose:SetSize(70,20)
		bclose:SetPos(0,-200+25)
		self:SetupStyle(bclose)
		bclose.OnClick = function() 
			self:Close()
			self.dialog = nil
			BLOCK_MOUSE = false 
		end
		self:Add(bclose) 
		self.bclose = bclose
		
		
		local label = panel.Create()
		label:SetText("text")
		label:SetTextAlignment(ALIGN_CENTER)
		label:SetSize(400,60)
		label:SetPos(0,100) 
		label:SetTextColor(bcol) 
		label:SetColor(pcol)
		label:SetMultiline(true)
		--label:SetAlpha(0.7)
		label:SetTextOnly(true)
		self:Add(label)
		
		self.dialtext = label

		local anslst = panel.Create("list")
		anslst:SetSize(400,100)
		anslst:SetPos(0,-40) 
		self:Add(anslst)
		self.anslst = anslst 
	end
	self.label:SetText(title) 
	input.setMousePosition( self:GetPos()*Point(0.5,-0.5)+ GetViewportSize()  / 2 )
end
function PANEL:Open(text,options) 

	self.dialtext:SetText(text)
	--self:ClearOptions() 
	if options then
        self.anslst:ClearItems()
		local opt = {}
		for k,v in pairs(options) do
			local bopt = panel.Create("button")
			bopt:SetText(string.lower( v.t))
			bopt:SetSize(300,20)
			bopt:SetPos(0,100-k*50)
			self:SetupStyle(bopt)
			bopt.OnClick = function()  
				MsgN("dasdas",v.t)
				LocalPlayer():Say(v.t)
				if not v.f(self.npc,self,v) then
					debug.Delayed(900,function() input.setMousePosition( GetViewportSize()  / 2 ) end)
					debug.Delayed(1000,function() self:Close() BLOCK_MOUSE = false  end)
				end
			end
			--self:Add(bopt)
			self.anslst:AddItem(bopt)
			opt[#opt+1] = bopt
		end 
		self.opt = opt
	end
	
	self:UpdateLayout()  
	self:Show()
	self:SetPos(0,-700)
    self.anslst:Scroll(-99999)
	facecontroller.Vocalize(self.npc.ent,string.lower( text))
end
function PANEL:SetDialogText(str) 
	self.dialtext:SetText(str)
end
function PANEL:ClearOptions() 
	local opt = self.opt or {}
	for k,v in pairs(opt) do self:Remove(v) end
end

function PANEL:MouseDown() 
end
function PANEL:MouseUp() 
end
function PANEL:MouseEnter() 
end
function PANEL:MouseLeave() 
end