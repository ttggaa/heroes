--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--GM工具对象

GM = GM or {}

QuickBattleNet = {
    [1] = {
        Name = "listTest01",
        Hero = {
           }
     },
     [2] = {
        Name = "listTest02",
        Hero = {
           }
     }
}

local AllGMCommand = {
    [1] = {
        TypeName = "GM指令",
        SubType = {
            [1] = {
                SubTypeName = "战斗调试",
                GMCommand = {
--                    [1] = {
--                        Name = "开始测试1 数值1",
--                        FunctionName = "test01",
--                        Parms = {
--                        },
--                    },
--                    [2] = {
--                        Name = "开始测试2 数值3",
--                        FunctionName = "test02",
--                        Parms = {
--                            [1] = "数值1",
--                            [2] = "数值2",
--                            [3] = "数值2",
--                        },
--                    },
--                    [3] = {
--                        Name = "开始测试3 float",
--                        FunctionName = "test03",
--                        Parms = {
--                            [1] = { Name = "数值1", Type = "float", Default = 10},
--                        },
--                    },
--                    [4] = {
--                        Name = "开始测试4 list",
--                        FunctionName = "test04",
--                        Parms = {
--                            [1] = { Name = "数值1", Type = "list",  List = QuickBattleNet, Default = 1},
--                        }
--                    },
--                    [3] = {
--                        Name = "开始测试5",
--                        FunctionName = "test05",
--                        Parms = {
--                            [1] = { Name = "数值",  Type = "float",   Default = 1},
--                            [2] = { Name = "百分比",  Type = "percent", Default = 80},
--                            [3] = { Name = "开关",    Type = "bool",    Default = true},
--                        }
--                    },
                    [1] = {
                        Name = "添加指定buff",
                        FunctionName = "addBuff",
                        Parms = {
                            [1] = "发起者",
                            [2] = "攻击者",
                            [3] = "buff ID",
                        },
                    },

                    [2] = {
                        Name = "释放技能",
                        FunctionName = "releaseSkill",
                        Parms = {
                            [1] = "team Id",
                            [2] = "skill ID",
                        },
                    },
                    [3] = {
                        Name = "设置兵团死亡",
                        FunctionName = "setDie",
                        Parms = {
                            [1] = "team Id",
                            [2] = "死亡数量",
                        },
                    },
                    [4] = {
                        Name = "出现援助",
                        FunctionName = "addHelpTeam",
                        Parms = {
                            [1] = "team",
                        },
                    },
                    --showSquare
                    [5] = {
                        Name = "设置显示方格",
                        FunctionName = "showSquare",
                        Parms = {
                            [1] = { Name = "数值",  Type = "float",   Default = 100},
                        },
                    },
                    [6] = {
                        Name = "显示兵团的位置或攻击范围",
                        FunctionName = "showTeamAck",
                        Parms = {
                            [1] = { Name = "数值",  Type = "float",   Default = 0},
                        },
                    },

                    [7] = {
                        Name = "添加特定buff",
                        FunctionName = "addGivenBuff",
                        Parms = {
                            [1] = "目标",
                            [2] = { Name = "沉默",    Type = "bool",    Default = false},     --playerSilence
                            [3] = { Name = "击飞",    Type = "bool",    Default = false},     --hitfly
                            [4] = { Name = "禁动",    Type = "bool",    Default = false},     --banmove
                            [5] = { Name = "定帧",    Type = "bool",    Default = false},     --still
                            [6] = { Name = "禁攻",    Type = "bool",    Default = false},     --banattack
                            [7] = { Name = "禁技",    Type = "bool",    Default = false},     --banskill
                            [8] = { Name = "无敌",    Type = "bool",    Default = false},     --bandie
                            [9] = { Name = "标签",  Type = "float",   Default = 1},
                            [10] = { Name = "时间",  Type = "float",   Default = 6000},
                            [11] = { Name = "类型",  Type = "float",   Default = 0},
                        },
                    },
                    [8] = {
                        Name = "设置兵团复活",
                        FunctionName = "setRevive",
                        Parms = {
                            [1] = "team Id",
                            [2] = "复活数量",
                        },
                    },
                    [9] = {
                        Name = "切换地图场景",
                        FunctionName = "setMapScene",
                        Parms = {
                            [1] = { Name = "数值",  Type = "string",   Default = "shenpan"},
                        },
                    },
                    [10] = {
                        Name = "添加指定Totem",
                        FunctionName = "addTotem",
                        Parms = {
                            [1] = "发起者",
                            [2] = "攻击者",
                            [3] = "buff ID",
                            [4] = "nType",
                        },
                        -- attackIndex, targetIndex, totemId, nType
                    },
                    [11] = {
                        Name = "自动战斗脚本的设置",
                        FunctionName = "setAutoAttack",
                        Parms = {
                            --我方
                            [1] = { Name = "1英雄id",  Type = "string",   Default = 0},
                            [2] = { Name = "1兵团id",  Type = "string",   Default = 0},
                            [3] = { Name = "1援助类型加兵团",  Type = "string",   Default = 0},
                            [4] = { Name = "1器械随机",    Type = "bool",    Default = true},
                            [5] = { Name = "1宝物随机",    Type = "bool",    Default = true},
                            
                            --敌方
                            [6] = { Name = "2英雄id",  Type = "string",   Default = 0},
                            [7] = { Name = "2兵团id",  Type = "string",   Default = 0},
                            [8] = { Name = "2援助类型加兵团",  Type = "string",   Default = 0},
                            [9] = { Name = "2器械随机",    Type = "bool",    Default = true},
                            [10] = { Name = "2宝物随机",    Type = "bool",    Default = true},

                            [11] = { Name = "战斗的选择",    Type = "float",    Default = 40},
                        },
                    },
                    [12] = {
                        Name = "设置战斗的类型",
                        FunctionName = "setAutoAttackType",
                        Parms = {
                            [1] = { Name = "矮人",    Type = "bool",    Default = false},
                            [2] = { Name = "僵尸",    Type = "bool",    Default = false},
                            [3] = { Name = "攻城战(副本&远征)",    Type = "bool",    Default = false},
                            [4] = { Name = "毒龙",    Type = "bool",    Default = false},
                            [5] = { Name = "仙女龙",    Type = "bool",    Default = false},
                            [6] = { Name = "水晶龙",    Type = "bool",    Default = false},
                            [7] = { Name = "联盟探索石头人1",    Type = "bool",    Default = false},
                            [8] = { Name = "联盟探索石头人2",    Type = "bool",    Default = false},
                            [9] = { Name = "联盟探索石头人3",    Type = "bool",    Default = false},
                            [10] = { Name = "元素位面 火",    Type = "bool",    Default = false},
                            [11] = { Name = "元素位面 水",    Type = "bool",    Default = false},
                            [12] = { Name = "元素位面 气",    Type = "bool",    Default = false},
                            [13] = { Name = "元素位面 土",    Type = "bool",    Default = false},
                            [14] = { Name = "元素位面 混乱",    Type = "bool",    Default = false},
                            [15] = { Name = "木桩自己打自己",    Type = "bool",    Default = false},
                            [16] = { Name = "木桩",    Type = "bool",    Default = false},
                            [17] = { Name = "世界BOSS",    Type = "bool",    Default = false},
                        },
                        -- attackIndex, targetIndex, totemId, nType
                    },
                },
            },
            [2] = {
                SubTypeName = "数值的修改",
                GMCommand = {
                    [1] = {
                        Name = "个人物品的发放",
                        FunctionName = "getGoods",
                        Parms = {
                            [1] = { Name = "Id", Type = "float", Default = 0},
                            [2] = { Name = "数量", Type = "float", Default = 0},
                        },
                    },
                },
            },
            [3] = {
                SubTypeName = "战斗的测试",
                GMCommand = {
                    [1] = {
                        Name = "进入指定的战斗",
                        FunctionName = "intoTypeAttack",
                        Parms = {
                            [1] = { Name = "Id", Type = "float", Default = 6},
                        },
                    },
                },
            },
        },
    },
}

