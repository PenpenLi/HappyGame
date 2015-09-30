--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendGroomCell.lua
-- author:    liyuhang
-- created:   2015/5/18
-- descrip:   推荐好友cell
--===================================================
local FriendGroomCell = class("FriendGroomCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function FriendGroomCell:ctor()
    -- 层名称
    self._strName = "FriendGroomCell"        

    self._fNormalScale = 1.0                  -- 正常大小尺寸
    self._fBigScale = 1.04                    -- 按下时的放大尺寸
    -- 地图背景
    self._pParams = nil
    self._pBg = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

    self._pDataInfo = nil
end

-- 创建函数
function FriendGroomCell:create(dataInfo)
    local dialog = FriendGroomCell.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function FriendGroomCell:dispose(dataInfo)
    --注册（请求游戏副本列表）
    --NetRespManager:getInstance():addEventListener(kNetCmd.kQueryBattleList, handler(self, self.updateQueryBattleList))
    ResPlistManager:getInstance():addSpriteFrames("GroomFriend.plist")
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
            self:onExitFriendGroomCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function FriendGroomCell:initUI()
    -- 背景图
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self:toBigScale()
            self._fMoveDis = 0
        elseif eventType == ccui.TouchEventType.moved then
            self._fMoveDis = self._fMoveDis + 1
            if self._fMoveDis >= 5 then
                self:toNormalScale()
            end
        elseif eventType == ccui.TouchEventType.ended then
            if self:getScale() > self._fNormalScale then
                -- 显示邮件内容弹框
                DialogManager:getInstance():showDialog("FriendTipsDialog",{self._pDataInfo})
            end
            self:toNormalScale()
            self._fMoveDis = 0
        end
    end

    --图标按钮
    local onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            FriendCGMessage:sendMessageApplyFriend22010(self._pDataInfo.roleId)
            self._pParams._pAddButton:setVisible(false)
            self._pParams._pSendImage:setVisible(true)
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    -- 加载csb 组件
    local params = require("GroomFriendParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pGroomInfoBg
    
    self._pBg:setTouchEnabled(true)
    self._pBg:setSwallowTouches(false)
    self._pBg:addTouchEventListener(onTouchBg)
    
    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)
    
    self._pParams._pAddButton:addTouchEventListener(onTouchButton)

    self:updateData()
end

function FriendGroomCell:updateData()
    if self._pDataInfo == nil then
        return
    end
    
    self._pParams._pAddButton:setVisible(true)
    self._pParams._pSendImage:setVisible(false)

    self._pParams._pPlayerName:setString(self._pDataInfo.roleName)
    self._pParams._pHeadIcon:loadTexture(
        kRoleIcons[self._pDataInfo.roleCareer],
        ccui.TextureResType.plistType)
    self._pParams._pLvText:setString("Lv"..self._pDataInfo.level)
end

function FriendGroomCell:setInfo(info)
    self._pDataInfo = info

    self:updateData()
end

-- 整体到放大尺寸
function FriendGroomCell:toBigScale()
    self:setScale(self._fBigScale)
end

-- 整体到正常尺寸
function FriendGroomCell:toNormalScale()
    self:setScale(self._fNormalScale)
end

-- 退出函数
function FriendGroomCell:onExitFriendGroomCell()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("GroomFriend.plist")
end

return FriendGroomCell
