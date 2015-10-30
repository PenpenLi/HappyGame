--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldFuncBtnSecondaryDialog.lua
-- author:    liyuhang
-- created:   2015/10/19
-- descrip:   主UI 右下角主功能二级菜单
--===================================================
local WorldFuncBtnSecondaryDialog = class("WorldFuncBtnSecondaryDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function WorldFuncBtnSecondaryDialog:ctor()
    self._strName = "WorldFuncBtnSecondaryDialog" 
    self._pTouchListener = nil
    self._pParams = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

    self._tDailyMission = {}
    self._tTimeMission = {}

    self._pListController = nil
end

-- 创建函数
function WorldFuncBtnSecondaryDialog:create()
    local dialog = WorldFuncBtnSecondaryDialog.new()
    dialog:dispose()
    return dialog
end

function WorldFuncBtnSecondaryDialog:dispose()

    ResPlistManager:getInstance():addSpriteFrames("ActivityPanel.plist")

    local params = require("ActivityPanelParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBg
    self._pCloseButton = params._pCloseButton
    self._pParams = params
    
    self:disposeCSB()

    self._pParams._pScrollView_1:setInnerContainerSize(self._pParams._pScrollView_1:getContentSize())
    self._pParams._pScrollView_1:setTouchEnabled(true)
    self._pParams._pScrollView_1:setBounceEnabled(true)
    self._pParams._pScrollView_1:setClippingEnabled(true)

    self._pParams._pLeftButton:setTitleText("日常活动")
    
    self._pListController = require("ListController"):create(self,self._pParams._pScrollView_1,listLayoutType.LayoutType_vertiacl,0,140)
    self._pListController:setVertiaclDis(2)
    self._pListController:setHorizontalDis(3)

    self:initTouches()

    self:updateData()

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWorldFuncBtnSecondaryDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

function WorldFuncBtnSecondaryDialog:updateData()
    
    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local info = TableSubActivityFunc[index]

        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("WorldFuncSecondaryCell"):create(info)
        else
            cell:setInfo(info)
        end
        cell:setDelegate(delegate)

        return cell
    end

    self._pListController._pNumOfCellDelegateFunc = function ()
        return table.getn(TableSubActivityFunc)
    end

    self._pListController:setDataSource(self._tDiaryTasks)
end

-- 触摸注册
function WorldFuncBtnSecondaryDialog:initTouches()   
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            
        end
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
function WorldFuncBtnSecondaryDialog:onExitWorldFuncBtnSecondaryDialog()
    ResPlistManager:getInstance():removeSpriteFrames("ActivityPanel.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return WorldFuncBtnSecondaryDialog
