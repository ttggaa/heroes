--[[
    Filename:    PaymentModel.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2016-10-31 20:41:04
    Description: File description
--]]

local PaymentModel = class("PaymentModel", BaseModel)

PaymentModel.kProductType1 = 1
PaymentModel.kProductType2 = 2
PaymentModel.kProductType3 = 3

function PaymentModel:ctor()
    PaymentModel.super.ctor(self)
end

function PaymentModel:chargeSuccess()
    ViewManager:getInstance():showTip(lang("pay1"))
end

function PaymentModel:chargeFailed()
    --ViewManager:getInstance():showTip(lang("pay2"))
    ViewManager:getInstance():showSelectDialog("充值失败", "取消", function()
        
    end, "帮助", function()
        CustomServiceUtils.rechargeFailed()
    end)
end

function PaymentModel:chargeCancel()
    ViewManager:getInstance():showTip(lang("pay3"))
end

function PaymentModel:chargeForbidden()
    ViewManager:getInstance():showTip(lang("pay4"))
end

function PaymentModel:chargeUnknownError()
    ViewManager:getInstance():showTip(lang("pay5"))
end

function PaymentModel:charge(productType, productInfo, callback)
    ServerManager:getInstance():sendMsg("PaymentServer", "beforePay", {}, true, {}, function(success)
        if not success then
            return self:chargeFailed()
        end
        local idToName = {}
        local product_id = nil
        local tableData = nil
        if productType == PaymentModel.kProductType1 then
            idToName = {
                [1] = "payment_30",
                [2] = "payment_60",
                [3] = "payment_98",
                [4] = "payment_198",
                [5] = "payment_328",
                [6] = "payment_648",
                [7] = "payment_6",
                [8] = "payment_18",
            }
            if OS_IS_IOS then
                idToName = {
                    [1] = "diamond_300",
                    [2] = "diamond_600",
                    [3] = "diamond_980",
                    [4] = "diamond_1980",
                    [5] = "diamond_3280",
                    [6] = "diamond_6480",
                    [7] = "diamond_60",
                    [8] = "diamond_180",
                }
            end
            local productIndex = productInfo
            product_id = idToName[productIndex]
            tableData = tab:Payment(product_id)
        else
            print("wrong product type")
            return self:chargeFailed()
        end
        if not (product_id and tableData) then return self:chargeFailed() end
        local game_coin = tableData.gem
        local sec = GameStatic.sec
        local price = tableData.cash

        ViewManager:getInstance():lock()
        sdkMgr:charge({product_id = OS_IS_IOS and "com.tencent.yxwdzzjy." .. product_id or product_id, game_coin = game_coin, sec = sec, price = price}, function(code, data)
            ViewManager:getInstance():unlock()
            if code == sdkMgr.SDK_STATE.SDK_CHARGE_FAIL then
                ApiUtils.gsdkPay({tag = "101", status = "false", msg = "fail"})
                return self:chargeFailed()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_CANCEL then
                -- ApiUtils.gsdkPay({tag = "102", status = "false", msg = "cancel"})
                return self:chargeCancel()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_FORBIDDEN then
                ApiUtils.gsdkPay({tag = "102", status = "false", msg = "forbidden"})
                return self:chargeForbidden()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_SUCCESS then
                ApiUtils.gsdkPay({tag = "100", status = "true", msg = "success"})
                ServerManager:getInstance():sendMsg("PaymentServer", "afterPay", {ext = data}, true, {}, function(success, data)
                    if not success then
                        return self:chargeFailed()
                    end
                    self:chargeSuccess()
                    ApiUtils.playcrab_monitor_recharge(price)
                    if callback and type(callback) == "function" then
                        callback(success, data)
                    end
                end)
            else
                return self:chargeUnknownError()
            end
        end)
    end)
end

--[[
productContext = 
{
    ftype = 1,
    gname = lang("TOOL_39991"),
    gdes = lang("TOOLDES_39991"),
    ext = json.encode({acId = acitivyId, eid = itemId})
}
payitem_ios = "productID*price*num"
]]

function PaymentModel:chargeDirect(productContext, payitem_ios)
    if OS_IS_WINDOWS then
        dump(productContext)
        print("payitem_ios == "..payitem_ios)
        return
    end
    ServerManager:getInstance():sendMsg("PaymentServer", "buyGoods", productContext, true, {}, function(success, data)
        if not success then
            return self:chargeFailed()
        end
        local params = {
            service_code = "GOODS",
            sec = GameStatic.sec
        }
        if OS_IS_IOS then
            if not payitem_ios then
                print("payitem_ios is nil")
                return self:chargeFailed() 
            end
            params.product_id = productContext.product_id
            params.payitem = payitem_ios
        else
            if not data["url_params"] then
                print("url_params is nil")
                return self:chargeFailed() 
            end
            params.token_url = data["url_params"]
        end
        
        ViewManager:getInstance():lock()
        -- dump(params)game_coin
        sdkMgr:charge(params, function(code, data)
            ViewManager:getInstance():unlock()
            if code == sdkMgr.SDK_STATE.SDK_CHARGE_FAIL then
                ApiUtils.gsdkPay({tag = "101", status = "false", msg = "fail"})
                return self:chargeFailed()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_CANCEL then
                -- ApiUtils.gsdkPay({tag = "102", status = "false", msg = "cancel"})
                return self:chargeCancel()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_FORBIDDEN then
                ApiUtils.gsdkPay({tag = "102", status = "false", msg = "forbidden"})
                return self:chargeForbidden()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_SUCCESS then
                ApiUtils.gsdkPay({tag = "100", status = "true", msg = "success"})
                self:chargeSuccess()
            else
                return self:chargeUnknownError()
            end
        end)
    end)
