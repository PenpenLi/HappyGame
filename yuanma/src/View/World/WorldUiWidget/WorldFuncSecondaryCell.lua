--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldFuncSecondaryCell.lua
-- author:    liyuhang
-- created:   2015/10/23
-- descrip:   战斗活动二级菜单cell
--===================================================
local WorldFuncSecondaryCell = class("WorldFuncSecondaryCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function WorldFuncSecondaryCell:ctor()
    -- 层名称
    self._strName = "WorldFuncSecondaryCell"        

    -- 地图背景
    self._pParams = nil
    self._pBg = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

    self._pDataInfo = nil
   
    self._pDialogDelegate = nil
end

-- 创建函数
function WorldFuncSecondaryCell:create(dataInfo)
    local dialog = WorldFuncSecondaryCell.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function WorldFuncSecondaryCell:dispose(dataInfo)
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
            self:onExitWorldFuncSecondaryCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function WorldFuncSecondaryCell:initUI()
    --图标按钮
    local  onShowDetailButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    --前往按钮
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            PurposeManager:getInstance():createPurpose( self._pDataInfo.QueueId)
            PurposeManager:getInstance():startOperateByTaskId( self._pDataInfo.QueueId)
            self._pDialogDelegate:close()
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    -- 加载csb 组件
    local params = require("ActivityParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pActivityBgButton

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)
    
    self._pParams["_pGoButton"]:addTouchEventListener(onTouchBg)
    self._pBg:addTouchEventListener(onShowDetailButton)

    self:updateData()
end

function WorldFuncSecondaryCell:setDelegate(delegate)
	self._pDialogDelegate = delegate
end

function WorldFuncSecondaryCell:updateData()
    if self._pDataInfo == nil then
        return
    end

    self._pParams["_pActivityIcon"]:loadTexture("MainIcon/" .. self._pDataInfo.Icon .. ".png",ccui.TextureResType.plistType)
    self._pParams["_pInstructionText"]:setString(self._pDataInfo.Desc) 
    
    self._pParams["_pTimes"]:setVisible(false)

    if self._pDataInfo.ActivityTime ~= nil then
        self._pParams["_pActivityTime"]:setVisible(true)
        for i=1,table.getn(self._pDataInfo.ActivityTime) do
            self._pParams["_pActivityTime"]:setString(self._pDataInfo.ActivityTime[i][1]/3600 .. ":00 - " .. self._pDataInfo.ActivityTime[i][2]/3600 .. ":00")
        end
    else
        self._pParams["_pActivityTime"]:setVisible(false)
    end
    
    if self._pDataInfo.Reward ~= nil and table.getn(self._pDataInfo.Reward) > 0 then
        self._pParams["_pRewardIcon"]:setVisible(true)
        local RewardInfo = self._pDataInfo.Reward[1]
            if RewardInfo[1] <= 99 then
                local FinanceIcon = FinanceManager:getInstance():getIconByFinanceType(RewardInfo[1])
                self._pParams["_pRewardIcon"]:loadTexture(
                    FinanceIcon.filename,
                    ccui.TextureResType.plistType)
            else
                local pItemInfo = {id = RewardInfo[1], baseType = RewardInfo[2], value = 0}
                pItemInfo = GetCompleteItemInfo(pItemInfo)

                self._pParams["_pRewardIcon"]:loadTexture(
                    pItemInfo.templeteInfo.Icon ..".png",
                    ccui.TextureResType.plistType)
            end
    else
        self._pParams["_pRewardIcon"]:setVisible(false)
    end

end

function WorldFuncSecondaryCell:setInfo(info)
    self._pDataInfo = info

    self:updateData()
end

-- 退出函数
function WorldFuncSecondaryCell:onExitWorldFuncSecondaryCell()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return WorldFuncSecondaryCell
