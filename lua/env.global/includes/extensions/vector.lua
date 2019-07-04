

function VectorToString(vec)
    return '['..vec.x..', '..vec.y..', '..vec.z..']'
end
function StringToVector(str)
    local a =cstring.replace( cstring.replace(string.trim(str),'[','',nil,true),']','',nil,true)
    local x,y,z = unpack(string.split(a,','))
    return Vector(tonumber(x),tonumber(y),tonumber(z))
end