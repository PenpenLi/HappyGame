--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryGuideRoleRunState.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:    剧情引导中玩家角色奔跑状态
--===================================================
local StoryGuideRoleRunState = class("StoryGuideRoleRunState",function()
    return require("State"):create()
end)

-- 构造函数
function StoryGuideRoleRunState:ctor()
    self._strName = "StoryGuideRoleRunState"           -- 状态名称
    self._kTypeID = kType.kState.kStoryGuideRole.kRun  -- 状态类型ID
    self._fCurAngleInMoveDirections = 0                 -- 当前指定移动方向集合的行进步中的角度
    self._funcCallBackFunc = nil                        -- 指定移动方向集合结束后的回调函数
    self._pEndPos = nil                                 -- 结束的pos
    self._nRunSoundID = -1                               -- 跑步的声音ID
    self._nCurSpeed = nil                               --当前移动的速度(每次可能有变化)
    
end

-- 创建函数
function StoryGuideRoleRunState:create()
    local state = StoryGuideRoleRunState.new()
    return state
end

-- 进入函数
function StoryGuideRoleRunState:onEnter(args)
    --print(self._strName.."角色奔跑")
    
    if self:getMaster() then
       self._funcCallBackFunc = args.func
       self._pEndPos = args.endPos
       self._nCurSpeed = args.speed
    end
        -- 刷新动作
        self:getMaster():playRunAction()
        
        -- 脚步声 只有人走路有声音
         if self:getMaster()._kStoryRoleType == kType.kRole.kPlayer  then
            self._nRunSoundID = AudioManager:getInstance():playEffect(self:getMaster()._tTempleteInfo.RunSound,true,true)
         end
             -- 奔跑逻辑
        self:procRun()
    return
end

-- 退出函数
function StoryGuideRoleRunState:onExit()
    --print(self._strName.." is onExit!")
    self._funcCallBackFunc = nil
    
    AudioManager:getInstance():stopEffect(self._nRunSoundID)
    self._nRunSoundID = -1
    
    return
end

-- 更新逻辑
function StoryGuideRoleRunState:update(dt)
    return
end

-- 奔跑逻辑
function StoryGuideRoleRunState:procRun()

    
    local direction = self:getMaster()._kDirection
    local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
    local fSpeed = self._nCurSpeed
    local sTileSize = self:getMapManager()._sTiledPixelSize

   local fAttackAngle = mmo.HelpFunc:gAngleAnalyseForRotation(posRole.x, posRole.y, self._pEndPos.x, self._pEndPos.y)
   self:getMaster():setAngle3D(fAttackAngle)

    if posRole.x == self._pEndPos.x and posRole.y == self._pEndPos.y then  -- 起点终点一样直接返回
       self._funcCallBackFunc()
       self._pOwnerMachine:setCurStateByTypeID(kType.kState.kStoryGuideRole.kStand)

    else -- 有指定的路径，则自动行走开始
        local pStartDisEnd = math.sqrt(math.pow((posRole.x-self._pEndPos.x),2)+math.pow((posRole.y-self._pEndPos.y),2))
        local pTime = pStartDisEnd/fSpeed
        local timeCallBack = function ()
              self._funcCallBackFunc()
              self._pOwnerMachine:setCurStateByTypeID(kType.kState.kStoryGuideRole.kStand)
        end
        self:getMaster():runAction( cc.Sequence:create(cc.MoveTo:create(10,cc.p(self._pEndPos)),cc.CallFunc:create(timeCallBack)))
    end

    return
end


return StoryGuideRoleRunState