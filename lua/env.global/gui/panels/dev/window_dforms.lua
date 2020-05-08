PANEL.basetype = "window"

function PANEL:Init()
	self.base.Init(self)
    local inner = self.inner
    gui.FromTable({
        subs = {
            { type = "files",
                dock = DOCK_FILL,
                FormFS = false,
                OnItemDoubleClick = function (s,formid)
                    formid = cstring.replace(formid,'/','.')
                    MsgN(formid)
                    local actor = LocalPlayer()
                    if IsValidEnt(actor) then 
                        if string.starts(formid,'ability.') then
                            actor:GiveAbility(cstring.sub(formid,9)) 
                        else
                            actor:Give(formid) 
                        end
                    end
                end
            } 
        }
    },inner,{},self)
	self:UpdateLayout()
end