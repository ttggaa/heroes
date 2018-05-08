--[[
    Filename:    init.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-05-31 11:59:37
    Description: File description
--]]
-- 系统用utils

json = {decode = cjson.decode, encode = cjson.encode}
require "utils.lang.table"
utf8 = require "utils.utf8.utf8"
require "utils.shader.shader"
require "utils.json4lua"
require "utils.bitExtend"
require "utils.profiler.luaprofiler"
require "utils.security"

PushUtils = require "utils.PushUtils"
ApplicationUtils = require "utils.ApplicationUtils"
ApiUtils = require "utils.ApiUtils"
