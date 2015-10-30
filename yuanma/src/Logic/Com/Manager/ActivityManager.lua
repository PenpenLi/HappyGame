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
	if self._pScheduler ~= nil then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduler)
		self._pScheduler = nil 
	end
	-- 已经领取的等级礼包
	self._tCompleteLevelGiftList = {}
	-- 首充奖励的状态(0表示条件不足; 1表示条件满足未领取; 2表示已领取 )
	self._nFirstChargeState = 0
	-- 体力赠送的状态(0:不可领取 1:可以领取 2：已经领取)
	self._tPhysicalGiftState = {}
	-- 月签到数据
	self._pMonthSignAward = nil
	self._nMonth = 6            --当前月份
    self._nMonthDayCount = 30    --当前月份每月多少天
    self._nTheDay = 0           --当前天
    self._nSignCount = 10        --当前月已签到次数
    self._nSignVip = 0        --当前天完成vip领取状态 （0:未领取 1:普通领取 2:VIP领取）
    self._nReSignCount = 0        --本月已经补签次数

    -- 累积充值奖励 lzx
    -- 已经领过的奖品ID列表
    self.tAmassAward = nil
    --当前正在与服务器通信的奖品ID
    self.nCurrentAward = -1
end

-- 获取累积充值奖励时间范围
function ActivityManager:getCumulativeRechargeTime()
	local time = ""
	-- 2表示累积活动ID
	local t = self._tActivityStateInfoList[2]
	if t.remainTime > 0 then 
		time = "活动时间:" .. t.startTime .. "-" .. t.endTime
	end
	return time
end

function ActivityManager:startTimeDown()
	local function timeUpdate(dt)
		-- 更新玩家的在线时间
		self._nRoleOnlineTime = self._nRoleOnlineTime + dt
	end
	self._pScheduler =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(timeUpdate,0,false)
end

-- 设置玩家的在线时长
function ActivityManager:setOnlineTime(nSec)
	self._nRoleOnlineTime = nSec
	if self._pScheduler ~= nil then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduler)
		self._pScheduler = nil 
	end
	self:startTimeDown()
end

-- 获取需要显示标签的集合
function ActivityManager:getTagListByPageIndex(pageIndex)
	-- 清除数据
	self._tActivityTagList = {}
	-- 显示在第几页的标签
	local nPageIndex = 1
	if pageIndex ~= nil then 
		nPageIndex = pageIndex
	end
	-- 角色的等级
	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level
    for i,pActivityDataInfo in ipairs(TableActivity) do
    	if pActivityDataInfo.Location == nPageIndex 
    		and self._tActivityStateInfoList[pActivityDataInfo.ID].remainTime > 0 
    		and self._tActivityStateInfoList[pActivityDataInfo.ID].openLevel <= roleLevel then 
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
		if v == nIndex - 1 then -- 服务器索引从0开始
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
		elseif v.totalTime <= self._nRoleOnlineTime and i == nGiftNum then 
			self._nCurOnlineGiftIndex = 99999
		elseif v.totalTime <= self._nRoleOnlineTime and self._nRoleOnlineTime < self._tOnlineGiftLocalList[i + 1].totalTime then
			self._nCurOnlineGiftIndex = i + 1
		end
	end

end

-- 检测当前是否还有没有可领取的在线奖励
function ActivityManager:isShowOnlineWarn()
	self:getCurOnlineGiftIndex()
	local nGiftNum = #self._tOnlineGiftLocalList
	for i = 1, nGiftNum do
		if i < self._nCurOnlineGiftIndex then 
			if self:isOnlineGiftIsComplete(i) == false then
				return true
			end
		else
			return false
		end
	end
	return false
end

-- 判断等级礼包是否已经领取
function ActivityManager:isLevelGiftIsComplete(gift_idx)
	for record_idx,nIndex in ipairs(self._tCompleteLevelGiftList) do
		if nIndex == gift_idx - 1 then -- 服务器索引从零开始
			return true
		end
  	end
  	return false
end

-- 判断是否还有没有可领取的等级礼包
function ActivityManager:isShowLevelGiftWarn()
	-- 角色的等级
  	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level
  	for gift_idx,pLevelGift in ipairs(TableLevelGift) do
  		if roleLevel >= pLevelGift.Level then 
  			if self:isLevelGiftIsComplete(gift_idx) == false then 
  				return true
  			end
  		end
  	end
	return false
end

-- 判断是否可以领取首充奖励
function ActivityManager:isShowFirstChargeWarn()
	if self._nFirstChargeState == 1 then 
		return true
	end
	return false
end

-- 判断是否有体力礼包可以领取
function ActivityManager:isShowPhysicalGiftWarn()
	for i,state in ipairs(self._tPhysicalGiftState) do
		if state == 1 then 
			return true
		end 	
	end 
	return false
end
