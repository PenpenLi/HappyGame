--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendManager.lua
-- created:   2015/5/25
-- descrip:   好友管理器
--===================================================
FriendManager = {}

local instance = nil

-- 单例
function FriendManager:getInstance()
    if not instance then
        instance = FriendManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function FriendManager:clearCache()
    self._bGetInitData = false      
    self._pFriendList = nil            -- 好友列表
    self._pApplyFriendList = nil       -- 好友请求列表
    self._pGiftList = nil              -- 好友礼物列表
    
    self._pRecommendList = nil         -- 好友推荐列表
    
    self._nMountFriendSkill = nil      -- 配置的好友技能 的好友信息
    self._nMountFriendSkillId = -1     -- 配置的好友技能id
    
    self._tNewMessageWarning = {}      -- 新消息提醒
    
    self.friendListFlag = false
    self.applyListFlag = false
    self.giftListFlag = false
    ----------------------------- 永远放在最下面  ---------------------------------------
    
end

function FriendManager:setFriendList(friendList)
    self._pFriendList = friendList
    
    table.sort(self._pFriendList, function(a,b) return a.offlineTime>b.offlineTime end )
    
    if self._pRecommendList ~= nil then
        for i=1,table.getn(self._pRecommendList) do
            local result = self:checkIsFriendWithRoleId(self._pRecommendList[i].roleId)
            if result ~= -1 then
            	FriendCGMessage:sendMessageRecommendList22008()
            end
    	end
    end
end

function FriendManager:setGiftList(giftList)
    self._pGiftList = giftList
    
    table.sort(self._pGiftList, function(a,b) return a.timestamp>b.timestamp end )
end
-- 设置好友技能信息
function FriendManager:setFriendSkillInfo(FriendRoleFightInfo)
    self._nMountFriendSkill = FriendRoleFightInfo
    
    local friendShip = 0
    for i=1,table.getn(self._pFriendList) do
        if self._pFriendList[i].roleId == self._nMountFriendSkill.roleId then
            friendShip = self._pFriendList[i].friendship
    	end
    end
    
    local temp = (self._nMountFriendSkill.roleCareer - 1) * TableConstants.FSMaxLv.Value + 
        ((self._nMountFriendSkill.level * TableConstants.FLvMax.Value) / (self._nMountFriendSkill.level + TableConstants.FLvReduce.Value)) * (1 + (friendShip * TableConstants.FSMax.Value) / (friendShip + self._nMountFriendSkill.level * TableConstants.FSReduce.Value))

    local temp1,temp2 = math.modf(temp / 1)
    self._nMountFriendSkillId = temp2 > 0 and temp1 + 1 or temp1
end

-- 更新好友助战的时间戳
function FriendManager:setFriendHelpCheerTime(cheerTime,friendId)
    for i=1,table.getn(self._pFriendList) do
        if self._pFriendList[i].roleId == friendId then
            self._pFriendList[i].cheerTime = cheerTime
        end
    end
end

-- 获取好友技能id
function FriendManager:getFriendSkillId()
    return self._nMountFriendSkillId
end

function FriendManager:cancleFriendSkill()
    self._nMountFriendSkill = nil
    self._nMountFriendSkillId = -1
end

function FriendManager:checkIsFriendWithRoleId(roleId)
    for i=1,table.getn(self._pFriendList) do
        if self._pFriendList[i].roleId == roleId then
            return i
        end
    end

    return -1
end
-------------------------------------------------------------------------------------------------------------------

