--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NoticeCommonHandler.lua
-- created:   2015/5/22
-- descrip:   通用notice的handler
--===================================================
local NoticeCommonHandler = class("NoticeCommonHandler")

-- 构造函数
function NoticeCommonHandler:ctor()     
    -- 背包数据返回
    NetHandlersManager:registHandler(29511, self.handleFriendNotice29511)

    -- 人物等级提升
    NetHandlersManager:registHandler(29515, self.handleLevelUpNotice29515)
    
    -- 人物属性变化
    NetHandlersManager:registHandler(29517, self.handleAttributeNotice29517)
    
    -- 支付成功
    NetHandlersManager:registHandler(29523, self.handleRechargeNotice29523)
  
    -- 接收家族申请
    NetHandlersManager:registHandler(29525, self.handleApplyFamilyNotice29525)
   
    -- 相同账号登陆通知
    NetHandlersManager:registHandler(29527, self.handleSameLoginNotice29527)
    
    -- 强制退服通知（停服）
    NetHandlersManager:registHandler(29529, self.handleStopServiceNotice29529)

    -- 家族职位变化的通知
    NetHandlersManager:registHandler(29533, self.handleChangePositionNotice29533)

end

-- 创建函数
function NoticeCommonHandler:create()
    local handler = NoticeCommonHandler.new()
    return handler
end

function NoticeCommonHandler:handleFriendNotice29511(msg)
    if msg.header.result == 0 then 
        if msg.body.friendListFlag == true then
            FriendCGMessage:sendMessageQueryFriendList22000()

            FriendManager:getInstance().friendListFlag = true
            
            NetRespManager:dispatchEvent(kNetCmd.kFriendWarning,{tag = 1})
        end
        if msg.body.applyListFlag == true then
            FriendCGMessage:sendMessageQueryApplyFriendList22002()
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "好友按钮" , value = true})  
            NetRespManager:dispatchEvent(kNetCmd.kFriendWarning,{tag = 2})

            FriendManager:getInstance().applyListFlag = true
        end
        if msg.body.giftListFlag == true then
            FriendCGMessage:sendMessageQueryGiftList22004()
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "好友按钮" , value = true})  
            NetRespManager:dispatchEvent(kNetCmd.kFriendWarning,{tag = 3})

            FriendManager:getInstance().giftListFlag = true
        end
    else
        local strError = "返回错误码："..msg.header.result
    end
end

function NoticeCommonHandler:handleLevelUpNotice29515(msg)
    if msg.header.result == 0 then 
        SkillCGMessage:sendMessageQuerySkillList21400()
        RolesManager._pMainRoleInfo.level = msg["body"].curLevel
        RolesManager._pMainRoleInfo.exp = msg["body"].curExp
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kRoleLevelUp, event)
       
        if isMobilePlatform() == true then
            local info = LoginManager:getInstance()._tLastServer
            -- 母包角色等级升级信息接口
            mmo.HelpFunc:roleLevelUpZTGame(self:getRolesManager()._pMainRoleInfo.roleId, self:getRolesManager()._pMainRoleInfo.roleName, info.zoneId, info.zoneName, self:getRolesManager()._pMainRoleInfo.level)
        end
        RolesManager._pMainPlayerRole:refreshName()
        
        -- 检查是否有可升级技能
        SkillsManager:getInstance():checkSkills()

        -- 提示用户超过全服百分之多少的玩家
        if msg.body.fpRank > msg.body.oldfpRank and RolesManager:getInstance()._pMainRoleInfo.level > 5  then 
            cc.Director:getInstance():getRunningScene():showLayer(require("FightPowerUpTip"):create(msg.body.oldfpRank,msg.body.fpRank)) 
        end
    else
        local strError = "返回错误码："..msg.header.result
    end
end


function NoticeCommonHandler:handleAttributeNotice29517(msg)
    if msg.header.result == 0 then 
        local nPowerChange = msg["body"].attrs.fightingPower-RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        if nPowerChange ~= 0 and nPowerChange ~= nil and LayerManager:getCurSenceLayerSessionId() == kSession.kWorld  then
            NoticeManager:getInstance():showFightStrengthChange(nPowerChange)
        end
    
        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg["body"].attrs
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
    else
        local strError = "返回错误码："..msg.header.result
    end
end

function NoticeCommonHandler:handleRechargeNotice29523(msg)
    if msg.header.result == 0 then 
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kRechargeNotice, msg["body"])
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
    else
        local strError = "返回错误码："..msg.header.result
    end
end

function NoticeCommonHandler:handleApplyFamilyNotice29525(msg)
    if msg.header.result == 0 then 
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "家族按钮" , value = true})  
    else
        local strError = "返回错误码："..msg.header.result
    end
end

function NoticeCommonHandler:handleSameLoginNotice29527(msg)
    if msg.header.result == 0 then 
        local okCallBack = function()
            disconnect()
            LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER)
            cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = true
        end
        showSystemAlertDialog("您的账号已在另一台设备登陆！", okCallBack)
        cc.Director:getInstance():getRunningScene()._bForceQuit = true
    else
        local strError = "返回错误码："..msg.header.result
    end
    
end

function NoticeCommonHandler:handleStopServiceNotice29529(msg)
    if msg.header.result == 0 then 
        local okCallBack = function()
            disconnect()
            LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER)
            cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = true
        end
        showSystemAlertDialog("服务器开始维护中！", okCallBack)
        cc.Director:getInstance():getRunningScene()._bForceQuit = true
    else
        local strError = "返回错误码："..msg.header.result
    end
    
end

-- 职位变化的通知
function NoticeCommonHandler:handleChangePositionNotice29533(msg)
    if msg.header.result == 0 then 
        print("您的职位已经变化为"..msg.body.position)
        FamilyManager:getInstance()._position = msg.body.position
        -- 请求家族成员列表
        FamilyCGMessage:queryFamilyMemberReq22322()
    else
        local strError = "返回错误码："..msg.header.result
    end
end

return NoticeCommonHandler