local rootconfig = {
    { menber = "_TypeList",         name = "TypeList",  num = 0 },
    { menber = "_ModelType",        name = "Type",      num = 0 },
    { menber = "_ModelSubType",     name = "SubType",   num = 0 },
}

local typeconfig = {
    { menber = "_TypeName",         name = "TypeName",  num = 0 },
    { menber = "_SubTypeList",      name = "SubTypeList",      num = 0 },
}

local subtypeconfig = {
    { menber = "_SubTypeName",      name = "SubTypeName",  num = 0 },
    { menber = "_GMLayer",         name = "GMLayer",      num = 0 },
}

function seekNodeByName(rootNode, name)
	if not rootNode or not name then
		return nil
	end

	if rootNode:getName() == name then
		return rootNode
	end

	local children = rootNode:getChildren()
	if not children or #children == 0 then
		return nil
	end
	for i, parentNode in ipairs(children) do
		local childNode = seekNodeByName(parentNode, name)
		if childNode then
			return childNode
		end
	end
	return nil
end

function lInitNodeUI(root, config, _type)

    if _type == nil then
        for _,v in ipairs(config) do
            if (v.num <= 0) then
                root[v.menber] = seekNodeByName(root, v.name)
                if root[v.menber] then
                    if string.find(v.name, "gl_da") then
                        root[v.menber]:getVirtualRenderer():setBlendFunc(GL_DA)
                    end
                end
            else
                root[v.menber] = { }
                for i=1,v.num do
                    root[v.menber][i] = seekNodeByName(root, v.name .. i)
                    if root[v.menber][i] and string.find(v.name, "gl_da") then
                        root[v.menber][i]:getVirtualRenderer():setBlendFunc(GL_DA)
                    end
                end
            end
        end
    else
        for key, var in ipairs(config) do
            local _lNode = seekNodeByName(root, var)
            if _lNode ~= nil then
                _lNode:getVirtualRenderer():setBlendFunc(GL_DA)
            end
        end
        
    end
end

function lSetNodeSelect(node, b)
    node:setColor(b and cc.c3b(255,255,255) or cc.c3b(125,125,125))
end

function lSetNodeCascadeEnabled(node)
    node:setCascadeColorEnabled(true)

    --默认都不选中
    lSetNodeSelect(node, false)
end

function lListViewAutoAdjustHeight(listview)
    local contentSize = listview:getContentSize()
    listview:setContentSize(cc.size(contentSize.x, 1))
    listview:refreshView()
    -- listview:setContentSize(listview:getInnerContainerSize())
    listview:doLayout()
    listview:setClippingEnabled(false)
end

function GM.lInit(parent)
    GM._pGMRoot = ccs.GUIReader:getInstance():widgetFromBinaryFile("asset/ui/GMLayer.csb")
    if parent == nil then
        parent = cc.Director:getInstance():getRunningScene()
    end
    GM._pGMRoot:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    GM._pGMRoot:setAnchorPoint(0.5, 0.5)
    GM._pGMRoot:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    parent:addChild(GM._pGMRoot, 999999)

    --Type按钮
    local function btnTypeEvent(pSender)

        for key, _ in ipairs(AllGMCommand) do
            GM.lSetTypePanelVisible(key, false)
        end

        GM.lSetTypePanelVisible(pSender._nType, true)
    end

    --SubType按钮
    local function btnSubTypeEvent(pSender)

        for key, _ in ipairs(AllGMCommand[pSender._nType].SubType) do
            GM.lSetSubTypePanelVisible(pSender._nType, key, false)
        end

        GM.lSetSubTypePanelVisible(pSender._nType, pSender._nSubType, true)
    end

    lInitNodeUI(GM._pGMRoot, rootconfig)

    for key, var in ipairs(AllGMCommand) do

        local pTypeItem = GM._pGMRoot._ModelType:clone()
        lSetNodeCascadeEnabled(pTypeItem)
        lInitNodeUI(pTypeItem, typeconfig)

        pTypeItem._TypeName:setTitleText(var.TypeName)

        if var.SubType then
            for subkey, subvar in ipairs(var.SubType) do

                local pSubTypeItem = GM._pGMRoot._ModelSubType:clone()
                lSetNodeCascadeEnabled(pSubTypeItem)
                lInitNodeUI(pSubTypeItem, subtypeconfig)
                pSubTypeItem._SubTypeName:setTitleText(subvar.SubTypeName)
                pSubTypeItem._SubTypeName:addClickEventListener(btnSubTypeEvent)
                pSubTypeItem._SubTypeName._nType = key
                pSubTypeItem._SubTypeName._nSubType = subkey

                pTypeItem._SubTypeList:pushBackCustomItem(pSubTypeItem)
            end
        end
        --移除编辑器中默认的Item
        pTypeItem._SubTypeList:removeItem(0)
        lListViewAutoAdjustHeight(pTypeItem._SubTypeList)

        GM._pGMRoot._TypeList:pushBackCustomItem(pTypeItem)

        --指令按钮
        pTypeItem._TypeName:addClickEventListener(btnTypeEvent)
        pTypeItem._TypeName._nType = key
        pTypeItem._SubTypeList:setVisible(false)
    end
    local function btnLuaProfileStart()
