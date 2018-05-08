--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-11 22:33:06
--
local SpellBookRefreshView = class("SpellBookRefreshView",BasePopView)
function SpellBookRefreshView:ctor(param)
    self.super.ctor(self)
    self._result = param and param.result or {}
    self._heroData = param and param.heroData
    dump(self._result,"result------------++++++++++")
end

-- 初始化UI后会调用, 有需要请覆盖
function SpellBookRefreshView:onInit()
	self:registerClickEventByName("bg.layer.btn_close",function( )
	    self:close()
	    UIUtils:reloadLuaFile("spellbook.SpellBookRefreshView")
	end)
	self._item = self:getUI("bg.layer.item")
	self._scrollView = self:getUI("bg.layer.scrollview")
	self._initScrollHeight = self._scrollView:getContentSize().height
	self._initScrollWidth = self._scrollView:getContentSize().width

	self:registerClickEventByName("bg.layer.btn_change",function() 
		self:sendSaveMsg()
	end)

	self:registerClickEventByName("bg.layer.btn_cancel",function() 
		self:close()
		UIUtils:reloadLuaFile("spellbook.SpellBookRefreshView")
	end)

	local tp,na = self._heroData.slot.tp,self._heroData.slot.na
	if tp and na then
		local tpDesMap = {"神剑","中级","大招","被动","万能"}
		local naDesMap = {"火系","水系","气系","土系","彩虹"}
		local name_1 = self:getUI("bg.layer.layer_icon_1.name")
		name_1:setString(naDesMap[na])
		local name_2 = self:getUI("bg.layer.layer_icon_2.name")
		name_2:setString(tpDesMap[tp])

		local slotImgs = {
			"spellBook_na_1.png","spellBook_na_2.png","spellBook_na_5.png","spellBook_na_3.png","spellBook_na_4.png",
			"spellBook_tp_1.png","spellBook_tp_2.png","spellBook_tp_5.png","spellBook_tp_3.png","spellBook_tp_4.png",
		}
		local img_1 = self:getUI("bg.layer.layer_icon_1.icon.img")
		img_1:loadTexture(slotImgs[na],1)
		local img_2 = self:getUI("bg.layer.layer_icon_2.icon.img")
		img_2:loadTexture(slotImgs[tp+1],1)
	end
end

-- 第一次进入调用, 有需要请覆盖
function SpellBookRefreshView:onShow()

end

-- 接收自定义消息
function SpellBookRefreshView:reflashUI(data)
	local x,y = 0,0
	local offsetx,offsety = 10,15
	local itemW,itemH = 290,110
	local resultNum = table.nums(self._result)
	local linenum = math.ceil(resultNum/2)
	local maxHeight = linenum*itemH
	maxHeight = math.max(self._initScrollHeight,maxHeight)
	self._scrollView:setInnerContainerSize(cc.size(self._initScrollWidth,maxHeight))
	self._items = {}
	for k,data in pairs(self._result) do
		local idx = tonumber(k)
		local item = self:createItem(data,idx)
		x = (idx-1)%2*itemW+offsetx 
		y = maxHeight - math.floor((idx-1)/2+1)*itemH+offsety
		item:setPosition(x,y)
		self._scrollView:addChild(item)
		self._items[idx] = item
	end
end

function SpellBookRefreshView:createItem( data,idx )
	local tp,na = data["1"],data["2"]
	local isRecommand = tp == 5 and na == 5
	local item = self._item:clone()
	local idxLab = item:getChildByName("idxLab")
	idxLab:setString(idx)

	local recommendTag = item:getChildByName("recommendTag")
	recommendTag:setVisible(isRecommand)
	local image_rec = item:getChildByName("image_rec")
	image_rec:setVisible(isRecommand)
	
	local tpDesMap = {"神剑","中级","大招","被动","万能"}
	local naDesMap = {"火系","水系","气系","土系","彩虹"}
	local name_1 = item:getChildByName("name_1")
	name_1:setString(naDesMap[na])
	local name_2 = item:getChildByName("name_2")
	name_2:setString(tpDesMap[tp])

	local slotImgs = {
		"spellBook_na_1.png","spellBook_na_2.png","spellBook_na_5.png","spellBook_na_3.png","spellBook_na_4.png",
		"spellBook_tp_1.png","spellBook_tp_2.png","spellBook_tp_5.png","spellBook_tp_3.png","spellBook_tp_4.png",
	}
	local img_1 = item:getChildByFullName("icon_1.img")
	img_1:loadTexture(slotImgs[na],1)
	local img_2 = item:getChildByFullName("icon_2.img")
	img_2:loadTexture(slotImgs[tp+1],1)
	local image_selected = item:getChildByName("image_selected")
	image_selected:setVisible(false)
    local checkBox = item:getChildByName("checkbox_select")
    checkBox:setSelected(isRecommand)
    checkBox:addEventListener(function (_, state)
        local selected = state == 0
        self._selIdx = idx
        if not self._preSelIdx or self._preSelIdx ~= idx then
        	local preItem = self._items[self._preSelIdx or 0]
        	self._preSelIdx = idx
	        self:setItemSelect(preItem,false)
        end
        self:setItemSelect(item,selected)
    end)

	return item
end

function SpellBookRefreshView:setItemSelect( item,isSelect )
	if not item then return end
	local checkBox = item:getChildByName("checkbox_select")
    local image_selected = item:getChildByName("image_selected")
	image_selected:setVisible(isSelect)
	checkBox:setSelected(isSelect)
end

function SpellBookRefreshView:sendSaveMsg( )
	self._serverMgr:sendMsg("HeroServer","saveHeroSlot",{heroId = self._heroData.id,id = self._selIdx}, true, {}, function(result, success)
    	local heroData = result.d and result.d.heros
        if self._heroData and heroData then
            self._modelMgr:getModel("HeroModel"):mergeHeroData(self._heroData, heroData[tostring(self._heroData.id)] or {})
        end
        self:close()
		UIUtils:reloadLuaFile("spellbook.SpellBookRefreshView")
    end)
end

return SpellBookRefreshView