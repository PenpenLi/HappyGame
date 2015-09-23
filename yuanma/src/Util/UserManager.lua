--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  UserManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   玩家管理器
--===================================================
UserManager = {}

local instance = nil

-- 单例
function UserManager:getInstance()
    if not instance then
        instance = UserManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function UserManager:clearCache()  

end

-- 循环处理
function UserManager:update(dt)

end

