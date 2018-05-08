-- 内存泄漏检查相关

-- 弱引用表, 当某对象只有该表引用的时候，会自动取消引用
G_weak = {}
setmetatable(G_weak, {__mode = "kv"})

local SHOW_TABLE 		 = true
local SHOW_FUNCTION 	 = true
local SHOW_USERDATA		 = true
local SHOW_OTHER		 = true

local SHOW_CLASS		 = true
local SHOW_CLASS_DETAIL  = false

local SHOW_FIND_RES		 = false

local TraversaledObj = {}

local function MemLC_addToGWeak(root)
	if G_weak[root] then
		G_weak[root] = G_weak[root] + 1
	else
		G_weak[root] = 1
	end
end

local function MemLC_CheckObj(root)
	local _type = type(root)
	if _type == "table" then
		MemLC_addToGWeak(root)
		if TraversaledObj[root] == nil then
			TraversaledObj[root] = true
			for k, v in pairs(root) do
				MemLC_CheckObj(k)
				MemLC_CheckObj(v)
			end
			local metatable = debug.getmetatable(root)
	        if metatable then
	            MemLC_CheckObj(metatable)
	        end
		end
	elseif _type == "function" then
		MemLC_addToGWeak(root)
		if TraversaledObj[root] == nil then
			TraversaledObj[root] = true

			MemLC_CheckObj(getfenv(root))

		    local uvIndex = 1  
		    while true do  
		        local name, value = debug.getupvalue(root, uvIndex)  
		        if name == nil then  
		            break  
		        end  
		        MemLC_CheckObj(value)
		        uvIndex = uvIndex + 1  
		    end 
		end
	elseif _type == "thread" then
		MemLC_addToGWeak(root)
		local metatable = debug.getmetatable(root)
        if metatable then
            MemLC_CheckObj(metatable)
        end
	elseif _type == "userdata" then
		MemLC_addToGWeak(root)
		local metatable = debug.getmetatable(root)
        if metatable then
            MemLC_CheckObj(metatable)
        end
	end
end

local FindedObj = {}
local FindCount = 0
local function MemLC_FindOne(root, obj)
	local _type = type(root)
	local find = root == obj
	if find then
		FindCount = FindCount + 1
	end
	if _type == "table" and root ~= TraversaledObj and root ~= G_weak and root ~= FindedObj then
		if FindedObj[root] == nil then
			FindedObj[root] = true
			for k, v in pairs(root) do
				local findone = false
				if MemLC_FindOne(k, obj) then
					if SHOW_FIND_RES then
						Gprint("find in table key, key=", k, "value=", v, k == v)
					end
					findone = true
				end
				if MemLC_FindOne(v, obj) then
					if SHOW_FIND_RES then
						Gprint("find in table value, key=", k)
					end
					findone = true
				end
				if findone then
					if SHOW_FIND_RES then
						if root.class then
							Gprint("table=classInst", root.__cname)
						elseif root.__cname then
							Gprint("table=class", root.__cname)
						end
					end
				end
			end
			local metatable = debug.getmetatable(root)
	        if metatable then
	            MemLC_FindOne(metatable, obj)
	        end
		end
	elseif _type == "function" then
		if FindedObj[root] == nil then
			FindedObj[root] = true

			if MemLC_FindOne(getfenv(root), obj) then
				if SHOW_FIND_RES then
					Gprint("find in function env, func=", root)
					-- root()
				end
			end

		    local uvIndex = 1  
		    while true do  
		        local name, value = debug.getupvalue(root, uvIndex)  
		        if name == nil then  
		            break  
		        end  
		        if MemLC_FindOne(value, obj) then
		        	if SHOW_FIND_RES then
		        		Gprint("find in function upvalue, name=", name)
		        		-- root()
		        	end
		        end
		        uvIndex = uvIndex + 1  
		    end 
		end
	elseif _type == "thread" then
		local metatable = debug.getmetatable(root)
        if metatable then
            MemLC_FindOne(metatable, obj)
        end
	elseif _type == "userdata" then
		local metatable = debug.getmetatable(root)
        if metatable then
            MemLC_FindOne(metatable, obj)
        end
	end
	return find
end

function MemLC_FindObject(obj)
	FindedObj = {}
	FindCount = 0

	MemLC_FindOne(debug.getregistry(), obj)
	MemLC_FindOne(_G, obj) -- getfenv(debug.getmetatable) == _G
	MemLC_FindOne(debug.getmetatable, obj)

	FindedObj = {}
	return FindCount
end

function MemLC_Traversal()
	for k, v in pairs(G_weak) do
		G_weak[k] = nil
	end
	TraversaledObj = {}
	MemLC_CheckObj(debug.getregistry())
	MemLC_CheckObj(_G) -- getfenv(debug.getmetatable) == _G
	MemLC_CheckObj(debug.getmetatable)

	TraversaledObj = {}
end

function MemLC_Dump()
	local countArr = {}
	for k, v in pairs(G_weak) do
		countArr[#countArr + 1] = {k, v}
	end
	table.sort(countArr, function (a, b)
		return a[2] > b[2]
	end)
	local _type, inG, inRegistry, str, count2
	for i = 1, #countArr > 100 and 100 or #countArr do
		local obj, count = countArr[i][1], countArr[i][2] 
		_type = type(obj)
		inRegistry, inG = nil, nil
		for k, v in pairs(_G) do
			if v == obj then
				inG = k
			elseif k == obj then
				inG = "key"
			end
		end
		for k, v in pairs(debug.getregistry()) do
			if v == obj then
				inRegistry = k
			elseif k == obj then
				inRegistry = "key"
			end
		end

		if inG then
			str = "[G]"..inG
		elseif inRegistry then
			str = "[R]"..inRegistry
		else
			str = ""
		end
		count = string.format("% 5d", count)
		if _type == "table" then
			if obj.__cname then
				if SHOW_CLASS then
					if obj.class then
						count2 = MemLC_FindObject(obj)
						count2 = string.format("% 5d", count2)
						Gprint(count, count2, "[classInst] "..obj.__cname, str)
						if SHOW_CLASS_DETAIL then
							dump(obj)
						end
					else
						count2 = MemLC_FindObject(obj)
						count2 = string.format("% 5d", count2)
						Gprint(count, count2, "[class] "..obj.__cname, str)
						if SHOW_CLASS_DETAIL then
							dump(obj)
						end
					end
				end
			else
				if SHOW_TABLE then
					local key = next(obj)
					count2 = MemLC_FindObject(obj)
					count2 = string.format("% 5d", count2)
					if type(key) == "number" or type(key) == "string" then
						Gprint(count, count2, "[table] "..key, str)
					else
						Gprint(count, count2, "[table] "..type(key), str)
					end
				end
			end
		elseif _type then
			if _type == "function" and SHOW_FUNCTION then
				count2 = MemLC_FindObject(obj)
				count2 = string.format("% 5d", count2)
				Gprint(count, count2, "[".._type.."]", str)
			elseif _type == "userdata" and SHOW_USERDATA then
				count2 = MemLC_FindObject(obj)
				count2 = string.format("% 5d", count2)
				Gprint(count, count2, "[".._type.."]", str)
			else
				if SHOW_OTHER then
					count2 = MemLC_FindObject(obj)
					count2 = string.format("% 5d", count2)
					Gprint(count, count2, "["..obj.."]", str)
				end
			end
		else
			if SHOW_OTHER then
				count2 = MemLC_FindObject(obj)
				count2 = string.format("% 5d", count2)
				Gprint(count, count2, "["..obj.."]", str)
			end
		end

	end
end