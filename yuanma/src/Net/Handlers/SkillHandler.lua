--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SkillHandler.lua
-- author:    liyuhang
-- created:   2015/3/12
-- descrip:   技能相关handler
--===================================================
local SkillHandler = class("SkillHandler")

-- 构造函数
function SkillHandler:ctor()     
    -- 获取技能列表列表
    NetHandlersManager:registHandler(21401, self.handleMsgQuerySkillList)
    -- 请求升级技能
    NetHandlersManager:registHandler(21403, self.handleMsgUpgradeSkill)
    -- 出战技能
    NetHandlersManager:registHandler(21405, self.handleMsgMountSkill)
end

-- 创建函数
function SkillHandler:create()
    print("SkillHandler create")
    local handler = SkillHandler.new()
    return handler
end

-- 获取技能列表列表
function SkillHandler:handleMsgQuerySkillList(msg)
    print("SkillHandler 21401")
    if msg.header.result == 0 then 
        SkillsManager:getInstance()._bGetInitData = true
    
        SkillsManager:getInstance()._tMainRoleMountSkills = msg.body.mountSkills
        SkillsManager:getInstance()._tMainRoleSkillsLevels.actvSkills = msg.body.actvSkills -- 主动技能等级
        SkillsManager:getInstance()._tMainRoleSkillsLevels.pasvSkills = msg.body.pasvSkills -- 被动技能等级
        SkillsManager:getInstance()._tMainRoleSkillsLevels.consSkills = msg.body.consSkills -- 天赋技能等级
        
        local mountActSkills = {}
        local mountAngerSkills = {}
        for i=1,table.getn(msg.body.mountSkills) do
            local skillInfo = SkillsManager:getInstance():getMainRoleSkillDataByID(msg.body.mountSkills[i].id,msg.body.mountSkills[i].level)
            if skillInfo.SkillType == 5 then
                table.insert(mountAngerSkills,msg.body.mountSkills[i])
            else
                table.insert(mountActSkills,msg.body.mountSkills[i])
        	end
        end
        
        SkillsManager:getInstance()._tMainRoleMountActvSkills = mountActSkills
        SkillsManager:getInstance()._tMainRoleMountAngerSkills = mountAngerSkills 
        
        SkillsManager:getInstance():updateMountPasvSkills()
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateSkill, {})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 请求升级技能
function SkillHandler:handleMsgUpgradeSkill(msg)
    print("SkillHandler 21403")
    if msg.header.result == 0 then 
        local changeSkill = msg.body.skillInfo
        
        if table.getn(msg.body.roleAttr) > 0 then
            local fightPowerChange = msg.body.roleAttr[1].fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
            if fightPowerChange ~= 0 then
                NoticeManager:getInstance():showFightStrengthChange(fightPowerChange)
            end
        
            RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg.body.roleAttr[1]
            RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        end
        
        SkillsManager:getInstance():setMainRoleSkillLevelByID(changeSkill.id,changeSkill.level)
        SkillsManager:getInstance():updateMountPasvSkills()
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpgradeSkill, {data = changeSkill})
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

-- 出战技能
function SkillHandler:handleMsgMountSkill(msg)
    print("SkillHandler 21405")
    if msg.header.result == 0 then 
        SkillsManager:getInstance()._tMainRoleMountSkills = msg.body.roleSkills
        local fightPowerChange = msg.body.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower = msg.body.fightingPower
        NoticeManager:getInstance():showFightStrengthChange(fightPowerChange)
        RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        
        local mountActSkills = {}
        local mountAngerSkills = {}
        for i=1,table.getn(msg.body.roleSkills) do
            local skillInfo = SkillsManager:getInstance():getMainRoleSkillDataByID(msg.body.roleSkills[i].id,msg.body.roleSkills[i].level)
            if skillInfo.SkillType == 5 then
                table.insert(mountAngerSkills,msg.body.roleSkills[i])
            else
                table.insert(mountActSkills,msg.body.roleSkills[i])
            end
        end

        SkillsManager:getInstance()._tMainRoleMountActvSkills = mountActSkills
        SkillsManager:getInstance()._tMainRoleMountAngerSkills = mountAngerSkills 
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kMountSkill, {})
    else
        print("返回错误码："..msg.header.result)
    end
end

return SkillHandler