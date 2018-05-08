--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-19 11:29:32
--
local LeagueSeasonHotView = class("LeagueSeasonHotView",BasePopView)
function LeagueSeasonHotView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueSeasonHotView:onInit()
	self:registerClickEvent(self:getUI("bg"),function() 
		self:close()
		UIUtils:reloadLuaFile("league.LeagueSeasonHotView")
	end)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(1200,1000))
	layout:setAnchorPoint(0.5,0.5)
	-- layout:setBackGroundColorOpacity(255)
	-- layout:setBackGroundColorType(1)
	layout:setPosition(480,400)
	local bg = self:getUI("bg")
	bg:addChild(layout,-1)
	self:registerClickEvent(layout,function() 
		self:close()
		UIUtils:reloadLuaFile("league.LeagueSeasonHotView")
	end)
end

-- 第一次进入调用, 有需要请覆盖
function LeagueSeasonHotView:onShow()

end

-- 接收自定义消息
function LeagueSeasonHotView:reflashUI(data)
	local ids = data.ids
	dump(ids)
	print("ids count",#ids)
	local showMap = {
		[1] = {{pos={x=276,y=315},idsIdx=0},{pos={x=480,y=315},idsIdx=1},{pos={x=700,y=315},idsIdx=0}},
		[2] = {{pos={x=326,y=315},idsIdx=1},{pos={x=480,y=315},idsIdx=0},{pos={x=650,y=315},idsIdx=2}},
		[3] = {{pos={x=276,y=315},idsIdx=1},{pos={x=480,y=315},idsIdx=2},{pos={x=700,y=315},idsIdx=3}},
	}
	if data.upNum then
		local des1 = self:getUI("bg.des1")
		des1:setString("本段位内兵团攻击和生命上升")
		local title = self:getUI("bg.title")
		title:setString("段位热点")
	end
	local des2 = self:getUI("bg.des2")
	des2:setString(" " .. (data.upNum or 50) .. "%")
	local idsMap = showMap[#ids]
	for i=1,3 do
		local teamD = tab.team[tonumber(ids[idsMap[i].idsIdx])]
		local teamBg 	= self:getUI("bg.teamBg" .. i)
		teamBg:setPosition(idsMap[i].pos)
		teamBg:setVisible(teamD ~= nil) 
		if teamD then
			local nameLab 	= teamBg:getChildByName("name")
			local statusLab = teamBg:getChildByName("status")
			local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tonumber(ids[idsMap[i].idsIdx]))
			local isAwaked = false
			local awakeArt = nil
			local awakeName = nil
	        if teamData then
	        	statusLab:setString("（已拥有）")
	        	statusLab:setColor(cc.c3b(0, 255, 23))
	        	isAwaked = TeamUtils:getTeamAwaking(teamData)
				awakeName,_,_,awakeArt = TeamUtils:getTeamAwakingTab(teamData, teamD.id)
	        else
	        	statusLab:setString("（未拥有）")
	        	statusLab:setColor(cc.c3b(182, 182, 182))
	        end
			nameLab:setString(lang(awakeName or teamD.name))
			local teamIcon = ccui.ImageView:create()
			local steam = awakeArt or teamD.steam 
			-- teamIcon:loadTexture("")
			local filename = "asset/uiother/steam/" .. steam .. ".png"
		    local fu = cc.FileUtils:getInstance()
		    if not fu:isFileExist(filename) then
		        filename = "asset/uiother/steam/" .. steam .. ".jpg"
		    end
			print("teamD.art teamD.art1",filename,teamD.art ,teamD.art1,TeamUtils.getNpcTableValueByTeam(teamD, "art1"))
	        teamIcon:loadTexture(filename)
	        teamIcon:setPosition(70,20)
	        teamIcon:setAnchorPoint(0.5,0)
	        -- local teamHegith = teamIcon:getContentSize().height
	        -- local scale = teamHegith > 180 and 180/teamHegith or 0.75
	        -- print("teamHegith",teamHegith,scale)
	        teamIcon:setScale(.65)
			teamBg:addChild(teamIcon)

			local clipNode = cc.ClippingNode:create()
		    clipNode:setPosition(teamBg:getContentSize().width/2,288)
		    clipNode:setContentSize(cc.size(100, 100))
		    local mask = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
		    mask:setAnchorPoint(0.5,0.5)
		    clipNode:setStencil(mask)
		    clipNode:setAlphaThreshold(0.05)
		    clipNode:setInverted(true)

		    local mcAnim = mcMgr:createViewMC("jianzhuguangxiao_intancebuildingeffect-HD", true, false)   
		    mcAnim:setPosition(0, -50)
		    mcAnim:setScale(0.4)
		    clipNode:addChild(mcAnim)
		    teamBg:addChild(clipNode, -1)
		end
	end
end

return LeagueSeasonHotView