--        GM.battleCustom()
        -- GM.BattleGloryArena()
        GM.BattleWorldBosss()
    end
    GM.lInitSpecialBtn("测试数据", btnLuaProfileStart)

    GM.lInitSpecialBtn("关闭", function()
        GM.lHideGMRoot()
    end)

--    移除编辑器中默认的Item
    GM._pGMRoot._TypeList:removeItem(0)
    lListViewAutoAdjustHeight(GM._pGMRoot._TypeList)
    GM.lInitAllGMLayer()
end

function GM.lInitSpecialBtn(btnName, btnCallBack, color)
    
    if color == nil then
        color = cc.c3b(255,0,0)    
    end

    local pTypeItem = GM._pGMRoot._ModelType:clone()
    lSetNodeCascadeEnabled(pTypeItem)
    lInitNodeUI(pTypeItem, typeconfig)
    pTypeItem._TypeName:setTitleText(btnName)
    pTypeItem._TypeName:setTitleColor(color)
    pTypeItem._SubTypeList:removeFromParent()
    GM._pGMRoot._TypeList:pushBackCustomItem(pTypeItem)
    pTypeItem._TypeName:addClickEventListener(btnCallBack)

end

function GM.lInitAllGMLayer()
    for key, var in ipairs(AllGMCommand) do
        if var.SubType then
            for subkey, subvar in ipairs(var.SubType) do
                GM.lInitGMLayer(key, subkey)
            end
        end
    end
end

function GM.lInitGMLayer(nType, nSubType)

    local config = {
        { menber = "_ListRoot",          name = "ListRoot",   num = 0 },
        { menber = "_ModelFunction",     name = "Function",   num = 0 },
        { menber = "_ModelPanelParm",    name = "PanelParm",  num = 0 },
        { menber = "_ModelPanelParmCheckBox", name = "PanelParmCheckBox",   num = 0 },
        { menber = "_ModelPanelParmSlider",   name = "PanelParmSlider",     num = 0 },
        { menber = "_ModelPanelParmListView", name = "PanelParmListView",   num = 0 },
    }

    local subconfig = {
        { menber = "_BtnName",      name = "BtnName",   num = 0 },
        { menber = "_ListParm",     name = "ListParm",   num = 0 },
        { menber = "_BtnConfirm",   name = "BtnConfirm",  num = 0 },
        { menber = "_TxtShortcut",  name = "TxtShortcut", num = 0 },
    }

    local subsubconfig = {
        { menber = "_parmName",     name = "parmName",  num = 0 },
        { menber = "_parmValue",    name = "parmValue", num = 0 },
        { menber = "_CheckBox",     name = "CheckBox",  num = 0 },
        { menber = "_Slider",       name = "Slider",    num = 0 },
        { menber = "_ListView",     name = "ListView",  num = 0 },
        { menber = "_CurName",      name = "CurName",  num = 0 },
        { menber = "_ImageBG",      name = "Image_bg",  num = 0 },
    }

    local listviewconfig = {
        { menber = "_Text",     name = "Text",  num = 0 },
    }

    local pTypeItem     = GM._pGMRoot._TypeList:getItem(nType-1)
    local pSubTypeItem  = pTypeItem._SubTypeList:getItem(nSubType-1)
    local pGMLayer      = pSubTypeItem._GMLayer
    pGMLayer:setVisible(false)

    --指令按钮
    local function btnCommandEvent(pSender)
        
        local nType     = pSender._nType
        local nSubType  = pSender._nSubType
        local GMCommand = AllGMCommand[nType].SubType[nSubType].GMCommand

        for key, _ in ipairs(GMCommand) do
            GM.lSetFuncPanelVisible(nType, nSubType, key, false)
        end

        GM.lSetFuncPanelVisible(nType, nSubType, pSender._nFuncType, true)
    end

    --确定按钮
    local function btnEvent(pSender, eventType)
        if eventType == ccui.TouchEventType.ended then
            GM.lCommandProcess(pSender._nType, pSender._nSubType, pSender._nFuncType)
        end
    end

    lInitNodeUI(pGMLayer, config)

    local GMCommand = AllGMCommand[nType].SubType[nSubType].GMCommand

    for key, var in ipairs(GMCommand) do
        
        --GM按钮
        local pFuncItem = pGMLayer._ModelFunction:clone()
        lSetNodeCascadeEnabled(pFuncItem)
        lInitNodeUI(pFuncItem, subconfig)
        pFuncItem._BtnName:setTitleText(var.Name)

        --快捷键
        if var.Shortcut then
            pFuncItem._TxtShortcut:setString(var.Shortcut)
        else
            pFuncItem._TxtShortcut:removeFromParent()
        end

        pFuncItem._Parms = {}
        pFuncItem._Parms._list = {}
        local defaultItemCount = pFuncItem._ListParm:getChildrenCount()

        --参数面板
        if var.Parms and #var.Parms > 0 then

            for nParmIdx, parm in ipairs(var.Parms) do
                
                local newParm
                if type(parm) == "string" then
                    newParm = {Name = parm, Type = "float", Default = nil}
                else
                    newParm = parm
                end     
                
                local pParmItem
                
                if newParm.Type == "float" or newParm.Type == "string" then
                    pParmItem = pGMLayer._ModelPanelParm:clone()
                elseif newParm.Type == "bool" then
                    pParmItem = pGMLayer._ModelPanelParmCheckBox:clone()
                elseif newParm.Type == "percent" then
                    pParmItem = pGMLayer._ModelPanelParmSlider:clone()
                elseif newParm.Type == "list" then
                    pParmItem = pGMLayer._ModelPanelParmListView:clone()
                end
                pParmItem.Type = newParm.Type
                lInitNodeUI(pParmItem, subsubconfig)

                pParmItem._parmName:setColor(cc.c3b(255, 0, 0))
                pParmItem._parmName:setString(newParm.Name)

                --默认值
                if newParm.Default ~= nil then
                    GM.lSetParmValue(pParmItem, newParm.Default)
                end

                if newParm.Type == "list" then
                    pParmItem._ListView._nParmIdx = nParmIdx
                    table.insert(pFuncItem._Parms._list, pParmItem._ListView)
                    local function textEvent(pSender)
                        
                        local nParmIdx = pParmItem._ListView._nParmIdx
                        local bVisible = pParmItem._ListView:isVisible()
                        pParmItem._ListView:setVisible(not bVisible)

                        for _, var1 in ipairs(pFuncItem._Parms._list) do
                            if var1._nParmIdx ~= nParmIdx then
                                var1:setVisible(false)
                            end
                        end
                    end

                    pParmItem._ImageBG:addClickEventListener(textEvent)

                    local function itemEvent(pSender)
                        pParmItem._CurName:setString(tostring(pSender._nIdx))
                        pParmItem._ListView:setVisible(false)
                    end

                    local text = seekNodeByName(pParmItem, "Text")
                    for key1, var1 in pairs(newParm.List) do
                        local clonedText = text:clone()
                        clonedText:setString(tostring(key1)..":"..tostring(var1.Name))
                        clonedText._nIdx = key1
                        clonedText:addClickEventListener(itemEvent)
                        pParmItem._ListView:pushBackCustomItem(clonedText)
                    end
                    pParmItem._ListView:removeItem(0)
                    pParmItem._ListView:setVisible(false)
