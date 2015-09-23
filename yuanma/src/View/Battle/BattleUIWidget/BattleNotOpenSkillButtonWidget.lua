--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleNotOpenSkillButtonWidget.lua
-- author:    liyuhang
-- created:   2015/1/27
-- descrip:   未开启技能按钮
--===================================================
local BattleNotOpenSkillButtonWidget = class("BattleNotOpenSkillButtonWidget",function()
    return cc.Layer:create()
end)

-- 构造函数
function BattleNotOpenSkillButtonWidget:ctor()
    self._strName = "BattleNotOpenSkillButtonWidget"       -- 层名称

    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形
    
    self._pSkillBg = nil            -- 技能按钮 背景框
    self._pOpenLevellbl = nil              
  
    self._nTag = 1
end

-- 创建函数
function BattleNotOpenSkillButtonWidget:create()
    local layer = BattleNotOpenSkillButtonWidget.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleNotOpenSkillButtonWidget:dispose()
    --加载ui
    self._pSkillBtn = nil
    self._pSkillBtn = ccui.Button:create(
        "FightUIRes/skillicon01.png",
        "FightUIRes/skillicon02.png",
        "FightUIRes/skillicon01.png",
        ccui.TextureResType.plistType)
    self._pSkillBtn:setTouchEnabled(true)
    self._pSkillBtn:setPosition(-12,-13)
    self._pSkillBtn:setAnchorPoint(cc.p(0, 0))
    self:addChild(self._pSkillBtn)
    self._pSkillBtn:setVisible(true)

    self._pSkillBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            
        end
    end)
    
    self._pSkillBg = ccui.ImageView:create("FightUIRes/zdjm37.png",ccui.TextureResType.plistType)
    self._pSkillBg:setPosition(2,-0)
    self._pSkillBg:setScale(1.0)
    self._pSkillBg:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pSkillBg)

    self._pOpenLevellbl = ccui.Text:create()
    self._pOpenLevellbl:setFontName(strCommonFontName)
    self._pOpenLevellbl:setString("冷去中")
    self._pOpenLevellbl:setPosition(36,33)
    self._pOpenLevellbl:setFontSize(20)
    self._pOpenLevellbl:setColor(cRed)
    self:addChild(self._pOpenLevellbl)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBattleNotOpenSkillButtonWidget()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

function BattleNotOpenSkillButtonWidget:setTag(tag)
    --print("setTag is register " .. tag)
    self._nTag = tag
    local offsetActive = TableConstants.ActiveSkillNumber.Value + 1
    local level = SkillsManager:getMainRoleSkillDataByID(offsetActive*(RolesManager:getInstance()._pMainRoleInfo.roleCareer-1) + 2 + 3*(self._nTag-1),1).RequiredLevel
    self._pOpenLevellbl:setString(level .. "级开启")
end 

-- 退出函数
function BattleNotOpenSkillButtonWidget:onExitBattleNotOpenSkillButtonWidget()

end

return BattleNotOpenSkillButtonWidget
