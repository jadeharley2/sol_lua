
local schema_path = "forms/_meta/schema/"

local schemas = json.schemas or {}
json.schemas = schemas

function json.GetSchema(keytype)
	local trg = string.split(keytype, '/')
	local frs = schemas[trg[1]]
	local ctr = #trg
	--MsgN("dddd ",ctr)
	if ctr > 1 then
		for k=1,ctr-1 do
			--MsgN("dddd ",k,trg[k+1])
			frs = frs.properties[trg[k+1]]
		end 
	end 
	return frs
end

function json.LoadSchemas()
	for k,v in pairs(file.GetFiles(schema_path),'*.json',true) do
		local key = file.GetFileNameWE(v)
		schemas[key] = json.Read(v)
	end 
	
	for k,v in pairs(schemas) do
		if v.properties then
			for kk,vv in pairs(v.properties) do
				if isstring(vv) then
					v.properties[kk] = json.GetSchema(vv) 
					--MsgN("<>>: ",vv,v.properties[kk])
				end
			end  
		end
		--MsgN("schema: ",k)
	end
end
json.LoadSchemas()