
local forms = forms

function forms.ReadForm(form)
	local path = forms.GetForm(form)
	if path then
		local j = json.Read(path)
		return j
	end
end
function forms.LoadForm(form)
	local path = forms.GetForm(form)
	if path then
		local j = json.Load(path)
		return j
	end
end