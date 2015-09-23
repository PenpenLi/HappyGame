--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MutlipeUseItemDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2014/12/26
-- descrip:   物品的批量使用对话框
--===================================================
local MutlipeUseItemDialog = class("MutlipeUseItemDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function MutlipeUseItemDialog:ctor()
    self._strName = "MutlipeUseItemDialog"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pLowButton = nil
    self._pAddButton = nil
    self._pNumPutInText = nil
    self._pOkButton = nil
    self._nNum = 1                                -- 当前使用物品的数量
    self._nLimitNum = 99                          -- 最大限制的数量
    self._kPurpose = 1                            -- 用途类型
    self._pItemInfo = nil                         -- 物品信息 
    self._pGoodsInfo = nil                        -- 商品信息
    self._kFinaneType = nil                       -- 消耗货币的类型
    self._kShopType = 0                           -- 商城的类型
    self._pSchedulerEntry = nil 
    
end

-- 创建函数
-- pDataInfo 除 kPurpose = 2 为 goodsInfo外为 itemInfo 
-- kPurpose 1: 批量使用 2：批量购买 3：批量出售
-- kFinaneType 消耗货币的类型
function MutlipeUseItemDialog:create(args)
    local dialog = MutlipeUseItemDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function MutlipeUseItemDialog:dispose(args)
    self._kPurpose = args[2]
    if self._kPurpose ==  2 then
        self._pGoodsInfo = args[1]
    else
        self._pItemInfo = BagCommonManager:getItemInfoByPosition(args[1].position)   
    end 
    self._kFinaneType = args[3]
    self._kShopType = args[4]
    -- 加载公司合图资源
    ResPlistManager:getInstance():addSpriteFrames("NumPutInDialog.plist")

    -- 加载dialog组件
    local params = require("NumPutINDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pNumBg	-- 背景图
    self._pCloseButton = params._pCloseButton	-- 关闭按钮
    self._pLowButton = params._pLowButton	-- 减少按钮
    self._pAddButton = params._pAddButton	-- 增加按钮
    self._pNumPutInText = params._pNumPutInText	-- 输入框
    self._pOkButton = params._pOkButton	-- 确定按钮
    
    -- 初始化dialog的基础组件
    self:disposeCSB()
    
    local price = self._kPurpose == 2 and self._pGoodsInfo.currentPrice or  self._pItemInfo.dataInfo.Price
    -- 设置数字标签的字体颜色
    local needPirce = price * self._nNum
    self:setNumFontColor(needPirce)
    
        -------------------- 定时器事件---------------------------
  
    -- 用于调节单位时间数字变化量
    local stepNum = 0
    -- (速度)数字
    local speedNum = 1
    
    
    local function stepAdd(dt)
        stepNum = stepNum + 1
        if stepNum == 15  then-- 1.5秒
            speedNum = 3
        elseif stepNum == 30 then
            speedNum = 5 
        end
        if self._kPurpose ~= 2 then
            self._nNum = self._nNum + speedNum >= self._pItemInfo.value and self._pItemInfo.value or self._nNum + speedNum
            if self._kPurpose == 1 then 
                self._nNum = self._nNum >= TableConstants.BatchUseMax.Value and TableConstants.BatchUseMax.Value or self._nNum
            end

            local str = string.format("%d",self._nNum)
            self._pNumPutInText:setString(str)
        else
            if self._nNum >= self._pGoodsInfo.remainBuy then
                self._nNum = self._pGoodsInfo.remainBuy == -1 and self._nNum + speedNum or self._pGoodsInfo.remainBuy
                if self._nNum >= 99 then
                    self._nNum = 99 
                end
            else
                self._nNum = self._nNum + speedNum
            end
            local str = string.format("%d",self._nNum)
            self._pNumPutInText:setString(str)
            local price = self._kPurpose == 2 and self._pGoodsInfo.currentPrice or  self._pItemInfo.dataInfo.Price
            -- 设置数字标签的字体颜色
            needPirce = price * self._nNum
            self:setNumFontColor(needPirce)
        end       
    end

    local function stepLow(dt)
        stepNum = stepNum + 1
        if stepNum == 15  then-- 1.5秒
            speedNum = 3
        elseif stepNum == 30 then
            speedNum = 5
        end
        self._nNum = self._nNum <= 1 and 1 or self._nNum - speedNum
        -- 避免出现小于1的现象
        self._nNum = self._nNum <= 1 and 1 or self._nNum 
        local str = string.format("%d",self._nNum)
        self._pNumPutInText:setString(str)
        local price = self._kPurpose == 2 and self._pGoodsInfo.currentPrice or  self._pItemInfo.dataInfo.Price
        -- 设置数字标签的字体颜色
        needPirce = price * self._nNum
        self:setNumFontColor(needPirce)
    end
     
    local function touchEvent (sender,eventType)    
        if eventType == ccui.TouchEventType.began then 
            AudioManager:getInstance():playEffect("ButtonClick")
            if sender:getTag() == 1000 or sender:getTag() == 2000 then
                local step = nil 
                step = sender:getTag() == 1000 and stepAdd or stepLow
                step()
                self._pSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(step,0.1,false)
            end
        end
        if eventType == ccui.TouchEventType.ended then
            if self._pSchedulerEntry ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pSchedulerEntry )
                self._pSchedulerEntry = nil
            end
             -- 清空加速器
             stepNum = 0
             speedNum = 1
             if cc.Director:getInstance():isPaused() then
                    cc.Director:getInstance():resume()
             end
            -- 点击确定按钮
            if sender:getTag() == 3000 then 
                if self._kPurpose == 1 then 
                    -- 具体逻辑 根据 self._pItemInfo 的信息做处理
                    local pItemBaseType =  self._pItemInfo.baseType
                    if pItemBaseType == kItemType.kBox then --如果是宝箱
                        OpenItemSystemCGMessage:sendMessageOpenBox20132(self._pItemInfo.position,self._nNum)
                        self:close()
                        if self._pItemInfo.value - self._nNum < 1 then 
                            DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
                        end
                    end                  
                end
                if self._kPurpose == 2 then
                    if needPirce > self:getFinaneInfo().value then
                       local strMsg = string.format("%s不足",self:getFinaneInfo().title)
                       showSystemMessage(strMsg)
                    else                       
                        local finaceName = FinanceManager:getInstance():getFinanceTitleByType(self._kFinaneType)
                        showConfirmDialog("是否花费"..needPirce.."个"..finaceName.."购买"..self._nNum.."个"..self._pGoodsInfo.itemInfo.templeteInfo.Name.."?",function()
                            ShopSystemCGMessage:buyGoodsReq20504(self._kShopType,self._pGoodsInfo.goodsId,self._nNum)
                            self:close()
                        end)  
                    end
                elseif self._kPurpose == 3 then
                    -- 批量出售
                    local nItemName = self._pItemInfo.templeteInfo.Name
                    local nItemPrice =  self._pItemInfo.dataInfo.Price*self._nNum
                    showConfirmDialog("是否确定出售 "..self._nNum.."个"..nItemName.." 出售后不可回收\n\n您将获得"..nItemPrice.."金币",function()
                        EquipmentCGMessage:sendMessageSellItem20128(self._pItemInfo.position,self._nNum)
                        if self._nNum == self._pItemInfo.value then
                            BagCommonManager:getInstance():setSellOutPosition(self._pItemInfo.position)
                        end
                        self:close()
                        DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
                    end)  --（背包中的下表，数量）    
                end
               
            end
        end
        if eventType == ccui.TouchEventType.canceled then
            if self._pSchedulerEntry ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pSchedulerEntry )
                self._pSchedulerEntry = nil
            end
        end
    end
    -- 数量文本框字体居中
    self._pNumPutInText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    if self._kPurpose ==  2 then
        self._pNumPutInText:setString(1)
    else
        self._nNum = self._pItemInfo.value 
        if self._kPurpose == 1 then 
            self._nNum = self._nNum >= TableConstants.BatchUseMax.Value and TableConstants.BatchUseMax.Value or self._nNum
        end
        local str = string.format("%d",self._nNum)
        self._pNumPutInText:setString(str)
    end

    self._pAddButton:addTouchEventListener(touchEvent)
    self._pAddButton:setTag(1000)
    self._pAddButton:setZoomScale(nButtonZoomScale)  
    self._pAddButton:setPressedActionEnabled(true)
    self._pLowButton:addTouchEventListener(touchEvent)
    self._pLowButton:setTag(2000)
    self._pLowButton:setZoomScale(nButtonZoomScale)
    self._pLowButton:setPressedActionEnabled(true)
    self._pOkButton:addTouchEventListener(touchEvent)
    self._pOkButton:setTag(3000)
    self._pOkButton:setZoomScale(nButtonZoomScale)
    self._pOkButton:setPressedActionEnabled(true)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMutlipeUseItemDialog()
        end
    end    
    self:registerScriptHandler(onNodeEvent)
        -- 初始化触摸相关
    self:initTouches()

    return
