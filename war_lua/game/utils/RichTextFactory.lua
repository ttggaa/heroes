--[[
    Filename:    RichTextFactory.lua
    Author:      caoxin 
    Datetime:    
    Description: File description
--]]

RichTextFactory = {}
DefaultSetting = {
    font = "static/common.ttf",
    fontsize = 20,
    color =  cc.c3b(255,255,255),
    opacity = 255,
}
function RichTextFactory:initialize()
    -- body
end
function RichTextFactory:dispose()
    -- body

end

function RichTextFactory:create(string ,width ,height,ignoreContentAdapt)
    -- bodys
    if string == nil or string == "" then
        string = "[color=ffffff]~[-]"
    end
    local stringTable
    pcall(function ()
        stringTable = richTextDecode(string)
    end)
    if stringTable == nil then
        stringTable = richTextDecode("[color=ffffff]~[-]")
    end
    local _richText =RichTextFactory:createNode(width,height,ignoreContentAdapt)
    RichTextFactory:init(_richText,stringTable)
    return _richText;
end
function RichTextFactory:init(_richText,content)
    -- body
    local index = 1;
    for k,v in pairs(content) do
        local element 
        if v.isNewLine ~= nil then 
            element = RichTextFactory:insertNewLine(index);
        elseif v.pic ~= nil then
            -- print(v.pic)
            element = RichTextFactory:insertImage(v.pic ,index ,v.opacity)
        elseif v.gif ~= nil then
            element = RichTextFactory:insertGif(v.gif, index, v.width, v.height, v.tile)
        else
            element =RichTextFactory:insertLable(v.content, v.font, v.fontsize, index, v.color, v.opacity, v.outlinecolor, v.outlinesize or 1)
            if v.linklinecolor and v.linklinesize then
                element:enableLinkLine(v.linklinecolor, v.linklinesize)
            end
            -- print(v.content)
        end
        index  = index + 1 
         _richText:pushBackElement(element)
    end
end

function RichTextFactory:createNode(width,height,ignoreContentAdapt)
    -- body
    local _richText =pc.PCRichText:create()
    _richText:ignoreContentAdaptWithSize(ignoreContentAdapt or false);
    _richText:setContentSize(cc.size(width,height))
    return _richText;
end

function RichTextFactory:insertLable(stringLable, font, fontsize, tag, color, opacity, outlinecolor, outlinesize)
    font = font ~= nil and font or DefaultSetting.font;
    if not tag then tag =  1 end
    color = color ~= nil and color or DefaultSetting.color;
    opacity = opacity ~= nil and opacity or DefaultSetting.opacity
    fontsize = fontsize ~= nil and fontsize or DefaultSetting.fontsize
    fontsize = tonumber(fontsize)
    if fontsize and fontsize > 100 then
        fontsize = 100
    end
    outlinesize = tonumber(outlinesize)
    if outlinesize and outlinesize > 5 then
        outlinesize = 5
    end
    if type(outlinecolor) == "table" and outlinesize then
        return pc.RichElementTextPC:create(tag,color,tonumber(opacity) or 255 ,stringLable,
                font ,fontsize or 20, outlinecolor, outlinesize)
    elseif type(outlinecolor) == "table" then
        return pc.RichElementTextPC:create(tag,color,tonumber(opacity) or 255 ,stringLable,
                font ,fontsize or 20, outlinecolor)
    else
        return pc.RichElementTextPC:create(tag,color,tonumber(opacity) or 255 ,stringLable,
                font ,fontsize or 20)
    end
end

function RichTextFactory:insertImage(src,tag,opacity)
    -- body
    return  pc.RichElementImagePC:create(tag, cc.c3b(255,255,255),opacity or DefaultSetting.opacity ,src,0,0,false)
end

function RichTextFactory:insertGif(src,tag,width,height, tile)
    if tile then 
        tile = true
    end
    return  pc.RichElementGifPC:create(tag, src, width or 60, height or 60, tile or false)
end


function RichTextFactory:insertNewLine(tag)
    -- body
    return pc.RichElementNewLine:create(tag);
end