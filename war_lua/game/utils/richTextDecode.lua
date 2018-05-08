--[[
    Filename:    richTextDecode.lua
    Author:      <guanfeng@playcrab.com> 
    Datetime:    2014-10-08 17:58:19
    Description: transform special string format to lua table to describe richText

    e.g:
        str = " \
            [color= aabbcc ,font = 黑体,fontsize=20,shadow=0,stroke=0] \
                今天天气 \
                [  color= 150,font=黑体,fontsize=20,shadow=0,stroke=0] \
                    真   \
                    [color =  2a3aa,font=黑体,fontsize=20,shadow=0,stroke=0] \
                        他妈 \
                    [-] \
                    [  pic = 'gem.png'] \
                    [ -]\
                    [  gif = 'asset/other/test.gif'] \
                    [ -]\
                    好 \
                        [] [-] \
                [ -] \
                啊! \
            [ -  ] \
            [color=efeefe,font=黑体,fontsize=20,shadow=0,stroke=0] \
                是的 \
            [ -] \
            [] [-]  \
        "

        luaTalbe = richTextDecode(str);
        
        luaTable = {
            [1] = {
                color = {r = 170, g = 187, b = 204}，
                font = "黑体"，
                fontsize = "20",
                shadow = "0",
                stroke = "0",
                content = "今天天气"
            }, 
            [2] = {
                color = {r = 0, g = 1, b = 80}，
                font = "黑体"，
                fontsize = "20",
                shadow = "0",
                stroke = "0",
                content = "真"   
            },
            [3] = {
                color = {r = 2, g = 163, b = 170}，
                font = "黑体"，
                fontsize = "20",
                shadow = "0",
                stroke = "0",
                content = "他妈"   
            },
            [4] = {
                pic='gem.png'   
            },
            [5] = {
                gif='asset/other/test.gif'   
            },
            [6] = {
                color = {r = 0, g = 1, b = 80}，
                font = "黑体"，
                fontsize = "20",
                shadow = "0",
                stroke = "0",
                content = "好"   
            },
            [7] = {
                isNewLine = true -- type is bool 
            },
            [8] = {
                color = {r = 170, g = 187, b = 204}，
                font = "黑体"，
                fontsize = "20",
                shadow = "0",
                stroke = "0",
                content = "啊!"   
            },
            [9] = {
                color = {r = 239, g = 238, b = 254}，
                font = "黑体"，
                fontsize = "20",
                shadow = "0",
                stroke = "0",
                content = "是的"   
            },       
            [10] = {
                isNewLine = true -- type is bool 
            }                 
        }
--]]

--stack begin
local stack = {}

function stack.init(stackCapacityNumber)
    stack.reset();
    stack.setMaxCapacity(stackCapacityNumber)
end

function stack.push(item)
    if stack.isFull() then 
        print(item .. ": stack.push(item) but stack is full.")
    end 
    table.insert(stack, item);
end

function stack.pop()
    local item = nil;
    if stack.isEmpty() then
        return;
    end
    item = table.remove(stack);
    return item;
end

