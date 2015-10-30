--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldPlayerRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   世界中玩家角色状态机
--===================================================
local WorldPlayerRoleStateMachine = class("WorldPlayerRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function WorldPlayerRoleStateMachine:ctor()
    self._strName = "WorldPlayerRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kWorldPlayerRole  -- 状态类机型ID
    self._bHasOpenTalk = false                            -- 是否有对话
    self._pLashNpcId = nil
end

-- 创建函数
function WorldPlayerRoleStateMachine:create(master)
    local machine = WorldPlayerRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function WorldPlayerRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    
    self:setMaster(master)
    
    self:addState(require("WorldPlayerRoleStandState"):create())  -- 加入站立状态到状态机
    self:addState(require("WorldPlayerRoleRunState"):create())    -- 加入奔跑状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand)  -- 设置当前状态为站立状态
    
    return
end

-- 退出函数
function WorldPlayerRoleStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function WorldPlayerRoleStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    local pRoleX,pRoleY = self:getMaster():getPosition()
    local pNpc =  RolesManager:getInstance()._tNpcRoles
    for k,v in pairs(pNpc) do
       	local pNpcX,pNpcY = v:getPosition()
        if math.pow((pRoleY - pNpcY), 2) + math.pow((pRoleX - pNpcX), 2) < 150*150 then --在npc的对话范围内
           if CDManager:getInstance():getOneCdTimeByKey(v._pRoleInfo.ID + 200) == 0 and CDManager:getInstance():getOneCdTimeByKey(cdType.kNpcWaiting) == 0 then --标示没有cd
              local tTempleteInfo = v._tTempleteInfo
              local pIndex = mmo.HelpFunc:gGetRandNumberBetween(1,table.getn(tTempleteInfo.Texts))
              local nVoiceTime = 0
              local pCallBack = function(time,id)
                    if tTempleteInfo.CD - time == nVoiceTime then --音效播完了
                      if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
                         v:closeNpcTalkPanel()
                      end
                  end
              end
              
              CDManager:getInstance():insertCD({v._pRoleInfo.ID + 200, tTempleteInfo.CD,pCallBack})  
              v:showNpcTalkPanel(tTempleteInfo.Texts[pIndex])
              local pEffect = tTempleteInfo.Voice[pIndex][1]
              AudioManager:getInstance():playEffect(pEffect)
              nVoiceTime = tTempleteInfo.Voice[pIndex][2]
           end
   	    end
   	
   end
   
   
    
    
    
    return
end

return WorldPlayerRoleStateMachine
