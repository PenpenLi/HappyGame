--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ActivityManager.lua
-- author:    wuquandong
-- created:   2015/02/04
-- descrip:   活动管理器
--===================================================
ActivityManager = {}
local instance = nil 

-- 单例
function ActivityManager:getInstance()
	if not instance then 
		instance = ActivityManager
		instance:clearCache()
	end
	return instance
end

-- 清空缓存
function ActivityManager:clearCache()
	-- 活动状态表
	self._tActivityStateInfoList = {}
	-- 标签的集合
	self._tActivityTagList = {}
	-- 已经领取的在线奖励
	self._tCompleteOnlineGiftList = {}
	-- 玩家的在线时长
	self._nRoleOnlineTime = 0
	-- 在线礼包的集合
	self._tOnlineGiftLocalList = {}
	-- 当前记时的在线礼包索引
	self._nCurOnlineGiftIndex = -1
	-- 获取在线礼包的本地数据
	self:getOnlineGiftList ()
end

function ActivityManager:update(dt)
	-- 更新玩家的在线时间
	self._nRoleOnlineTime = self._nRoleOnlineTime + dt
end

-- 设置玩家的在线时长
function ActivityManager:setOnlineTime(nSec)
	self._nRoleOnlineTime = nSec
end

-- 获取需要显示标签的集合
function ActivityManager:getTagListByPageIndex(pageIndex)
	-- 显示在第几页的标签
	local nPageIndex = 1
	if pageIndex ~= nil then 
		nPageIndex = pageIndex
	end
	-- 角色的等级
	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level
    for i,pActivityDataInfo in ipairs(TableActivity) do
    	if pActivityDataInfo.Location == nPageIndex 
    		and pActivityDataInfo.ID == self._tActivityStateInfoList[pActivityDataInfo.ID].remainTime > 0 
    		and pActivityDataInfo.RequiredLevel <= roleLevel then 
    		table.insert(self._tActivityTagList,pActivityDataInfo)
    	end
    end
    -- 排序
    table.sort( self._tActivityTagList, function (a, b)  
    	return a.SortNumber < b.SortNumber  -- 从小到大
	end)
end

-- 判断在线活动是否已经领奖
function ActivityManager:isOnlineGiftIsComplete(nIndex)
	for i,v in ipairs(self._tCompleteOnlineGiftList) do
		if v == nIndex then 
			return true
		end
	end
	return false
end

-- 获取在线礼包的集合
function ActivityManager:getOnlineGiftList ()
	self._tOnlineGiftLocalList = shallowcopy(TableOnlineRewards)
	local nTotalTime = 0
	for i,v in ipairs(self._tOnlineGiftLocalList) do
		nTotalTime = nTotalTime + v.OnlineTime 
		v.totalTime = nTotalTime
	end
end

-- 获取当前记时的在线礼包的索引
-- return 99999 表示玩家所有礼包都已可以领取
function ActivityManager:getCurOnlineGiftIndex()
	local nGiftNum = #self._tOnlineGiftLocalList
	for i,v in ipairs(self._tOnlineGiftLocalList) do
		if i == 1 and v.totalTime > self._nRoleOnlineTime then 
			self._nCurOnlineGiftIndex = i
		elseif v.totalTime < self._nRoleOnlineTime and i == nGiftNum then 
			self._nCurOnlineGiftIndex = 99999
		elseif v.totalTime < self._nRoleOnlineTime and self._nRoleOnlineTime < self._nRoleOnlineTime[i + 1].totalTime then
			self._nCurOnlineGiftIndex = i
		end
	end

end