function stack.getTop()
    if stack.isEmpty() then
        return;
    end
    local topItem = stack[#stack];
    return topItem;
end 

function stack.count()
    local count = #stack;
    return count;
end

function stack.isEmpty()
    if stack.count() == 0 then
        return true;
    else
        return false;
    end
end

function stack.isFull()
    if stack.count() == stack._maxCapacity then
        return true;
    else
        return false;
    end
end 

function stack.setMaxCapacity(number)
    local number = number and number or 8
    stack._maxCapacity = number
end

function stack.reset()
    while stack.isEmpty() == false do 
        stack.pop();
    end 
end
--stack end 

--Private functions statement
local private_scanWhitespace;
local private_writeToLuaTable;
local private_scanWitespaceFromBack;
local private_deleteWhiltspaceFrontAndBack;
local private_assertIfBracketsWithCloseOrNothing;
local private_isNextWordClose;

--to save the last operate to judge whether the str to be decoded format is right 
local LastOperateState = {
    kPush = 1, -- last decode operation is push string in stack
    kPop = 2,  -- last decode operation is pop string from stack
    kWriteTable = 3, --last decode operation is fillin richTextLuaTable
    kNone = 4, -- begin operation is kNone
}

--public function

--transform special string format to lua table to describe richText
--return richtext lua table
function richTextDecode(str)
    --To judge whether str format is wrong
    local function _reasonableJudge(currentOperateState, lastOperateState)
        if currentOperateState == LastOperateState.kPush then
            if lastOperateState == LastOperateState.kPush then 
                -- print(str .. ": wrong str format!1")
            end
        elseif currentOperateState == LastOperateState.kPop then
            if lastOperateState == LastOperateState.kPush  then
                -- print(str .. ": wrong str format!2")
            end 
        elseif currentOperateState == LastOperateState.kWriteTable then
            if lastOperateState == LastOperateState.kWriteTable
              or stack.isEmpty() == true then
                -- print(str .. ": wrong str format!3")
            end
        else
            -- print(str .. ": wrong str format!4")
        end
    end

    local luaTable = {};
    local startPos = 1; 
    local endPos = nil;
    local lastOperateState = LastOperateState.kNone;
    startPos = private_scanWhitespace(str, 1);
    if string.sub(str, startPos, startPos) ~= '[' then
        print(str .. ": not begin with [ .")
    end
    stack.init();
    --[[
        scan str
        if [color= xx ,font = xx,fontsize=xx,shadow=xx,stroke=xx] then push stack
        if content e.g: 今天天气 then writeToLuaTable with stack's top Property string
        if [-] pop stack
    ]]
    while true do 
        startPos = private_scanWhitespace(str, startPos);
        if startPos == string.len(str) + 1 then
            if stack.isEmpty() == false then
                -- print(str .. ": wrong str format!5");
            end 
            break;
        end
        if string.sub(str, startPos, startPos) == '[' then
            --delete whiteSpace after '['
            startPos = private_scanWhitespace(str, startPos + 1);
            if startPos == string.len(str) + 1 then
                 -- print(str .. ": wrong str format!6");
                 break
            end 
            --popup stack
            if string.sub(str, startPos, startPos) == '-' then
                _reasonableJudge(LastOperateState.kPop, lastOperateState);
                stack.pop();
                startPos = string.find(str, ']', startPos, true) + 1;
                lastOperateState = LastOperateState.kPop;
            -- put pic table in final table
            elseif string.sub(str, startPos, startPos + 2) == 'pic' then
                endPos = private_assertIfBracketsWithCloseOrNothing(str, startPos);
                local propertyString = private_deleteWhiltspaceFrontAndBack(
                    string.sub(str, startPos, endPos-1)
                )
                private_writeToLuaTable(luaTable, propertyString);
                -- delete next [-]
                startPos = endPos + 1;
                endPos = private_assertIfBracketsWithCloseOrNothing(str, startPos);
                startPos = endPos + 1;
            elseif string.sub(str, startPos, startPos + 2) == 'gif' then
                endPos = private_assertIfBracketsWithCloseOrNothing(str, startPos);
                local propertyString = private_deleteWhiltspaceFrontAndBack(
                    string.sub(str, startPos, endPos-1)
                )
                private_writeToLuaTable(luaTable, propertyString);
                -- delete next [-]
                startPos = endPos + 1;
                endPos = private_assertIfBracketsWithCloseOrNothing(str, startPos);
                startPos = endPos + 1;
            --begin with [],  deal with [] [-],  create a value {isNewLIne = true}.
            elseif string.sub(str, startPos, startPos) == ']' then 
                startPos = private_isNextWordClose(str, startPos + 1);
                if startPos then 
                    local t = {["isNewLine"] = true};
                    luaTable[#luaTable + 1] = t;
                else 
                    -- print(str .. ": wrong str format!7");
                    break
                end 
            --push property in stack
            else
                _reasonableJudge(LastOperateState.kPush, lastOperateState); 
                endPos = private_assertIfBracketsWithCloseOrNothing(str, startPos);
                stack.push(string.sub(str, startPos, endPos - 1));
                startPos = endPos + 1;
                lastOperateState = LastOperateState.kPush;
            end 
        else 
            _reasonableJudge(LastOperateState.kWriteTable, lastOperateState);
            local stackTopPropertyString = stack.getTop();
            endPos = string.find(str, '[', startPos, true);
            local contentString = string.sub(str, startPos, endPos - 1);
            private_writeToLuaTable(luaTable, stackTopPropertyString, contentString);
            startPos = endPos;
            lastOperateState = LastOperateState.kWriteTable;
        end
    end 
    stack.reset();
    return luaTable;
end

-- check whether after startPos, 3 non blank word is [-]
-- return nil or the position after ']'
function private_isNextWordClose(str, startPos)
    local pos = nil;
    pos = private_scanWhitespace(str, startPos);
    if '[' ~= string.sub(str, pos, pos) then 
        return nil;
    end 
    pos = private_scanWhitespace(str, pos + 1);
    if '-' ~= string.sub(str, pos, pos) then 
        return nil;
    end 
    pos = private_scanWhitespace(str, pos + 1);
    if ']' ~= string.sub(str, pos, pos) then 
        return nil;
    end 
    return pos + 1;
end

-- check the position of ] in str
-- if ] is the first letter, means there is [] in str, assert wrong format!
-- if ] is not found, assert wrong format! 
-- else return the positon of ] in str  
function private_assertIfBracketsWithCloseOrNothing(str, startPos)
    local endPos;
    endPos = string.find(str, ']', startPos, true);
    if endPos == nil or startPos  > endPos - 1 then 
        print(str .. ": wrong str format!8");
    end 
    return endPos;
