--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-06-21 15:18:46
--
local TeamHeroCGView = class("TeamHeroCGView",BasePopView)
function TeamHeroCGView:ctor(param)
    self.super.ctor(self)
    param = param or {}
    self._data = param
    dump(param,"....")
end

-- 初始化UI后会调用, 有需要请覆盖
function TeamHeroCGView:onInit()
	self:registerClickEventByName("closeBtn",function() 
		if self._closeCallback then
			self._closeCallback()
		end
		self:close(true)
		UIUtils:reloadLuaFile("global.TeamHeroCGView")
	end)
	if ADOPT_IPHONEX then
		local closeBtn = self:getUI("closeBtn")
		local parameter = closeBtn:getLayoutParameter()
        parameter:setMargin({left=0,top=0,right=125,bottom=0})
        closeBtn:setLayoutParameter(parameter)
	end
	self._img = self:getUI("bg.img")
	self._img:setSwallowTouches(true)
	if self._data.imgName then
		self._img:loadTexture(self._data.imgName)
		local xscale = MAX_SCREEN_WIDTH / self._img:getContentSize().width
	    local yscale = MAX_SCREEN_HEIGHT / self._img:getContentSize().height
	    if xscale > yscale then
	        self._img:setScale(xscale)
	    else
	        self._img:setScale(yscale)
	    end
	    self._img:setPosition(567, 320)
	end
	self._heroName = self:getUI("bg.heroName")
	self._heroName:setVisible(false)
	if self._data.isHero then
		print("innnnnhere   ,,,,")
		-- 手动管理hero 图
	    local tc = cc.Director:getInstance():getTextureCache() 
	    local sfc = cc.SpriteFrameCache:getInstance()
	    if not tc:getTextureForKey("d_Mephala.png") then
	    	sfc:addSpriteFrames("asset/ui/hero1.plist", "asset/ui/hero1.png")
	        sfc:addSpriteFrames("asset/ui/hero.plist", "asset/ui/hero.png")
	        self._toDelSprites = true
	    end
		local heroData = tab.hero[self._data.heroId or 0]
		if heroData and heroData.heromp then
		    ScheduleMgr:delayCall(0, self, function( )
		    	if not self._heroName then return end
				self._heroName:setVisible(true)
			    self._heroName:loadTexture(heroData.heromp .. ".png",1)

		    	local size = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
				local isPad = (size.width / size.height) <= (3.0 / 2.0)
			    if isPad then
		            self._heroName:setPosition(960 / 2 + heroData.ipadmppos[1], heroData.ipadmppos[2])
		        else
		            self._heroName:setPosition(960 / 2 + heroData.mppos[1], heroData.mppos[2])
		        end
		    end)
		end
		if self._data.heroSkinImgName then
			local fu = cc.FileUtils:getInstance()
			local fileName ="asset/uiother/hero/"..  self._data.heroSkinImgName ..".jpg" 
	        if fu:isFileExist( fileName ) then 
			    self._img:loadTexture(fileName)
	        end
		end
	end
end

-- 接收自定义消息
function TeamHeroCGView:reflashUI(data)
end

return TeamHeroCGView