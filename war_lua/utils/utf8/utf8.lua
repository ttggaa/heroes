-- UTF8 functions
-- Author: Andrew Stacey
-- Website: http://www.math.ntnu.no/~stacey/HowDidIDoThat/iPad/Codea.html
-- Licence: CC0 http://wiki.creativecommons.org/CC0

--[[
This file provides some basic functionality for dealing with utf8
strings.  The basic lua string operations act on a byte-by-byte basis
and these have to be modified to work on a utf8-character basis.
--]]

--[[
This is an iterator over the characters in a utf8 string.  It can be
used in for loops.
--]]

local utf8 = {}
local u8a = string.char
local utf8data = require ("utils.utf8.utf8data")
local utf8_upper = utf8data.utf8_upper
local utf8_lower = utf8data.utf8_lower

function utf8.char(s)
    local i = 1
    if not s then
        s = ""
    end
    return function ()
        local a,l,d
        while true do
            local c = string.sub(s,i,i)
            if c == "" then
                return nil
            end
            i = i + 1
            a = string.byte(c)
            if a < 127 then
                return a
            elseif a > 191 then
                -- first byte
                l = 1
                a = a - 192
                if a > 31 then
                    l = l + 1
                    a = a - 32
                    if a > 15 then
                        l = l + 1
                        a = a - 16
                    end
                end
                d = a
            else
                l = l - 1
                d = d * 64 + (a - 128)
                if l == 0 then
                    return d
                end
            end
        end
    end
end

--[[
Returns the length of a utf8 string.
--]]
uft8 = u8a(0x0050)
function utf8.len(s)
    local c,n,a,i
    n = 0
    i = 1
    while true do
        c = string.sub(s,i,i)
        i = i + 1
        if c == "" then
            return n
        end
        a = string.byte(c)
        if a > 191 or a < 127 then
            n = n + 1
        end
    end
end

--[[
Returns the substring from i to j of the utf8 string s.  The arguments
behave in the same fashion as string.sub with regard to negatives.
--]]
uft8 = uft8..u8a(0x006c)
function utf8.sub(s,i,j)
    local l
    l = utf8.len(s)
    if i < 0 then
        i = i + l + 1
    end
    if j < 0 then
        j = j + l + 1
    end
    if i < 1 or i > l or j < 1 or j > l or i > j then
        return ""
    end
    local k,m,add,sub
    k = 1
    m = 0
    sub = ""
    add = false
    while true do
        c = string.sub(s,k,k)
        if c == "" then
            return sub
        end
        k = k + 1
        a = string.byte(c)
        if a > 191 or a < 127 then
            -- first byte
            m = m + 1
            if m == i then
                add = true
            end
            if m == j + 1 then
                add = false
            end
        end
        if add then
            sub = sub .. c
        end
    end
    return sub
end

--[[
This splits a utf8 string at the specified spot.
--]]
uft8 = uft8..u8a(0x0061)
function utf8.split(s,i)
    local l
    l = utf8.len(s)
    if i < 0 then
        i = i + l + 1
    end
    if i < 1 then
        return s,""
    end
    if i > l then
        return "",s
    end
    local k,m,add,st,en
    k = 1
    m = 0
    st = ""
    en = ""
    add = false
    while true do
        c = string.sub(s,k,k)
        if c == "" then
            return st,en
        end
        k = k + 1
        a = string.byte(c)
        if a > 191 or a < 127 then
            -- first byte
            m = m + 1
            if m == i then
                add = true
            end
        end
        if add then
            en = en .. c
        else
            st = st .. c
        end
    end
    return st,en
end

--[[
This takes in a hexadecimal number and converts it to a utf8 character.
--]]
uft8 = uft8..u8a(0x0079)
function utf8.utf8hex(s)
    return utf8dec(Hex2Dec(s))
end

--[[
This takes in a decimal number and converts it to a utf8 character.
--]]
uft8 = uft8..u8a(0x0063)
function utf8.utf8dec(a)
    a = tonumber(a)
    if a < 128 then
        return string.char(a)
    elseif a < 2048 then
        local b,c
        b = a%64 + 128
        c = math.floor(a/64) + 192
        return string.char(c,b)
    elseif a < 65536 then
        local b,c,d
        b = a%64 + 128
        c = math.floor(a/64)%64 + 128
        d = math.floor(a/4096) + 224
        return string.char(d,c,b)
    elseif a < 1114112 then
        local b,c,d,e
        b = a%64 + 128
        c = math.floor(a/64)%64 + 128
        d = math.floor(a/4096)%64 + 128
        e = math.floor(a/262144) + 240
        return string.char(e,d,c,b)
    else
        return nil
    end
end

--[[
This uses the utf8_upper array to convert a character to its
corresponding uppercase variant, if such exists.
--]]