--                    lListViewAutoAdjustHeight(pParmItem._ListView)
                end

                pFuncItem._ListParm:pushBackCustomItem(pParmItem)

            end
        else
            pFuncItem._ListParm:setTouchEnabled(false)
            pFuncItem._BtnConfirm:setPositionX(pFuncItem._ListParm:getPositionX() + 60)
        end

        --移除编辑器中默认的Item
        for i = 1, defaultItemCount do
            pFuncItem._ListParm:removeItem(0)
        end
        -- local contentSize = pFuncItem._ListParm:getContentSize()
        -- pFuncItem._ListParm:setTouchEnabled(true)
        pFuncItem._ListParm:setClippingEnabled(false)
        -- pFuncItem._ListParm:setInnerContainerSize(cc.size(200, 640))
        -- pFuncItem._ListParm:setContentSize(cc.size(200, 640))
        -- pFuncItem._ListParm:refreshView()
        -- listview:setContentSize(listview:getInnerContainerSize())
        -- pFuncItem._ListParm:doLayout()
--        lListViewAutoAdjustHeight(pFuncItem._ListParm)

        pGMLayer._ListRoot:pushBackCustomItem(pFuncItem)

        --指令按钮
        pFuncItem._BtnName:addClickEventListener(btnCommandEvent)
        pFuncItem._BtnName._nType       = nType
        pFuncItem._BtnName._nSubType    = nSubType
        pFuncItem._BtnName._nFuncType   = key

        --确认按钮
        pFuncItem._BtnConfirm:addTouchEventListener(btnEvent)
        pFuncItem._BtnConfirm._nType        = nType
        pFuncItem._BtnConfirm._nSubType     = nSubType
        pFuncItem._BtnConfirm._nFuncType    = key

        pFuncItem._ListParm:setVisible(false)
        pFuncItem._BtnConfirm:setVisible(false)

    end
    
    --移除编辑器中默认的Item
    pGMLayer._ListRoot:removeItem(0)
    lListViewAutoAdjustHeight(pGMLayer._ListRoot)

end

function GM.lCommandProcess(nType, nSubType, nFunctionType)

    local GMCommand = AllGMCommand[nType].SubType[nSubType].GMCommand
            
    if GMCommand[nFunctionType] and GMCommand[nFunctionType].FunctionName then
        
        local name = GMCommand[nFunctionType].Name
        local funcName = GMCommand[nFunctionType].FunctionName
        local commandStr = ""
        if GM[funcName] then
            commandStr = "GM." .. funcName .. "("
        else
            ViewManager:getInstance():showTip("【"..name.."】函数不存在")
            return
        end

        --参数
        if GM._pGMRoot and GMCommand[nFunctionType].Parms and #GMCommand[nFunctionType].Parms > 0 then
                    
            local pGMLayer  = GM.lGetGMLayerByType(nType, nSubType)
            local pFuncItem = pGMLayer._ListRoot:getItem(nFunctionType-1)

            for key, var in ipairs(GMCommand[nFunctionType].Parms) do
                local parmItem = pFuncItem._ListParm:getItem(key-1)
                if parmItem then
                    
                    commandStr = commandStr .. tostring(GM.lGetParmValue(parmItem))
                    if key ~= #GMCommand[nFunctionType].Parms then
                        commandStr = commandStr .. ","
                    else
                        commandStr = commandStr .. ")"
                    end
                end
            end
        else
            commandStr = commandStr ..")"
        end

        GM._nCurType            = nType
        GM._nCurSubType         = nSubType
        GM._nCurFunctionType    = nFunctionType

        if GM[funcName] then
            assert(loadstring(commandStr))()
        else
            ViewManager:getInstance():showTip("【"..name.."】函数不存在")
            return
        end
        ViewManager:getInstance():showTip("【"..name.."】已执行")	
    end

end

function GM.lGetGMLayerByType(nType, nSubType)
    local pTypeItem = GM._pGMRoot._TypeList:getItem(nType-1)
    local pSubTypeItem = pTypeItem._SubTypeList:getItem(nSubType-1)
    return pSubTypeItem._GMLayer
end

function GM.lGetParmValue(parmItem)
    
    if parmItem._parmValue then
        local str = "0"
        if parmItem._parmValue:getString() ~= "" then
            str = parmItem._parmValue:getString()
        end
        if parmItem.Type == "string" then
            str = "\"" .. str .. "\""
        end
        return str
    elseif parmItem._CheckBox then
        return parmItem._CheckBox:isSelected()
    elseif parmItem._Slider then
        return parmItem._Slider:getPercent()
    elseif parmItem._ListView then
        return parmItem._CurName:getString()
    end

    print("GM.lGetParmValue error")
end

function GM.lSetParmValue(parmItem, value)
    
    if parmItem._parmValue then
        parmItem._parmValue:setString(value)
    elseif parmItem._CheckBox then
        parmItem._CheckBox:setSelected(value)
    elseif parmItem._Slider then
        parmItem._Slider:setPercent(value)
    elseif parmItem._ListView then
        parmItem._CurName:setString(value)
    else
        print("GM.lSetParmValue error")
    end

