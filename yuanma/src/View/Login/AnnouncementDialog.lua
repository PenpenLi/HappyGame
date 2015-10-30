--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  AnnouncementDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/8/10
-- descrip:   公告
--===================================================
local AnnouncementDialog = class("AnnouncementDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function AnnouncementDialog:ctor()
    self._strName = "AnnouncementDialog"        -- 层名称
    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pMountNode = nil
    self._tScrollViewList = {}
    self._pHasInitIndex = {}
    self._tBtnTab = {}

end

-- 创建函数
function AnnouncementDialog:create(args)
    local dialog = AnnouncementDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function AnnouncementDialog:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kNoticeTagListResp, handler(self,self.getAnnouncementResp))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNoticeDescResp, handler(self,self.getNoticeDescResp))
    ResPlistManager:getInstance():addSpriteFrames("AnnouncementDialog.plist")
    local params = require("AnnouncementDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pMountNode = params._pNode01
    self._pScrollViewTitle = params._pScrollViewTitle
    self._pListViewitem = params._pListItemBtn
    self._pScrollViewModel = params._pScrollViewDesc
    self._pDescTitle = params._pTitleText

    -- 初始化dialog的基础组件
    self:disposeCSB()
    LoginCGMessage:sendMessageGetNoticeTag()

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
            self:onExitAnnouncementDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end


function AnnouncementDialog:getAnnouncementResp(event)
    self:createListItem(event.tagList)
    self:toJumpByIndex(event.tagIndex,event.noticeInfo)
end

function AnnouncementDialog:getNoticeDescResp(event )
    self:toJumpByIndex(event.argsBody.tagIndex,event.noticeInfo)
end


function AnnouncementDialog:createListItem(pStringList)

     local onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           local nTag = sender:getTag()
           local pHasInit,nIndex = self:setTabStateByIndex(nTag)
            if pHasInit then --说明加载过了
               self._pDescTitle:setString(self._pHasInitIndex[nIndex][2].title)
              return 
           end
           LoginCGMessage:sendMessageNotice(nTag)
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    local pItemHeight = self._pListViewitem:getContentSize().height*0.65
    local pItemWidth = self._pListViewitem:getContentSize().width*0.65
    local pItemNum = table.getn(pStringList)
    local pUpAndDownDis = 0
    local pTempHeight = (pItemHeight+pUpAndDownDis)*pItemNum

    local pContentSize = self._pScrollViewTitle:getContentSize()
    local pHasMove = false
    local pInnerHeight = 0 
    if pContentSize.height > pTempHeight then
    	pInnerHeight = pContentSize.height 
    else
    	pInnerHeight = pTempHeight 
    	pHasMove = true
    end
    
    self._pScrollViewTitle:setInnerContainerSize(cc.size(pContentSize.width,pInnerHeight))
    
    self._pScrollViewTitle:setBounceEnabled(pHasMove)
    
    for i=1,table.getn(pStringList) do
       local pItem = nil 
       local pScrollView = nil
       if i == 1 then 
          pScrollView = self._pScrollViewModel
       else
          pScrollView = self._pScrollViewModel:clone()
          self._pMountNode:addChild(pScrollView)
       end
     pItem = self._pListViewitem:clone()
   
     
     pItem:setTag(i)
     pItem:setVisible(true)
     pItem:setAnchorPoint(cc.p(0, 1))
     pItem:setPosition(cc.p(0,pInnerHeight-pItemHeight*(i-1)))
     pItem:addTouchEventListener(onTouchButton)
     self._pScrollViewTitle:addChild(pItem)

     table.insert(self._tBtnTab,pItem)
     table.insert( self._tScrollViewList,pScrollView)
     local pNotic = pItem:getChildByName("notice")
     pNotic:setVisible(pStringList[i].isNew)
     local pText = pItem:getChildByName("btnText")
     pText:setString(pStringList[i].tagName)
    end   

end


--设置某一个tab的状态
function AnnouncementDialog:setTabStateByIndex(pIndex)
    for i=1,table.getn(self._tScrollViewList) do
        if i== pIndex then 
            self._tScrollViewList[i]:setVisible(true)
        else
            self._tScrollViewList[i]:setVisible(false)
        end
    end
    self:setTabBtnStateByIndex(pIndex)
    for k,v in pairs( self._pHasInitIndex) do
        if v[1] == pIndex then --标示章节已经加载过了
            return true,k
        end
    end

    return false
	
end

--设置TabButton的图片状态

function AnnouncementDialog:setTabBtnStateByIndex(nIndex)
    
    local pNomalImage = "AnnouncementDialogRes/ggjm1.png"
    local pPushImage = "AnnouncementDialogRes/ggjm2.png"
    
    local pClickNomalImage = "AnnouncementDialogRes/ggjm3.png"
    local pClickPushImage = "AnnouncementDialogRes/ggjm4.png"
    
    for i=1,table.getn(self._tBtnTab) do
      self._tBtnTab[i]:loadTextures(pNomalImage,pPushImage,nil,ccui.TextureResType.plistType)
    end
 self._tBtnTab[nIndex]:loadTextures(pClickNomalImage,pClickPushImage,nil,ccui.TextureResType.plistType)

end


function AnnouncementDialog:toJumpByIndex(pIndex,pNoticInfo)
    local pScrollView = self._tScrollViewList[pIndex]
    self:setTabStateByIndex(pIndex)
    
    local pSWidth = pScrollView:getContentSize().width
    local pSHeight = pScrollView:getContentSize().height
    self._pTimePoke = cc.Label:createWithTTF("", strCommonFontName, 30)
    self._pTimePoke:setAnchorPoint(0,1)
    self._pTimePoke:setWidth(pSWidth)
    self._pTimePoke:setString(pNoticInfo.content)
    local pHeight = self._pTimePoke:getContentSize().height
    local pInnerHeight = 0
    local pHasScoll = false
    if  pHeight > pSHeight then 
        pInnerHeight = pHeight
        pHasScoll = true
    else
     
        pInnerHeight = pSHeight
    end
    pScrollView:setBounceEnabled(pHasScoll)
    self._pTimePoke:setPosition(cc.p(0,pInnerHeight))
    pScrollView:setInnerContainerSize(cc.size(pSWidth,pInnerHeight))
    pScrollView:addChild(self._pTimePoke)
    table.insert( self._pHasInitIndex ,{pIndex,pNoticInfo})
    self._pDescTitle:setString(pNoticInfo.title)
end


-- 退出函数
function AnnouncementDialog:onExitAnnouncementDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("AnnouncementDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function AnnouncementDialog:update(dt)
    return
end

-- 显示结束时的回调
function AnnouncementDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function AnnouncementDialog:doWhenCloseOver()
    return
end

return AnnouncementDialog