end 


-- Scans a string skipping all whitespace from the current start position.
-- Returns the position of the first non-whitespace character,
-- or string.len(s)+1 if the whole end of string is reached.
function private_scanWhitespace(s, startPos)
    local whitespace =" \n\r\t";
    local stringLen = string.len(s);
    startPos = startPos and startPos or 1;
    while ( string.find(whitespace, string.sub(s, startPos, startPos), 1, true)  
      and startPos <= stringLen) do
        startPos = startPos + 1;
    end
    return startPos;
end

-- Reversed scans a string skipping all whitespace from the current start position .
-- Returns the position of the first non-whitespace character from back,
-- or 0 if the whole begin of string is reached.
function private_scanWitespaceFromBack(s, startPos)
    local stringLen = string.len(s);
    local endPos = startPos and startPos or stringLen;
    local whitespace = " \n\r\t";
    while ( string.find(whitespace, string.sub(s, endPos, endPos), 1, true)
      and endPos >= 1) do 
        endPos = endPos - 1;
    end 
    return endPos;
end

--Scans a string, deleting whitespace at front and back, 
--but keep whitespace in string's middle.
--return the string which begin and end without whitespace or ""
function private_deleteWhiltspaceFrontAndBack(s)
    local startPos = private_scanWhitespace(s);
    local endPos = private_scanWitespaceFromBack(s);
    if (startPos ~= string.len(s) + 1) and endPos ~= 0 then 
        return string.sub(s, startPos, endPos);
    end 
    return "";
end

