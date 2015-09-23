--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SkillObj.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/8
-- descrip:   所有技能对象基类
--===================================================
local SkillObj = class("SkillObj",function()
    return cc.Node:create()
end)

-- 构造函数
function SkillObj:ctor()
    self._strName = "SkillObj"                          -- 技能对象名称
    self._pMaster = nil                                 -- 当前技能的持有者
    self._pStateMachineDelegate = nil                   -- 状态机组代理器
    self._tTempleteInfo = nil                           -- 技能模板表数据
    self._pSkillInfo = nil                              -- 技能属性表数据
    self._fCDTime = 0                                   -- 技能冷却时间
    self._fCDCounter = 0                                -- 技能冷却时间计数
    self._strAniName = nil                              -- 动画资源名称
    self._kAniType = kType.kAni.kNone                   -- 动画展现类型
    self._pAni = nil                                    -- 动画对象
    self._bActive = true                                -- 是否为有效活跃状态（为false时会被自动删除）
    self._tFrameRegion = {}                             -- 帧区间
    self._tActionsTime = {}                             -- 动作时间
    self._tActionsLoop = {}                             -- 帧区间动画是否循环
    self._tActsSpeed = {}                               -- 帧区间动画速度
    self._tFrameEventBodyRects = {}                     -- 动作帧事件上的碰撞矩形集合{  {{矩形},{矩形},{矩形}}, {}.....  }
    self._tCurAttackRects = {}                          -- 当前技能事件帧上的伤害矩形信息集合（动态更新的）
    self._nSettledZorder = nil                          -- 技能施展的时候，当需要指定的zorder时候，设置这个值来代替地图的zorder机制，默认值为nil
    self._nCurFrameRegionIndex = 0                      -- 技能当前动画所处区间的index，默认从1开始计数
    self._nCurFrameEventIndex = 0                       -- 技能当前动画所处区间中的帧事件的index，末日呢从1开始计数
    self._bForceMinPositionZ = false                    -- 是否需要强制positionZ
    self._nForceMinPositionZValue = 0                   -- 当已经强制了positionZ时候，给其设置的固定值
    self._strFrameEventName = ""                        -- 事件类型名称

    self._pChantOverActionNode = nil                    -- 状态机中的吟唱结束action依托节点
    self._pSkillActOverActionNode = nil                 -- 状态机中的技能表现action依托节点

end

-- 创建函数
function SkillObj:create(master, skillInfo)
    local obj = SkillObj.new()
    obj:dispose(master, skillInfo)
    return obj
end

-- 处理函数
function SkillObj:dispose(master, skillInfo)
    -- 设置技能信息 
    self:initInfo(master, skillInfo)
    -- 初始化动画和动作
    self:initAnisAndActions()
    -- 动作依托的节点
    self._pChantOverActionNode = cc.Node:create()
    self._pSkillActOverActionNode = cc.Node:create()
    self:addChild(self._pChantOverActionNode)
    self:addChild(self._pSkillActOverActionNode)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSkillObj()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function SkillObj:onExitSkillObj()
  --  print(self._strName.." onExit!")

end

-- 循环更新
function SkillObj:updateSkillObj(dt)
    if self._pStateMachineDelegate ~= nil then
        self._pStateMachineDelegate:procAllStateMachines(dt)
    end
    self:procActionsFrameEvents()
    self:procCD(dt)
    self:refreshZorder()
end

-- 帧事件的处理
function SkillObj:procActionsFrameEvents()

end

-- 更新CD
function SkillObj:procCD(dt)
    -- 技能冷却proc
    if self._fCDTime ~= 0 then
        self._fCDCounter = self._fCDCounter + dt
        if self._fCDCounter >= self._fCDTime then
            self._fCDCounter = self._fCDTime
        end
    end
    
end

-- 是否CD结束
function SkillObj:isCDOver()
    if self._fCDCounter == self._fCDTime then
        return true
    end
    return false
end

-- 通过索引值设置位置
function SkillObj:setPositionByIndex(index)
    local pos = self:getMapManager():convertIndexToPiexl(index)
    self:setPosition(pos)
end

-- 获取当前的索引位置
function SkillObj:getPositionIndex()
    local posX, posY = self:getPosition()
    local index = self:getMapManager():convertPiexlToIndex(cc.p(posX,posY))
    return index
end

-- 初始化技能信息
function SkillObj:initInfo(master, skillInfo)
    self._pMaster = master
    self._pSkillInfo = skillInfo
    self._tTempleteInfo = TableTempleteSkills[self._pSkillInfo.TempleteID]
    if self._tTempleteInfo then
        self._strAniName = self._tTempleteInfo.DetailInfo.AniResName
        self._kAniType = self._tTempleteInfo.DetailInfo.AniType
    end
    self._fCDTime = self._pSkillInfo.CD
    self._fCDCounter = self._fCDTime        -- 默认都已经冷却结束

