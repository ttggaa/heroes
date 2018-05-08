--[[
    Filename:    CommentServer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-01-16 19:40:51
    Description: File description
--]]


local CommentServer = class("CommentServer", BaseServer)

function CommentServer:ctor(data)
    CommentServer.super.ctor(self,data)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._commentModel = self._modelMgr:getModel("CommentModel")
end

-- 获取评论数据
function CommentServer:onGetCommentData(result, error)
    if error ~= 0 then 
        return
    end
    if result and result.type == "7" then
        self._commentModel:setTypeData(result)
    else
        self._commentModel:setTeamData(result)
    end
    self:callback(result)
end

-- 评论
function CommentServer:onCommentMessage(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

-- 赞或踩
function CommentServer:onCommentAttitude(result, error)
    if error ~= 0 then 
        return
    end
    -- self:handAboutServerData(result)
    self:callback(result)
end

-- 取官方评论详情
function CommentServer:onGetCommentDetail(result, error)
    if error ~= 0 then 
        return
    end

    self:callback(result)
end

function CommentServer:handAboutServerData(result)

end

return CommentServer