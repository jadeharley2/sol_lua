
--[[

function sortby(tt,func) 
	local nkd = {}
	local nks = {}
	for	k,v in pairs(tt) do
		local val = func(v)
		nkd[val] = v
		nks[k] = val
	end
	table.sort(nks)
	local rez = {}
	for	k,v in pairs(nks) do
		rez[k] = nkd[v]
	end
	return rez
end


function line_intersection(l1p1, l1p2, l2p1, l2p2)

	local dir1 = l1p2 - l1p1
	local dir2 = l2p2 - l2p1

	local a1 = -dir1.y
	local b1 = +dir1.x
	local d1 = -(a1 * l1p2.x + b1 * l1p2.y)

	local a2 = -dir2.y
	local b2 = +dir2.x
	local d2 = -(a2 * l2p2.x + b2 * l2p2.y)

	local seg1_line2_start = a2 * l1p1.x + b2 * l1p1.y + d2
	local seg1_line2_end = a2 * l1p2.x + b2 * l1p2.y + d2

	local seg2_line1_start = a1 * l2p1.x + b1 * l2p1.y + d1
	local seg2_line1_end = a1 * l2p2.x + b1 * l2p2.y + d1

	if (seg1_line2_start * seg1_line2_end >= 0 || seg2_line1_start * seg2_line1_end >= 0) then
		return false
	end

	local u = seg1_line2_start / (seg1_line2_start - seg1_line2_end)
	if (u > 0.9999 || u < 0.0001) then
		return false
	end 
	return true
end






function TEST11()

	local points = {}
	local rand = Random(131)
	local vmin = Vector(-100,-100,0)
	local vmax = Vector(100,100,0) 
	for k=1,100 do 
		points[k] ={ p =  rand:NextVector(vmin,vmax)}
	end
	local segments = {} 
	for k,p1 in pairs(points) do
		local sorted = sortby(points,function(val) return p1.p:DistanceSquared(val.p) end)
		for k2=1,10 do
			local p2 = points[k2]
			local add = true
			for _,seg in pairs(segments) do
				if (seg.p1 == p1 and seg.p2 == p2) or (seg.p1 == p2 and seg.p2 == p1) then
					add = false
					break
				end
				if line_intersection(p1.p,p2.p,seg.p1.p,seg.p2.p) then
					add = false
					break
				end
			end
			if add then
				local seg = {["p1"] = p1, ["p2"] = p2}
				p1.s = p1.s or {}
				p2.s = p2.s or {}
				segments[#segments+1] = seg
				p1.s[#p1.s+1] = seg
				p2.s[#p2.s+1] = seg 
			end
		end 
	end 
	local triangles = {}
	for k,p in pairs(points)  
		for k1,seg1 in pairs(p.s) do
			for k2,seg2 in pairs(p.s) do
				if k1 ~= k2 then
					local valid = false
					for k3,seg3 in pairs(
				end
			end
		end
	end
	
end
]]