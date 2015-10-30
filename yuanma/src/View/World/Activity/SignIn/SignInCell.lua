--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SignInCell.lua
-- author:    liyuhang
-- created:   2015/10/13
-- descrip:   月签到cell
--===================================================
local SignInCell = class("SignInCell",function () 
    return ccui.ImageView:create()
end)

function SignInCell:ctor()
    self._strName = "SignInCell"
    -- 挂载节点
    self._pCCS = nil
    -- 背景图片 
    self._pBg = nil 
    
    self._pParams = nil

    self._pDataInfo = nil
    self._nIndex = 0
end

function SignInCell:create()
    local imageView = SignInCell.new()
    imageView:dispose()
    return imageView
end

function SignInCell:dispose()
    NetRespManager:getInstance():addEventListener(kNetCmd.kMonthSign,handler(self,self.handleMonthSign))  

    local params = require("ActivitySignInRewardParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pRewardBg
    self._pParams = params
    
    self:addChild(self._pCCS)

    ------------------ 节点事件 -----------------------------
    local function onNodeEvent(event)
        if event == "exit" then 
            self:onExitSignInCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

-- 设置等级礼包的数据
function SignInCell:setData(index,pDataInfo)
    if not pDataInfo then 
        return
    end
    self._pDataInfo = pDataInfo
    self._nIndex = index
    
    -- 点击签到
    self._pBg:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            ActivityMessage:SignIn(false,false)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self:updateData()
end

function SignInCell:updateData()
    if ActivityManager:getInstance()._nSignCount > self._nIndex then
        self._pParams._pGou:setVisible(true)
        self._pParams._pSignIn:setVisible(false)
        self._pBg:setTouchEnabled(false)
    elseif ActivityManager:getInstance()._nSignCount == self._nIndex then 
        if self._pDataInfo.VipLevel ~= 0 and self._pDataInfo.VipLevel <= RolesManager._pMainRoleInfo.vipInfo.vipLevel and ActivityManager:getInstance()._nSignVip == 1
        then
            self._pParams._pGou:setVisible(false)
            self._pParams._pSignIn:setVisible(true)
            self._pBg:setTouchEnabled(true)
        else
            self._pParams._pGou:setVisible(true)
            self._pParams._pSignIn:setVisible(false)
            self._pBg:setTouchEnabled(false)
        end
    else
        self._pParams._pGou:setVisible(false)
        if ActivityManager:getInstance()._nSignVip == 0 and ActivityManager:getInstance()._nSignCount + 1 == self._nIndex then
            self._pParams._pSignIn:setVisible(true)
            self._pBg:setTouchEnabled(true)
        else
            self._pParams._pSignIn:setVisible(false)
            self._pBg:setTouchEnabled(false)
        end
    end

    local RewardInfo = self._pDataInfo.Reward[1]
    if RewardInfo[1] <= 99 then
        local FinanceIcon = FinanceManager:getInstance():getIconByFinanceType(RewardInfo[1])
        self._pParams._pRewardIcon:loadTexture(
            FinanceIcon.filename,
            ccui.TextureResType.plistType)
        --self._pParams._pRewardIcon:setString(RewardInfo[2])
    else
        local pItemInfo = {id = RewardInfo[1], baseType = RewardInfo[3], value = RewardInfo[2]}
        pItemInfo = GetCompleteItemInfo(pItemInfo)

        self._pParams._pRewardIcon:loadTexture(
            pItemInfo.templeteInfo.Icon ..".png",
            ccui.TextureResType.plistType)
        --self._pParams._pRewardIcon:setString(RewardInfo[2])
    end

    if self._pDataInfo.VipLevel ~= 0 then
        self._pParams._pVipDouble:setVisible(true)
        self._pParams._pVipDoubleText:setString("Vip"..self._pDataInfo.VipLevel.."双倍")
    else
        self._pParams._pVipDouble:setVisible(false)
    end
end

function SignInCell:handleMonthSign(event)
    self:updateData()
end

--  退出函数
function SignInCell:onExitSignInCell()
-- cleanup
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return SignInCell