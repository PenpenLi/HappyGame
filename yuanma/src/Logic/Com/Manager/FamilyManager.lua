--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyManager.lua
-- author:    wuqd
-- created:   2015/05/12
-- descrip:   家族管理器
--===================================================
FamilyManager = {}
local instance = nil 

-- 单例 
function FamilyManager:getInstance()
    if not instance then
        instance = FamilyManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function FamilyManager:clearCache()

    --是否有家族
    self._bOwnFamily = false
    -- 在家族中的职位
    self._position = kFamilyPosition.kNone 
    -- 自己家族的信息
    self._pFamilyInfo = nil 
    -- 自己的捐献次数
    self._nDonateCount = 0

    -- 自家家族的成员信息
    self._tMembers = {}

    self._tTechInfo = {}
    --初始化家族科技buff信息
    self:initFamilyTechInfo()

end

-- 根据权限类型和对方的职位来判断权限
function FamilyManager:whetherHasPermission(familyCheifType,position)
	
    -- 族长任命他人为族长
    if self._position == kFamilyPosition.kLeader 
        and familyCheifType == kFamilyPosition.kLeader 
        and position ~= kFamilyPosition.kLeader then 
        return true
    end

    if position ~= nil and position <= self._position then 
		return false
	end
		
	if TableFamilyPosition[self._position][familyCheifType] == 0 then 
	   return false
	end
	
	return true
end


-- 获取相应职位的在职人数
function FamilyManager:getPositionNum(kPosition)
    local nMemberNum = 0
    for i,v in ipairs(self._tMembers) do
        if v.position == kPosition then 
            nMemberNum = nMemberNum + 1
        end
    end
    return nMemberNum
end

--初始化家族科技buff信息
function FamilyManager:initFamilyTechInfo()
    for k,v in pairs(TableFamilyTech) do
    if self._tTechInfo[v.ID] == nil then 
       self._tTechInfo[v.ID]= {}
    end
       self._tTechInfo[v.ID][v.Level+1] = v  	
    end
end

--得到家族科技buff
function FamilyManager:getTechInfoByIdAndLevel(nId,nLevel)
    return  self._tTechInfo[nId][nLevel+1]  
end

--得到家族科技buff大小
function FamilyManager:getTechNums()
    return  table.getn(self._tTechInfo) 
end

-- 查询自己在家族中的信息 
function FamilyManager:getSelfFamilyMemberInfo()
    for i,v in ipairs(self._tMembers) do
        if v.roleId == RolesManager:getInstance()._pMainRoleInfo.roleId then 
            return v
        end
    end
end

-- 获取家族当前在线人数
function FamilyManager:getOnlineMemberNum()
     local memberNum = 0
     for i,v in ipairs(self._tMembers) do
        if v.offlineTime == 0 then
            memberNum = memberNum + 1
        end
     end
     return memberNum
end