--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BeautyManager.lua
-- author:    wuquandong
-- created:   2015/02/04
-- descrip:   美人管理器
--===================================================
BeautyManager = {}
local instance = nil 

-- 单例 
function BeautyManager:getInstance()
	if not instance then
		instance = BeautyManager
		instance:clearCache()
	end
	return instance
end

-- 清空缓存
function BeautyManager:clearCache()
	-- 美人model集合
	self._tBeautyModelList = {}
	-- 美人组model集合
	self._tBeautyGroupModelList = {}
	-- 美人组的解锁特效
	self._nCurUnLockGroupId = 0

	self:getBeautyModels()
	self:getBeautyGroupModels()
	--self:getBeautyGroupUnlockId()
end

-- 获得本地美人信息
function BeautyManager:getBeautyModels()
	for k,dataInfo in pairs(TableIBeauties) do
		local beautyModel = {id = TableIBeauties.ID,num = 0,level = 0,expValue = 0,haveSeen = false}
		beautyModel.dataInfo = dataInfo
		for k1,v in pairs(TableTempleteBeauties) do
			if v.TempleteID == dataInfo.TempleteID then
				beautyModel.templeteInfo = v
				break
			end
		end
		-- 新的尝试 kev = value 
		self._tBeautyModelList[dataInfo.ID] = beautyModel
	end
end

-- 获得美人的完整信息 
function BeautyManager:getFullBeautyInfo(pBeautyInfo)
	pBeautyInfo.dataInfo = nil 
	pBeautyInfo.templeteInfo = nil 
	pBeautyInfo.value = pBeautyInfo.num
	for k,dataInfo in pairs(TableIBeauties) do
		if pBeautyInfo.id == dataInfo.ID then
			pBeautyInfo.dataInfo = dataInfo
		end
	end
	if pBeautyInfo.dataInfo == nil then 
		return pBeautyInfo
	end 
	for k1,templeteInfo in pairs(TableTempleteBeauties) do
		if templeteInfo.TempleteID == pBeautyInfo.dataInfo.TempleteID then
			pBeautyInfo.templeteInfo = templeteInfo
		end
	end
	return pBeautyInfo
end

-- 获得本地美人组信息
function BeautyManager:getBeautyGroupModels()
	for k,v in pairs(TableIBeautiesGroup) do
		local beautyGroupModel = {id = v.ID,beautyStates = {},beautys = {}}
		beautyGroupModel.dataInfo = v
		for k1,v1 in pairs(v.BeautiesID) do
			table.insert(beautyGroupModel.beautys,self._tBeautyModelList[v1])
		end
		self._tBeautyGroupModelList[v.ID] = beautyGroupModel
	end
end

-- 获得美人组当前特效已经播放的组
function BeautyManager:getBeautyGroupUnlockId()
	local temp = cc.UserDefault:getInstance():getIntegerForKey("UnLockBeautyGroupId_"..RolesManager:getInstance()._pMainRoleInfo.roleId)
    
    if temp ~= 0 then
        self._nCurUnLockGroupId = temp
    end
end

-- 设置目前美人组特效已经播放的组
function BeautyManager:setBeautyGroupUnLockId(nGroupId)
	self._nCurUnLockGroupId = nGroupId 
	cc.UserDefault:getInstance():setIntegerForKey("UnLockBeautyGroupId_"..RolesManager:getInstance()._pMainRoleInfo.roleId, self._nCurUnLockGroupId)
    cc.UserDefault:getInstance():flush()
end