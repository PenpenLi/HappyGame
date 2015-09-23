--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BombEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/4
-- descrip:   地雷实体
--===================================================
local BombEntity = class("BombEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("Entity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function BombEntity:ctor()
    self._strName = "BombEntity"                -- 实体名字
    self._kEntityType = kType.kEntity.kBomb     -- 实体对象类型
    self._pSkill = nil                          -- 技能对象
    self._fNormalInterval = 0                   -- 实体normal状态下的间隔周期

end

-- 创建函数
function BombEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = BombEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function BombEntity:dispose()

    self:initBombAdditionalAniAction()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBombEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function BombEntity:onExitBombEntity()
    -- 执行父类退出方法
    self:onExitEntity()
end

-- 循环更新
function BombEntity:updateEntity(dt)
    self:updateGameObj(dt)

end

-- 初始化动作
function BombEntity:initBombAdditionalAniAction()

end

-- 播放点燃动作
function BombEntity:playOnFireAction()
    -- 正常动作
    if self._tTempleteInfo.AdditionalActFrameRegion ~= nil then
        local onFire = cc.CSLoader:createTimeline(self._strAniName..".csb")
        self._pAni:stopAllActions()
        onFire:setTag(nEntityActAction)
        onFire:gotoFrameAndPlay(self._tTempleteInfo.AdditionalActFrameRegion[1], self._tTempleteInfo.AdditionalActFrameRegion[2], true) 
        onFire:setTimeSpeed(self._tTempleteInfo.AdditionalActFrameRegion[3])
        self._pAni:runAction(onFire)
    end
    
end

return BombEntity
