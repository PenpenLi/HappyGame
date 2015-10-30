--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CashTreeDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/10/22
-- descrip:   摇钱树界面
--===================================================
local CashTreeDialog = class("CashTreeDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function CashTreeDialog:ctor()
    self._strName = "CashTreeDialog"        -- 层名称
    self._pBg = nil
end

-- 创建函数
function CashTreeDialog:create(args)
    local dialog = CashTreeDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function CashTreeDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("BuyMoney.plist")
    --获取摇钱树信息回复
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryGoldTreeInfo, handler(self,self.handlerMsgUpdateCashTreeInfo))
    --玉璧购买铜钱回复
    NetRespManager:getInstance():addEventListener(kNetCmd.kDiamondBuyGold, handler(self,self.handlerMsgUpdateCashTreeInfo))
    --初始化ui
    self:initUi()
    --初始button
    self:initBtn()
   ShopSystemCGMessage:QueryGoldTreeInfo21322 ()
   --local event = {buyCount = 0}
    --self:handlerMsgUpdateCashTreeInfo(event)

    -- 触摸注册
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

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitCashTreeDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end


function CashTreeDialog:initUi()

    local params = require("BuyMoneyParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBuyBg
    self._pRichNode = params._pNode_2
    self._pCurBuyAndMaxNum = params._pText_P3_2        --当前跟总次数

    self._pCloseButton = params._pNo
    self._pCloseButton:setZoomScale(nButtonZoomScale)
    self._pCloseButton:setPressedActionEnabled(true)

    self._pBuyOneButton = params._pYes                 --购买一次
    self._pBuyOneButton:setZoomScale(nButtonZoomScale)
    self._pBuyOneButton:setPressedActionEnabled(true)

    self._pBuyMoreButton = params._pYes_Copy             --购买10次
    self._pBuyMoreButton:setZoomScale(nButtonZoomScale)
    self._pBuyMoreButton:setPressedActionEnabled(true)
    self:disposeCSB()

end

function CashTreeDialog:initBtn()

    local onTypeSelectButton = function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()


            local pConst = (nTag == 1) and self._nBuyOneConst or self._nBuyMoreConst --购买需要的钱数
            if pConst > FinanceManager:getInstance()._tCurrency[kFinance.kDiamond] or self._nBuyMoreNum  == 0 then --钱不够或者没有购买次数弹出vip界面
                DialogManager:getInstance():showDialog("BuyStrengthDialog",{kBuyThingsType.kBuyGoldNumber,self._pCurHasBuyCount,self._pMaxBuyCount,pConst})
                return
            end
            local buyNum = 0
            if nTag == 1 then --购买一次
                buyNum = 1
            else --购买多次
                buyNum = self._nBuyMoreNum    
            end
            ShopSystemCGMessage:QueryGoldTreeInfo21324 (buyNum)

        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pBuyOneButton:setTag(1)
    self._pBuyMoreButton:setTag(2)
    self._pBuyOneButton:addTouchEventListener(onTypeSelectButton)
    self._pBuyMoreButton:addTouchEventListener(onTypeSelectButton)

end


--更新界面信息
function CashTreeDialog:handlerMsgUpdateCashTreeInfo( event )
    --已经买过了多少次
    self._pCurHasBuyCount = event.buyCount
    --每天一共可以买多少次
    local MaxBuyCount = TableVIP[RolesManager:getInstance()._pMainRoleInfo.vipInfo.vipLevel+1].GetGold
    self._pMaxBuyCount = MaxBuyCount
    self._pCurBuyAndMaxNum:setString(self._pCurHasBuyCount.."/"..MaxBuyCount)
    self:loadReshText()
    self._nBuyMoreNum = ((MaxBuyCount - self._pCurHasBuyCount) <= TableConstants.GetGoldMax.Value ) and (MaxBuyCount - self._pCurHasBuyCount) or TableConstants.GetGoldMax.Value

    if self._nBuyMoreNum == 0 then
         self._pBuyMoreButton:setTitleText("购买"..TableConstants.GetGoldMax.Value.."次")
       
    else
         self._pBuyMoreButton:setTitleText("购买".. self._nBuyMoreNum.."次")
    end

    self._nBuyMoreConst = 0 --买多次需要的钱数
    for i = self._pCurHasBuyCount, MaxBuyCount do
        self._nBuyMoreConst = TableGetGold[i+1].Cost + self._nBuyMoreConst
    end

end


--加载数据的富文本
function CashTreeDialog:loadReshText()

 self._pRichNode:removeAllChildren(true)
   local GoldInfo = TableGetGold[self._pCurHasBuyCount+1]
   self._nBuyOneConst = GoldInfo.Cost  --买一次需要的钱数
      local msg = {
            {title = "是否使用"},
            {title = GoldInfo.Cost,fontColor = cGreen},
            {title = "玉璧购买"},
            {title = GoldInfo.GetGold,fontColor = cGreen},
            {title = "铜钱"},
        }
    local goodRichText = ccui.RichText:create()
    goodRichText:ignoreContentAdaptWithSize(false)
    goodRichText:setContentSize(cc.size(360,60))
    for k,v in pairs(msg)do
        if v.fontColor == nil then 
           v.fontColor = cWhite
        end
        local re1 = ccui.RichElementText:create(1,v.fontColor, 255,v.title, strCommonFontName, 20)
        goodRichText:pushBackElement(re1)
    end  
    goodRichText:setAnchorPoint(cc.p(0,1))
    goodRichText:setPosition(cc.p(0,0))
    self._pRichNode:addChild(goodRichText)
end


-- 退出函数
function CashTreeDialog:onExitCashTreeDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("BuyMoney.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function CashTreeDialog:update(dt)
    return
end

-- 显示结束时的回调
function CashTreeDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function CashTreeDialog:doWhenCloseOver()
    return
end

return CashTreeDialog
