--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SignInPanel.lua
-- author:    liyuhang
-- created:   2015/10/12
-- descrip:   月签到面板 
--===================================================
local SignInPanel = class("SignInPanel",function()
    return cc.Layer:create()
end)

--构造函数
function SignInPanel:ctor()
    self._strName = "SignInPanel"
    self._pDataInfo = nil
    self._pParams = nil
    
    self._pListController = nil
end

--创建函数
function SignInPanel:create()
    local layer = SignInPanel.new()
    layer:dispose()
    return layer
end

-- 处理函数
function SignInPanel:dispose()
    -- 右侧列表的回调函数
    --self._pDataInfo = info
    NetRespManager:getInstance():addEventListener(kNetCmd.kMonthSign,handler(self,self.handleMonthSign))  
    -- 加载图片资源
    ResPlistManager:getInstance():addSpriteFrames("ActivitySignIn.plist")
    -- 加载UI组件
    local params = require("ActivitySignInParams"):create()
    self._pCCS = params._pCCS
    self._pParams = params

    self._pBg = params._pRightBg
    self:addChild(self._pCCS)

    self._pListController = require("ListController"):create(self,params._pSiScrollView,listLayoutType.LayoutType_rows,120,142)
    self._pListController:setVertiaclDis(2)
    self._pListController:setHorizontalDis(9)
    self._pListController:setRowsCount(5)
    
    self._pParams._pButton_5:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local resignStr = "还可补签" .. (ActivityManager._nTheDay - ActivityManager._nSignCount) .. "次,本月已补签" .. ActivityManager._nReSignCount .. "/" .. (ActivityManager._nReSignCount+ActivityManager._nTheDay - ActivityManager._nSignCount) .. "次"
            DialogManager:showDialog("ResignConfirmDialog",{resignStr})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    self:updateData()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSignInPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

function SignInPanel:updateData()
    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local info = TableMonthSign[index]
        
        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("SignInCell"):create()
        end
        cell:setData(index,info)
        
        return cell
    end

    self._pListController._pNumOfCellDelegateFunc = function ()
        return ActivityManager:getInstance()._nMonthDayCount
    end

    self._pListController:setDataSource(self._tDiaryTasks)

    self._pParams._pLeijiText:setString("(本月已累计签到"..ActivityManager:getInstance()._nSignCount.."天")
    self._pParams._pMoonText:setString(ActivityManager:getInstance()._nMonth.."月签到")

    if ActivityManager._nTheDay - ActivityManager._nSignCount == 0 or ActivityManager._nSignVip == 0 then
        self._pParams._pButton_5:setTouchEnabled(false)
    else
        self._pParams._pButton_5:setTouchEnabled(true)
    end
end

function SignInPanel:handleMonthSign(event)
    self._pParams._pLeijiText:setString("(本月已累计签到"..ActivityManager:getInstance()._nSignCount.."天")
    self._pParams._pMoonText:setString(ActivityManager:getInstance()._nMonth.."月签到")

    if ActivityManager._nTheDay - ActivityManager._nSignCount == 0 or ActivityManager._nSignVip == 0 then
        self._pParams._pButton_5:setTouchEnabled(false)
    else
        self._pParams._pButton_5:setTouchEnabled(true)
    end
end

function SignInPanel:onExitSignInPanel()
    -- 释放资源
    ResPlistManager:getInstance():removeSpriteFrames("ActivitySignIn.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return SignInPanel