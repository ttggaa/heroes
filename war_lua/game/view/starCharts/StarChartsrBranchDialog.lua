--[[
    @FileName   StarChartsrBranchDialog.lua
    @Authors    cuiyake
    @Date       2018-03-29 17:49:05
    @Email      <cuiyake@playcrad.com>
    @Description   星图分支UI
--]]

local StarChartsrBranchDialog = class("StarChartsrBranchDialog",BaseLayer)
function StarChartsrBranchDialog:ctor(params)
    self.super.ctor(self)
    self._parent = params.container
    self._starId = params.starId
    self._bodyId = params.bodyId
    self._callBack = params.callback
    self._starChartsModel = self._modelMgr:getModel("StarChartsModel")
    self._selectIndex = 0
end

-- 初始化UI后会调用, 有需要请覆盖
function StarChartsrBranchDialog:onInit()
    -- self:registerScriptHandler(function (state)
    --     if state == "exit" then
    --         UIUtils:reloadLuaFile("starCharts.StarChartsrBranchDialog")
    --     end
    -- end)
    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 1)
    
    self._Panel1 = self:getUI("Panel1")
    self:registerClickEvent(self._Panel1, function()
        ScheduleMgr:nextFrameCall(self, function()
            self._viewMgr:closeHintView()
            UIUtils:reloadLuaFile("starCharts.StarChartsrBranchDialog")
        end)
    end)

    self.branchNodeTable = {
        [1] = self:getUI("Panel1.branch1"),
        [2] = self:getUI("Panel1.branch2"),
        [3] = self:getUI("Panel1.branch3"),
        [4] = self:getUI("Panel1.branch4"),
        [5] = self:getUI("Panel1.branch5")
    }

    self:resetUI()
    self:initBranch()
    local catenaIndex,catenaId = self:getCatenaIndex()
    self:itemSelect(catenaIndex,catenaId,true)
end

function StarChartsrBranchDialog:getCatenaIndex()
    local index = 0   --分支索引
    local catenaId = 0    --分支id
    if self._starChartsModel:getCatenaByBodyId(self._starId,self._bodyId) == nil then
        return index,catenaId
    else
        catenaId = self._starChartsModel:getCatenaByBodyId(self._starId,self._bodyId)
        local branchIds = tab.starCharts[self._starId]["catena_id"]
        for k ,id in pairs(branchIds) do
            if tonumber(id) == tonumber(catenaId) then
                index = k
                return index,catenaId
            end
        end
    end
    return index,catenaId
end


function StarChartsrBranchDialog:initBranch()
    local branchIds = tab.starCharts[self._starId]["catena_id"]
    for k ,id in pairs(branchIds) do

        local branceNode = self.branchNodeTable[k]
        self:registerClickEvent(branceNode, function()
            self:itemSelect(k,id,true)
        end)

        branceNode:setVisible(true)
        local activityNum ,totalNum = self._starChartsModel:getBodyIdsByCatenaId(id)
        print("==activityNum,totalNum====",activityNum,totalNum)
        local isComplete = activityNum == totalNum or false
        branceNode:getChildByFullName("completed"):setVisible(isComplete)

        local catenaName = lang(tab.starChartsCatena[id]["name"])

        local value = activityNum .. "/" ..totalNum
        local str1 = "[color=fcf4c5,fontsize=22]"..catenaName .."( [-]"
        local str2 = ""
        if isComplete then
            str2 = "[color=00FF00,fontsize=22,outlinecolor=603010,outlinesize=0]"..value .."[-]"
        else
            str2 = "[color=cd201e,fontsize=22,outlinecolor=603010,outlinesize=0]"..value .."[-]"
        end
        local str3 = "[color=fcf4c5,fontsize=22] )[-]"

        local rtxStr = str1 .. str2 .. str3
        print("======rtxStr=========",rtxStr)
        local branchDes = RichTextFactory:create(rtxStr,240,30)
        branchDes:formatText()
        branchDes:setVerticalSpace(0)
        branchDes:setAnchorPoint(cc.p(0,0.5))
        local w = branceNode:getContentSize().width
        local h = branceNode:getContentSize().height
        branchDes:setName("branchDes")
        branchDes:setPosition(-w/2+36,h/2-5)
        branceNode:addChild(branchDes)
    end
end

function StarChartsrBranchDialog:resetUI()
    for k , node in pairs(self.branchNodeTable) do
        node:setVisible(false)
    end
end

function StarChartsrBranchDialog:itemSelect(selectIndex,catenaId,moveAni)
    for k , v in pairs(self.branchNodeTable) do
        local curImage = v:getChildByFullName("curimg")
        local curLab = v:getChildByFullName("curLab")
        if selectIndex == 0 then
            v:loadTexture("starCharts_branchNoselect.png",1)
            curImage:setVisible(false)
            curLab:setVisible(false)
            self._selectIndex = 0
        else
            if tonumber(selectIndex) == k then
                if tonumber(self._selectIndex) == tonumber(selectIndex) then return end
                v:loadTexture("starCharts_branchSelect.png.png",1)
                curImage:setVisible(true)
                curLab:setVisible(true)
                if catenaId ~= 0 then
                    local centerBodyId = tab.starChartsCatena[catenaId]["position"]
                    if self._callBack then
                        self._parent:mapToCenterPos(centerBodyId,moveAni,self._callBack(catenaId))
                    else
                        self._parent:mapToCenterPos(centerBodyId,moveAni,nil)
                    end
                end
                self._selectIndex = selectIndex
            else
                v:loadTexture("starCharts_branchNoselect.png",1)
                curImage:setVisible(false)  
                curLab:setVisible(false)             
            end
        end
    end
end

-- 第一次进入调用, 有需要请覆盖
function StarChartsrBranchDialog:onShow()

end

-- 接收自定义消息
function StarChartsrBranchDialog:reflashUI(data)

end

return StarChartsrBranchDialog