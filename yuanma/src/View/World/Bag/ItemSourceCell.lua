--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ItemSourceCell.lua
-- author:    liyuhang
-- created:   2015/7/27
-- descrip:   物品获得物品的单元
--===================================================
local ItemSourceCell = class("ItemSourceCell",function()
    return ccui.ImageView:create()
end)



-- 构造函数
function ItemSourceCell:ctor()
    self._strName = "ItemSourceCell"        -- 层名称
    self._pBg = nil                --背景
    
    self._nOperateQueueId = 0      
    self._tQueue = nil     
    
    self._bBeWaitNet = false
    
    self._pDelegate = nil
end 

-- 创建函数
function ItemSourceCell:create(data)
    local layer = ItemSourceCell.new()
    layer:dispose(data)
    return layer
end

-- 处理函数
function ItemSourceCell:dispose(operateQueueId) 
    NetRespManager:getInstance():addEventListener(kNetCmd.kItemSourceGo,handler(self, self.handleItemSourceGo))
    -- 加载资源
    --ResPlistManager:getInstance():addSpriteFrames("BagPanel.plist")
    --ResPlistManager:getInstance():addSpriteFrames("BagIconEffect.plist")
    
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            for i=1,table.getn(self._tQueue) do
                if self._tQueue[i].id == 3 then
                    if self._tQueue[i].args.params[2] ~= nil then
                        self._bBeWaitNet = true
                        MessageGameInstance:sendMessageQueryBattleInfo21018(self._tQueue[i].args.params[2])
                    else
                        PurposeManager:startOperateByTaskId(self._nOperateQueueId)
                    end
                elseif self._tQueue[i].id == 4 then
                    PurposeManager:startOperateByTaskId(self._nOperateQueueId)
                end
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    -- 加载csb 组件
    local params = require("LinkToObtainParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    
    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)
    
    self._pGoBtn = params._pButton
    self._pGoBtn:addTouchEventListener(onTouchButton)
    self._pGoBtn:setVisible(true)

    self._pNameLbllbl = params._pText1
    self._pNameLbllbl:setString("剧情副本")
    
    self:setQueueId(operateQueueId)

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()    

        return false   --可以向下传递事件
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
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)

        if event == "exit" then
            self:onExitItemSourceCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end


-- 退出函数
function ItemSourceCell:onExitItemSourceCell()
    --self:onExitLayer()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    --ResPlistManager:getInstance():removeSpriteFrames("BagPanel.plist")
    --ResPlistManager:getInstance():removeSpriteFrames("BagIconEffect.plist")
end

-- 循环更新
function ItemSourceCell:update(dt)
    

    return
end

function ItemSourceCell:handleItemSourceGo(event)
    if self._bBeWaitNet == false then
    	return
    end
    
    self._bBeWaitNet = false
    if event.battleInfo.battleId == 0 then
        NoticeManager:showSystemMessage("副本未开启")
    elseif event.battleInfo.extCount == 0 and event.battleInfo.currentCount == 0 then
        NoticeManager:showSystemMessage("副本次数用完")
    else
        PurposeManager:startOperateByTaskId(self._nOperateQueueId)
	end
end

function ItemSourceCell:setDelegate(delegate)
    self._pDelegate = delegate
    
    if self._pDelegate._kSrcType == kCalloutSrcType.KCalloutSrcTypeUnKnow then
    	self._pGoBtn:setVisible(false)
    end
end

function ItemSourceCell:setQueueId(queueId)
    self._nOperateQueueId = queueId
    self._tQueue = TableOperateQueues[self._nOperateQueueId].Queue

    PurposeManager:createPurpose(self._nOperateQueueId)
    
    for i=1,table.getn(self._tQueue) do
        if self._tQueue[i].id == 3 then
            if self._tQueue[i].args.copyType == 10 and self._tQueue[i].args.params[2] ~= -1 then
                local storyInfo = TableStoryCopys[self._tQueue[i].args.params[2]-10000]
                self._pNameLbllbl:setString(storyInfo.Name)
            elseif self._tQueue[i].args.copyType == 10 and self._tQueue[i].args.params[2] == -1 then
                local storyInfo = TableStoryCopys[self._tQueue[i].args.params[2]-10000]
                self._pNameLbllbl:setString(kType.kCopyDesc[tostring(self._tQueue[i].args.copyType)] .. "第" .. storyInfo.Chapter .. "章" )
            else
                self._pNameLbllbl:setString(kType.kCopyDesc[tostring(self._tQueue[i].args.copyType)])
            end
        elseif self._tQueue[i].id == 4 then
            self._pNameLbllbl:setString( kCopyDesc[tostring(self._tQueue[i].args.sysType)])
        end
    end
end

return ItemSourceCell