end

--[[
function GM.lUnscheduleUpdate(nType, nSubType)

    local pTypeItem     = GM._pGMRoot._TypeList:getItem(nType-1)
    local pSubTypeItem  = pTypeItem._SubTypeList:getItem(nSubType-1)
    local pGMLayer      = GM.lGetGMLayerByType(nType, nSubType)
    pGMLayer._ListRoot:unscheduleUpdate()

    local GMCommand = AllGMCommand[nType].SubType[nSubType].GMCommand
    for key, var in ipairs(GMCommand) do
        local pFuncItem = pGMLayer._ListRoot:getItem(key-1)
        pFuncItem._ListParm:unscheduleUpdate()
    end

end]]

function GM.lSetTypePanelVisible(nType, b)
    local pTypeItem = GM._pGMRoot._TypeList:getItem(nType-1)
    lSetNodeSelect(pTypeItem, b)
    pTypeItem._SubTypeList:setVisible(b)
end

function GM.lSetSubTypePanelVisible(nType, nSubType, b)
    local pTypeItem = GM._pGMRoot._TypeList:getItem(nType-1)
    local pSubTypeItem = pTypeItem._SubTypeList:getItem(nSubType-1)
    lSetNodeSelect(pSubTypeItem, b)
    pSubTypeItem._GMLayer:setVisible(b)
end

function GM.lSetFuncPanelVisible(nType, nSubType, nFunctionType, b)
    local pTypeItem     = GM._pGMRoot._TypeList:getItem(nType-1)
    local pSubTypeItem  = pTypeItem._SubTypeList:getItem(nSubType-1)
    local pGMLayer      = GM.lGetGMLayerByType(nType, nSubType)
    local pFuncItem     = pGMLayer._ListRoot:getItem(nFunctionType-1)
    lSetNodeSelect(pFuncItem, b)
    pFuncItem._ListParm:setVisible(b)
    pFuncItem._BtnConfirm:setVisible(b)

    if b then
        GM.lRefreshParms(nType, nSubType, nFunctionType)
    end
end

function GM.lShowGMRoot()
    if GM._pGMRoot then
        GM._pGMRoot:setVisible(true)
    end
end

function GM.lHideGMRoot()
    if GM._pGMRoot then
        GM._pGMRoot:setVisible(false)
    end
end

function GM.lGetParmItem(nType, nSubType, nFunctionType, nIdx)

    local pTypeItem     = GM._pGMRoot._TypeList:getItem(nType-1)
    local pSubTypeItem  = pTypeItem._SubTypeList:getItem(nSubType-1)
    local pGMLayer      = GM.lGetGMLayerByType(nType, nSubType)
    local pFuncItem     = pGMLayer._ListRoot:getItem(nFunctionType-1)
    local pParmItem     = pFuncItem._ListParm:getItem(nIdx-1)
    return pParmItem

end

--刷新参数
function GM.lRefreshParms(nType, nSubType, nFunctionType)

    local GMCommand = AllGMCommand[nType].SubType[nSubType].GMCommand
    local funcName = GMCommand[nFunctionType].FunctionName
    if funcName == "lSetMacros" then
        for key, var in ipairs(GMCommand[nFunctionType].Parms) do
            local parmItem = GM.lGetParmItem(nType, nSubType, nFunctionType, key)
            GM.lSetParmValue(parmItem, _G[var.MarcoName])
        end
    end

end

function GM.lSwitch()
    if GM._pGMRoot then
        if GM._pGMRoot:isVisible() then
            GM.lHideGMRoot()
        else
            GM.lShowGMRoot()
        end
    else
        GM.lInit()
        GM.lShowGMRoot()
    end
end



----本地数据的保存

--local MarcosSavedTag    = "MarcosSaved"
--local MarcosKeyTag      = "Marcos"

--function GM.lInitMacros()

--    --待修改
--    local nType         = 3
--    local nSubType      = 1
--    local nFunctionType = 1

--    local bMacrosSaved = GM.lGetMacrosSaved()
--    if bMacrosSaved then
--        nType         = cc.UserDefault:getInstance():getIntegerForKey(MarcosKeyTag.."Type")
--        nSubType      = cc.UserDefault:getInstance():getIntegerForKey(MarcosKeyTag.."SubType")
--        nFunctionType = cc.UserDefault:getInstance():getIntegerForKey(MarcosKeyTag.."FunctionType")
--    end

--    local GMCommand     = AllGMCommand[nType].SubType[nSubType].GMCommand
--    for key, var in ipairs(GMCommand[nFunctionType].Parms) do
--        local b = false
--        if bMacrosSaved then
--            if cc.UserDefault:getInstance():getStringForKey(MarcosKeyTag..tostring(key)) ~= "" then
--                b = cc.UserDefault:getInstance():getBoolForKey(MarcosKeyTag..tostring(key))
--            else
--                b = var.Default
--            end
--        else
--            b = var.Default
--        end
--        _G[var.MarcoName] = b
--        print("Macro".. tostring(key) .. " " .. var.MarcoName .. " = ".. tostring(b))
--    end

--    if EnableLuaCoverage then
--    	lcovtools = require("lcovtools")
--        lcovtools.start(true)
--    end

--end

--function GM.lSetMacros(...)

--    local nType     = GM._nCurType
--    local nSubType  = GM._nCurSubType
--    local nFunctionType = GM._nCurFunctionType
--    local GMCommand = AllGMCommand[nType].SubType[nSubType].GMCommand

--    for key, var in ipairs(GMCommand[nFunctionType].Parms) do
--        local b = select(key, ...)
--        _G[var.MarcoName] = b
--        --保存在文件中 下次启动时再从文件读取
--        cc.UserDefault:getInstance():setBoolForKey(MarcosKeyTag..tostring(key), b)
--        print("Macro " .. var.MarcoName .. " = ".. tostring(b))
--    end

--    cc.UserDefault:getInstance():setIntegerForKey(MarcosKeyTag.."Type",         nType)
--    cc.UserDefault:getInstance():setIntegerForKey(MarcosKeyTag.."SubType",      nSubType)
--    cc.UserDefault:getInstance():setIntegerForKey(MarcosKeyTag.."FunctionType", nFunctionType)

--    GM.lSetMacrosSaved(true)
--end

