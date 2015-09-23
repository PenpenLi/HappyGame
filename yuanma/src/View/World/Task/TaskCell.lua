--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TaskCell.lua
-- author:    liyuhang
-- created:   2015/04/23
-- descrip:   任务cell
--===================================================
local TaskCell = class("TaskCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function TaskCell:ctor()
    -- 层名称
    self._strName = "TaskCell"        

    -- 地图背景
    self._pParams = nil
    self._pBg = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

    self._pDataInfo = nil
   
    self._pTaskDialogDelegate = nil
end

-- 创建函数
function TaskCell:create(dataInfo)
    local dialog = TaskCell.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function TaskCell:dispose(dataInfo)
    --注册（请求游戏副本列表）
    --NetRespManager:getInstance():addEventListener(kNetCmd.kQueryBattleList, handler(self, self.updateQueryBattleList))

    self._pDataInfo = dataInfo

    self:initUI()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,pLocal) == false then

        end

        return false
    end
    local function onTouchMoved(touch,event)
        local location = self._pBg:convertTouchToNodeSpace(touch)

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)

    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitTaskCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function TaskCell:initUI()
    --图标按钮
    local  onGainAwardButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            TaskCGMessage:sendMessageGainTaskAward21702(self._pDataInfo.data.TaskID)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    --图标按钮
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local operate = TableOperateQueues[self._pDataInfo.data.OperateQueues] 
            for i=1,table.getn(operate.Queue) do
                if operate.Queue[i].id == 3 and operate.Queue[i].args.copyType == 10 and operate.Queue[i].args.params[2] ~= nil then
                    local temp = TasksManager:getInstance():getCopyHasOpenByBattleId(operate.Queue[i].args.params[2])
                    if temp == false then
                    	NoticeManager:showSystemMessage("关卡未开启")
                    	return
                    end
            	end
            end
        
            TasksManager:getInstance():startOperateByTaskId(self._pDataInfo.data.TaskID)
            self._pTaskDialogDelegate:close()
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    -- 加载csb 组件
    local params = require("MissionOneParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pOneBg

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)
    
    self._pParams["_pGoButton02"]:addTouchEventListener(onTouchBg)
    self._pParams["_pGoButton01"]:addTouchEventListener(onGainAwardButton)

    self:updateData()
end

function TaskCell:setDelegate(delegate)
	self._pTaskDialogDelegate = delegate
end

function TaskCell:updateData()
    if self._pDataInfo == nil then
        return
    end

    self._pParams["_pLoadingBar"]:setPercent(self._pDataInfo.progress/100 * 100)
    self._pParams["_pname"]:setString(self._pDataInfo.data.Title)
    self._pParams["_ptarget2"]:setString(self._pDataInfo.data.Target)
    self._pParams["_ptarget3"]:setVisible(false)
    
    local index,mov = math.modf(self._pDataInfo.data.TaskID/10000)

    if index == kTaskType.kBounty then
        self._pParams["_picon"]:loadTexture(
            "MissionOneRes/rwjm10.png",
            ccui.TextureResType.plistType)
    elseif index == kTaskType.kMain then
        self._pParams["_picon"]:loadTexture(
            "MissionOneRes/rwjm7.png",
            ccui.TextureResType.plistType)
    elseif index == kTaskType.kSub then
        self._pParams["_picon"]:loadTexture(
            "MissionOneRes/rwjm8.png",
            ccui.TextureResType.plistType)
    elseif index == kTaskType.kDaily then
        self._pParams["_picon"]:loadTexture(
            "MissionOneRes/rwjm9.png",
            ccui.TextureResType.plistType)
    end
    
    local expShow = false
    local vitalityShow = false
 
    for i=1,6 do
        self._pParams["_pawardicon0"..i]:setVisible(true)
        self._pParams["_pawardtext0"..i]:setVisible(true)
        if table.getn(self._pDataInfo.data.Reward) >= i then
            self._pParams["_pawardicon0"..i]:setVisible(true)
            local RewardInfo = self._pDataInfo.data.Reward[i]
            if RewardInfo[1] <= 99 then
                local FinanceIcon = FinanceManager:getInstance():getIconByFinanceType(RewardInfo[1])
                self._pParams["_pawardicon0"..i]:loadTexture(
                    FinanceIcon.filename,
                    ccui.TextureResType.plistType)
                self._pParams["_pawardtext0"..i]:setString(RewardInfo[2])
            else
                local pItemInfo = {id = RewardInfo[1], baseType = RewardInfo[3], value = RewardInfo[2]}
                pItemInfo = GetCompleteItemInfo(pItemInfo)

                self._pParams["_pawardicon0"..i]:loadTexture(
                    pItemInfo.templeteInfo.Icon ..".png",
                    ccui.TextureResType.plistType)
                self._pParams["_pawardtext0"..i]:setString(RewardInfo[2])
            end
        else
            if expShow == false then
                expShow = true
                if self._pDataInfo.data.Exp == 0 then
                    if vitalityShow == false then
                        vitalityShow = true
                        if self._pDataInfo.data.Vitality == 0 then
                            self._pParams["_pawardicon0"..i]:setVisible(false)
                            self._pParams["_pawardtext0"..i]:setVisible(false)
                        else
                            self._pParams["_pawardicon0"..i]:loadTexture(
                                "ccsComRes/icon_000.png",
                                ccui.TextureResType.plistType)
                            self._pParams["_pawardtext0"..i]:setString(self._pDataInfo.data.Vitality)
                        end
                    end
                else
                    self._pParams["_pawardicon0"..i]:loadTexture(
                        "ccsComRes/icon_000.png",
                        ccui.TextureResType.plistType)
                    self._pParams["_pawardtext0"..i]:setString(self._pDataInfo.data.Exp)
                end
            else 
                if vitalityShow == false then
                	vitalityShow = true
                    if self._pDataInfo.data.Vitality == 0 then
                        self._pParams["_pawardicon0"..i]:setVisible(false)
                        self._pParams["_pawardtext0"..i]:setVisible(false)
                    else
                        self._pParams["_pawardicon0"..i]:loadTexture(
                            "icon_0006.png",
                            ccui.TextureResType.plistType)
                        self._pParams["_pawardtext0"..i]:setString(self._pDataInfo.data.Vitality)
                    end
                else
                    self._pParams["_pawardicon0"..i]:setVisible(false)
                    self._pParams["_pawardtext0"..i]:setVisible(false)
                end
            end
        end
    end
    
    if self._pDataInfo.state == kTaskState.kFinish then
    	self._pParams["_pGoButton01"]:setVisible(true)
        self._pParams["_pGoButton02"]:setVisible(false)
        self._pParams["_pfinish"]:setVisible(true)
    elseif self._pDataInfo.state == kTaskState.kRunning then
        self._pParams["_pGoButton01"]:setVisible(false)
        self._pParams["_pGoButton02"]:setVisible(true)
        self._pParams["_pfinish"]:setVisible(false)
    end
end

function TaskCell:setInfo(info)
    self._pDataInfo = info

    self:updateData()
end

-- 退出函数
function TaskCell:onExitTaskCell()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return TaskCell
