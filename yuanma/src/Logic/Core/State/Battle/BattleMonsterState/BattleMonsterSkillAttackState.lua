--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterSkillAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/23
-- descrip:   战斗中怪物角色技能攻击状态
--===================================================
local BattleMonsterSkillAttackState = class("BattleMonsterSkillAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterSkillAttackState:ctor()
    self._strName = "BattleMonsterSkillAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kSkillAttack  -- 状态类型ID
    
    self._pTarget = nil
    self._pCurSkill = nil                                     -- 当前正在使用的技能对象 
    self._nCurSkillIndexInChain = 0                           -- 当前正在使用的技能在技能链中的index
    self._bToNextSkill = false                                -- 用于标记是否需要开始释放下一个技能(该标记位在野怪技能中设置)
    self._fEarlyWarningTime = 0                               -- 预警时间标准
    self._fEarlyWarningCount = 0                              -- 预警时间计数
    self._kEarlyWarningType = kType.kSkillEarlyWarning.kNone  -- 预警类型

end

-- 创建函数
function BattleMonsterSkillAttackState:create()
    local state = BattleMonsterSkillAttackState.new()
    return state
end

-- 进入函数
function BattleMonsterSkillAttackState:onEnter(args)    
    if self:getMaster() then
        -- 复位本次攻击缓存的技能链相关信息
        self._pTarget = nil
        self._pCurSkill = nil 
        self._nCurSkillIndexInChain = 0
        self._bToNextSkill = false
        self._fEarlyWarningTime = 0
        self._fEarlyWarningCount = 0
        self._kEarlyWarningType = kType.kSkillEarlyWarning.kNone
        
        -- 从确定好的技能链中第一个技能开始使用 
        self._nCurSkillIndexInChain = 0
        -- 预警时间标准
        self._fEarlyWarningTime = 0 
        -- 预警时间计数
        self._fEarlyWarningCount = 0
        -- 下一个技能可以使用
        self._bToNextSkill = true
        -- 检测遮挡
        self:getMaster():checkCover()

    end
    return
end

-- 退出函数
function BattleMonsterSkillAttackState:onExit()
    if self:getMaster() then
        -- 将当前当前的防御等级为默认自身的防御等级
        self:getMaster()._pCurDefLevel = TableTempleteMonster[self:getMaster()._pRoleInfo.TempleteID].DefenseLevel
    end
    -- 复位本次攻击缓存的技能链相关信息
    self._pTarget = nil
    self._pCurSkill = nil 
    self._nCurSkillIndexInChain = 0
    self._bToNextSkill = false
    self._fEarlyWarningTime = 0
    self._fEarlyWarningCount = 0
    self._kEarlyWarningType = kType.kSkillEarlyWarning.kNone

    return
end

-- 更新逻辑
function BattleMonsterSkillAttackState:update(dt)
    if self:getMaster() then
        if self._bToNextSkill == true and self:getMaster()._nCurHp > 0 then   -- 可使用下一个技能
            if self._fEarlyWarningTime == 0 then  -- 需要显示预警特效
                -- 从确定好的技能链中确定下一个准备使用的技能的index
                self._nCurSkillIndexInChain = self._nCurSkillIndexInChain + 1
                --cclog("野怪当前技能链中的第"..self._nCurSkillIndexInChain.."个，技能链中技能个数："..table.getn(self:getMaster()._tCurSkillChain))
                if self._nCurSkillIndexInChain <= table.getn(self:getMaster()._tCurSkillChain) then
                    -- 确定要使用的技能
                    self._pCurSkill = self:getMaster()._tReverseIDSkills[self:getMaster()._tCurSkillChain[self._nCurSkillIndexInChain] ]
                    -- 确定预警类型
                    self._kEarlyWarningType = self._pCurSkill._pSkillInfo.EarlyWarningType
                    -- 预警计数器
                    self._fEarlyWarningCount = 0
                    -- 播放预警特效(返回预警时间标准和预警对象)
                    self._fEarlyWarningTime, self._pTarget = self:getMaster():playSkillEarlyWarningEffect(self._pCurSkill, self._kEarlyWarningType)
                    -- 刷新动作(技能链中非首个技能时，需要切换到站立动作)
                    if self._nCurSkillIndexInChain >= 2 then
                        self:getMaster():playStandAction()
                    end
                    -- 刷新方向
                    if TableTempleteMonster[self:getMaster()._pRoleInfo.TempleteID].AppointedRotation == -1 then
                        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self._pCurSkill)
                    end
                else
                    -- 当前技能链中的技能已经全部释放完，人物状态机切入待机状态
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
                end
            else
                -- 计算时间
                self._fEarlyWarningCount = self._fEarlyWarningCount + dt
                if self._pTarget and self._pTarget._nCurHp <= 0 then  -- 目标已经死亡，则取消记录
                    self._pTarget = nil
                end
                if self._pTarget then
                    if self._kEarlyWarningType == kType.kSkillEarlyWarning.kType2 then  -- 准心特效位置和可见性的刷新
                        if (self:getMaster():getPositionX() - self._pTarget:getPositionX())*(self:getMaster():getPositionX() - self._pTarget:getPositionX()) + (self:getMaster():getPositionY() - self._pTarget:getPositionY())*(self:getMaster():getPositionY() - self._pTarget:getPositionY()) > self._pCurSkill._pSkillInfo.WarnRange*self._pCurSkill._pSkillInfo.WarnRange then
                            self:getMaster()._pEarlyWarningEffectAnis[self._kEarlyWarningType]:setVisible(false)
                        else
                            self:getMaster()._pEarlyWarningEffectAnis[self._kEarlyWarningType]:setVisible(true)
                            self:getMaster()._pEarlyWarningEffectAnis[self._kEarlyWarningType]:setPosition(cc.p(self._pTarget:getPositionX(), self._pTarget:getPositionY()+self._pTarget:getHeight()/2))
                        end
                    end
                end

                -- 预警特效播放完毕
                if self._fEarlyWarningCount >= self._fEarlyWarningTime then 
                    self:getMaster()._pEarlyWarningEffectAnis[self._kEarlyWarningType]:setVisible(false)
                    -- 刷新方向（考虑野怪是否有指定转向）
                    if self._kEarlyWarningType ~= kType.kSkillEarlyWarning.kType3 then  -- 只要不为大箭头方向的技能，野怪均可以自动刷新方向
                        if TableTempleteMonster[self:getMaster()._pRoleInfo.TempleteID].AppointedRotation == -1 then
                            self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self._pCurSkill)
                        end
                    end
                    self._pCurSkill:onUse()
                    -- 将当前技能的防御等级赋给当前的防御等级
                    self:getMaster()._pCurDefLevel = self._pCurSkill._pSkillInfo.DefenseLevel
                    -- 标记位复位
                    self._pTarget = nil
                    self._bToNextSkill = false
                    self._fEarlyWarningTime = 0
                    self._fEarlyWarningCount = 0
                    self._kEarlyWarningType = kType.kSkillEarlyWarning.kNone
                    self._pCurSkill = nil
                end

            end
        end

    end

    return
end

return BattleMonsterSkillAttackState
