--[[
 	@FileName 	FormationEditInfoDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-09-05 17:54:58
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local FormationEditInfoDialog = class("FormationEditInfoDialog", BasePopView)

function FormationEditInfoDialog:ctor(params)
    FormationEditInfoDialog.super.ctor(self)
    params = params or {}
    self._isOnly = params.isOnly
    self._isShowTreasure = params.isShowTreasure
    self._isShowPokedex = params.isShowPokedex
    self._tFormId = params.tFormId
    self._formationId = params.formationId
    self._callback = params.callback
    self._fieldCallback = params.fieldCallback
    self._hireTeamData = params.hireTeamData
end

function FormationEditInfoDialog:getAsyncRes()
    return 
        {
            
        }
end

function FormationEditInfoDialog:onInit()
	self:registerClickEventByName("bg.btn_close", function ()
        if self._callback then
        	self._callback(self._tFormId)
        end
        self:close()
    end)

    self._title = self:getUI("bg.headNode.title")
    UIUtils:setTitleFormat(self._title, 1, 1)

    local tabConfig = {"tab_treasure", "tab_pokedex", "tab_lingyu"}
    self._tab = {}
    for i = 1, #tabConfig do
        local tab = self:getUI("bg." .. tabConfig[i])
        table.insert(self._tab, tab)
        UIUtils:setTabChangeAnimEnable(tab, 175, handler(self, self.touchTab), i)
    end
    local showIndex = 1
    if self._isOnly and self._isOnly == "treasure" then
        showIndex = 1
        for i = 1, #tabConfig do
            local tab = self:getUI("bg." .. tabConfig[i])
            tab:setVisible(false)
        end
        self._title:setString("宝物编组")
    elseif self._isOnly and self._isOnly == "pokedex" then
        showIndex = 2
        for i = 1, #tabConfig do
            local tab = self:getUI("bg." .. tabConfig[i])
            tab:setVisible(false)
        end
        self._title:setString("图鉴编组")
    else
        if not self._isShowTreasure then
        	showIndex = 2
        	self:getUI("bg.tab_treasure"):setTouchEnabled(false)
        	UIUtils:setGray(self:getUI("bg.tab_treasure"), true)
        end
        if not self._isShowPokedex then
        	self:getUI("bg.tab_pokedex"):setTouchEnabled(false)
        	UIUtils:setGray(self:getUI("bg.tab_pokedex"), true)
        	if showIndex == 2 then
        		showIndex = 3
        	end
        end
    end
    self:touchTab(showIndex)

    self:listenReflash("TformationModel",function( )
    	if self._treasureNode then
    		self._treasureNode:reflashUI(self._tFormId, self._formationId)
    	end
    end)
end

function FormationEditInfoDialog:switchPanel( idx )
	local subBg = self:getUI("bg.subBg")

	if idx == 1 and self._treasureNode == nil then
		self._treasureNode = self:createLayer("treasure.TreasureSelectFormDialog", {callback = function ( tid, isClose )
			self._tFormId = tid
            if isClose then
                if self._callback then
                    self._callback(self._tFormId)
                end
                self:close()
            end
		end})
		self._treasureNode:reflashUI(self._tFormId, self._formationId)
		subBg:addChild(self._treasureNode, 5)
	end
	if idx == 2 and self._pokedexNode == nil then
		self._pokedexNode = self:createLayer("pokedex.PokedexSFromDialog")
		self._pokedexNode:reflashUI()
		subBg:addChild(self._pokedexNode, 5)
	end
	if idx == 3 and self._fieldNode == nil then
		self._fieldNode = self:createLayer("formation.FieldSelectNode", {callback = function ( areaSkillTeam )
            if self._fieldCallback then
                self._fieldCallback(areaSkillTeam)
            end
        end})
		self._fieldNode:reflashUI(self._formationId, self._hireTeamData)
		subBg:addChild(self._fieldNode, 5)
	end
	if self._treasureNode then
		self._treasureNode:setVisible(idx == 1)
	end
	if self._pokedexNode then
		self._pokedexNode:setVisible(idx == 2)
	end
	if self._fieldNode then
		self._fieldNode:setVisible(idx == 3)
	end
end

function FormationEditInfoDialog:touchTab( idx )
	for i, v in ipairs(self._tab) do
        if i ~= idx then
            self:setTabStatus(v, false)
            if self._preBtn then
                UIUtils:tabChangeAnim(self._preBtn, nil, true)
            end
        end
    end
    local selectTab = self._tab[idx]
    self._preBtn = selectTab 
    UIUtils:tabChangeAnim(selectTab, function( )
        self:setTabStatus(selectTab, true)
    end)
    self:switchPanel(idx)
end

function FormationEditInfoDialog:setTabStatus( tabBtn, isSelect )
    if isSelect then
        tabBtn:loadTextureNormal("globalBtnUI4_page1_p.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        text:disableEffect()
    else
        tabBtn:loadTextureNormal("globalBtnUI4_page1_n.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        text:disableEffect()
    end
    tabBtn:setEnabled(not isSelect)
end

return FormationEditInfoDialog