end

-- 初始化动画和动作
function SkillObj:initAnisAndActions()
    if self._tTempleteInfo then
        -- 动画对象
        self._pAni = cc.CSLoader:createNode(self._strAniName..".csb")
        self:addChild(self._pAni)
        -- 添加动画动作
        for mk,mv in pairs(self._tTempleteInfo.DetailInfo.ActsFrameRegions) do
            table.insert(self._tFrameRegion,{mv[1],mv[2]})
            table.insert(self._tActsSpeed,self._tTempleteInfo.DetailInfo.ActsSpeed[mk])
            table.insert(self._tActionsLoop,self._tTempleteInfo.DetailInfo.ActsLoop[mk])
            -- 计算时间
            local time = (self._tFrameRegion[mk][2] - self._tFrameRegion[mk][1])*cc.Director:getInstance():getAnimationInterval()
            local timeSpeed = self._tActsSpeed[mk]
            time = time * (1/timeSpeed)
            table.insert(self._tActionsTime,time)
        end
        -- 碰撞矩形信息
        local regionCount = table.getn(self._tTempleteInfo.DetailInfo.ActsFrameRegions)
        regionCount = self:initFrameEventBodyRects1(regionCount)
        regionCount = self:initFrameEventBodyRects2(regionCount)
        regionCount = self:initFrameEventBodyRects3(regionCount)
        regionCount = self:initFrameEventBodyRects4(regionCount)
        regionCount = self:initFrameEventBodyRects5(regionCount)
        regionCount = self:initFrameEventBodyRects6(regionCount)
        regionCount = self:initFrameEventBodyRects7(regionCount)
        regionCount = self:initFrameEventBodyRects8(regionCount)
    end
    
end

-- 获取状态机
function SkillObj:getStateMachineByTypeID(id)
    return self._pStateMachineDelegate:getStateMachineByTypeID(id)
end

-- 刷新zorder
function SkillObj:refreshZorder()
    -- 如果没有指定的zorder，则按照地图的zorder规则设置技能的zorder即可
    if self._bForceMinPositionZ == true then    -- 强制positionZ
        self:setPositionZ(self._nForceMinPositionZValue)
    else                                        -- 非强制positionZ
        self:setPositionZ(self:getPositionIndex().y*(self:getMapManager()._f3DZ))
    end

    if self._nSettledZorder then
        self:setLocalZOrder(self._nSettledZorder)
    else
        self:setLocalZOrder(kZorder.kMinSkill + self:getMapManager()._sMapRectPixelSize.height - self:getPositionY())
    end
end

-- 播放动画
function SkillObj:playActionByIndex(index)
    if self._pAni then
        self._pAni:stopAllActions()
        self._pAni:getActionManager():removeAllActionsFromTarget(self._pAni)
        local action = cc.CSLoader:createTimeline(self._strAniName..".csb")
        action:gotoFrameAndPlay(self._tFrameRegion[index][1],self._tFrameRegion[index][2],self._tActionsLoop[index])   
        action:setTimeSpeed(self._tActsSpeed[index])
        action:clearFrameEventCallFunc()
        self:initActionsFrameEvents(index, action)   -- 初始化actions的回调逻辑
        self._pAni:runAction(action)
    end
end

-- 停止动画
function SkillObj:stopActionByIndex(index)
    if self._pAni then
        self._pAni:stopAllActions()
        self._pAni:getActionManager():removeAllActionsFromTarget(self._pAni)
    end
end

-- 停止所有动画
function SkillObj:stopAllAnimationActions()
    if self._pAni then
        self._pAni:stopAllActions()
        self._pAni:getActionManager():removeAllActionsFromTarget(self._pAni)
    end
end

-- 获取动画时间
function SkillObj:getActionTimeByIndex(index)
    return self._tActionsTime[index]
end

-- 停止所有动画依托节点【重要：在异常状态时，均需要条用该接口】
function SkillObj:stopAllActionNodes()
    self._pChantOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:stopAllActions()
    self:stopActionByTag(nSkillFlyActTag)
    self:getMaster():stopActionByTag(nRoleShootAheadTag)
    
end

