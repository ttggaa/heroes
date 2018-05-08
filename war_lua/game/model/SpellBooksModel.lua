--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-08 15:59:28
--
local SpellBooksModel = class("SpellBooksModel", BaseModel)

function SpellBooksModel:ctor()
    SpellBooksModel.super.ctor(self)
    self._data = {}
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self:cacheToolWithBookBase()
    -- 书柜页签红点，参照背包，记内存里
    self._tabNotice = {}
    self._tabHadNotice = {}
end

function SpellBooksModel:setData(data)
    self._data = data
    self:checkNotice()
    self:reflashData()
end

function SpellBooksModel:getData()
    return self._data
end

local mergeB2AData
mergeB2AData = function( ta,tb )
	if not ta or not next(ta) then 
		ta = tb  
		return tb
	end
	if not tb then return ta end 
	for k,v in pairs(tb) do
		if type(v) ~= "table" then 
			ta[k] = v
		else
			ta[k] = mergeB2AData(ta[k],v)
		end
	end
    return ta
end

function SpellBooksModel:updateData( inData )
	if not inData then return end
	self._data = mergeB2AData(self._data,inData)
	self:checkNotice()
	self:reflashData()
end

function SpellBooksModel:checkNotice( )
	if  SystemUtils.enableSkillBook and not SystemUtils:enableSkillBook() then return false end 
	if table.nums(self._tabHadNotice) >= 4 then return false end
	self._tabNotice = {}
	local tableD = tab.skillBookBase
	for bookId,bookD in pairs(tableD) do
		local bookInfo = self._data[tostring(bookId)]
		local nature = bookD.nature 
		if not self._tabHadNotice[nature] and not self._tabNotice[nature] then
			local maxLevel = #bookD.skillbook_exp
			local level = bookInfo and tonumber(bookInfo.l) or 0
			local needNum = bookD.skillbook_exp[math.min(maxLevel,level+1)] or 0
		    local itemId = bookD.goodsId 
		    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
			if haveNum >= needNum and level < maxLevel and bookD.show == 1 then
				self._tabNotice[nature] = true
				self._tabNotice[5] = true
			end
		end	
	end
end

function SpellBooksModel:isTabHaveNotice( nature )
	return not self._tabHadNotice[nature] and self._tabNotice[nature]
end

function SpellBooksModel:checkBookCaseRed( )
	return table.nums(self._tabHadNotice) <= 4 and table.nums(self._tabNotice) > 0
end

function SpellBooksModel:cancelNotice( nature )
	-- self._tabHadNotice[nature] = true
end

function SpellBooksModel:caculateFightNum( )
	local ulvl = self._modelMgr:getModel("UserModel"):getData().lvl 
	local heroBase = tab.heroPower[ulvl] and tab.heroPower[ulvl].base or 0
	local totalScore = 0
	local allAttrs = self:getSpellBookAttrs()
	local allAttrNum = 0
	for k,v in pairs(allAttrs) do
		allAttrNum = allAttrNum+v
	end
	totalScore = totalScore+allAttrNum*heroBase*0.0025
	local allBookPower = 0
	for k,v in pairs(self._data) do
		local heroId = v.b 
		local heroScore = 0
		if v.b and tonumber(v.b) ~= 0 then
			local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(v.b)
			heroScore = heroData and heroData.slot and heroData.slot.score or 0
		end
		totalScore = totalScore+heroScore
		local level = tonumber(v.l) or 0
		local bookD = tab.skillBookBase[tonumber(k)]
		local bookPower = bookD.attrpoweradd*level
		allBookPower = allBookPower+bookPower
	end
	totalScore = totalScore+allBookPower*heroBase
	totalScore = tonumber(string.format("%d",totalScore))
	print(totalScore,"===============totalScore===================")
	return totalScore
end

-- 计算英雄法术槽上战斗力
function SpellBooksModel:sumHeroSlotScore( )
	local totalScore = 0
	for k,v in pairs(self._data) do
		local heroId = v.b 
		if v.b and tonumber(v.b) ~= 0 then
			local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(v.b)
			local heroScore = heroData and heroData.slot and heroData.slot.score or 0
			totalScore = totalScore + heroScore
		end
	end
	return totalScore
end

function SpellBooksModel:sumLvlQuality( bookId,lvl )
	local bookId = tonumber(bookId) or 0
	local bookD = tab.skillBookBase[bookId]
	local attType = bookD.quality_type
    if not bookD or bookD.show == 0 then return 0,attType end
	local quality = bookD.quality
	local attr = 0
	for i,num in ipairs(quality) do
		if i <= lvl+1 then
			attr = attr+num 
		else
			break
		end
	end
	return attr,attType
