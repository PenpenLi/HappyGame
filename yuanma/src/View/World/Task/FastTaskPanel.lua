--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FastTaskPanel.lua
-- author:    liyuhang
-- created:   2015/10/29
-- descrip:   主UI 任务列表
--===================================================
local FastTaskPanel = class("FastTaskPanel",function()
	return cc.Layer:create()
end)

local STATE_ABLE = 1
local STATE_DISABLE = 2

-- 构造函数
function FastTaskPanel:ctor()
	self._strName = "FastTaskPanel" 
    self._pTouchListener = nil
	
	self._kState = STATE_ABLE
	
    self._pMainTaskParams = nil
    self._pCurGuideTask = nil
end

-- 创建函数
function FastTaskPanel:create()
	local menu = FastTaskPanel.new()
    menu:dispose()
	return menu
end

function FastTaskPanel:dispose()
    -- 添加监听器
    --self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    --self._pTouchListener:setSwallowTouches(true)
    --self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    --self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    --self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    -- self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryTasksResp ,handler(self, self.handleMainTaskchange))
    
    self._pMainTaskParams = require("FastMissionTipsParams"):create() 
    self._pMainTaskParams._pCCS:setPosition(mmo.VisibleRect:right().x - 300,mmo.VisibleRect:left().y+70)
    self:addChild(self._pMainTaskParams._pCCS)

    self._pMainTaskParams._pBg2:setVisible(false)
    self._pMainTaskParams._pBg2:addTouchEventListener(function (sender,eventType) 
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        elseif eventType == ccui.TouchEventType.ended then
            if self._pCurGuideTask == nil then
                NewbieManager:getInstance():showNewbieByID(self._pCurGuideTask.GuideId)
                self._pMainTaskParams._pBg2:setVisible(false)
            end
        end
    end)

    self._pMainTaskParams._pTips:addTouchEventListener(function (sender,eventType) 
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        elseif eventType == ccui.TouchEventType.ended then
            DialogManager:getInstance():showDialog("TaskDialog",{false})
        end
    end)

    self._pMainTaskParams._pButton:addTouchEventListener(function (sender,eventType) 
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        elseif eventType == ccui.TouchEventType.ended then
            self:changeState()
        end
    end)

    self._pMainTaskParams._pButton:loadTextures(
                    "FastMissionTipsRes/zjm20.png",
                    "FastMissionTipsRes/zjm20.png",
                    "FastMissionTipsRes/zjm20.png",
                    ccui.TextureResType.plistType)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFastTaskPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 处理主线任务改变
function FastTaskPanel:handleMainTaskchange(event)
    self._pMainTaskParams._pCCS:setVisible(true)
    self._pMainTaskParams._pNodeAll:setVisible(true)
    self:updateMainTask()
end

function FastTaskPanel:updateMainTask()
    local info = TasksManager:getInstance():getTaskInfoWithTaskInfo(TasksManager:getInstance()._pMainTaskInfo)
    if TasksManager:getInstance()._pMainTaskInfo.state == 1 then
        self._pMainTaskParams._pname02:setString(info.data.Title)
        self._pMainTaskParams._pBg1:addTouchEventListener(function( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                if TasksManager:getInstance()._pMainTaskInfo == nil then
                    TaskCGMessage:sendMessageQueryTasks21700()
                    return
                end
            
                NewbieManager:showOutAndRemoveWithRunTime()
                
                self._pMainTaskParams._pButton:runAction(cc.Sequence:create(
                    cc.DelayTime:create(1.0),
                    cc.CallFunc:create(function() 
                        if TasksManager:getInstance():getAllOperateBeOver() == true then
                            TasksManager:getInstance():startOperateByTaskId(TasksManager:getInstance()._pMainTaskInfo.taskId)
                        end
                    end)
                ))
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("FunctionButton")
            end
        end)
    elseif TasksManager:getInstance()._pMainTaskInfo.state == 2 then
        self._pMainTaskParams._pname02:setString(info.data.Title .. "(已完成)")
        self._pMainTaskParams._pBg1:addTouchEventListener(function( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                if TasksManager:getInstance()._pMainTaskInfo == nil then
                    TaskCGMessage:sendMessageQueryTasks21700()
                    return
                end
            
                TaskCGMessage:sendMessageGainTaskAward21702(TasksManager:getInstance()._pMainTaskInfo.taskId)
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("FunctionButton")
            end
        end)
    end

    self._pMainTaskParams._ptext02:setString(info.data.Target)

    for i=1,4 do
        if table.getn(info.data.Reward) >= i then
            self._pMainTaskParams["_picon0"..i]:setVisible(true)
            local RewardInfo = info.data.Reward[i]
            if RewardInfo[1] <= 99 then
                local FinanceIcon = FinanceManager:getInstance():getIconByFinanceType(RewardInfo[1])
                self._pMainTaskParams["_picon0"..i]:loadTexture(
                    FinanceIcon.filename,
                    ccui.TextureResType.plistType)
                self._pMainTaskParams["_picontext0"..i]:setString(RewardInfo[2])
            else
                local pItemInfo = {id = RewardInfo[1], baseType = RewardInfo[3], value = RewardInfo[2]}
                pItemInfo = GetCompleteItemInfo(pItemInfo)

                self._pMainTaskParams["_picon0"..i]:loadTexture(
                    pItemInfo.templeteInfo.Icon ..".png",
                    ccui.TextureResType.plistType)
                self._pMainTaskParams["_picontext0"..i]:setString(RewardInfo[2])
            end
        else
            self._pMainTaskParams["_picon0"..i]:setVisible(false)
            self._pMainTaskParams["_picontext0"..i]:setVisible(false)
        end
    end
end

function FastTaskPanel:setStateAble( )
	self._kState = STATE_ABLE
end

function FastTaskPanel:setStateDisable( )
	self._kState = STATE_DISABLE
end

function FastTaskPanel:setTouchAble(visible)
	self._bTouchAble = visible
end

function FastTaskPanel:getState( )
	return self._kState
end

function FastTaskPanel:changeState(  )
    if self._kState == STATE_ABLE then
        self._kState = STATE_DISABLE
        self._pMainTaskParams._pButton:loadTextures(
                    "FastMissionTipsRes/zjm21.png",
                    "FastMissionTipsRes/zjm21.png",
                    "FastMissionTipsRes/zjm21.png",
                    ccui.TextureResType.plistType)
        self._pMainTaskParams._pCCS:runAction(
            cc.MoveTo:create(0.1,cc.p(mmo.VisibleRect:right().x -25,mmo.VisibleRect:left().y+70))
        )
    else
        self._kState = STATE_ABLE
        self._pMainTaskParams._pButton:loadTextures(
                    "FastMissionTipsRes/zjm20.png",
                    "FastMissionTipsRes/zjm20.png",
                    "FastMissionTipsRes/zjm20.png",
                    ccui.TextureResType.plistType)
        self._pMainTaskParams._pCCS:runAction(
            cc.MoveTo:create(0.1,cc.p(mmo.VisibleRect:right().x -300,mmo.VisibleRect:left().y+70))
        )
    end
end

function FastTaskPanel:setCurGuide( guide )
    -- body
    self._pCurGuideTask = guide

    if self._pCurGuideTask ~= nil then
        self._pMainTaskParams._pBg2:setVisible(true)

        self._pMainTaskParams._pYdname01:setString(self._pCurGuideTask.FunctionName)
    end
end

-- 退出函数
function FastTaskPanel:onExitFastTaskPanel()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FastTaskPanel
