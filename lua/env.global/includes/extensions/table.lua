

--example ({['a.u'] = 2,['a.z'] = 3},'.') => {a={ u:2,z:3 }}  
table.MakeKVTree = function(strdict,separator)
   local root = {}
   for k,v in pairs(strdict) do
      --MsgN(k)
      local parts = k
      if isstring(k) then
         parts = string.split(k,separator) 
      else
         return root
         --error("key is not string")
      end

      local node = root
      if istable(node) then
         local pcount = #parts
         for kk, vv in pairs(parts) do
            local nnode = node[vv]
            if not nnode then
               if kk==pcount then
                  nnode = v
               else
                  nnode = {}
               end
               if istable(node) then
                  node[vv] = nnode
               end
            end
            node = nnode
         end
      end
   end
   return root
end

--example ({'a.u','a.z'},'.') => {a={ u:{},z:{} }}  
table.MakeTree = function(strarray,separator)
   local root = {} 
   for k,v in pairs(strarray) do 

      local parts = v
      if isstring(v) then
         parts = string.split(v,separator) 
      end

      local node = root
      local pcount = #parts
      for kk, vv in pairs(parts) do
         local nnode = node[vv]
         if not nnode then
            if kk==pcount then
               nnode = true
            else
               nnode = {}
            end
            node[vv] = nnode
         end
         node = nnode
      end
      
   end
   return root
end

table.get = function(t,key,separator) 
   local n = t
   for k,v in pairs(string.split(key,separator or '.')) do 
      n = n[v]
      if n==nil then return nil end
   end
   return n
end

table.count = function(t)
   local c = 0
   for k,v in pairs(t) do
      c = c + 1
   end
   return c
end
