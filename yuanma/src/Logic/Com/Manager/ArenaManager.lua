--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ArenaManager.lua
-- author:    wuqd
-- created:   2015/05/12
-- descrip:   竞技场管理器
--===================================================
ArenaManager = {}
local instance = nil 

-- 单例 
function ArenaManager:getInstance()
	if not instance then
        instance = ArenaManager
		instance:clearCache()
	end
	return instance
end

-- 清空缓存
function ArenaManager:clearCache()
    self._nCurPvpRank = 0          -- 当前竞技场排名
end

