--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendHandler.lua
-- author:    liyuhang
-- created:   2015/5/22
-- descrip:   好友相关handler
--===================================================
local FriendHandler = class("FriendHandler")

-- 构造函数
function FriendHandler:ctor()     
    -- 获取好友列表
    NetHandlersManager:registHandler(22001, self.handleMsgQueryFriendList)
    -- 获取好友申请列表
    NetHandlersManager:registHandler(22003, self.handleMsgQueryApplyFriendList)
    -- 获取礼物列表
    NetHandlersManager:registHandler(22005, self.handleMsgQueryGiftList)
    -- 查找角色请求
    NetHandlersManager:registHandler(22007, self.handleMsgQueryFriendRoleInfo)
    -- 获取推荐好友请求
    NetHandlersManager:registHandler(22009, self.handleMsgRecommendList)
    -- 添加好友
    NetHandlersManager:registHandler(22011, self.handleMsgApplyFriend)
    -- 处理好友请求
    NetHandlersManager:registHandler(22013, self.handleMsgReplyApplication)
    -- 赠送礼物
    NetHandlersManager:registHandler(22015, self.handleMsgGiftFriend)
    -- 删除好友
    NetHandlersManager:registHandler(22017, self.handleMsgRemoveFriend)
    -- 请求查看详情
    NetHandlersManager:registHandler(22019, self.handleMsgQueryRoleInfo)
    -- 请求好友技能
    NetHandlersManager:registHandler(22021, self.handleMsgQueryFriendSkill)
    -- 配置好友技能
    NetHandlersManager:registHandler(22023, self.handleMsgMountFriendSkill)
end

-- 创建函数
function FriendHandler:create()
    print("FriendHandler create")
    local handler = FriendHandler.new()
    return handler
end

-- 获取好友列表
function FriendHandler:handleMsgQueryFriendList(msg)
    print("FriendHandler 22001")
    if msg.header.result == 0 then
        FriendManager:getInstance():setFriendList(msg.body.friendList)
        
        FriendCGMessage:sendMessageQueryApplyFriendList22002()
        FriendCGMessage:sendMessageQueryGiftList22004()
        FriendCGMessage:sendMessageQueryFriendSkill()
        FriendCGMessage:sendMessageRecommendList22008()
        
        NetRespManager:dispatchEvent(kNetCmd.kUpdateFriendDatas,{1})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 获取好友申请列表
function FriendHandler:handleMsgQueryApplyFriendList(msg)
    print("FriendHandler 22003")
    if msg.header.result == 0 then 
        FriendManager:getInstance()._pApplyFriendList = msg.body.applyFriendList
        
        NetRespManager:dispatchEvent(kNetCmd.kUpdateFriendDatas,{2})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 获取礼物列表
function FriendHandler:handleMsgQueryGiftList(msg)
    print("FriendHandler 22005")
    if msg.header.result == 0 then 
        FriendManager:getInstance():setGiftList(msg.body.giftList)
        
        NetRespManager:dispatchEvent(kNetCmd.kUpdateFriendDatas,{3})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 查找角色请求
function FriendHandler:handleMsgQueryFriendRoleInfo(msg)
    print("FriendHandler 22007")
    if msg.header.result == 0 then 
        if msg.body.roleInfo == nil then
        	NoticeManager:showSystemMessage("查无此人")
        else
            --DialogManager:getInstance():showDialog("FriendFindInfoDialog",{msg.body.roleInfo}) 
            
            NetRespManager:dispatchEvent(kNetCmd.kQueryFriendRoleInfo,{msg.body.roleInfo})
        end
        
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 获取推荐好友请求
function FriendHandler:handleMsgRecommendList(msg)
    print("FriendHandler 22009")
    if msg.header.result == 0 then 
        FriendManager:getInstance()._pRecommendList =  msg.body.recommendList

        NetRespManager:dispatchEvent(kNetCmd.kUpdateRecommendFriendDatas,{})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 添加好友
function FriendHandler:handleMsgApplyFriend(msg)
    print("FriendHandler 22011")
    if msg.header.result == 0 then 
        NewbieManager:showOutAndRemoveWithRunTime()
        NoticeManager:showSystemMessage("申请成功,请等待对方回复.")
    else
        NewbieManager:showOutAndRemoveWithRunTime()
        print("返回错误码："..msg.header.result)
    end
end

-- 处理好友请求
function FriendHandler:handleMsgReplyApplication(msg)
    print("FriendHandler 22013")
    if msg.header.result == 0 then 
        FriendManager:getInstance():setFriendList(msg.body.friendList)
        FriendManager:getInstance()._pApplyFriendList = msg.body.applyFriendList
        
        NetRespManager:dispatchEvent(kNetCmd.kUpdateFriendDatas,{1,2})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 赠送礼物
function FriendHandler:handleMsgGiftFriend(msg)
    print("FriendHandler 22015")
    if msg.header.result == 0 then 
        for i=1,table.getn(FriendManager:getInstance()._pFriendList) do
            if FriendManager:getInstance()._pFriendList[i].roleId == msg.body.argsBody.roleId then
                FriendManager:getInstance()._pFriendList[i].friendship = msg.body.friendShip
                
                NetRespManager:dispatchEvent(kNetCmd.kUpdateFriendDatas,{1})
                break
            end
        end
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 删除好友
function FriendHandler:handleMsgRemoveFriend(msg)
    print("FriendHandler 22017")
    if msg.header.result == 0 then 
        for i=1,table.getn(FriendManager:getInstance()._pFriendList) do
            if FriendManager:getInstance()._pFriendList[i].roleId == msg.body.argsBody.roleId then
                table.remove(FriendManager:getInstance()._pFriendList,i)
                break
        	end
        end
        
        if FriendManager:getInstance()._nMountFriendSkill ~= nil and FriendManager:getInstance()._nMountFriendSkill.roleId == msg.body.argsBody.roleId then
            FriendManager:getInstance():cancleFriendSkill()
        end
        
        NetRespManager:dispatchEvent(kNetCmd.kUpdateFriendDatas,{1})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 请求查看详情
function FriendHandler:handleMsgQueryRoleInfo(msg)
    print("FriendHandler 22019")
    if msg.header.result == 0 then 
        DialogManager:getInstance():showDialog("PvperDetialDialog",msg.body.roleInfo)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 请求好友技能
function FriendHandler:handleMsgQueryFriendSkill(msg)
    print("FriendHandler 22021")
    if msg.header.result == 0 then 
        FriendManager:getInstance()._bGetInitData = true 
        if table.getn( msg.body.friendSkill) ~= 0 then
            FriendManager:getInstance():setFriendSkillInfo(msg.body.friendSkill[1])
        else
            FriendManager:getInstance():cancleFriendSkill()
        end
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 配置好友技能
function FriendHandler:handleMsgMountFriendSkill(msg)
    print("FriendHandler 22023")
    if msg.header.result == 0 then 
        if table.getn( msg.body.friendSkill) ~= 0 then
            FriendManager:getInstance():setFriendSkillInfo(msg.body.friendSkill[1])
        else
            FriendManager:getInstance():cancleFriendSkill()
        end
        
        NetRespManager:dispatchEvent(kNetCmd.kUpdateFriendSkillDatas,{})
    else
        print("返回错误码："..msg.header.result)
    end
end

return FriendHandler