-- 获取技能节点上的主干body在地图中的绝对（位置）碰撞矩形
-- 参数1：技能FrameEventBodyRects中的帧区间索引值
-- 参数2：技能FrameEventBodyRects中的相应帧区间中的事件帧索引
function SkillObj:getFrameEventBodyRectsInMap(actFrameRegionIndex, frameEventIndex)
    local posX, posY = self:getPosition()
    local tRects = {}
    if self._kAniType == kType.kAni.k2D then
        if self._tFrameEventBodyRects[actFrameRegionIndex][frameEventIndex] ~= nil then
            for k,v in pairs(self._tFrameEventBodyRects[actFrameRegionIndex][frameEventIndex]) do
                table.insert(tRects,cc.rect(posX + v[1], posY + v[2], v[3], v[4]))
            end 
        end
    end
    return tRects
end

-- 设置技能节点在当前事件帧上的信息
-- 包括：帧事件index和主干body集合在地图中的绝对（位置）碰撞矩形等信息
-- 参数1：技能FrameEventBodyRects中的帧区间索引值
-- 参数2：技能FrameEventBodyRects中的相应帧区间中的事件帧索引
function SkillObj:setCurAttackFrameEventInfo(actFrameRegionIndex, frameEventIndex)
    self._nCurFrameRegionIndex = actFrameRegionIndex
    self._nCurFrameEventIndex = frameEventIndex
    self._tCurAttackRects = self:getFrameEventBodyRectsInMap(actFrameRegionIndex,frameEventIndex)
    return
end

-- 清空技能节点在当前事件帧上的主干body集合在地图中的绝对（位置）碰撞矩形
function SkillObj:clearCurAttackFrameEventInfo()
    self._nCurFrameRegionIndex = 0
    self._nCurFrameEventIndex = 0
    self._tCurAttackRects = {}
    return
end

-- 刷新相机
function SkillObj:refreshCamera()
    self:getMapManager()._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
end

-- 获取技能的主人
function SkillObj:getMaster() 
    return self._pMaster
end

-- 设置当前状态机的持有者
function SkillObj:setMaster(master)
    self._pMaster = master
end

-- 初始化第1区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects1(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects1_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
end

-- 初始化第2区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects2(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects2_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
end

-- 初始化第3区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects3(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects3_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
end

-- 初始化第4区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects4(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects4_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
end

-- 初始化第5区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects5(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects5_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
end

-- 初始化第6区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects6(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects6_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    
end

-- 初始化第7区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects7(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects7_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
end

-- 初始化第8区间内的碰撞矩形信息
function SkillObj:initFrameEventBodyRects8(regionCount)
    if regionCount == 0 then
        return regionCount
    end
    local rects = {}
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_1 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_1)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_2 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_2)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_3 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_3)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_4 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_4)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_5 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_5)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_6 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_6)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_7 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_7)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_8 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_8)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_9 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_9)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_10 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_10)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_11 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_11)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_12 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_12)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end

    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_13 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_13)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
    if self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_14 then
        table.insert(rects,self._tTempleteInfo.DetailInfo.FrameEventBodyRects8_14)
    else
        table.insert(self._tFrameEventBodyRects,rects)
        regionCount = regionCount - 1
        return regionCount
    end
    
end

function SkillObj:initActionsFrameEvents(index, action)

end

-- 技能使用接口
function SkillObj:onUse()

end

-- 技能待机状态onEnter时技能操作
function SkillObj:onEnterIdleDo(state)

end

-- 技能待机状态onExit时技能操作
function SkillObj:onExitIdleDo()

end

-- 技能待机状态onUpdate时技能操作
function SkillObj:onUpdateIdleDo(dt)

end

-- 技能吟唱状态onEnter时技能操作
function SkillObj:onEnterChantDo(state)

end

-- 技能吟唱状态onExit时技能操作
function SkillObj:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function SkillObj:onUpdateChantDo(dt)

end

-- 技能执行状态onEnter时技能操作
function SkillObj:onEnterProcessDo(state)

end

-- 技能执行状态onExit时技能操作
function SkillObj:onExitProcessDo()

end

-- 技能执行状态onUpdate时技能操作
function SkillObj:onUpdateProcessDo(dt)

end

-- 技能释放状态onEnter时技能操作
function SkillObj:onEnterReleaseDo(state)

end

-- 技能释放状态onExit时技能操作
function SkillObj:onExitReleaseDo()

end

-- 技能释放状态onUpdate时技能操作
function SkillObj:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function SkillObj:reset()

end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function SkillObj:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function SkillObj:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function SkillObj:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function SkillObj:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function SkillObj:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function SkillObj:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function SkillObj:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function SkillObj:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function SkillObj:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取战斗AI管理器
function SkillObj:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

--------------------------------------------------------------------------------------------------------------

return SkillObj
