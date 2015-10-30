--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ResignConfirmDialog.lua
-- author:    liyuhang
-- created:   2015/10/14
-- descrip:   补签确认面板
--===================================================


local ResignConfirmDialog = class("ResignConfirmDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function ResignConfirmDialog:ctor()
    self._strName = "ResignConfirmDialog"        -- 层名称
    self._pText = nil                    -- 显示文字
    self._pOkBtn = nil                   -- 确定按钮
    self._fOk = nil                      -- 确定按钮回调
    self._pCancelBtn = nil               -- 
    self._pAllResignPriceText = nil
    self._pOnetimeResignPriceText = nil
end

-- 创建函数
function ResignConfirmDialog:create(alertContent , okCallbackFunc , cancelCallbackFunc)
    local dialog = ResignConfirmDialog.new()
    dialog:dispose(alertContent , okCallbackFunc,cancelCallbackFunc)
    return dialog
end

-- 处理函数
function ResignConfirmDialog:dispose(alertContent , okCallbackFunc, cancelCallbackFunc)

    NetRespManager:getInstance():addEventListener(kNetCmd.kMonthSign,handler(self,self.handleMonthSign))  
    -- 加载dialog组件
    ResPlistManager:getInstance():addSpriteFrames("ReSignIn.plist")

    local params = require("ReSignInParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pReSignInBg
    self._pCloseButton = params._pCloseButton
    self._pText = params._pReSignInText
    self._pOkBtn = params._pOneTimeButton
    self._pOkBtn:setZoomScale(nButtonZoomScale)  
    self._pOkBtn:setPressedActionEnabled(true)
    self._pCancelBtn = params._pAllTimeButton
    self._pCancelBtn:setZoomScale(nButtonZoomScale)
    self._pCancelBtn:setPressedActionEnabled(true)
    self._pAllResignPriceText = params._pAllTimeText
    self._pOnetimeResignPriceText = params._pOneTimeText
    -- 初始化dialog的基础组件
    self:disposeCSB()
    --self._pCloseButton:setVisible(false)
    self._pText:setString(alertContent[1])
    self._pAllResignPriceText:setString((ActivityManager._nTheDay - ActivityManager._nSignCount) * TableConstants.ReCheckCost.Value)
    self._pOnetimeResignPriceText:setString(TableConstants.ReCheckCost.Value)
    
    self._pCloseButton:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    -- ok按钮回调
    self._pOkBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if FinanceManager:getValueByFinanceType(kFinance.kDiamond) < TableConstants.ReCheckCost.Value then
                DialogManager:getInstance():showAlertDialog("玉璧不足,是否前往充值?",function()
                    DialogManager:getInstance():showDialog("ChargeDialog")
                end)
                return
            end

            ActivityMessage:SignIn(false,true)
            --self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    -- 取消按钮回调
    self._pCancelBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if FinanceManager:getValueByFinanceType(kFinance.kDiamond) < (ActivityManager._nTheDay - ActivityManager._nSignCount) * TableConstants.ReCheckCost.Value then
                DialogManager:getInstance():showAlertDialog("玉璧不足,是否前往充值?",function()
                    DialogManager:getInstance():showDialog("ChargeDialog")
                end)
                return
            end

            ActivityMessage:SignIn(true,true)
            --self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
          self:close()
        end
        return true
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

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "enter" then
            self:setPositionZ(5000)
            self._pOkBtn:setPositionZ(5000)
            self._pCancelBtn:setPositionZ(5000)
        elseif event == "exit" then
            self:onExitResignConfirmDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function ResignConfirmDialog:onExitResignConfirmDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("ReSignIn.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

function ResignConfirmDialog:handleMonthSign(event)
    local resignStr = "还可补签" .. (ActivityManager._nTheDay - ActivityManager._nSignCount) .. "次,本月已补签" .. ActivityManager._nReSignCount .. "/" .. (ActivityManager._nReSignCount+ActivityManager._nTheDay - ActivityManager._nSignCount) .. "次"
    self._pText:setString(resignStr)

    self._pAllResignPriceText:setString((ActivityManager._nTheDay - ActivityManager._nSignCount) * TableConstants.ReCheckCost.Value)

    if ActivityManager._nTheDay - ActivityManager._nSignCount == 0 then
        self._pOkBtn:setTouchEnabled(false)
        self._pCancelBtn:setTouchEnabled(false)
        self:close()
    end
end

-- 循环更新
function ResignConfirmDialog:update(dt)
    return
end

-- 显示结束时的回调
function ResignConfirmDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function ResignConfirmDialog:doWhenCloseOver()
    return
end

return ResignConfirmDialog
