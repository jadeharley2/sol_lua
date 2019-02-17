local coord_meta = coord_meta or {}

function coord_meta:World(c2)
	return matrix.Translation(c2[2]) * self[1]:GetLocalSpace(c2[1]) * matrix.Translation(-self[2]) 
end

function coord_meta:Position(c2) 
	return self:World(c2):Position()
end
function coord_meta:DistanceSquared(c2) 
	return self:World(c2):Position():LengthSquared()
end
function coord_meta:Distance(c2) 
	return self:World(c2):Position():Length()
end
function coord_meta:Direction(c2) 
	return self:World(c2):Position():Normalized()
end

function coord_meta:RealPosition(c2) 
	return self:Position(c2)*self[1]:GetSizepower()
end
function coord_meta:RealDistanceSquared(c2) 
	return self:DistanceSquared(c2)*self[1]:GetSizepower()
end
function coord_meta:RealDistance(c2) 
	return self:Distance(c2)*self[1]:GetSizepower()
end

coord_meta.__index = coord_meta
coord_meta.__newindex = coord_meta

function Coordinate(origin,pos)
	local c = {origin,pos or Vector(0,0,0)}
	setmetatable(c,coord_meta)
	return c
end