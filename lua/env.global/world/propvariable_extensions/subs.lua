
hook.Add("prop.variable.load","subs",function (self,j,tags)   
    if j.subs then
        for k,v in pairs(j.subs) do
            local sub = forms.Spawn(v.form,self,{data = v.data})
            if sub then
                if v.pos then
                    sub:SetPos(JVector(v.pos))
                end
                if v.ang then
                    sub:SetAng(JVector(v.ang))
                end
            end
        end
    end 
end)