end

--[[
function PaymentModel:charge(productType, productInfo, callback)
    local context = {}
    if productType == PaymentModel.kProductType2 or productType == PaymentModel.kProductType3 then
        context = {ext = json.encode({acId = productInfo.activityId, eid = productInfo.itemId})}
    end
    ServerManager:getInstance():sendMsg("PaymentServer", "beforePay", context, true, {}, function(success)
        if not success then
            return self:chargeFailed()
        end
        local idToName = {}
        local product_id = nil
        local tableData = nil
        if productType == PaymentModel.kProductType1 then
            idToName = {
                [1] = "payment_30",
                [2] = "payment_60",
                [3] = "payment_98",
                [4] = "payment_198",
                [5] = "payment_328",
                [6] = "payment_648",
                [7] = "payment_6",
            }
            if OS_IS_IOS then
                idToName = {
                    [1] = "diamond_300",
                    [2] = "diamond_600",
                    [3] = "diamond_980",
                    [4] = "diamond_1980",
                    [5] = "diamond_3280",
                    [6] = "diamond_6480",
                    [7] = "diamond_60",
                }
            end
            local productIndex = productInfo
            product_id = idToName[productIndex]
            tableData = tab:Payment(product_id)
        elseif productType == PaymentModel.kProductType2 then
            local productIndex = productInfo.itemId
            local acTableData = tab:AcRmb(productIndex)
            if not acTableData then 
                print("wrong product index", productIndex, productInfo.activityId, productInfo.itemId)
                return self:chargeFailed() 
            end
            local goodsId = acTableData.goodsId
            if not goodsId then 
                print("wrong goods id", productIndex, productInfo.activityId, productInfo.itemId)
                return self:chargeFailed() 
            end
            tableData = tab:CashGoodsLib(goodsId)
            if not tableData then 
                print("wrong table data", productIndex, productInfo.activityId, productInfo.itemId)
                return self:chargeFailed() 
            end
            if OS_IS_IOS then
                product_id = tableData.payment_ios
            else
                product_id = tableData.payment_android
            end
            
            -- idToName = {
            --     [1] = "payment_month",
            --     [2] = "payment_monthsuper",
            -- }
            -- product_id = idToName[productIndex]
            -- tableData = tab:Payment(product_id)
        elseif productType == PaymentModel.kProductType3 then
            local goodsId = tab:Setting("G_NESTREWARD").value
            if not goodsId then 
                print("wrong goods id", productInfo.activityId)
                return self:chargeFailed() 
            end
            tableData = tab:CashGoodsLib(goodsId)
            if not tableData then 
                print("wrong table data", productInfo.activityId)
                return self:chargeFailed() 
            end
            if OS_IS_IOS then
                product_id = tableData.payment_ios
            else
                product_id = tableData.payment_android
            end
        else
            print("wrong product type")
            return self:chargeFailed()
        end
        if not (product_id and tableData) then return self:chargeFailed() end
        local game_coin = tableData.gem
        local sec = GameStatic.sec
        local price = tableData.cash

        ViewManager:getInstance():lock()
        sdkMgr:charge({product_id = OS_IS_IOS and "com.tencent.yxwdzzjy." .. product_id or product_id, game_coin = game_coin, sec = sec, price = price}, function(code, data)
            ViewManager:getInstance():unlock()
            if code == sdkMgr.SDK_STATE.SDK_CHARGE_FAIL then
                ApiUtils.gsdkPay({tag = "101", status = "false", msg = "fail"})
                return self:chargeFailed()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_CANCEL then
                -- ApiUtils.gsdkPay({tag = "102", status = "false", msg = "cancel"})
                return self:chargeCancel()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_FORBIDDEN then
                ApiUtils.gsdkPay({tag = "102", status = "false", msg = "forbidden"})
                return self:chargeForbidden()
            elseif code == sdkMgr.SDK_STATE.SDK_CHARGE_SUCCESS then
                ApiUtils.gsdkPay({tag = "100", status = "true", msg = "success"})
                ServerManager:getInstance():sendMsg("PaymentServer", "afterPay", {ext = data}, true, {}, function(success, data)
                    if not success then
                        return self:chargeFailed()
                    end
                    self:chargeSuccess()
                    ApiUtils.playcrab_monitor_recharge(price)
                    if callback and type(callback) == "function" then
                        callback(success, data)
                    end
                end)
            else
                return self:chargeUnknownError()
            end
        end)
    end)
end
]]

return PaymentModel