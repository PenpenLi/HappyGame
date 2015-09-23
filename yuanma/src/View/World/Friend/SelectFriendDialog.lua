--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SelectFriendDialog.lua
-- author:    liyuhang
-- created:   2015/9/22
-- descrip:   选取好友系统面板
--===================================================
local SelectFriendDialog = class("SelectFriendDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function SelectFriendDialog:ctor()
    -- 层名字
    self._strName = "SelectFriendDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self.params = nil

    self._pItems = {}
    
    self._pDelegate = nil
end

-- 创建函数
function SelectFriendDialog:create(args)
    local layer = SelectFriendDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function SelectFriendDialog:dispose(args)
    -- 注册网络回调事件
    -- NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFriendDatas, handler(self,self.handleMsgkUpdateFriendDatas))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kFriendWarning, handler(self,self.handleMsgFriendWarning))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetUnFieldPet, handler(self,self.handleMsgUnFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    
    self._pDelegate = args[1]
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("FriendListDialog.plist")

    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSelectFriendDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function SelectFriendDialog:initUI()
    -- 加载组件
    local params = require("FriendListDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    params._pMyFriendButton:setVisible(false)
    params._pFriendMessageButton:setVisible(false)
    params._pGiftsInfoButton:setVisible(false)

    FriendCGMessage:sendMessageQueryFriendList22000()

    self.params["_pAddFriendButton"]:setVisible(false)

    self:disposeCSB()

    self:updateFriendListData()
end

function SelectFriendDialog:updateFriendListData()
    self.params._pFriendListScrollView:removeAllChildren()
    self._pCells = {}

    local rowCount = FriendManager:getInstance()._pFriendList == nil and 0 or table.getn(FriendManager:getInstance()._pFriendList)
    self.params._pListNum:setString(rowCount.."/"..TableConstants.FriendLimit.Value)

    local nUpAndDownDis = 2                             --装备上下与框的间隔
    local nLeftAndReightDis = 3                         --装备左右与框的间隔
    local nSize = 90
    local nViewWidth  = self.params._pFriendListScrollView:getContentSize().width
    local nViewHeight = self.params._pFriendListScrollView:getContentSize().height
    local scrollViewHeight =((nUpAndDownDis+160)*(rowCount) > nViewHeight) and (nUpAndDownDis+160)*(rowCount)   or nViewHeight
    self.params._pFriendListScrollView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))

    for i = 1,rowCount do
        -- 按照宠物索引 取宠物数据
        local info = FriendManager:getInstance()._pFriendList[i]
        --local info = nil
        -- 按照宠物索引 取宠物数据
        local cell = self._pCells[i]
        if not self._pCells[i] then
            cell = require("FriendHelpBattleCell"):create(info)
        end

        cell:setPosition(304+nLeftAndReightDis, scrollViewHeight-(160+nUpAndDownDis)*i +80 )
        cell:setAnchorPoint(cc.p(0,0))
        cell._fCallback = function (friendInfo)
            self._pDelegate:setFriendHelpInfo(friendInfo)
        	self:close()
        end
        self.params._pFriendListScrollView:addChild(cell)
        self._pCells[i] = cell

        --cell:setInfo(info)
        --cell:setDelegate(self)
    end
end

-- 初始化触摸相关
function SelectFriendDialog:initTouches()
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
function SelectFriendDialog:onExitSelectFriendDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FriendListDialog.plist")
end

return SelectFriendDialog