---- 重置宏设置为默认值
--function GM.lResetMacros()
--    local nType         = 3
--    local nSubType      = 1
--    local nFunctionType = 1

--    local GMCommand     = AllGMCommand[nType].SubType[nSubType].GMCommand
--    for key, var in ipairs(GMCommand[nFunctionType].Parms) do
--        _G[var.MarcoName] = var.Default
--        print("Macro".. tostring(key) .. " " .. var.MarcoName .. " = ".. tostring(var.Default))
--    end
--end

--function GM.lGetMacrosSaved()

--    if TARGET_PLATFORM ~= cc.PLATFORM_OS_WINDOWS then
--        return false
--    end

--    return cc.UserDefault:getInstance():getBoolForKey(MarcosSavedTag, false)
--end

--function GM.lSetMacrosSaved(b)

--    if TARGET_PLATFORM ~= cc.PLATFORM_OS_WINDOWS then
--        return
--    end

--    cc.UserDefault:getInstance():setBoolForKey(MarcosSavedTag, b)
--end

--endregion

function GM.addBuff(attackIndex, targetIndex, buffID)
    local logic = BC.logic
    if logic and logic._allTeams then
        local attackTeam = logic._allTeams[attackIndex]
        local targetTeam = logic._allTeams[targetIndex]
        if attackTeam and targetTeam then
            local attackSoldier = attackTeam.aliveSoldier[1]
            local targets = targetTeam.aliveSoldier
            local caster = attackSoldier.caster
            
            for t = 1, #targets do
                if not targets[t].die then
                    local buff = BC.initSoldierBuff(buffID, caster.level, caster, targets[t], buffID)
                    targets[t]:addBuff(buff)
                    ViewManager:getInstance():showTip("添加BUFF ID " .. buffID .. " 成功")
                end
            end
        end
    end
end

function GM.addTotem(attackIndex, targetIndex, totemId, nType)
    if attackIndex == 1 then
        totemId = 190102--190080
    else
        totemId = 190080
    end
    local totemD = tab.object[totemId]
    local logic = BC.logic
    if logic and logic._allTeams then
        local attackTeam = logic._allTeams[attackIndex]
        local targetTeam = logic._allTeams[targetIndex]
        if attackTeam and targetTeam then
            local attackSoldier = attackTeam.aliveSoldier[1]
            local targets = targetTeam.aliveSoldier
            local caster = attackSoldier.caster
            if nType == 1 then
                if totemD then
                    logic:addTotemToPos(totemD, 10, caster.attacker, BC.MAX_SCENE_WIDTH_PIXEL / 2, BC.MAX_SCENE_HEIGHT_PIXEL / 2)
                end
            else
                for i,v in pairs(targets) do
                    -- print(i,v)
                    if v then
                        logic:addTotemToPos(totemD, 10, caster.attacker, v)
                    end
                end
                -- addTotemToSoldier(totemD, level, attacker, soldier, rangePro, forceDoubleEffect, yunBuff, index, inSkill) 
            end
        end
    end

--     local _battleView = ViewManager:getInstance()._views["battle.BattleView"]
-- --    if _battleView and _battleView.view then
-- --        _battleView.view._battleScene:setBattleSpeed(0)
-- --    end
--     ScheduleMgr:delayCall(400, nil, function()
--         if _battleView and _battleView.view then
--             _battleView.view._battleScene:setBattleSpeed(0)
--         end
--     end)
--     ScheduleMgr:delayCall(1500, nil, function()
--         if _battleView and _battleView.view then
--             _battleView.view._battleScene:setBattleSpeed(2)
--         end
--     end)
    -- self:setBattleSpeed(0)

    -- logic:playerSkillUp(0, 0, true)

end

function GM.initSoldierBuff(skilllevel, caster, target, fromSkillId, parm)
    local id = 10001
    local camp = caster.camp
    local buffD
    -- buff替换
    buffD = clone(tab.skillBuff[id])
    local buffid = buffD["id"]
    if buffD == nil then
        print("buff ID 不存在 " .. id)
    end
    if buffD["bufftype"] ~= 1 then
        -- print("buffid: "..id.." 为怪兽buff")
    end
    local skilladd = skilllevel - 1
    -- 持续时间
    local duration = parm.duration
    local value = {0}
    local valueEx
    local shield = 0
    local hurt = 0
    local maxhurt = 0
    local buffOpen
    buffD["kind"] = parm.kind
    local _kind = buffD["kind"]
    if _kind == 0 or _kind == 1 then
            
    elseif _kind == 2 or _kind == 3 then
        
    end
    buffD.label = parm.label
    buffD.playerSilence = parm.playerSilence
    buffD.hitfly = parm.hitfly
    buffD.banmove = parm.banmove
    buffD.still = parm.still
    buffD.banattack = parm.banattack
    buffD.banskill = parm.banskill
    buffD.bandie = parm.bandie

    local result = BC.initBuff(buffD, skilllevel, duration, value, valueEx, shield, caster.attacker, hurt, camp, target.camp, false)
    -- buff的来源技能id
    result.fromSkillId = fromSkillId
    return result
end
                            
function GM.addGivenBuff(targetIndex, playerSilence, hitfly, banmove, still, banattack, banskill, bandie, label, duration, kind)
    local logic = BC.logic
    if logic and logic._allTeams then
        local parm = {}
        parm.duration = tonumber(duration)
        parm.label = tonumber(label)
        parm.playerSilence = playerSilence and 1 or 0
        parm.hitfly = hitfly and 1 or 0
        parm.banmove = banmove and 1 or 0
        parm.still = still and 1 or 0
        parm.banattack = banattack and 1 or 0
        parm.banskill = banskill and 1 or 0
        parm.bandie = bandie and 1 or 0
        parm.kind = tonumber(kind)
        local attackTeam = logic._allTeams[1]
        local targetTeam = logic._allTeams[targetIndex]
        if attackTeam and targetTeam then
            local attackSoldier = attackTeam.aliveSoldier[1]
            local targets = targetTeam.aliveSoldier
            local caster = attackSoldier.caster
            for t = 1, #targets do
                if not targets[t].die then
                    local buff = GM.initSoldierBuff(caster.level, caster, targets[t], -1, parm)
                    targets[t]:addBuff(buff)
                    ViewManager:getInstance():showTip("添加特定BUF成功")
                end
            end
        end
    end
end

