--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SturaLibraryManager.lua
-- author:    wuquandong
-- created:   2015/09/15
-- descrip:   藏经阁管理器
--===================================================
SturaLibraryManager = {}
local instance = nil 

-- 单例
function SturaLibraryManager:getInstance()
	if not instance then 
		instance = SturaLibraryManager
		instance:clearCache()
	end
	return instance
end

-- 清空缓存
function SturaLibraryManager:clearCache()
	-- 经书的集合
	self._tSutraBookList = {}
	-- 获取本地的经书信息
	self:getLocalSturaBooks()
	-- 本地的残页信息
	self._tSutraPages = {}
	-- 已经解锁的经书
	self._nCurUnLockBookId = 0
end

-- 获取本地的经书信息
function SturaLibraryManager:getLocalSturaBooks()
	for i,dataInfo in ipairs(TableCJG) do
		local bookInfo = {id = dataInfo.BookID,index = i,state = 0,pages = {0,0,0,0,0}}
		bookInfo.dataInfo = dataInfo
		self._tSutraBookList[i] = bookInfo
	end
end

-- 更新经书的信息
-- {bookId,pages}
function SturaLibraryManager:updateSturaBookInfo(tBooks)
	for i,v in ipairs(tBooks) do
		for k,bookInfo in pairs(self._tSutraBookList) do
			if bookInfo.id == v.bookId then 
				bookInfo.pages = v.pages
				local bActive = true
				for i,v in ipairs(bookInfo.pages) do
					local nConstPagesNum = bookInfo.dataInfo.PageDetails[i][2]
					if v < nConstPagesNum then 
						bActive = false
					end
				end
				if bActive == true then 
					bookInfo.state = 2 -- 表示经书已经全部激活
				end
				break
			end
		end
	end
	-- 检查最新解锁的经书
	self:checkNewUnlockBooks()
end

-- 获取本地残页信息的集合
function SturaLibraryManager:getLocalSturaPages()
	-- 清除缓存数据
	self._tSutraPages = {}
	local pBagManager = BagCommonManager:getInstance() 
	for k,v in pairs(TableItems) do
		if v.UseType == kItemUseType.kPage then 
			local itemInfo = pBagManager:getItemRealInfo(v.ID,kItemType.kFeed)
			table.insert(self._tSutraPages,itemInfo)
		end
	end

    table.sort(self._tSutraPages,function(a,b)
        return a.dataInfo.SortNumber < b.dataInfo.SortNumber -- 从小到大排序
    end)

end

-- 根据经书的Id 获取经书的信息
function SturaLibraryManager:getLocalSturaBookInfoById(bookId)
	for i,v in ipairs(self._tSutraBookList) do
		if v.id == bookId then 
			return v
		end 
	end
	return nil 
end

-- 设置藏经阁解锁的id
function SturaLibraryManager:setSturaLibraryUnlockInfo(nBookId)
	self._nCurUnLockBookId = nBookId 
	cc.UserDefault:getInstance():setIntegerForKey("UnLockSturaBookId_"..RolesManager:getInstance()._pMainRoleInfo.roleId, self._nCurUnLockBookId)
    cc.UserDefault:getInstance():flush()
end

-- 获取经书的解锁id 
function SturaLibraryManager:getSturaLibraryUnlockInfo()
	local temp = cc.UserDefault:getInstance():getIntegerForKey("UnLockSturaBookId_"..RolesManager:getInstance()._pMainRoleInfo.roleId)
    
    if temp ~= 0 then
        self._nCurUnLockBookId = temp
    end
end

-- 根据残页的id 获取残页的信息
function SturaLibraryManager:getSturaPageInfoById (id)
	for i,v in ipairs(self._tSutraPages) do
		if v.id == id then 
			return v
		end 
	end
	return nil 
end

-- 获取最新解锁的经书集合
-- return true 表示有新的藏经阁解锁
-- return false 表示没有新的藏经阁解锁
function SturaLibraryManager:checkNewUnlockBooks()
	-- 角色的等级
	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level	
	for i,v in ipairs(self._tSutraBookList) do
		if v.id > self._nCurUnLockBookId then 
			-- 经书的解锁等级
			local needLevel = v.dataInfo.RequiredLevel
			if i == 1 then 
				if roleLevel >= needLevel then
					v.state = 1 -- 表示经书已经解锁
					self:setSturaLibraryUnlockInfo(v.id)
					return true
				end
			else
				if v.state == 0 and roleLevel >= needLevel and self._tSutraBookList[i -1].state == 2 then 
					v.state = 1 -- 表示经书已经解锁
					self:setSturaLibraryUnlockInfo(v.id)
					return true
				end
			end
		end
	end
	return false
end