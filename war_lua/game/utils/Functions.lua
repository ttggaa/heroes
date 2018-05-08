-- @deprecated
function copyTab(st)
    return table.copy(st)
end


--[[
    @desc Convert byte number to human readable string.
    @param bytes Number of bytes.
    @return a string ends with "B"/"KB"/"MB".
]]
function byteToString(bytes)
    if bytes < 1024 then
        return string.format("%.2f", bytes) .. " B"
    end
    bytes = bytes / 1024;
    if bytes < 1024 then
        return string.format("%.2f", bytes) .. " KB"
    end
    bytes = bytes / 1024;
    return string.format("%.2f", bytes) .. " MB"
end



--[[
    @desc Display contents in the object.
    @param object Object to be dumped.
    @param label [optional]  The object name. String "class" is reserved for 
        internal use.
    @param maxNesting [optional]  The maximum nesting count.
]]


function PCLuaError(msg)
    pc.PCTools:showError(msg)
end

local _dump = dump
local _print = print

if GameStatic.superDebug == "playcrab19870515" then 
    local maxLine = GameStatic.consoleMaxLine
    local console = {}
    local hasNew
    local needReload
    local function printToConsole(msg)
        console[#console + 1] = msg
        -- 超过300 删除前面50条
        if #console > maxLine then
            local newConsole = {}
            for i = 51, #console do
                newConsole[i - 50] = console[i]
            end
            console = newConsole
            needReload = true
        end
        hasNew = true
    end

    function CONSOLE_GETLOG()
        return console
    end

    function CONSOLE_NEEDRELOAD()
        local _needReload = needReload
        if needReload then
            needReload = false
        end
        return _needReload
    end

    function CONSOLE_HASNEW()
        local _hasNew = hasNew
        if hasNew then
            hasNew = false
        end
        return _hasNew
    end

    local function sddump_value_(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function sddump(value, desciption, nesting)
        if type(nesting) ~= "number" then nesting = 6 end

        local lookupTable = {}
        local result = {}

        local traceback = string.split(debug.traceback("", 2), "\n")
        printToConsole("dump from: " .. string.trim(traceback[5]))

        local function dump_(value, desciption, indent, nest, keylen)
            desciption = desciption or "<var>"
            local spc = ""
            if type(keylen) == "number" then
                spc = string.rep(" ", keylen - string.len(sddump_value_(desciption)))
            end
            if type(value) ~= "table" then
                result[#result +1 ] = string.format("%s%s%s = %s", indent, sddump_value_(desciption), spc, sddump_value_(value))
            elseif lookupTable[tostring(value)] then
                result[#result +1 ] = string.format("%s%s%s = *REF*", indent, sddump_value_(desciption), spc)
            else
                lookupTable[tostring(value)] = true
                if nest > nesting then
                    result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, sddump_value_(desciption))
                else
                    result[#result +1 ] = string.format("%s%s = {", indent, sddump_value_(desciption))
                    local indent2 = indent.."    "
                    local keys = {}
                    local keylen = 0
                    local values = {}
                    for k, v in pairs(value) do
                        keys[#keys + 1] = k
                        local vk = sddump_value_(k)
                        local vkl = string.len(vk)
                        if vkl > keylen then keylen = vkl end
                        values[k] = v
                    end
                    table.sort(keys, function(a, b)
                        if type(a) == "number" and type(b) == "number" then
                            return a < b
                        else
                            return tostring(a) < tostring(b)
                        end
                    end)
                    for i, k in ipairs(keys) do
                        dump_(values[k], k, indent2, nest + 1, keylen)
                    end
                    result[#result +1] = string.format("%s}", indent)
                end
            end
        end
        dump_(value, desciption, "- ", 1)

        for i, line in ipairs(result) do
            printToConsole(line)
        end
    end

    dump = function (object, tip, nesting)
        if object == nil then
            return
        end
        sddump(object, tip, nesting)
    end

    print = function (...)
        local args = {...}
        local printString = ""
        for k,v in pairs(args) do
            if k > 1 then 
                printString = printString .. "    "
            end
            if type(v) == "table" or 
                type(v) == "userdata" or 
                type(v) == "function" then
                printString = printString .. type(v)
            else
                if type(v) == "string" then 
                    local uresult,count1 = string.gsub(v, " ", "﹎")
                    if count1 > 0 then 
                        v = uresult
                    end
                    local uresult,count1 = string.gsub(v, "　", "﹎")
                    if count1 > 0 then 
                        v = uresult
                    end
                end
                printString = printString .. tostring(v)
            end
        end
        printToConsole(printString)
    end
else
    if GameStatic.closeLog or not GameStatic.openDumpLog then
        dump = function ()
            -- to nothing
        end
    else
        dump = function (object, tip, nesting)
            if object == nil then
                return
            end
            _dump(object, tip, nesting)
        end
    end

    if GameStatic.closeLog or not GameStatic.openDebugLog then 
        print = function ()
            -- to nothing
        end
    else
        print = function (...)
            local args = {...}
            local printString = ""
            for k,v in pairs(args) do
                if k > 1 then 
                    printString = printString .. "    "
                end
                if type(v) == "table" or 
                    type(v) == "userdata" or 
                    type(v) == "function" then
                    printString = printString .. type(v)
                else
                    if type(v) == "string" then 
                        local uresult,count1 = string.gsub(v, " ", "﹎")
                        if count1 > 0 then 
                            v = uresult
                        end
                        local uresult,count1 = string.gsub(v, "　", "﹎")
                        if count1 > 0 then 
                            v = uresult
                        end
                    end
                    printString = printString .. tostring(v)
                end
            end
            _print(printString)
        end
    end
end

---------------
--http://zh.wikipedia.org/wiki/specialize
--
function specialize(f, ...)
    local args = {...}
    return function (...)
        local vars = {...}
        local a = {}
        for i,v in ipairs(args) do
            a[#a+1] = v
        end
        for i,v in ipairs(vars) do
            a[#a+1] = v
        end
        return f(unpack(a))
    end
end

--[[
    @desc Split a string.
    @param str  The source string.
    @param sep  The seperator string.
    @param count The maximum count of substrings.
    @return An array contains the splited substrings. If `count` is provided and
        it's greator then 0, the last substring is the remaining part of the 
        original string.
]]

function string.split(str, sep, count)
    if string.find(str, sep) == nil then
        return { str }
    end

    if count==nil or count<1 then
        count = 0
    end

    local result = {}
    local n = 0
    local p = "(.-)" .. sep
    local nextPos = 1
    while true do
        n = n+1
        if (count>0 and count<=n) then
            result[n] = string.sub(str, nextPos)
            break
        end

        local s, e, substr = string.find(str, p, nextPos)
        if s==nil then
            result[n] = string.sub(str, nextPos)
            break
        else
            result[n] = substr
            nextPos = e+1
        end
    end

    return result
end

-- 获取字符串字节数 一个英文一个字节，一个中文两个字节
function limitLen(str)
    if not str or str == "" then
        return 0
    end
    local lenInByte = #str
    local lenNum = 0
    local maxlen = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            lenNum = lenNum + 1
            maxlen = maxlen + 1
        elseif curByte>=192 and curByte<=247 then
            lenNum = lenNum + 3
            maxlen = maxlen + 2
        end
        -- if lenNum >= maxNum then
        --     break
        -- end
    end
    return maxlen
end

function formatDate(seconds,dataformat)
    -- body
    seconds = tonumber(seconds)

    dataformat = dataformat or "%Y-%m-%d %H:%M:%S"

    return os.date(dataformat,seconds);
end

--e.g: seconds = 10000 return  02:46:40
function formatTime(seconds)
    local function _twoDigitCompletion(str)
        if string.len(str) == 1 then
            str = "0"..str;
        end 
        return str;
    end
    local timeStr = nil;
    local seconds = math.floor(seconds);
    local minutes = math.floor(seconds / 60);
    local hours = math.floor(minutes / 60);
    local hourStr = tostring(hours % 24);
    hourStr = _twoDigitCompletion(hourStr);
    local minuteStr = tostring(minutes % 60); 
    minuteStr = _twoDigitCompletion(minuteStr); 
    local secondStr = tostring(seconds % 60);
    secondStr = _twoDigitCompletion(secondStr)
    timeStr = minuteStr .. ":" .. secondStr; -- hourStr .. ":" .. minuteStr .. ":" .. secondStr; 
    return timeStr;
end
function getFeatureColorByAccount(count)
    -- body
    local color 
    if count <= 0 then 
        color = tab:getValueTableBykey(35)
    elseif count < tab:getValueBykey(33) then 
        color = tab:getValueTableBykey(36)
    else
        color = tab:getValueTableBykey(37)
    end
    return cc.c3b(color[1],color[2],color[3]);
end

function pairsByKeys(t)  
    local a = {}
    for n in pairs(t) do
        a[#a+1] = n
    end
    table.sort(a)
    local i = 0  
    return function()  
        i = i + 1  
        return a[i], t[a[i]]  
    end  
end 

function delete(class)
    if type(class) ~= "table" then return end
    local _type
    for k, v in pairs(class) do
        _type = type(v)
        if _type == "table" or _type == "userdata" then
            class[k] = nil
        end
    end
end