function GM.releaseSkill(attackIndex, skillId)
    local logic = BC.logic
    if logic and logic._updateList then
        local attackTeam = logic._updateList[attackIndex]
        if attackTeam then
            local attacks = attackTeam.aliveSoldier
            local k = nil
            for key, var in pairs(attacks[1].skillTab) do
                if var then
                    for _key, _var in pairs(var) do
                        if _var == skillId then
                            k = key
                            break
                        end
                    end
                end
                if k ~= nil then
                    break
                end
            end
            if k == nil then
                ViewManager:getInstance():showTip("该英雄没有这个技能")
                return
            end
            for t = 1, #attacks do
                if not attacks[t].die then
--                    buff = BC.initSoldierBuff(buffID, caster.level, caster, targets[t], buffID)
                    attacks[t]:checkSkill(k, skillId, nil, nil)
                end
            end
        end
    end
end

function GM.setDie(teamId, dieCount)
    if teamId < 0 then
        ViewManager:getInstance():showTip("数据有问题")
        return
    end
    local logic = BC.logic
    if logic and logic._updateList then
        local attackTeam = logic._updateList[teamId]
        if attackTeam then
            local attacks = attackTeam.soldier
--            local Hp = attacks[1].maxHP * percenHp
            if dieCount ~= 0 then
                for key, var in pairs(attacks) do
                    if dieCount <= 0 then
                        break
                    end
                    if var ~= nil and not var.die then
                        dieCount = dieCount - 1
                        var:rap(nil, -9999999999, false, false, 0, 199, true)
                    end
                end
            else
                for key, var in pairs(attacks) do
                    if var ~= nil and not var.die then
                        var:rap(nil, -9999999999, false, false, 0, 199, true)
                    end
                end
            end
        end
    end
end



function GM.addHelpTeam(camp)
    local logic = BC.logic
    if logic == nil then
        return
    end
    if camp and  camp > 0 then
        logic:addHelpTeam(1)
    else
        logic:addHelpTeam(2)
    end
end

function GM.setRevive(teamId, reviceCount)
    if teamId < 0 then
        ViewManager:getInstance():showTip("数据有问题")
        return
    end
    local logic = BC.logic
    if logic and logic._updateList then
        local attackTeam = logic._updateList[teamId]
        if attackTeam then
            local attacks = attackTeam.soldier
--            local Hp = attacks[1].maxHP * percenHp
            if reviceCount ~= 0 then
                for key, var in pairs(attacks) do
                    if reviceCount <= 0 then
                        break
                    end
                    if var ~= nil and var.die then
                        reviceCount = reviceCount - 1
                        var:setRevive(false)
                    end
                end
            else
                for key, var in pairs(attacks) do
                    if var ~= nil and var.die then
                        var:setRevive(false)
                    end
                end
            end
        end
        ViewManager:getInstance():showTip("复活成功")
    end
end

function GM.showSquare(nSize)
    if nSize < 40 then
        nSize = 40
    end
    if ViewManager:getInstance()._views["battle.BattleView"] then
        local _battleView = ViewManager:getInstance()._views["battle.BattleView"]
        if _battleView and _battleView.view then
            _battleView.view._battleScene._mapLayer:showSquare(nSize)
        end
    end
end

--0显示方正位置，1 显示攻击范围, > 1关闭显示
function GM.showTeamAck(nType)
    if nType > 1 then
        BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER = false
        if BC and BC.objLayer then
            BC.objLayer:lClearDrawNode()
        end
    else
        BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER = true
        BattleUtils.XBW_SKILL_TEAM_ATTACK_ARER_TYPE = nType
    end
end

function GM.setMapScene(strMapId)
    if ViewManager:getInstance()._views["battle.BattleView"] then
        local _battleView = ViewManager:getInstance()._views["battle.BattleView"]
        if _battleView and _battleView.view then
            _battleView.view._battleScene:setMapSceneRes(strMapId)
        end
    end
end

