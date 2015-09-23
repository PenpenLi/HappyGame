--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OperateTalk.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/7
-- descrip:   对话操作（用于任务中的操作队列）
--===================================================
local OperateTalk = class("OperateTalk", function()
	return require("Operate"):create()
end)

-- 构造函数
function OperateTalk:ctor()
    self._strName = "OperateTalk"      -- 操作名称
    self._nTalkID = 0                  -- 对话id
    
end

-- 创建函数
function OperateTalk:create(args)
    local op = OperateTalk.new()
    op:dispose(args)
    return op
end

-- 初始化处理
function OperateTalk:dispose(args)

    self._nTalkID = args.talkID
    
end

-- 开始
function OperateTalk:onEnter()
    self:onBaseEnter()
    
    self:getTalksManager():setCurTalks(self._nTalkID)
    
    return
end

-- 结束
function OperateTalk:onExit()
    self:onBaseExit()
    
    return
end

-- 循环更新
function OperateTalk:onUpdate(dt)
    self:onBaseUpdate(dt)
    
    -- 对话不再显示，表示当前对话操作已经结束
    if self:getTalksManager():isCurTalksFinished() == true then
        self._bIsOver = true    -- 已经结束
    end
    
    return
end

-- 复位
function OperateTalk:reset()
    self:baseReset()
    
    return
end

-- 检测结束标记
function OperateTalk:checkOver(dt)
    if self._bIsOver == true then
        self:onExit()
    end
    return
end

return OperateTalk