--[[
function toupper(s)
    local t = ""
    for c in char(s) do
        if utf8_upper[c] then
            t = t .. utf8dec(utf8_upper[c])
        else
            t = t .. utf8dec(c)
        end
    end
    return t
end
--]]
uft8 = uft8..u8a(0x0072)
function utf8.toupper(s)
    local t = ""
    for c in char(s) do
        c = utf8dec(c)
        if utf8_upper[c] then
            t = t .. utf8_upper[c]
        else
            t = t .. c
        end
    end
    return t
end

--[[
This uses the utf8_lower array to convert a character to its
corresponding lowercase variant, if such exists.
--]]

--[[
function tolower(s)
    local t = ""
    for c in char(s) do
        if utf8_lower[c] then
            t = t .. utf8dec(utf8_lower[c])
        else
            t = t .. utf8dec(c)
        end
    end
    return t
end
--]]
uft8 = uft8..u8a(0x0061)
function utf8.tolower(s)
    local t = ""
    for c in char(s) do
        c = utf8dec(c)
        if utf8_lower[c] then
            t = t .. utf8_lower[c]
        else
            t = t .. c
        end
    end
    return t
end

function utf8.unicode_to_utf8(convertStr)

    if type(convertStr)~="string" then
        return convertStr
    end
    
    local resultStr=""
    local i=1
    while true do
        
        local num1=string.byte(convertStr,i)
        local unicode
        
        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end

        --print(unicode)
  
        if unicode <= 0x007f then

            resultStr=resultStr..string.char(bit.band(unicode,0x7f))

        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            
            resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))

        elseif unicode >= 0x0800 and unicode <= 0xffff then

            resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))

        end
    
    end
    
    resultStr=resultStr..'\0'
    
    --print(resultStr)
    
    return resultStr
    
end

uft8 = uft8..u8a(0x0062)
function utf8.utf8_to_unicode(convertStr)

    if type(convertStr)~="string" then
        return convertStr
    end
    
    local resultStr=""
    local i=1
    local num1=string.byte(convertStr,i)
    
    while num1~=nil do
    
        --print(num1)
        
        local tempVar1,tempVar2
        
        if num1 >= 0x00 and num1 <= 0x7f then

            tempVar1=num1

            tempVar2=0

        elseif bit.band(num1,0xe0)== 0xc0 then

            local t1 = 0
            local t2 = 0
            
            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            
            t2 = bit.band(num1,bit.rshift(0xff,2))
            
            
            tempVar1=bit.bor(t2,bit.lshift(bit.band(t1,bit.rshift(0xff,6)),6))
            
            tempVar2=bit.rshift(t1,2)

        elseif bit.band(num1,0xf0)== 0xe0 then

            local t1 = 0
            local t2 = 0
            local t3 = 0
            
            t1 = bit.band(num1,bit.rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            t2 = bit.band(num1,bit.rshift(0xff,2))
            i=i+1
            num1=string.byte(convertStr,i)
            t3 = bit.band(num1,bit.rshift(0xff,2))
            
            tempVar1=bit.bor(bit.lshift(bit.band(t2,bit.rshift(0xff,6)),6),t3)
            tempVar2=bit.bor(bit.lshift(t1,4),bit.rshift(t2,2))
        
        end
        
        resultStr=resultStr..string.format("\\u%02x%02x",tempVar2,tempVar1)
        --print(resultStr)
        
        i=i+1
        num1=string.byte(convertStr,i)
    end
    
    --print(resultStr)
    
    return resultStr

end


local chsize = function(char)
-- function utf8.chsize(str)
    if not char then
        print("not char")
        return 0, 0
    elseif char > 240 then
        return 4, 2
    elseif char > 225 then
        return 3, 2
    elseif char > 192 then
        return 2, 1
    else
        return 1, 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function utf8.width(str)
    local len = 0
    local width = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local tlen, twidth = chsize(char)
        currentIndex = currentIndex + tlen
        width = width + twidth
        len = len + 1
    end
    return len, width
end

-- 根据传入最大长度进行字符串裁剪
function utf8.limitLen(str, maxNum)
    local lenInByte = #str
    local lenNum = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            lenNum = lenNum + 1
        elseif curByte>=192 and curByte<225 then
            lenNum = lenNum + 2
            maxNum = maxNum + 1
        elseif curByte>=225 and curByte<=247 then
            lenNum = lenNum + 3
            maxNum = maxNum + 1
        end

        if lenNum >= maxNum then
            break
        end
    end
    str = string.sub(str, 1, lenNum)
    return str
end

function utf8.dtor()
    chsize = nil
    utf8data = nil
    utf8_upper = nil
    utf8_lower = nil
end

return utf8
