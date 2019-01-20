--[[
    Filename:    MailBoxModel.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-06-17 16:51:31
    Description: File description
--]]

--[[
    ********数据瘦身记录********
    rid         => rid //角色Id
    mailId      => mId //Id
    sender      => ser //发件人
    tId         => tId //模板ID
    title       => til //标题
    content     => con //内容
    att         => att //附件
    all         => all //全服邮件
    delete      => del //删除状态
    read        => rea //读取状态
    receive     => rec //收取状态
    sTime       => st //发送时间
    source      => src //来源
    type        => type //类型
    eTime       => et //过期时间
]]--

local MailBoxModel = class("MailBoxModel", BaseModel)

function MailBoxModel:ctor()
    MailBoxModel.super.ctor(self)
    self._data = {}
    self._quary = {}
    self._newMail = {}
    self._newMailNum = 0
    for i=0,23 do
        self:registerTimer(i, 0, 30, specialize(self.getServerData, self))
    end

    self:registerTimer(11, 31, GRandom(0, 5), specialize(self.getServerData, self))   --by wangyan
    self:registerTimer(5, 0, 1, specialize(self.updateView, self))
end

function MailBoxModel:updateView()
    self:reflashData()  
end

function MailBoxModel:getServerData()
    self._serverMgr:sendMsg("MailServer", "getMails", {lastUpTime=0}, true, {}, function(result)
        self:setNewMail()
    end)
end

function MailBoxModel:getData()
    if table.nums(self._data) > 99 then
        local tempMail = {}
        for i,v in ipairs(self._data) do
            if i < 100 then
                table.insert(tempMail,v)
            end
        end
        tempMail = self:processData(tempMail)
        return tempMail
	elseif table.nums(self._data) > 0 then
        self._data = self:processData(self._data)
		return self._data
	end
    return self._data
end
 
-- 子类覆盖此方法来存储数据
function MailBoxModel:setData(data)
	local backData = self:processData(data)
    self._data = backData
	self:refreshDataOrder()
    self:reflashData()    
end

function MailBoxModel:setDataByMailID(data)
    for k,v in pairs(self._data) do
        if data.mId == v.mId then
            -- print("&&&&&&&&&&&&&&&数据修改")
            v = data
        end
    end
end

function MailBoxModel:addData(data)
    local flag = false
    local mId = data.mId
    for k,v in pairs(self._data) do
        if v.mId == mId then
            flag = true
            break
        end
    end
    print("flag=======6666666666======", flag)
    for k,v in pairs(self._newMail) do
        if v == mId then
            flag = true
            break
        end
    end
    print("flag=======6666666666======", flag)
    if flag == false then
        table.insert(self._newMail, mId)
        self._newMailNum = self._newMailNum + 1
        self:reflashData()    
    end
end

function MailBoxModel:setNewMail()
    self._newMailNum = 0
end

function MailBoxModel:getNewMail()
    return self._newMailNum or 0
end

--[[
--! @function processData
--! @desc 处理数据（临时）
--! @param inData table 追加数据集合
--! @return table
--]]
function MailBoxModel:processData(inData)
    local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local backData = {}
    for k1,v1 in pairs(inData) do
        local _,isExpired = TimeUtils.expireTimeString((v1.et or 0), 0, curTime)
        if not isExpired then
            table.insert(backData,v1)
        end
    end
    return backData
end

--[[
--! @function refreshDataOrder
--! @desc 对数据进行排序
--! @param 
--! @return 
--]]
function MailBoxModel:refreshDataOrder()
    if #self._data <= 1 then 
        return 
    end
    local sortFunc = function(a, b) 
        -- local arec = a.rec
        -- local brec = b.rec 
        -- local aread = a.read        
        -- local bread = b.read
        -- if a == nil then
        --     return
        -- end
        -- if b == nil then
        --     return
        -- end
        local aatt = 1
        local batt = 1
        if table.nums(a.att) ~= 0 then
            aatt = a.rec
        end
        if table.nums(b.att) ~= 0 then
            batt = b.rec
        end  
        local acheck = (a.rea .. aatt .. a.rec) + 0
        local bcheck = (b.rea .. batt .. b.rec) + 0
        if acheck < bcheck then
            return true
        elseif acheck == bcheck then 
            if a.st > b.st then
                return true
            end
        -- elseif arec == brec then -- 为使排序稳定,需要特别判定相等的时候
        --     if a.st > b.st then
        --         return true
        --     end
        end
    end
    table.sort(self._data, sortFunc)
end

--删除邮件
function MailBoxModel:removeMail(data)
	local tempIndex = 0
    for k1,v1 in ipairs(self._data) do
        if v1 == data or v1.mId == data.mId then 
            tempIndex = k1
            break
        end
    end
    if tempIndex > 0 then 
    	table.remove(self._data, tempIndex)
    end
    self:reflashData() 
end

function MailBoxModel:removeMailList(data)
    if (not data) or (table.nums(data) == 0) then
        return
    end
    for k,v in pairs(data) do
        self:removeMail(v)
    end
    self:refreshDataOrder()
    self:reflashData() 
end

function MailBoxModel:setDataByMailList(data)
    if (not data) or (table.nums(data) == 0) then
        return
    end
    for k,v in pairs(data) do
        self:setDataByMailID(v)
    end
    self:refreshDataOrder()
    self:reflashData()    
end


-- 按id删除
-- function MailBoxModel:removeMailById(mailid)
--     local tempIndex = 0
--     for k1,v1 in ipairs(self._data) do
--         if v1.mailId == mailid then 
--             if v1.type == 1 then
--                 tempIndex = k1
--                 break
--             else
--                 tempIndex = 0
--                 break
--             end
            
--         end
--     end
--     if tempIndex > 0 then 
--         table.remove(self._data, tempIndex)
--     end
--     self:reflashData()   
-- end

-- --根据ID获取邮件
-- function MailBoxModel:getMailInfo( mailid )
--     return self._quary[tostring(mailid)]
-- end

--是否有邮件
function MailBoxModel:haveNewMail()
    -- dump(self._data)
    -- local flag = false
    -- if #self._data == 0 then
    --     return false
    -- end
    if #self._data == 0 then
        return self:getNewMail()
    end
    local mailNewNum = 0
    for k,v in pairs(self._data) do
        if v.att and table.nums(v.att) == 0 and v.rea == 0 then -- 无附件
            mailNewNum = mailNewNum + 1
            -- return true
        -- elseif next(v.att) ~= nil and v.rec == 0 then
        elseif v.att and table.nums(v.att) ~= 0 and v.rec == 0 then --有附件
            mailNewNum = mailNewNum + 1
            -- return true
        end
    end
    -- if mailNewNum > 99 then
    --     mailNewNum = 99
    -- end
    mailNewNum = mailNewNum + self:getNewMail()
    return mailNewNum
    -- return flag
end 

function MailBoxModel:deleteReadedMail()
    local readNum = 0
    for i=#self._data, 1, -1 do
        local curData = self._data[i]
        if table.nums(curData.att) ~= 0 then
            if curData.rec == 1 then
                readNum = readNum + 1
            end
        else
            if curData.rea == 1 then
                readNum = readNum + 1
            end
        end
    end

    return readNum
end

return MailBoxModel