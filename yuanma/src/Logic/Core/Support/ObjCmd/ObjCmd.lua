--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ObjCmd.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/15
-- descrip:   对象命令（用于接收指令，然后做出展现）
--===================================================
local ObjCmd = class("ObjCmd")

-- 构造函数
function ObjCmd:ctor()
    self._strName = "ObjCmd"                   -- 命令名称
    self._kObjCmdType = kType.kObjCmd.kNone    -- 对象命令类型
    self._pMaster = nil                        -- 持有该cmd的主人

end

-- 创建函数
function ObjCmd:create()
    local cmd = ObjCmd.new()
    return cmd
end

-- 循环更新
function ObjCmd:update(dt)

    return
end

-- 退出函数
function ObjCmd:onExitObjCmd()

end

-- 设置master
function ObjCmd:setMaster(master)
    self._pMaster = master
end

-- 返回master
function ObjCmd:getMaster()
    return self._pMaster
end

-- cmd:站立
function ObjCmd:cmdStand(args)
    self._pMaster:setAngle3D(args.angle)
    self._pMaster._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(args.angle)
    
    if self._pMaster._kGameObjType == kType.kGameObj.kRole then -- 角色类型
        if self._pMaster._kRoleType == kType.kRole.kPlayer then -- 玩家
            if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand)
            elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
            end
        elseif self._pMaster._kRoleType == kType.kRole.kPet then  -- 宠物
            if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kWorldPetRole):setCurStateByTypeID(kType.kState.kWorldPetRole.kStand)
            elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kStand)
            end
        elseif self._pMaster._kRoleType == kType.kRole.kMonster then  -- 野怪
            if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
            end
        end
    end

    return
end

return ObjCmd
