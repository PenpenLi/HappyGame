--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleProgressWidget.lua
-- author:    liyuhang
-- created:   2015/1/27
-- descrip:   进度条控件（封装具体动画接口，增加，减少）
--===================================================
local BattleProgressWidget = class("BattleProgressWidget",function()
    return cc.Layer:create()
end)

-- 构造函数
function BattleProgressWidget:ctor()
    self._strName = "BattleProgressWidget"       -- 层名称

    ---------------------- ui wigdet -----------------------------
    self._pProgressBg = nil
    self._pProgressBar = nil
    --------------------------------------------------------------

    self._recBg = cc.rect(0,0,0,0)                     -- 背景框所在矩形
    self._sSpriteFrameBgName = nil                     -- 进度条背框图片名字
    self._sSpriteFrameName = nil                       -- 进度条图片名字

    self._nProgressMax = 1
    self._nProgressCur = 1
end

-- 创建函数
function BattleProgressWidget:create()
    local layer = BattleProgressWidget.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleProgressWidget:dispose()

    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBattleProgressWidget()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 设置进度条的背景框 ，和填充条的 sprite
-- 设置精灵后，才会初始化控件
function BattleProgressWidget:setSpriteFrameName( spriteName, spriteBgName )
    self._sSpriteFrameBgName = spriteBgName                     
    self._sSpriteFrameName = spriteName

    -- 初始化ui
    -- 进度条背景
    if spriteBgName ~= nil then
        self._pProgressBg = ccui.ImageView:create(self._sSpriteFrameBgName, ccui.TextureResType.plistType)
        self._pProgressBg:setAnchorPoint(cc.p(0.5, 0.5))
        self:addChild(self._pProgressBg)
    end

    -- 进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName(self._sSpriteFrameName)
    
    self._pProgressBar = cc.ProgressTimer:create(pSprite)
    self._pProgressBar:setAnchorPoint(0.5, 0.5)
    self._pProgressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pProgressBar:setMidpoint(cc.p(0, 0))
    self._pProgressBar:setBarChangeRate(cc.p(1, 0))
    self._pProgressBar:setPercentage(self._nProgressCur / self._nProgressMax * 100)
    self:addChild(self._pProgressBar)
end

-- 设置进度条max值
function BattleProgressWidget:setMax( numMax )
    self._nProgressMax = numMax
    self._pProgressBar:setPercentage(0 / self._nProgressMax * 100)
end

-- 设置进度条当前值
function BattleProgressWidget:setCur( numCur )
    self._nProgressCur = numCur
    self._pProgressBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, self._nProgressCur/self._nProgressMax*100.0)))
end

-- 设置经验值
function BattleProgressWidget:setExpUpNum( expUpNum )
    -- 剩余待添加值
    local lastExpUpNum = expUpNum
    
    local roleInfo = RolesManager:getInstance()._pMainRoleInfo
    local expTable = TableLevel
    local curLevel = roleInfo.level

    local function addExp()
        if self._nProgressCur + lastExpUpNum < self._nProgressMax then
            self:setCur( self._nProgressCur + lastExpUpNum )
        else
            lastExpUpNum = lastExpUpNum - (self._nProgressMax - self._nProgressCur)
            self._pProgressBar:runAction(cc.Sequence:create(
                cc.ProgressTo:create(0.5, 100.0) ,
                cc.CallFunc:create(actionOver,{true})))
        end
    end
    
    local function actionOver()
        NoticeManager:getInstance():showSystemMessage("升级了～～～")

        curLevel = curLevel + 1
        self:setMax(TableLevel[curLevel].Exp)
        if lastExpUpNum > 0 then
            addExp()
        end
    end

    addExp()
end

-- 退出函数
function BattleProgressWidget:onExitBattleProgressWidget()

end

return BattleProgressWidget
