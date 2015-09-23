--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TaskDialog.lua
-- author:    liyuhang
-- created:   2015/4/22
-- descrip:   任务系统面板
--===================================================

local TaskDialog = class("TaskDialog",function()
    return require("Dialog"):create()
end)

local TaskTabTypes = {
    TaskFlow = 1,
    TaskEveryday = 2,
    TaskFamilys = 3,
}

-- 构造函数
function TaskDialog:ctor()
    -- 层名字
    self._strName = "TaskDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self._pTabBtn = {}
    self._nTabType = 0
    
    self._tFamilyTasks = {}
    self._tDiaryTasks = {}
    self._tMainTasks = {}
    
    self._pListController = nil
    
    self.params = nil

    self._pCells = {}
    
    self._bInFamily = false
    
    self._pBoxOpenEffect = {}
    self._pBoxOpenEffectAct = {}
    self._pWarningSprite = {}
end

-- 创建函数
function TaskDialog:create(args)
    local layer = TaskDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function TaskDialog:dispose(args)
    if args[1] ~= nil then
        self._bInFamily = args[1]
    end
    
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "任务按钮" , value = false})

    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kGainTaskAwardResp, handler(self,self.handleMsgGainTaskAwardResp))
    NetRespManager:getInstance():addEventListener(kNetCmd.kGainVitalityAward, handler(self,self.handleMsgGainVitalityAward))
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryTasksResp, handler(self,self.handleMsgQueryTasksResp))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("MissionBg.plist")
    ResPlistManager:getInstance():addSpriteFrames("MissionOne.plist")
    ResPlistManager:getInstance():addSpriteFrames("BoxOpenEffect.plist")
    -- 开面板请求数据
    TaskCGMessage:sendMessageQueryTasks21700()

    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitTaskDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function TaskDialog:initUI()
    -- 加载组件
    local params = require("MissionParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    self.params._pScrollView:setInnerContainerSize(self.params._pScrollView:getContentSize())
    self.params._pScrollView:setTouchEnabled(true)
    self.params._pScrollView:setBounceEnabled(true)
    self.params._pScrollView:setClippingEnabled(true)
    
    self._pListController = require("ListController"):create(self,self.params._pScrollView,listLayoutType.LayoutType_vertiacl,0,170)
    self._pListController:setVertiaclDis(2)
    self._pListController:setHorizontalDis(3)

    self._pTabBtn[1] = params._pMissionButton1
    self._pTabBtn[2] = params._pMissionButton2

    

    self._pTabBtn[1]:loadTextures(
        self._nTabType == 1 and "MissionBgRes/rwjm4.png" or "MissionBgRes/rwjm3.png",
        "MissionBgRes/rwjm3.png",
        "MissionBgRes/rwjm3.png",
        ccui.TextureResType.plistType)

    self._pTabBtn[2]:loadTextures(
        self._nTabType == 2 and "MissionBgRes/rwjm6.png" or "MissionBgRes/rwjm5.png",
        "MissionBgRes/rwjm5.png",
        "MissionBgRes/rwjm5.png",
        ccui.TextureResType.plistType)

    local function tabButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()

            self:tabSelectAction(tag)
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pTabBtn[1]:setTag(1)
    self._pTabBtn[2]:setTag(2)

    self._pTabBtn[1]:addTouchEventListener(tabButton)
    self._pTabBtn[2]:addTouchEventListener(tabButton)
    
    for i=1 ,table.getn(self._pTabBtn) do
        self._pWarningSprite[i] = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
        self._pWarningSprite[i]:setPosition(15,55)
        self._pWarningSprite[i]:setScale(0.2)
        self._pWarningSprite[i]:setVisible(false)
        self._pWarningSprite[i]:setAnchorPoint(cc.p(0.5, 0.5))
        self._pTabBtn[i]:addChild(self._pWarningSprite[i])

        -- 上下移动动画效果
        local actionMoveBy = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
        local actionMoveToBack = cc.ScaleTo:create(0.5,0.6,0.6)
        local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
        self._pWarningSprite[i]:stopAllActions()
        self._pWarningSprite[i]:runAction(cc.RepeatForever:create(seq1))
    end
    
    self.params._pLoadingBar:setPercent(TasksManager:getInstance()._pVitalityInfo.vitality)
    for i=1,4 do
        self.params["_pAwardButton" .. i]:setTag(i)
    	self.params["_pAwardButton" .. i]:addTouchEventListener(
           function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local nTag = sender:getTag()
                    local bCanGet = (TableTaskVitality[nTag].Vitality <= TasksManager:getInstance()._pVitalityInfo.vitality)
                    DialogManager:getInstance():showDialog("BoxInfoDialog",{TableTaskVitality[nTag].VitalityBox, bCanGet , boxInfoShowType.kTaskAward , {nTag}})
                elseif eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")
                end
    	   end
    	)
        local bCanGet = (TableTaskVitality[i].Vitality <= TasksManager:getInstance()._pVitalityInfo.vitality)
        if TasksManager:getInstance()._pVitalityInfo.boxState[i] == true then
            self.params["_pAwardButton" .. i]:loadTextures(
                "MissionBgRes/rwjm19.png",
                "MissionBgRes/rwjm19.png",
                "MissionBgRes/rwjm19.png",
                ccui.TextureResType.plistType)
            self.params["_pAwardButton" .. i]:setTouchEnabled(false)
    	end
    	
        if bCanGet == true and TasksManager:getInstance()._pVitalityInfo.boxState[i] ~= true then
            self._pBoxOpenEffect[i] = cc.CSLoader:createNode("BoxOpenEffect.csb")
            self._pBoxOpenEffect[i]:setPosition(cc.p(self.params["_pAwardButton" .. i]:getContentSize().width/2-6 , self.params["_pAwardButton" .. i]:getContentSize().height/2))
            self.params["_pAwardButton" .. i]:addChild(self._pBoxOpenEffect[i],-2)
            local pBoxOpenEffectAct = cc.CSLoader:createTimeline("BoxOpenEffect.csb")
            pBoxOpenEffectAct:gotoFrameAndPlay(0,pBoxOpenEffectAct:getDuration(),true)
            pBoxOpenEffectAct:setTimeSpeed(0.3)
            self._pBoxOpenEffect[i]:runAction(pBoxOpenEffectAct)
        else
            self.params["_pAwardButton" .. i]:removeAllChildren()
    	end
    end

    self:disposeCSB()
    
    self:setTaskDatas()
    
    if self._bInFamily == true then
        self._nTabType = TaskTabTypes.TaskFamilys
        self._pTabBtn[1]:setVisible(false)
        self._pTabBtn[2]:setVisible(false)
        
        self.params._pLoadingBar:setVisible(false)
        for i=1,4 do
            self.params["_pAwardButton" .. i]:setVisible(false)
            self.params["_pAwardButton" .. i]:setVisible(false)
        end
        
        self:updateFamilyDatas()
    else
        
        self:tabSelectAction(2)
    
        self:updateEverydayDatas()
    end
end

function TaskDialog:tabSelectAction(type)
    if self._nTabType == type then
        return
    end

    self._nTabType = type
    local action = {
        [TaskTabTypes.TaskFlow] = function()
            self:updateFlowDatas()
        end,
        [TaskTabTypes.TaskEveryday] = function()
            self:updateEverydayDatas()
        end,
    }

    self._pTabBtn[1]:loadTextures(
        self._nTabType == 1 and "MissionBgRes/rwjm4.png" or "MissionBgRes/rwjm3.png",
        "MissionBgRes/rwjm3.png",
        "MissionBgRes/rwjm3.png",
        ccui.TextureResType.plistType)

    self._pTabBtn[2]:loadTextures(
        self._nTabType == 2 and "MissionBgRes/rwjm6.png" or "MissionBgRes/rwjm5.png",
        "MissionBgRes/rwjm5.png",
        "MissionBgRes/rwjm5.png",
        ccui.TextureResType.plistType)

    action[type]()
end

function TaskDialog:setTaskDatas()
    local tasks = TasksManager:getInstance()._pTaskSortInfos
    
    self._tDiaryTasks = {}
    self._tMainTasks = {}
    self._tFamilyTasks = {}
    
    for i=1,table.getn(tasks) do
        local taskInfo = tasks[i]
        local index,mov = math.modf(taskInfo.taskId/10000)
        
        if index == kTaskType.kDaily or index == kTaskType.kBounty then
            table.insert(self._tDiaryTasks , taskInfo)
        elseif index == kTaskType.kFamily then 
            table.insert(self._tFamilyTasks , taskInfo)
        else
            table.insert(self._tMainTasks , taskInfo)
        end
    end
    
    self._pWarningSprite[1]:setVisible(false)
    self._pWarningSprite[2]:setVisible(false)
    
    for i=1, table.getn(self._tMainTasks) do
        if self._tMainTasks[i].state == 2 then
            self._pWarningSprite[2]:setVisible(true)
    	end
    end
    
    for i=1, table.getn(self._tDiaryTasks) do
        if self._tDiaryTasks[i].state == 2 then
            self._pWarningSprite[1]:setVisible(true)
        end
    end
end

function TaskDialog:updateFamilyDatas()
    local rowCount = table.getn(self._tFamilyTasks)

    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local info = TasksManager:getInstance():getTaskInfoWithTaskInfo(self._tFamilyTasks[index])

        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("TaskCell"):create(info)
        else
            cell:setInfo(info)
        end
        cell:setDelegate(delegate)

        return cell
    end

    self._pListController._pNumOfCellDelegateFunc = function ()
        return table.getn(self._tFamilyTasks)
    end

    self._pListController:setDataSource(self._tDiaryTasks)
end

function TaskDialog:updateFlowDatas()
    local rowCount = table.getn(self._tDiaryTasks)
    
    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local info = TasksManager:getInstance():getTaskInfoWithTaskInfo(self._tDiaryTasks[index])

        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("TaskCell"):create(info)
        else
            cell:setInfo(info)
        end
        cell:setDelegate(delegate)

        return cell
    end
    
    self._pListController._pNumOfCellDelegateFunc = function ()
        return table.getn(self._tDiaryTasks)
    end

    self._pListController:setDataSource(self._tDiaryTasks)
end

function TaskDialog:updateEverydayDatas()
    local rowCount = table.getn(self._tMainTasks)
    
    
    
    self._pListController._pDataSourceDelegateFunc = function (delegate, controller, index)
        local info = TasksManager:getInstance():getTaskInfoWithTaskInfo(self._tMainTasks[index])
        
        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("TaskCell"):create(info)
        else
            cell:setInfo(info)
        end
        cell:setDelegate(delegate)
        
        return cell
    end
    
    self._pListController._pNumOfCellDelegateFunc = function ()
        return table.getn(self._tMainTasks)
    end
    
    self._pListController:setDataSource(self._tMainTasks)
end


-- 初始化触摸相关
function TaskDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

-- 退出函数
function TaskDialog:onExitTaskDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("MissionBg.plist")
    ResPlistManager:getInstance():removeSpriteFrames("MissionOne.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BoxOpenEffect.plist")
end

-- 领取活跃度奖励
function TaskDialog:handleMsgGainVitalityAward(event)
    self.params._pLoadingBar:setPercent(TasksManager:getInstance()._pVitalityInfo.vitality)
    
    for i=1,4 do
        if TasksManager:getInstance()._pVitalityInfo.boxState[i] == true then
            self.params["_pAwardButton" .. i]:loadTextures(
                "MissionBgRes/rwjm19.png",
                "MissionBgRes/rwjm19.png",
                "MissionBgRes/rwjm19.png",
                ccui.TextureResType.plistType)
            self.params["_pAwardButton" .. i]:setTouchEnabled(false)
        end
        
        local bCanGet = (TableTaskVitality[i].Vitality <= TasksManager:getInstance()._pVitalityInfo.vitality)

        if bCanGet == true and TasksManager:getInstance()._pVitalityInfo.boxState[i] ~= true  then
            self._pBoxOpenEffect[i] = cc.CSLoader:createNode("BoxOpenEffect.csb")
            self._pBoxOpenEffect[i]:setPosition(cc.p(self.params["_pAwardButton" .. i]:getContentSize().width/2-6 , self.params["_pAwardButton" .. i]:getContentSize().height/2))
            self.params["_pAwardButton" .. i]:addChild(self._pBoxOpenEffect[i],-2)
            local pBoxOpenEffectAct = cc.CSLoader:createTimeline("BoxOpenEffect.csb")
            pBoxOpenEffectAct:gotoFrameAndPlay(0,pBoxOpenEffectAct:getDuration(),true)
            pBoxOpenEffectAct:setTimeSpeed(0.3)
            self._pBoxOpenEffect[i]:runAction(pBoxOpenEffectAct)
        else
            self.params["_pAwardButton" .. i]:removeAllChildren()
        end
    end
end

-- 领取任务奖励
function TaskDialog:handleMsgGainTaskAwardResp(event)
    self:setTaskDatas()
    local action = {
        [TaskTabTypes.TaskFlow] = function()
            self:updateFlowDatas()
        end,
        [TaskTabTypes.TaskEveryday] = function()
            self:updateEverydayDatas()
        end,
    }

    action[self._nTabType]()
    
    self.params._pLoadingBar:setPercent(TasksManager:getInstance()._pVitalityInfo.vitality)

    for i=1,4 do
        if TasksManager:getInstance()._pVitalityInfo.boxState[i] == true then
            self.params["_pAwardButton" .. i]:loadTextures(
                "MissionBgRes/rwjm19.png",
                "MissionBgRes/rwjm19.png",
                "MissionBgRes/rwjm19.png",
                ccui.TextureResType.plistType)
            self.params["_pAwardButton" .. i]:setTouchEnabled(false)
        end
        
        local bCanGet = (TableTaskVitality[i].Vitality <= TasksManager:getInstance()._pVitalityInfo.vitality)

        if bCanGet == true and TasksManager:getInstance()._pVitalityInfo.boxState[i] ~= true  then
            self._pBoxOpenEffect[i] = cc.CSLoader:createNode("BoxOpenEffect.csb")
            self._pBoxOpenEffect[i]:setPosition(cc.p(self.params["_pAwardButton" .. i]:getContentSize().width/2-6 , self.params["_pAwardButton" .. i]:getContentSize().height/2))
            self.params["_pAwardButton" .. i]:addChild(self._pBoxOpenEffect[i],-2)
            local pBoxOpenEffectAct = cc.CSLoader:createTimeline("BoxOpenEffect.csb")
            pBoxOpenEffectAct:gotoFrameAndPlay(0,pBoxOpenEffectAct:getDuration(),true)
            pBoxOpenEffectAct:setTimeSpeed(0.3)
            self._pBoxOpenEffect[i]:runAction(pBoxOpenEffectAct)
        else
            self.params["_pAwardButton" .. i]:removeAllChildren()
        end
    end
end

-- 更新任务列表
function TaskDialog:handleMsgQueryTasksResp(event)
    self:setTaskDatas()
    
    local action = {
        [TaskTabTypes.TaskFlow] = function()
            self:updateFlowDatas()
        end,
        [TaskTabTypes.TaskEveryday] = function()
            self:updateEverydayDatas()
        end,
        [TaskTabTypes.TaskFamilys] = function()
            self:updateFamilyDatas()
        end,
    }
    
    action[self._nTabType]()
end

return TaskDialog