end

function SpellBooksModel:getSpellBookAttrs( )
	local attrs = {atk = 0,def = 0,int = 0,ack = 0,}
	local attrMap = {[112] = "atk",[115] = "def" ,[118] = "int" ,[121] = "ack"}
	for k,v in pairs(self._data) do
		local attr,attType = self:sumLvlQuality(tonumber(k),tonumber(v.l)) -- bookD.quality[tonumber(v.l)+1]
		local transId = attrMap[attType]
		attrs[transId] = attrs[transId]+attr
	end
	return attrs
end

--缓存道具id对应的法术书id
function SpellBooksModel:cacheToolWithBookBase()
	if self._haveCache then return end
	local tabData = tab.skillBookBase
	local result = {}
	for bookid,data in pairs (tabData) do 
		result[data.piece] = bookid
	end
	self._tool_bookList = result
	self._haveCache = true
end

function SpellBooksModel:getCacheTab()
	return self._tool_bookList or {}
end

--[[
	缓存toolid num key = skillBase id num value
]]
function SpellBooksModel:getCanBreakBooks( )
	local allHeroSplice = self._modelMgr:getModel("ItemModel"):getHeroSouls()
	local books = {}
	local tabCache = self:getCacheTab()
	for k,v in pairs(allHeroSplice) do
		if tabCache[v.goodsId or 0] then
			table.insert(books,v)
			books[#books]["bookId"] = tabCache[v.goodsId]   --add by wangyan 法术分解icon加满级标签
		end
	end
	return books
end

--[[
	@param toolNumId 道具碎片id
	return 法术书对应的数量描述
]]
function SpellBooksModel:getSkillBookInfoById(toolNumId)
	-- dump(self._tool_bookList,"self._tool_bookList",10)
	local bookId = self._tool_bookList[toolNumId]
	local tabData = tab:SkillBookBase(bookId)
	local userBookLevel = 1
	local maxLevel = #tabData.skillbook_exp
	local isShow = tabData.isShowNum == 1
	if not isShow then --不显示数量
		return
	end

	local findData = self._data[tostring(bookId)]
	if  findData then
		userBookLevel = findData.l or 0
		userBookLevel = userBookLevel + 1
	end

	if userBookLevel - 1 >= maxLevel then --最高级别
		return 
	end

	local needCount = tabData.skillbook_exp[userBookLevel]
	local _,totalHaveCount = self._itemModel:getItemsById(toolNumId)
	return "(" .. totalHaveCount .. "/" .. needCount .. ")",totalHaveCount >= needCount
end

--法术祈愿红点
function SpellBooksModel:checkSkillCardRed()
	local lvl = self._userModel:getData().lvl
	local needLevel = tab:SystemOpen("SkillBook")[1]
	if lvl < needLevel then
		return false
	end
	local count = self._playerTodayModel:getData().day68 or 0
	return count <= 0 
end

--法术祈愿数据
-- 'spbookNum'=>core_Schema::NUM, //法术书抽取次数
-- 'spbookScore'=>core_Schema::NUM, //法术书抽取积分
function SpellBooksModel:setDrawData(data)
	if not self._drawData then
		self._drawData = data
	else
		for k,v in pairs (data) do 
			self._drawData[k] = v
		end
	end
	
end

function SpellBooksModel:getDrawData()
	return self._drawData or {}
end

-- 提供给活动
-- 激活了品阶为N的法术书-- 激活了X个Y系M品质法术
function SpellBooksModel:isActivedBooks( quality,level,num,nature )
	quality = quality or 1
	num  = num or 0
	level  = level or 0
	local activeNum = 0
	for k,v in pairs(self._data) do
		local l = tonumber(v.l) or 0
		local bookId = tonumber(k) or 0
		local bookD = tab.skillBookBase[bookId]
		if bookD then
			local q = bookD.skillQuality or 1
			if l >= level and q == quality then
				if nature then
					local na = bookD.nature
					if na and na == nature then
						activeNum = activeNum+1
					end
				else
					activeNum = activeNum+1
				end
			end
		end
	end
	return activeNum >= num,activeNum
end

--法术祈愿预览是否有新的下一期预览
function SpellBooksModel:isNewGift(nextId)
	local preNextID = SystemUtils.loadAccountLocalData("SKILL_BOOK_NEXTID")
	if not preNextID then
		return true
	end
	if nextId > preNextID then
		return true
	end
end

return SpellBooksModel