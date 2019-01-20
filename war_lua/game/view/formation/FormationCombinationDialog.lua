--[[
    @FileName   FormationCombinationDialog.lua
    @Authors    yuxiaojing
    @Date       2018-05-11 16:21:29
    @Email      <yuxiaojing@playcrab.com>
    @Description   描述
--]]

local FormationCombinationDialog = class("FormationCombinationDialog", BasePopView)

function FormationCombinationDialog:ctor( data )
    self.super.ctor(self)
    self._relationData = data.relationData
    self._backupIds = data.backupIds or {}
end

function FormationCombinationDialog:onInit(  )
    self:registerClickEventByName("bg.layer.btn_close", function ()
        self:close()
        UIUtils:reloadLuaFile("formation.FormationCombinationDialog")
    end)

    self:getUI("bg.layer.image_title_bg.label_title"):setFontName(UIUtils.ttfName_Title)

    self:initView()
end

function FormationCombinationDialog:dealUI( item, v1, v2 )
    local items = {}
    local heroes = {}
    local teams = {}
    for k1, v1 in pairs(v2) do
        table.insert(heroes, {id = k1, itemType = 2})
    end

    for k1, v1 in pairs(v1) do
        table.insert(teams, {id = k1, itemType = 1})
    end

    table.sort(teams, function(a, b)
        return a.id < b.id
    end)

    for i = 1, #heroes do
        items[#items + 1] = heroes[i]
    end

    for i = 1, #teams do
        items[#items + 1] = teams[i]
    end

    for i = 1, 8 do
        local itemData = items[i]
        if itemData then
            local itemTableData = nil
            local iconFileName = ""
            local frameFileName = ""
            local scale = 1.0
            if 1 == itemData.itemType then
                itemTableData = tab:Team(itemData.id)
                iconFileName = itemTableData.art1 .. ".jpg"
                frameFileName = "globalImageUI_squality_jin.png"
                scale = 0.5
            elseif 2 == itemData.itemType then
                itemTableData = tab:Hero(itemData.id)
                iconFileName = itemTableData.herohead .. ".jpg"
                frameFileName = "globalImageUI4_heroBg1.png"
                scale = 0.5
            end
            if itemTableData then
                local item1 = item:getChildByFullName("item_" .. i)
                item1:setVisible(true)
                item1:setScale(scale)
                item1:loadTexture(iconFileName, 1)
                local itemFrame = item1:getChildByTag(6000)
                if not itemFrame then
                    itemFrame = ccui.ImageView:create()
                    itemFrame:setTag(6000)
                    item1:addChild(itemFrame, 5)
                end
                itemFrame = item1:getChildByTag(6000)
                itemFrame:setPosition(item1:getContentSize().width / 2, item1:getContentSize().height / 2)
                itemFrame:loadTexture(frameFileName, 1)
                if table.indexof(self._backupIds, itemData.id) then
                    local img_tip = ccui.ImageView:create("priviege_tipBg.png", 1)
                    img_tip:setAnchorPoint(cc.p(0, 1))
                    img_tip:setPosition(-3, item1:getContentSize().height + 3)
                    item1:addChild(img_tip, 10)

                    local txt_tip = ccui.Text:create("后援", UIUtils.ttfName, 24)
                    txt_tip:setPosition(img_tip:getContentSize().width / 2 - 13, img_tip:getContentSize().height / 2 + 3)
                    txt_tip:enableOutline(cc.c4b(0,0,0,255), 2)
                    txt_tip:setRotation(-45)
                    img_tip:addChild(txt_tip)
                end
            end
        end
    end
end

function FormationCombinationDialog:initView(  )

	local scrollView = self:getUI("bg.layer.scrollview_builds")
	local layer_item = scrollView:getChildByFullName("layer_item")
	layer_item:setVisible(false)

	local itemCount = table.nums(self._relationData)

	local height1 = scrollView:getContentSize().height
	local height2 = layer_item:getContentSize().height
	local totalHeight = math.max(itemCount * height2, height1)

	scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, totalHeight))
	scrollView:jumpToTop()
	local index = 1
	for k, v in pairs(self._relationData) do
		local item = layer_item:clone()
		scrollView:addChild(item, 10)
		item:setPosition(0, totalHeight - height2 * index)
		index = index + 1
		item:setVisible(true)

		local buildD = tab.formation_build[k]
		item:getChildByFullName("image_build_icon"):loadTexture("guanlian_" .. k .. ".png", 1)
		item:getChildByFullName("label_build_des"):setString(lang(buildD["lang1"]))
		item:getChildByFullName("label_effect_1"):setString(lang(buildD["lang2"]))
		item:getChildByFullName("label_effect_2"):setString(lang(buildD["lang3"]))

		for i = 1, 8 do
            local icon = item:getChildByFullName("layer_effect_1.item_" .. i)
            icon:setVisible(false)
            icon = item:getChildByFullName("layer_effect_2.item_" .. i)
            icon:setVisible(false)
        end

        self:dealUI(item:getChildByFullName("layer_effect_1"), v[1], v[3])
        self:dealUI(item:getChildByFullName("layer_effect_2"), v[2], v[4])

    end
end

function FormationCombinationDialog:onDestory(  )
    self.super.onDestroy(self)
end

function FormationCombinationDialog:getAsyncRes(  )
    return {}
end

return FormationCombinationDialog