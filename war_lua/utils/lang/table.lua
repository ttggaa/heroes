
--[[
    @desc Get all values in a table.
    @param t  The target table.
    @return An array contains all values.
]]
table.values = function (t)
    local ret = {}
    for _,v in pairs(t) do
        table.insert(ret, v)
    end
    return ret
end

--[[
    @desc Get all keys in a table.
    @param t  The target table.
    @param cmp  Comparation function used for sorting the values.
    @return An array contains all keys. If `cmp` is provided, keys will be
        sorted by their correponding values.
]]
table.keys = function (t, cmp)
    local ret = {}
    if cmp == nil then
        for k in pairs(t) do
            table.insert(ret, k)
        end
    else
        local reverse_map = {}
        local values = {}
        for k,v in pairs(t) do
            reverse_map[v] = k
            table.insert(values, v)
        end
        table.sort(values, cmp)
        for i,v in ipairs(values) do
            table.insert(ret, reverse_map[v])
        end
    end
    return ret
end

table.length = function ( t )
    -- body
    local count = 0 
    for k,v in pairs(t) do 
        count = count +1 ;
    end
    return count
end
--[[
    @desc Get the capacity of a table (the number of key-value pairs).
    @return The capacity of `t`.
]]
table.capacity = function (t)
    local cnt = 0
    local a = nil
    while true do
        a = next(t, a)
        if a==nil then
            break
        end
        cnt = cnt+1
    end
    return cnt
end

--[[
    @desc Copy all key-value pairs to another one.
    @param src  The source table.
    @param dest The destination. An empty table will be created if it's nil.
    @return The destination table.
]]
table.copy = function (src, dest)
    local u = dest or {}
    for k, v in pairs(src) do
        -- print(k, v);
        u[k] = v
    end
    if type(getmetatable(src)) == "string" then
        print("error!", "metatable.__metatable used, can't get metatable");
        return u;
    else
        return setmetatable(u, getmetatable(src))
    end 
end

--[[
    @desc Copy all key-value pais to another one. If the value is a table, it
        will also be deep copied.
    @param src  The source table.
    @param dest The destination. An empty table will be created if it's nil.
    @return The destination table.
]]
table.deepCopy = function (src, dest)
    local function _deepCopy(from ,to)
        --to is a instance of objectlua Class, use clone() method
        if from.isKindOf ~= nil and from:isKindOf(objectlua.Object) == true then 
            to = from:clone();
            return to;
        end 
        for k, v in pairs(from) do
            if type(v) ~= "table" then
                to[k] = v
            else
                to[k] = {}
                _deepCopy(v, to[k])
            end
        end
        if type(getmetatable(to)) == "string" then
            print("error!", "metatable.__metatable used, can't get metatable");
            return to;
        else
            return setmetatable(to, getmetatable(from))
        end 
    end
    return _deepCopy(src, dest or {})
end

--[[
    @desc Find value in a table.
    @param t  The target table.
    @param value  The value to search for.
    @param startKey The key (excluded) from which the searching starts.
    @return (k,v) if successes, nil if fails.
]]
table.find = function (t, value, startKey)
    local k, v = next(t, startKey)
    while k~=nil do
        if v==value then
            return k, v
        end
        k, v = next(t, k)
    end
    return nil
end

--[[
    @desc
    ...
]]
table.indexOf = function (t, value, start)
    assert(false, "to be implemented!!")
end
