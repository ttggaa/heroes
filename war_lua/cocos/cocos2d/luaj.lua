
local luaj = {}

local callJavaStaticMethod = LuaJavaBridge.callStaticMethod

local function checkArguments(args, sig)
    if type(args) ~= "table" then args = {} end
    if sig then return args, sig end
    if table.nums(args) >= 0 then
        local isHashMap = true
        for k, v in pairs(args) do
            if type(k) ~= "string" or (type(v) ~= "string" and type(v) ~= "number") then
                isHashMap = false
                break
            end
        end
        if isHashMap then
            sig = "(Ljava/util/HashMap;)Ljava/lang/String;"
            return {args}, sig
        end
    end
    sig = {"("}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    sig[#sig + 1] = ")V"
    return args, table.concat(sig)
end

function luaj.callStaticMethod(className, methodName, args, sig)
    local args, sig = checkArguments(args, sig)
    --echoInfo("luaj.callStaticMethod(\"%s\",\n\t\"%s\",\n\targs,\n\t\"%s\"", className, methodName, sig)
    return callJavaStaticMethod(className, methodName, args, sig)
end

return luaj