--luaTable is the final richtext lua table
--stackTopPropertyString e.g : [color=ffffff,font=黑体,fontsize=20,shadow=0,stroke=0] 
--contentString e.g : 今天天气
function private_writeToLuaTable(luaTable, stackTopPropertyString, contentString)
    local table = {};
    if contentString ~= nil then
        local content = private_deleteWhiltspaceFrontAndBack(contentString);
        table.content = content;
    end
    private_fillProperty(table, stackTopPropertyString);
    luaTable[#luaTable + 1] = table
end

-- hexValue e.g : ffffff
-- return e.g : {r = 255, g = 255, b = 255}
function private_transToRGBTable(hexValue)
    local function _hexToBin(hexString)
        local nonLetterOrNumber = string.find(hexString, "[^%w]");
        if nonLetterOrNumber ~= nil then
            print(hexValue .. ": wrong color format!9");
        end
        return tonumber("0x" .. hexString);
    end 
    local rgbTable = {};
    local valueLen = string.len(hexValue);
    if valueLen < 6 then
        local addLen = 6 - valueLen;
        local valueTemp = "";
        for i = 1, addLen do
            valueTemp = valueTemp .. "0"
        end
        hexValue = valueTemp .. hexValue;
    elseif valueLen > 6 then 
        print(hexValue .. ": wrong color format!10");
    end 
    local rValueString = string.sub(hexValue, 1, 2);
    local rValue = _hexToBin(rValueString);
    rgbTable.r = rValue;
    local gValueString = string.sub(hexValue, 3, 4);
    local gValue = _hexToBin(gValueString);
    rgbTable.g = gValue;
    local bValueString = string.sub(hexValue, 5, 6);
    local bValue = _hexToBin(bValueString);
    rgbTable.b = bValue;
    return rgbTable;
end

-- hexValue e.g : ffffffff
-- return e.g : {r = 255, g = 255, b = 255, a = 255}
function private_transToRGBATable(hexValue)
    local function _hexToBin(hexString)
        local nonLetterOrNumber = string.find(hexString, "[^%w]");
        if nonLetterOrNumber ~= nil then
            print(hexValue .. ": wrong color format!11");
        end
        return tonumber("0x" .. hexString);
    end 
    local rgbaTable = {};
    local valueLen = string.len(hexValue);
    if valueLen < 8 then
        local addLen = 8 - valueLen;
        local valueTemp = "";
        for i = 1, addLen do
            valueTemp = valueTemp .. "0"
        end
        hexValue = valueTemp .. hexValue;
    elseif valueLen > 8 then 
        print(hexValue .. ": wrong color format!12");
    end 
    local rValueString = string.sub(hexValue, 1, 2);
    local rValue = _hexToBin(rValueString);
    rgbaTable.r = rValue;
    local gValueString = string.sub(hexValue, 3, 4);
    local gValue = _hexToBin(gValueString);
    rgbaTable.g = gValue;
    local bValueString = string.sub(hexValue, 5, 6);
    local bValue = _hexToBin(bValueString);
    rgbaTable.b = bValue;
    local aValueString = string.sub(hexValue, 7, 8);
    local aValue = _hexToBin(aValueString);
    rgbaTable.a = aValue;
    return rgbaTable;
end

-- propertyString e.g : color= ffffff, outline= ffffff, font = 黑体,fontsize=20,shadow=0, stroke=0
-- before func call table e.g : {}
-- after func call table e.g :
-- {color = {r = 255, g = 255, b = 255}, outline = { r = 255, g = 255, b = 255, a = 255 }, font = 黑体,fontsize=20, shadow=0, stroke=0} 
function private_fillProperty(table, propertyString)
    local function _fill(keyAndValue)
        local equalSignPos = string.find(keyAndValue, '=', 1, true);
        if (equalSignPos == nil) 
            or (1 == equalSignPos) 
            or (equalSignPos == string.len(keyAndValue)) then
            print(propertyString .. ": wrong str format!13");
        end 
        local key = string.sub(keyAndValue, 1, equalSignPos - 1);
        local value = string.sub(keyAndValue, equalSignPos + 1);
        key = private_deleteWhiltspaceFrontAndBack(key);
        value = private_deleteWhiltspaceFrontAndBack(value);
        if key == "color" then
            value = private_transToRGBTable(value);
        end

        if key == "outlinecolor" or key == "linklinecolor" then
            value = private_transToRGBATable(value);
        end
        table[key] = value;     
    end

    local startPos = 1;
    local endPos = string.find(propertyString, ',', startPos, true);
    local propertyStringLen = string.len(propertyString);
    while endPos do 
        if startPos >= endPos then
            print(propertyString .. ": wrong str format!14");
        end
        local keyWithValueString = string.sub(propertyString, startPos, endPos-1);
        _fill(keyWithValueString);
        startPos = endPos + 1;
        endPos = string.find(propertyString, ',', startPos, true);
    end 
    if startPos < propertyStringLen then
        local keyWithValueString = string.sub(propertyString, 
            startPos, propertyStringLen);
        endPos = propertyStringLen;
        _fill(keyWithValueString);
    end 
end

--test
-- t = richTextDecode(str);
-- for k, v in pairs(t) do
--     print(k);
--     for i, j in pairs(v) do
--         print(i, j)
--     end
-- end

--public function is richTextDecode(str), see upside!
