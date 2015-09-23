--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  HuaShanHandler.lua
-- author:    wuqd
-- created:   2015/05/18
-- descrip:   华山论剑handler
--===================================================

local HuaShanHandler = class("HuaShanHandler")

-- 构造函数
function HuaShanHandler:ctor()     
    -- 获取华山论剑信息
    NetHandlersManager:registHandler(21901, self.handleMsgQueryHSResp21901)
    -- 查看挑战对手详细信息
    NetHandlersManager:registHandler(21903, self.handleMsgQueryHSEnemyDetialResp21903)
    -- 挑战对手回复
    NetHandlersManager:registHandler(21905, self.handleMsgFightHSEnemyRep21905)
    -- 挑战结果回复
    NetHandlersManager:registHandler(21907,self.handleMsgFightHSResultResp21907)
    -- 增加鼓舞Buf回复
    NetHandlersManager:registHandler(21909,self.handleMsgAddBufResp21909)
end

-- 创建函数
function HuaShanHandler:create()
    print("HuaShanHandler create")
    local handler = HuaShanHandler.new()
    return handler
end

function HuaShanHandler:handleMsgQueryHSResp21901(msg)
	print("HuaShanHandler 21901")
    if msg.header.result == 0 then
        local event = 
        {
        	-- buf 等级 
        	nBuffLevel = msg.body.buffLevel,
            -- 对手列表
            enemys = msg["body"].enemys,
        }
       DialogManager:getInstance():showDialog("HuaShanDialog",event)
    else
        print("返回错误码："..msg.header.result)
    end
end

function HuaShanHandler:handleMsgQueryHSEnemyDetialResp21903(msg)
	print("HuaShanHandler 21903")
    if msg.header.result == 0 then     
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryHSEnemyDetialResp,event)
         DialogManager:getInstance():showDialog("PvperDetialDialog",msg.body.roleInfo)
    else
        print("返回错误码："..msg.header.result)
    end
end

function HuaShanHandler:handleMsgFightHSEnemyRep21905(msg)
	print("HuaShanHandler 21905")
    if msg.header.result == 0 then
        local event = 
        {
        	-- 角色的战斗信息 
        	roleFightInfo = msg.body.roleInfo,
        }
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kFightHSFightResp,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

function HuaShanHandler:handleMsgFightHSResultResp21907(msg)
	print("HuaShanHandler 21907")
    if msg.header.result == 0 then
        local event = 
        {
            curStar = 0,
            addExp = 0,
            extPickCount = 0,
            currExp = RolesManager:getInstance()._pMainRoleInfo.exp,
            currLevel = RolesManager:getInstance()._pMainRoleInfo.level,
            items = msg.body.award.items,
            finances = msg.body.award.finances,
            roleAttrInfo = RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo,
        }
        DialogManager:getInstance():showDialog("BattleTowerAccountsDialog",{event})

        -- 领奖弹框
        -- DialogManager:getInstance():showDialog("GetItemsDialog",msg["body"].award)  
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kFightHSFightResp,event)
    else
        print("返回错误码："..msg.header.result)
        LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
    end
end

function HuaShanHandler:handleMsgAddBufResp21909(msg)
	print("HuaShanHandler 21909")
    if msg.header.result == 0 then
        local event = 
        {
        	-- 当前Buf 等级
        	buffLevel = msg.body.buffLevel,
        }
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kAddHSBuffResp,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

return HuaShanHandler
