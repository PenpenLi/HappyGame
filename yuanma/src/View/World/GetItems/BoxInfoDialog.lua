--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BoxInfoDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/11
-- descrip:   宝箱物品展示
--===================================================
local BoxInfoDialog = class("BoxInfoDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BoxInfoDialog:ctor()
    self._strName = "BoxInfoDialog"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pItemScrollView = nil
    self._pGetButton = nil
    self._pScrollViewDate = {}
    self._bHasClick = false
    self._pShowType = nil                  --物品展示界面的类型
    self._tArgs = {}
    self._tItemDate = {}                   --穿进来的物品数据

end

-- 创建函数{1物品信息,2是否可以领取 ,3进入界面类型,4其他信息（各个界面可以自由传递其他需要的信息,可有可无）}
function BoxInfoDialog:create(args)
    local dialog = BoxInfoDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function BoxInfoDialog:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kDrawStoryBox ,handler(self,self.openBoxResp))
    NetRespManager:getInstance():addEventListener(kNetCmd.kGainVitalityAward, handler(self,self.openBoxResp))
    NetRespManager:getInstance():addEventListener(kNetCmd.kGainVipBox, handler(self,self.openBoxResp))
    
    self:initScrollViewDate(args[1])
    self._tItemDate = args[1]
    self._bHasClick = args[2]
    self._pShowType = args[3]
    self._tArgs = args[4]
    ResPlistManager:getInstance():addSpriteFrames("BoxInfDialog.plist")
    local params = require("BoxInfDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pItemScrollView = params._pGetItemScrollView
    self._pGetButton = params._pButton

    -- 初始化dialog的基础组件
    self:disposeCSB()
    --加载ScrollView数据
    self:loadScrollViewDate()
    --加载button的事件
    self:initGetButtonInfo()

    NewbieManager:showOutAndRemoveWithRunTime()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
            return true
        end
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
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBoxInfoDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end
--初始化数据
function BoxInfoDialog:initScrollViewDate(tDate)
    self._pScrollViewDate = getBoxInfo(tDate)
end


function BoxInfoDialog:openBoxResp(event)
   local pInfo = {}
   pInfo.reward = self._tItemDate
   DialogManager:getInstance():showDialog("GetItemsDialog",pInfo)
   self:close()
  
end


--根据id来判断是否为是否为货币类型
function BoxInfoDialog:hasFinanceById(nId)
    if nId >kFinance.kNone and nId <=kFinance.kFC then
        return true
    end
    return false
end


--初始化ScrollView界面数据
function BoxInfoDialog:loadScrollViewDate()
    if #self._pScrollViewDate == 0 then
        return
    end

    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101                                   --每个cell的宽度和高度
    local nStartx = 0
    local nNum = #self._pScrollViewDate
    local nViewWidth  = self._pItemScrollView:getContentSize().width
    local nViewHeight  = self._pItemScrollView:getContentSize().height
    local pScrInnerWidth = (nViewWidth >(nLeftAndReightDis+nSize)*nNum) and nViewWidth or (nLeftAndReightDis+nSize)*nNum
    self._pItemScrollView:setInnerContainerSize(cc.size(pScrInnerWidth,nViewHeight))
    if pScrInnerWidth == nViewWidth then
        self._pItemScrollView:setBounceEnabled(false)
        nStartx = (nViewWidth-(nLeftAndReightDis+nSize)*(nNum-1))/2-nSize/2
    end

    for i=1,nNum do
        local pDateInfo = self._pScrollViewDate[i]
        local pCell =  require("BattleItemCell"):create()
        local nX = (i-1)*(nSize+nLeftAndReightDis)+nStartx
        local nY = (nViewHeight-nSize)/2
        pCell:setPosition(nX,nY)
        pCell:setTouchEnabled(false)
        self._pItemScrollView:addChild(pCell)
        
        local pName = cc.Label:createWithTTF("", strCommonFontName, 18)
        pName:setLineHeight(20)
        pName:setAdditionalKerning(-2)
        pName:setTextColor(cc.c4b(255, 255, 255, 255))
        pName:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        pName:setPosition(cc.p(nX+nSize/2,nY+nSize))
        pName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        pName:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        self._pItemScrollView:addChild(pName,1)
        

        if pDateInfo.finance then --是货币
            pCell:setFinanceInfo(self._pScrollViewDate[i])
            pName:setString(kFinanceNameTypeTitle[pDateInfo.id])
        else
            pCell:setItemInfo(self._pScrollViewDate[i])
            pName:setString(self._pScrollViewDate[i].templeteInfo.Name)
            local pQuality = self._pScrollViewDate[i].dataInfo.Quality
            if pQuality and pQuality >0 then
                pName:setColor(kQualityFontColor3b[pQuality])
            end
        end

      
   
      
  
    end
end

function BoxInfoDialog:initGetButtonInfo()

    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._pShowType ==boxInfoShowType.kBoxstoryCopy then --如果是剧情副本界面
                if self._tArgs ~= nil or table.getn( self._tArgs) == 0 then
                    MessageGameInstance:sendMessageDrawStoryBox21010(self._tArgs[1],self._tArgs[2])
                    NoticeManager:getInstance():showSystemMessage("领取成功，物品已放入您的背包！")
                   -- self:close()
                end
            elseif self._pShowType == boxInfoShowType.kTaskAward then 
                if self._tArgs ~= nil or table.getn( self._tArgs) == 0 then
                    TaskCGMessage:sendMessageGainVitalityAward21704(self._tArgs[1])
                    NoticeManager:getInstance():showSystemMessage("领取成功，物品已放入您的背包！")
                    --self:close()
                end
            elseif self._pShowType == boxInfoShowType.kVipDialog then 
                local roleVipLevel = self._tArgs[1]
        
                if roleVipLevel < self._tArgs[2] then 
                    NoticeManager:getInstance():showSystemMessage("Vip等级不足")
                    return
                else
                    NoticeManager:getInstance():showSystemMessage("您已经领过奖品了")
                    return
                end             
                ShopSystemCGMessage:gainVipBoxReq20508(self._tArgs[2])
                NoticeManager:getInstance():showSystemMessage("领取成功，物品已放入您的背包！")
                --self:close()
            end
        end
    end

    self._pGetButton:addTouchEventListener(onTouchButton)
    if self._bHasClick == nil or self._bHasClick == false then --信息不全领取按钮无法点击
        self._pGetButton:setTouchEnabled(false)
        darkNode(self._pGetButton:getVirtualRenderer():getSprite())
        self._pGetButton:setTitleText("未达成")
    elseif eventType == ccui.TouchEventType.began then
        AudioManager:getInstance():playEffect("ButtonClick")
    end


end

-- 退出函数
function BoxInfoDialog:onExitBoxInfoDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("BoxInfDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function BoxInfoDialog:update(dt)
    return
end

-- 显示结束时的回调
function BoxInfoDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BoxInfoDialog:doWhenCloseOver()
    return
end

return BoxInfoDialog
