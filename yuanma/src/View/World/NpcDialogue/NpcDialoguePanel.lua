--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NpcDialoguePanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/11
-- descrip:   npc对话
--===================================================
local NpcDialoguePanel = class("NpcDialoguePanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function NpcDialoguePanel:ctor()
    self._strName = "NpcDialoguePanel"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._tArgs = nil
    self._pNpcId = nil

end

-- 创建函数
function NpcDialoguePanel:create()
    local dialog = NpcDialoguePanel.new()
    dialog:dispose()
    return dialog
end

-- 处理函数
function NpcDialoguePanel:dispose()
    ResPlistManager:getInstance():addSpriteFrames("NpcDialogue.plist")
    --初始化界面
    self:initUi()
--[[
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
        end
        return true   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end ".."x="..location.x.."  y="..location.y)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    ]]

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitNpcDialoguePanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end


function NpcDialoguePanel:initUi()

    local params = require("NpcDialogueParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pDialogueBg
    --角色挂点
    self._pRoleMountNode = params._pRoleNode
    --Npc名称
    self._pNpcNameText = params._pNpcNameText
    --Npc对话
    self._pDialogTalkText = params._pDialogueText
    --功能按钮
    self._pFunctionButton = params._pFunctionButton
    -- 初始化dialog的基础组件
    self:addChild(self._pCCS)

end

function NpcDialoguePanel:refreshUI(args)
    self._tArgs = args
    self._pNpcId = args[1]
    -- 避免模型穿透
    RolesManager:getInstance():setForceMinPositionZ(true,-10000)
    PetsManager:getInstance():setForceMinPositionZ(true,-10000)
    self._pRoleMountNode:removeAllChildren(true)

    self._tTempleteInfo = TableTempleteNpcRoles[self._pNpcId]
    self._pNpcNameText:setString(self._tTempleteInfo.Name)
    self._pDialogTalkText:setString("你说了个p啊")

    ----------------加载人物模型--------------------------
   local fullAniName = self._tTempleteInfo.AniResName..".c3b"
   local fullTextureName = self._tTempleteInfo.Texture..".pvr.ccz"
    -- 记录并加载到纹理缓存中
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(self._tTempleteInfo.Texture)
    self._pAni = cc.Sprite3D:create(fullAniName)
    self._pAni:setTexture(fullTextureName)
    self._pRoleMountNode:addChild(self._pAni)
    self._pAni:setScale( self._tTempleteInfo.Scale)
    self:playCasualAction()

     self:setVisible(true)

end


-- 播放站立动作
function NpcDialoguePanel:playStandAction()
    -- 站立动作
    if self._tTempleteInfo.StandActFrameRegion ~= nil then
        local fullAniName = self._tTempleteInfo.AniResName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.StandActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.StandActFrameRegion[2]
        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        temp:setSpeed(self._tTempleteInfo.StandActFrameRegion[3])
        local stand = cc.RepeatForever:create(temp)
        self._pAni:stopActionByTag(nRoleActAction)
        stand:setTag(nRoleActAction)
        self._pAni:runAction(stand)
    end
end

-- 播放休闲动作
function NpcDialoguePanel:playCasualAction()
    -- 休闲动作
    if self._tTempleteInfo.CasualActFrameRegion ~= nil then
        local fullAniName = self._tTempleteInfo.AniResName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.CasualActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.CasualActFrameRegion[2]
        local casual = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        casual:setSpeed(self._tTempleteInfo.CasualActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        casual:setTag(nRoleActAction)
        self._pAni:runAction(casual)
        
        local casualOver = function()
            self:playStandAction()
        end
        local duration = casual:getDuration()
        local speed = casual:getSpeed()
        --local time = duration + (1.0 - speed)*duration
        local time = duration * (1/speed)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(casualOver)))
        
    end
    
end


function NpcDialoguePanel:setNpcDiaogueClose()
    self:setVisible(false)
    RolesManager:getInstance():setForceMinPositionZ(false)
    PetsManager:getInstance():setForceMinPositionZ(false)
end

-- 退出函数
function NpcDialoguePanel:onExitNpcDialoguePanel()
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("NpcDialogue.plist")
    -- 避免模型穿透
    RolesManager:getInstance():setForceMinPositionZ(false)
    PetsManager:getInstance():setForceMinPositionZ(false)
end

-- 循环更新
function NpcDialoguePanel:update(dt)
    return
end

-- 显示结束时的回调
function NpcDialoguePanel:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function NpcDialoguePanel:doWhenCloseOver()
    return
end

return NpcDialoguePanel