--获取自动战斗脚本数据
function GM.getAutoAttackData(heroId, teamsId, backTeamType, isWea, isTform)
    local _table1 =  {}
    if heroId ~= "0" and heroId ~= "" then
        _table1[1] = tonumber(heroId)
    end
    local _teamsId = {}
    if teamsId ~= "0" and teamsId ~= "" then
        local teamsTable = string.split(teamsId, ",")
        for i,v in ipairs(teamsTable) do
            if v then
                _teamsId[#_teamsId + 1] = tonumber(v)
            end
        end
    end
    _table1[2] = _teamsId
    --援助类型加兵团Id
    local _backTeamId = {}
    if backTeamType ~= "0" and backTeamType ~= "" then
        local backsTable = string.split(teamsId, ",")
        for i,v in ipairs(backsTable) do
            if v then
                _backTeamId[#_backTeamId + 1] = tonumber(v)
            end
        end
    end
    _table1[3] = _backTeamId
    _table1[4] = isWea
    _table1[5] = isTform
    return _table1
end

--自动战斗脚本的设置
function GM.setAutoAttack(heroId, teamsId, backTeamType, isWea, isTform, heroId2, teamsId2, backTeamType2, isWea2, isTform2, attackType)
    if _G.autoAttackTable == nil then
        _G.autoAttackTable = {}
    end
    
    _G.autoAttackTable[1] = GM.getAutoAttackData(heroId, teamsId, backTeamType, isWea, isTform)
    _G.autoAttackTable[2] = GM.getAutoAttackData(heroId2, teamsId2, backTeamType2, isWea2, isTform2)
    BattleUtils.__attackType = tonumber(attackType)
end


function GM.setAutoAttackType(n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17)
    -- BattleUtils.__attackTypeTable = tonumber(nAttackType)
    BattleUtils.__attackTypeTable = {}
    if n1 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 3
    end
    if n2 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 4
    end
    if n3 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 5
    end
    if n4 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 6
    end
    if n5 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 7
    end
    if n6 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 8
    end
    if n7 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 22
    end
    if n8 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 23
    end
    if n9 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 24
    end
    if n10 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 26
    end
    if n11 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 27
    end
    if n12 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 28
    end
    if n13 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 29
    end
    if n14 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 30
    end
    if n15 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 40
    end
    if n16 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 41
    end
    if n17 then
        BattleUtils.__attackTypeTable[#BattleUtils.__attackTypeTable + 1] = 44
    end

end


function GM.intoTypeAttack(nAttackType)
    ViewManager:getInstance():autoSwitchAttackFormationView(tonumber(nAttackType), true)
end

function GM.getGoods(id, number)
--    local UserModel = ModelManager:getInstance():getModel("UserModel")
--    local xhr = cc.XMLHttpRequest:new()
--	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
--    local strUid = UserModel:getUID()
--	local str = string.format("http://172.16.42.102:8001/?mod=http&method=Tools.sendItems&__noauth__=1&pGroup=default&sec=8001&MAX_FILE_SIZE=9900000&rid=%s&goodsId=%s&goodsNum=%s", tostring(strUid), tostring(id), tostring(number))
--    str = str .. "&uploadFrom=%E6%8F%90%E4%BA%A4"
--    print(str)
--    xhr:open("GET", str)
--    local function onResp()
--		local response = xhr.response
--        if xhr.response then
--            print(response)
--        end
--		xhr:unregisterScriptHandler()
--	end
--	xhr:registerScriptHandler(onResp)
--	xhr:send()
    
--    http://172.16.42.102:8003/index.php?&mod=global&reportKey=5b8e5aabc3666e16ac04ec7e&sec=8001&method=system.sysInterface&act=getCrossArenaBattleData
    local globalServerUrl = AppInformation:getInstance():getValue("global_server_url", GameStatic.httpAddress_global)
    if GameStatic.use_globalExPort and RestartMgr.globalUrl_planB then
        globalServerUrl = RestartMgr.globalUrl_planB
    end
    print("globalServerUrl: ", globalServerUrl)
    local param = {}
    param.mod = "global"
    param.act = "getCrossArenaBattleData"
    param.reportKey = "5b8e800dc3666e16ca51319d"--"5b8e5aabc3666e16ac04ec7e"
    -- self._battleInfo.k
    param.sec = "8001"
    param.method = "system.sysInterface"
    HttpManager:getInstance():sendMsg(globalServerUrl, nil, param, 
    function(inData)
        if inData.result ~= nil and inData.result.bcode ~= 1 then
--            dump(inData.result)
            ViewManager:getInstance():showDialog("gloryArena.GloryArenaDuelDialog", inData.result)
        else
            ViewManager:getInstance():showTip(lang("REPORTSHARE_ERROR"))
        end
    end,
    function(status, errorCode, response)
        ViewManager:getInstance():showTip(lang("REPORTSHARE_ERROR"))
    end,
    GameStatic.useHttpDns_Global)

end

--冠军对决demo
function GM.battleDemo_Fuben111()
    local file1=io.open("C:\\Users\\playcrab\\AppData\\Local\\war\\test22.txt", "r+") 
    local jsondata=file1:read()
    file1:close()
    local data = cjson.decode(jsondata)
    local playerInfo = BattleUtils.jsonData2lua_battleData(data.atk)
    local enemyInfo = BattleUtils.jsonData2lua_battleData(data.def)

    local r1 = data.r1
    local r2 = data.r2

    BattleUtils.enterBattleView_League(playerInfo, enemyInfo, r1, r2, true,
    function (info, callback)
        -- 战斗结束
        callback(info)
    end,
    function (info)
        -- 退出战斗
    end)
end

--木桩战斗demo
function GM.battleCustom()
    local file1=io.open("C:\\Users\\playcrab\\AppData\\Local\\war\\test01.txt", "r+") 
    local jsondata=file1:read()
    file1:close()
    local data = cjson.decode(jsondata)
    local leftInfo = BattleUtils.jsonData2lua_battleData(data["atk"])
    local rightInfo = BattleUtils.jsonData2lua_battleData(data["def"])
    BattleUtils.enterBattleView_WoodPile_1(leftInfo, rightInfo, 
        function (info, callback)
        -- 战斗结束
            callback(info)
        end,
        function (info)
            -- 退出战斗
        end,false)
end

--跨服诸神战斗demo

function GM.battleCrossGodWar()
    ServerManager:getInstance():sendMsg("CrossGodWarServer", "getBattleReport", {reportKey = "5b4dd7f0e31436d7381f8355"}, true, {},  function(res)
--		self:reviewTheBattle(res, 0)
        local file1=io.open("C:\\Users\\playcrab\\AppData\\Local\\war\\test01.txt", "w+") 
        local jsondata=file1:write(res)
        file1:close()
	end)
end

function GM.BattleGloryArena()
    local file1=io.open("C:\\Users\\playcrab\\AppData\\Local\\war\\test01.txt", "r+") 
    local jsondata=file1:read()
    file1:close()
    local data = cjson.decode(jsondata)
    local leftInfo = BattleUtils.jsonData2lua_battleData(data["atk"])
    local rightInfo = BattleUtils.jsonData2lua_battleData(data["def"])

    local data = BattleUtils.enterBattleView_GloryArena(leftInfo, rightInfo, nil, nil, false,
        function(info, callback)
            -- 战斗结束
            callback(info)
        end,
        function (info)
            -- 退出战斗
        end, true
    )

    dump(data)

end

--世界boss战斗
function GM.BattleWorldBosss()
    local file1=io.open("C:\\Users\\playcrab\\AppData\\Local\\war\\test.txt", "r+") 
    local jsondata=file1:read()
    file1:close()
    local data = cjson.decode(jsondata)
    local leftInfo = BattleUtils.jsonData2lua_battleData(data["atk"])
    local _data = BattleUtils.enterBattleView_BOSS_WordBoss(leftInfo, 
    function(info, callback)
        -- 战斗结束
        callback(info)
    end,
    function(info, callback)
        -- 退出战斗
    end,
    nil, nil, 7110031, 0, 5, 75020001
    )

end



--检听表中数据修改的函数
GM.listened_table = function(a, callback, d)
	local b, c = {}, {}
	d = d or {}
	if d[a] then 
		return d[a] 
	end
	d[a] = b
	for k,v in pairs(a) do
		if type(v) == "table" then
			c[k] = listened_table(v,function(kk,v,o)
				callback(k.."."..kk,v,o)
			end,d)
		end
	end
	local proxy = {
		__index = function(t,k)
--			print("get " .. k)
			return c[k] or a[k]
		end,
		__newindex = function(t,k,v)
			local ov = c[k] or a[k]
			if ov ~= v then
				local isTable = true
				if type(v) == "table" then
					isTable = false
					c[k] = listened_table(v,function(kk,v)
						callback(k .. "." .. kk,v,o)
					end,d)
				end
				a[k] = v
				callback(k,v,ov)
			end
		end
	}
	setmetatable(b,proxy)
	return b
end