end

-- 获得货币的简要信息
function MutlipeUseItemDialog:getFinaneInfo()
    local finaneInfo = {}
    finaneInfo.title = FinanceManager:getInstance():getFinanceTitleByType(self._kFinaneType)
    finaneInfo.value = FinanceManager:getInstance()._tCurrency[self._kFinaneType]
    return finaneInfo
end

-- 设置个数标签的字体颜色
function MutlipeUseItemDialog:setNumFontColor(needPirce)
    if not self:getFinaneInfo().value or self._kPurpose ~= 2 then 
        return 
    end
    if needPirce > self:getFinaneInfo().value then
        self._pNumPutInText:setColor(cRed)
    else
        self._pNumPutInText:setColor(cWhite)
    end
end

-- 退出函数
function MutlipeUseItemDialog:onExitMutlipeUseItemDialog()
    self:onExitDialog() 
    if self._pSchedulerEntry ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pSchedulerEntry )
        self._pSchedulerEntry = nil
    end  
    -- 释放掉login合图资源  
    ResPlistManager:getInstance():removeSpriteFrames("NumPutInDialog.plist")
    print(self._strName.." onExit!")
end

-- 初始化触摸相关
function MutlipeUseItemDialog:initTouches()
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

-- 循环更新
function MutlipeUseItemDialog:update(dt)
    return
end

-- 显示结束时的回调
function MutlipeUseItemDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function MutlipeUseItemDialog:doWhenCloseOver()
    return
end

return MutlipeUseItemDialog
