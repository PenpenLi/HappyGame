--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChatDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/6/25
-- descrip:   聊天信息界面
--===================================================
local ChatDialog = class("ChatDialog",function()
    return require("Dialog"):create()
end)
-- 构造函数
function ChatDialog:ctor()
    self._strName = "ChatDialog"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._tChatTypeButton = nil         --每个界面的button
    self._tChatNotice = nil             --每个界面的提示小图标pUseHornNumText
    self._pSetUpButton = nil            -- 设置按钮
    self._pListView = nil               --listView
    self._pTextBg = nil                 --输入层背景图
    self._pTextFild = nil               --输入框
    self._pSendButton = nil             --发送按钮
    self._pFaceButton = nil             --表情按钮
    self._pVoiceButton = nil            --语音按钮
    self._pTeamNotice = nil             --组队界面下方文字提示
    self._pTextNode = nil               --挂在富文本的node    
    self._pElementText = nil            --富文本
    self._pPrivateBg = nil              --私聊某人时上方的条目背景
    self._pPrivateName = nil            --私聊内层昵称 ：当前正在和玩家 “xxxxx” 聊天。
    self._pPrivateNameNode = nil        --挂载聊天的node
    self._pSearchNode = nil             --搜索框所在的node
    self._pPrivateBackBt = nil          --私聊内层返回按钮
    self._tChatTypeListView = {}        --聊天界面的每个界面的listview
    self._pListViewNode = nil           --聊天界面的listView挂载点
    self._tPrivateListItem = {}         --私聊界面第一目录中的item
    
    self._pFackBg = nil                 --表情底板
    self._pFackScrollView = nil         --表情列表
    self._pFackClose = nil              --表情关闭   
    
    self._pSearchButton = nil           --搜索按钮
    self._pSearchEditBox = nil          --输入查找玩家的昵称
    
    self._pHasUseHornBtn = nil          --是否使用小喇叭
    self._pHasUseHornNotice = nil       --是否使用了小喇叭提示
    self._bHasUseHorn = false           --是否使用了喇叭
    self._pUseHornNumText = nil         --小喇叭的个数
    
    
    self._pArgsInfo = nil               --其他信息
    self._bVoiceBtnDown = false         --语音按钮是否按下
    
    self._tAutoPlayBtn = {}             --自动播放语音的voicebtn
    self._bHasAutoPlay = true           --自动播放语音的开关
    
    self._pButtonCdTime = 0             --语音bt的点击cd
    self._nButtonCd = 3                 --语音的点击间隔
    self._nVoiceCdTime = 0              --语音倒计时

    self._pVoiceHistoryType = kChatType.kAll
    self._pVoiceHistoryRoleId = 0
     
end

-- 创建函数{1物品信息,2是否可以领取 ,3进入界面类型,4其他信息（各个界面可以自由传递其他需要的信息,可有可无）}
function ChatDialog:create(args)
    local dialog = ChatDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function ChatDialog:dispose(args)

   -- 设置是否需要缓存
    self:setNeedCache(true)
    ChatManager:getInstance()._bChatOpenView = true
    self._pArgsInfo = args
    local pChatType = kChatType.kAll
    local pRoleId = nil
    if self._pArgsInfo ~= nil  then
        pChatType = self._pArgsInfo[1]
        pRoleId = self._pArgsInfo[2]
    end
    mmo.HelpFunc:setMaxTouchesNum(1)
    NetRespManager:getInstance():addEventListener(kNetCmd.kChatResp, handler(self,self.updaeChatInfo))
    NetRespManager:getInstance():addEventListener(kNetCmd.kSetBlackList, handler(self,self.setBlackList))
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFriendRoleInfo, handler(self,self.searchRoleInfo))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateBagItemList, handler(self,self.updateBagItemList))
    ResPlistManager:getInstance():addSpriteFrames("ChatDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("PrivateChat.plist")
    ResPlistManager:getInstance():addSpriteFrames("SearchPlayer.plist")
    ResPlistManager:getInstance():addSpriteFrames("SpeekingEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("SpeakNowEffect.plist")
    
    local params = require("ChatDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._tChatTypeButton = {params._pButton1,params._pButton2,params._pButton3,params._pButton4,params._pButton5,params._pButton6}
    self._tChatNotice = {params._pNotice1,params._pNotice2,params._pNotice3,params._pNotice4,params._pNotice5,params._pNotice6}
    self._pSetUpButton = params._pOption                -- 设置按钮
    self._pListView = params._pListView                 --listView
    self._pTextBg = params._pTextBg                     --输入背景图
    self._pTextFieldNode = params._pTextFieldNode       --输入框
    self._pSendButton = params._pSend                   --发送按钮
    self._pFaceButton = params._pExpression             --表情按钮
    self._pVoiceButton = params._pVoice                 --语音按钮
    self._pTeamNotice = params._pTeamNotice             --组队界面下方文字提示
    self._pTextNode = params._pTextNode                 --挂在富文本的node
    self._pPrivateBg = params._pPrivateBg               --私聊某人时上方的条目背景
    self._pPrivateNameNode =  params._pPrivateName      --挂载聊天的node  
    self._pPrivateBackBt = params._pPrivateBack         --私聊内层返回按钮
    self._pSearchNode = params._pSearchNode             --搜索框所在的node
    self._pFackBg = params._pExpressionBg               --表情底板
    self._pFackScrollView = params._pExpressionList     --表情列表
    self._pFackClose = params._pExpressionClose         --表情关闭   
    self._pHasUseHornBtn = params._pBroadcast           --是否使用小喇叭
    self._pListViewNode = params._pListViewNode         --聊天界面的listView挂载点
    self._pChatTextBG = params._pChatTextBG             --私聊界面需要显示的底板
    self._pUseHornNumText = params._pBroadcastNum           --小喇叭的个数
    self._pTextFild = createEditBoxBySize(cc.size(640,50),TableConstants.ChatTextMaxWord.Value,0)
    self._pTextFieldNode:addChild(self._pTextFild)
    --self._pTextFieldNode:setOpacity(0)
    
    -- 初始化dialog的基础组件
    self:disposeCSB()
    --初始化button点击
    self:initFuncBts()
    --初始化界面的ui
    self:initChatUi()
    --初始化页面数据(第一次打开需要把缓存的数据一次性全部加载)
    self:initChatDate()
    --初始化界面的button显示信息
    self:setChatTypeBtnStateByType(pChatType,pRoleId)
    --更新某个界面的数据通过界面类型
    self:updateChatTypeDate(pChatType,pRoleId)
    --更新消息通知
    self:updateChatTypeNotice()
    --设置表情层
    self:setChatFacePanel()
    
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
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
            self:onExitChatDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

--初始化button点击
function ChatDialog:initFuncBts()
    --各个聊天频道按钮点击
    local onTouchChatTypeButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           local nTag = sender:getTag()
            if nTag == kChatType.kFamily and FamilyManager:getInstance()._bOwnFamily == false then  
              NoticeManager:getInstance():showSystemMessage("您还没有加入家族，无法使用家族频道")
              return 
           end

           --初始化button数据和view显示
           self:setChatTypeBtnStateByType(nTag)
           --初始化界面的数据问题
           self:updateChatTypeDate(nTag)
            --聊天界面的button上面提示新消息
           self:updateChatTypeNotice()
           --清空缓冲播放的语音按钮
           self:clearAutoPlayDate()
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    for i=1,table.getn(self._tChatTypeButton) do
        self._tChatTypeButton[i]:setTag(i)
        self._tChatTypeButton[i]:addTouchEventListener(onTouchChatTypeButton)
    end

    --设置按钮点击
    local onTouchButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            if nTag == 1000 then     --设置按钮
               DialogManager:getInstance():showDialog("ChatSetUpDialog")
            elseif nTag == 2000 then --发送按钮
                local bBool,nTime = ChatManager:getInstance():isCanSendMessage()
                local pText = self._pElementText._strContent
                if string.len(pText) == 0 then 
                    NoticeManager:getInstance():showSystemMessage("输入的内容不能为空")
                    return 
                end
                if bBool or self._bHasUseHorn  then  
                 self._pButtonCdTime = self._nButtonCd   
                 self:sendMessage(kContentType.kText,pText)
                else --正在cd
                    local pCurChatType = ChatManager:getInstance()._pSelectChatType
                    local pString = ChatManager:getInstance():getStringByChatType(pCurChatType)
                    if nTime ~= 0 then 
                        NoticeManager:getInstance():showSystemMessage("还需要"..nTime.."秒才能在"..pString.."发言")
                    end 
               end
            
            elseif nTag == 3000 then --表情按钮
               self._pFackBg:setVisible(true)
            elseif nTag == 4000 then --私聊内层返回按钮
               self:updateChatTypeDate(kChatType.kPrivate)
            elseif nTag == 5000 then --是否使用小喇叭
              local nNum =  BagCommonManager:getInstance():getItemNumById(TableConstants.HornID.Value)
              if self._bHasUseHorn == false then 
                 if nNum > 0 then 
                    NoticeManager:getInstance():showSystemMessage("已开启传音模式，每发送一条信息消耗一个小喇叭")
                 else
                    showConfirmDialog("您没有小喇叭，需要去商城购买吗？",function() 
                    DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop,kTagType.kTool})
                        end)   
                    return
                 end
              
              end

                --是否使用了小喇叭提示
                self._bHasUseHorn = not self._bHasUseHorn
                self._pHasUseHornNotice:setVisible(self._bHasUseHorn)
                self._pVoiceButton:setVisible(not self._bHasUseHorn)
             elseif eventType == ccui.TouchEventType.began then
          	    AudioManager:getInstance():playEffect("ButtonClick")
             end 
      
         end
    end

    --设置按钮
    self._pSetUpButton:setTag(1000)
    self._pSetUpButton:addTouchEventListener(onTouchButton)
    --发送按钮
    self._pSendButton:setTag(2000)
    self._pSendButton:addTouchEventListener(onTouchButton)
    --表情按钮
    self._pFaceButton:setTag(3000)
    self._pFaceButton:addTouchEventListener(onTouchButton)
     --私聊内层返回按钮
    self._pPrivateBackBt:setTag(4000)
    self._pPrivateBackBt:addTouchEventListener(onTouchButton)
    --是否使用小喇叭
    self._pHasUseHornBtn:setTag(5000)
    self._pHasUseHornBtn:addTouchEventListener(onTouchButton)
    
    
      local pBeginPosY = nil
      local onTouchVoiceButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then      -- 按下录音
             AudioManager:getInstance():playEffect("ButtonClick")
            if self._pButtonCdTime > 0 then
               NoticeManager:getInstance():showSystemMessage("点击太频繁，稍后重试")
               return
            end
                
            local bBool,nTime = ChatManager:getInstance():isCanSendMessage()
            if bBool then 
               pBeginPosY = sender:getTouchBeganPosition().y
               self._bVoiceBtnDown = true
               self:playVoiceAni() --播放动画
               mmo.HelpFunc:pressRecordVoice()
              self._pVoiceHistoryType = ChatManager:getInstance()._pSelectChatType
              self._pVoiceHistoryRoleId =  ChatManager:getInstance()._pSelectPrivateRoldId
                  
            else --正在cd
                local pCurChatType = ChatManager:getInstance()._pSelectChatType
                local pString = ChatManager:getInstance():getStringByChatType(pCurChatType)
                if nTime ~= 0 then 
                   NoticeManager:getInstance():showSystemMessage("还需要"..nTime.."秒才能在"..pString.."发言")
                end 
            end

         elseif eventType == ccui.TouchEventType.moved then
            local pPosY = sender:getTouchMovePosition().y
            if pPosY and pBeginPosY and pPosY - pBeginPosY > 150 and self._bVoiceBtnDown then
                self._bVoiceBtnDown = false --移动超过距离，取消语音
                self:stopVoiceAni() --停止动画
                mmo.HelpFunc:cancelSendVoice()
                NoticeManager:getInstance():showSystemMessage("录音已取消")
             end
         
        elseif eventType == ccui.TouchEventType.ended then     -- 抬起发送
      
            if self._bVoiceBtnDown == true then --如果还没有发送
               self._bVoiceBtnDown = false
               self:stopVoiceAni() --停止动画
           
                if self._nVoiceCdTime <= TableConstants.SpeechMin.Value then 
                    NoticeManager:getInstance():showSystemMessage("语音过短，发送失败！")
                    mmo.HelpFunc:cancelSendVoice()
                 else
                    mmo.HelpFunc:releaseSendVoice()
                end
                if self._pButtonCdTime == 0 then
                    self._pButtonCdTime = self._nButtonCd
                end
            end
          
     
        elseif eventType == ccui.TouchEventType.canceled then  --取消
            if self._bVoiceBtnDown == true then --如果还没有发送
                self._bVoiceBtnDown = false
                self:stopVoiceAni() --停止动画
                mmo.HelpFunc:releaseSendVoice()
            end
        end
    end
    
    self._pVoiceButton:addTouchEventListener(onTouchVoiceButton)        
       
end

--初始化界面ui
function ChatDialog:initChatUi()
    --先加载listView
    for i=1,6 do
        local listView = self:createOneListView()
        self._pListViewNode:addChild(listView)
        table.insert( self._tChatTypeListView,listView)
        if i == kChatType.kPrivate then --如果是饲料界面需要单独处理
            listView:setContentSize(cc.size(listView:getContentSize().width,listView:getContentSize().height-90))
            listView:setItemsMargin(0)
        end
    end
    
    
    --私聊搜索玩家
    local params = require("SearchPlayerParams"):create()
    local pSearchParams = params._pCCS
    self._pSearchButton = params._pSearch    --搜索按钮
    self._pSearchEditBoxNode = params._pTextFieldNode --输入查找玩家的昵称挂在
    self._pSearchEditBox= createEditBoxBySize(cc.size(440,30),TableConstants.NameMaxLenWord.Value)
    self._pSearchEditBoxNode:addChild(self._pSearchEditBox)

    self._pSearchNode:addChild(pSearchParams)
    
    local nMainLen = TableConstants.NameMinLen.Value
    local nMaxLen = TableConstants.NameMaxLen.Value
    
    local onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pString = self._pSearchEditBox:getText()
           for i=1, string.len(pString) do 
                if string.byte(pString, i) == 32 then
                    NoticeManager:getInstance():showSystemMessage("昵称中不能存在空格！")
                    return
                end
            end

            if strIsHaveMoji(pString) then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
            end   
            if string.find(pString,"□") then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
            end

            local nameLenth = string.len(pString)
            if nameLenth == 0 then
                NoticeManager:getInstance():showSystemMessage("昵称不能为空！")
            elseif nameLenth < nMainLen then
                NoticeManager:getInstance():showSystemMessage("昵称过短！")
            elseif nameLenth > nMaxLen then
                NoticeManager:getInstance():showSystemMessage("昵称过长！")
            else
                --查找好友
                FriendCGMessage:sendMessageQueryRoleInfoReq22006(pString)

            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
     end
        
    self._pSearchButton:addTouchEventListener(onTouchButton)

    local textFieldEvent = function(strEventName,pSender)
        local edit = pSender
        local strFmt 
        if strEventName == "began" then
            self._pTextFild:setText(self._pElementText._strContent) 
        elseif strEventName == "ended" then
            --release_print("2")
        elseif strEventName == "return" then
           -- release_print("3")
        elseif strEventName == "changed" then
            local pString = self._pTextFild:getText()
            if strIsHaveMoji(pString) then
                pString = unicodeToUtf8(pString)
            end  
            release_print(pString)
            self._pElementText:refresh(nil,nil,nil,nil,pString)  
            self._pTextFild:setText("") 
        end
    end

    self._pTextFild:registerScriptEditBoxHandler(textFieldEvent) 


    --下面输入框的富文本显示
    self._pElementText = require("ElementText"):create(nil,nil,nil,nil,nil,nil,nil,cc.size(10000,50))
    self._pElementText:setPosition(cc.p(0,0))
    self._pElementText:setAnchorPoint(cc.p(0,0.5))
    --self._pTextNode:addChild(self._pElementText)
    
    -- 初始化剪切矩形
    self._pClippingNode = cc.ClippingNode:create()
    self._pClippingNode:setInverted(false)
    self._pTextNode:addChild(self._pClippingNode)
    self._pClippingNode:addChild(self._pElementText)  
    
    
       
    local pStencil = cc.Sprite:createWithSpriteFrameName("ChatDialogRes/textfield.png")
    pStencil:setAnchorPoint(cc.p(0,0.5))
    pStencil:setScaleX(1.54)
    self._pClippingNode:setStencil(pStencil)
 
    --录音的动画
    self._pVoiceAniNode = cc.CSLoader:createNode("SpeekingEffect.csb")
    self._pVoiceAniNode:setPosition(mmo.VisibleRect:center())
    self._pVoiceAniNode:setVisible(false)
    self:addChild( self._pVoiceAniNode)
    --倒计时
    self._pdaojishi = self._pVoiceAniNode:getChildByName("Time")
    self._pdaojishi:setString(0)

    --设置传音的动画                                                                                                                                       SpeakNowEffect
    self._pHasUseHornNotice  = cc.CSLoader:createNode("SpeakNowEffect.csb")
    local pAction = cc.CSLoader:createTimeline("SpeakNowEffect.csb")
    self._pHasUseHornNotice:setPosition(cc.p(self._pHasUseHornBtn:getContentSize().width/2,self._pHasUseHornBtn:getContentSize().height/2))
    self._pHasUseHornBtn:addChild( self._pHasUseHornNotice)
    pAction:gotoFrameAndPlay(0,pAction:getDuration(), true)
    self._pHasUseHornNotice:runAction(pAction)
    self._pHasUseHornNotice:setVisible(false)
    self._pUseHornNumText:setString(BagCommonManager:getInstance():getItemNumById(TableConstants.HornID.Value))

end

--创建一个listView
function ChatDialog:createOneListView()
    local pX,pY = self._pListView:getPosition()
    local listView = self._pListView:clone()
    listView:setPosition(cc.p(pX,pY))
    return listView
end


--初始化界面数据
function ChatDialog:initChatDate()
    for i=1,6 do
     local pInfo = ChatManager:getInstance():selectChatMessageByType(i)
        local pListView = self._tChatTypeListView[i]
        self:setOneChatInfo(i,pInfo,pListView)
        
        if i== 3 then --如果是私聊则需要创建里面的目录
            for k,v in pairs(pInfo) do
                local listView = nil
                if self._tChatTypeListView[k] == nil then
                    listView = self:createOneListView() --创建里面的每个单人的listView
                    listView:setContentSize(cc.size(listView:getContentSize().width,listView:getContentSize().height-90))
                    
                    self._pListViewNode:addChild(listView)
                    self._tChatTypeListView[k] = listView
                else
                    listView = self._tChatTypeListView[k] 
                end
            
                self:setOneChatInfo(i,v,listView,k)
        	end
        end
    end

end

--设置界面聊天按钮的显示通过Type
function ChatDialog:setChatTypeBtnStateByType(nType,nRoleId)
    local pNomalImage = "ChatDialogRes/button_normal_029.png" 
    local pPressImage = "ChatDialogRes/ltjm10.png" 
    for k,v in pairs( self._tChatTypeButton) do
        v:loadTextures(pNomalImage,pPressImage,nil,ccui.TextureResType.plistType)
       
    end
    self._tChatTypeButton[nType]:loadTextures(pPressImage,pPressImage,nil,ccui.TextureResType.plistType)
    
    --listView隐藏或者显示
    local pIndex = nType
    self._pPrivateBg:setVisible(false)
    if nRoleId ~= nil then
    	pIndex = nRoleId
        self._pPrivateBg:setVisible(true)
    end
     for k,v in pairs( self._tChatTypeListView) do
        self._tChatTypeListView[k]:setVisible(false)
     end
    if self._tChatTypeListView[pIndex] then
       self._tChatTypeListView[pIndex]:setVisible(true)    
    end
 
end


--聊天信息回复
function ChatDialog:updaeChatInfo(event)
    if ChatManager:getInstance()._bChatOpenView then
        --release_print("Message Has Init")
        --聊天界面的button上面提示新消息
        self:updateChatTypeNotice()
        local pChatType = ChatManager:getInstance()._pSelectChatType 
        local pRoleId = ChatManager:getInstance()._pSelectPrivateRoldId 
        self:updateChatTypeDate(pChatType,pRoleId)
        --release_print("Message Load Successful")
        if self._bHasAutoPlay then
            self._bHasAutoPlay = false
            self:playAutoVoice()
        end

    end
 
end


--设置黑名单
function ChatDialog:setBlackList(event)
	
end

--查找玩家回复
function ChatDialog:searchRoleInfo(event)
    if event[1].roleId == RolesManager:getInstance()._pMainRoleInfo.roleId then  --代表查的是自己
       NoticeManager:getInstance():showSystemMessage("您不能和自己聊天！")
     return 
    end
    self._pSearchEditBox:setString("")
    ChatManager:getInstance():setDesInfoByRoleInfo(event[1])
    self:JumpPrivateDesRole(event[1].roleId)
end


--更新喇叭数量
function ChatDialog:updateBagItemList(event )
   self._pUseHornNumText:setString(BagCommonManager:getInstance():getItemNumById(TableConstants.HornID.Value))
end


-- 隐藏 （带动画）
function ChatDialog:hiddenWithAni()
  --如果当前语音动画正在播放，但是因为外界的原因强制关闭了dialog，这时候先关闭动画
  self:stopVoiceAni()  
  local sessionId = LayerManager:getInstance():getCurSenceLayerSessionId()
    if sessionId== kSession.kWorld then
        mmo.HelpFunc:setMaxTouchesNum(1)
    elseif sessionId== kSession.kBattle then
        mmo.HelpFunc:setMaxTouchesNum(2)
    end

    ChatManager:getInstance()._bChatOpenView = false
    self._pTouchListener:setEnabled(false)
    self._pTouchListener:setSwallowTouches(false)

    self:stopAllActions()
    local closeOver = function()
        self:setVisible(false)
        self:getGameScene():checkMaskBg()
    end

    local action = cc.Sequence:create(
        cc.EaseSineInOut:create(cc.ScaleTo:create(0.2,0,0)),
        cc.CallFunc:create(closeOver))
    --[[
    local action = cc.Sequence:create(
    cc.DelayTime:create(0.1),
    cc.CallFunc:create(closeOver))  
    ]]  
    self:runAction(action) 
end


--界面做了缓存再次打开的需要进行的操作
function ChatDialog:updateCacheWithData(args)
    ChatManager:getInstance()._bChatOpenView = true

    local pChatType = ChatManager:getInstance()._pSelectChatType 
    local pRoleId = ChatManager:getInstance()._pSelectPrivateRoldId 
    
    if args ~= nil then
        pChatType = args[1]
        pRoleId = args[2]
    end
    
    --初始化button数据和view显示
    self:setChatTypeBtnStateByType(pChatType,pRoleId)
       --初始化界面的数据问题
    self:updateChatTypeDate(pChatType,pRoleId)
       --聊天界面的button上面提示新消息
    self:updateChatTypeNotice()
    mmo.HelpFunc:setMaxTouchesNum(1)
             
    
end

--聊天界面的button上面提示新消息
function ChatDialog:updateChatTypeNotice()
    local pState = ChatManager:getInstance()._tNewMessage
    for k,v in pairs(self._tChatNotice) do
        v:setVisible(pState[k])
	end
end

--聊天的表情框
function ChatDialog:setChatFacePanel(bBool)
	if bBool == nil then 
       bBool = false
	end
    self._pFackBg:setVisible(bBool)
    
    --关闭按钮
    local  onTouchCloseButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
          self._pFackBg:setVisible(false)
        elseif eventType == ccui.TouchEventType.began then
          AudioManager:getInstance():playEffect("ButtonClick")
        end
     end
        
    self._pFackClose:addTouchEventListener(onTouchCloseButton)
     
    local nDateNum = TableConstants.ExpressionNum.Value --数据是90个
    local nHeight = 30
    local nRow  = math.ceil(nDateNum/10)
    local nLeftAndReightDis = 35
    local nUpAndDownDis = 35
    local nScale = 1.33 
    local nTopInter = 15
    local nBottomInter = 15
    local nViewWidth = self._pFackScrollView:getContentSize().width
    local nViewHeight = self._pFackScrollView:getContentSize().height
    local nInnerHeight = nRow*(nHeight+nUpAndDownDis)-nUpAndDownDis+nTopInter+nBottomInter
    nInnerHeight = nInnerHeight > nViewHeight and nInnerHeight or nViewHeight
    self._pFackScrollView:setInnerContainerSize(cc.size(nViewWidth,nInnerHeight))
       
    --图片的点击  
    local onTouchImage = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
          local nTag = sender:getTag()
          local pStr = nTag<10 and "{^0"..nTag.."}" or "{^"..nTag.."}"
          print(pStr)
          local pTempText =self._pElementText._strContent..pStr
          
          if string.len(pTempText) >100 then
                NoticeManager:getInstance():showSystemMessage("写入失败，超过最大上限")
          	 return
          end
            print("写入的字符串是"..pTempText)
            --self._pTextFild:setText(pTempText)
           self._pElementText:refresh(nil,nil,nil,nil,pTempText)
         
          self._pFackBg:setVisible(false)
        elseif eventType == ccui.TouchEventType.began then
          AudioManager:getInstance():playEffect("ButtonClick")
        end
     end
      
      
    for i=1,nDateNum do
        local pFace = nil
        if i<10 then 
           pFace = ccui.ImageView:create("emo/0"..i..".png",ccui.TextureResType.plistType)
         else
           pFace = ccui.ImageView:create("emo/"..i..".png",ccui.TextureResType.plistType)
        end
           pFace:setTag(i)
           pFace:setAnchorPoint(cc.p(0,0))
           pFace:setScale(nScale)
           pFace:addTouchEventListener(onTouchImage)
           local t1,t2 = math.modf((i-1)/10) 
           t2 = t2*10
           pFace:setTouchEnabled(true)
           pFace:setPosition(t2*(nHeight+nLeftAndReightDis)+nLeftAndReightDis,nInnerHeight-(nHeight+nUpAndDownDis)*t1-nHeight-nTopInter)  
           self._pFackScrollView:addChild(pFace)
     end 
      
end


--更新界面通过界面类型
function ChatDialog:updateChatTypeDate(nType,nRoleId)
  local pChatInfo = ChatManager:getInstance():getUnReadInfoByType(nType,nRoleId)
   ChatManager:getInstance():setSelectChatType(nType,nRoleId)
    self:setChatTypeBtnStateByType(nType,nRoleId)
    local pListView = nil
   if nRoleId then 
      pListView = self._tChatTypeListView[nRoleId]
      if pListView == nil then
         pListView = self:createOneListView() --创建里面的每个单人的listView
         pListView:setContentSize(cc.size(pListView:getContentSize().width,pListView:getContentSize().height-90))
         self._pListViewNode:addChild(pListView)
         self._tChatTypeListView[nRoleId] = pListView
      end   
      
   else
      pListView = self._tChatTypeListView[nType]
   end

    self:setOneChatInfo(nType,pChatInfo,pListView,nRoleId)
    local itemSize = table.getn(pListView:getItems())
    if itemSize > TableConstants.ChatHistoryMax.Value then -- 标示已经满了
        for i=1,itemSize-TableConstants.ChatHistoryMax.Value do
        pListView:removeItem(0)
    end

    end
end

--创建单个的lisetViewitem
function ChatDialog:createListViewItem(pInfo)
   local pRoleInfo = RolesManager:getInstance()._pMainRoleInfo
   local pChatView = nil
   local pWidth = 660
   if pInfo.contentType == kContentType.kText then --普通文字
        local pContext = ""
        if pInfo.roleId == 0 then --标示是系统封装的直接是string
            pContext = pInfo.content
        else
            pContext = StrToLua(pInfo.content)[1]
       end
       
        if strIsHaveMoji(pContext) then
            pContext = unicodeToUtf8(pContext)
        end   
       
        pContext = pContext.."   "..self:timeToString(pInfo.timestamp)
        local pContentTextColor = nil
        if pInfo.useHorn == true then -- 如果使用了喇叭要用字体要用橙色
        	pContentTextColor = cOrange
        end
       
    if pRoleInfo.roleId == pInfo.roleId then --说明是我说的话
            pChatView = require("ElementText"):create("[Vip"..pInfo.vipLv.."]",nil,pRoleInfo.roleName..":",cOrange,pContext,pContentTextColor,nil,cc.size(pWidth,1))
    elseif pInfo.roleId == 0 then --说明是系统消息
       pChatView = require("ElementText"):create(nil,nil,"系统消息:",nil,pContext,cRed,nil,cc.size(pWidth,1))  
    else --其他玩家消息
       pChatView = require("ElementText"):create("[Vip"..pInfo.vipLv.."]",nil,pInfo.name..":",nil,pContext,pContentTextColor,nil,cc.size(pWidth,1))
       pChatView:setTouchEnabled(true)
    end
 
   elseif pInfo.contentType == kContentType.kVoice then --语音类型
      
      local pVoice = require("VoiceView"):create(pInfo) --语音数据
      if pRoleInfo.roleId == pInfo.roleId then --说明是我说的话
            pChatView = require("ElementText"):create("[Vip"..pInfo.vipLv.."]",nil,pRoleInfo.roleName,cOrange,nil,nil,nil,cc.size(pWidth,1))
            pVoice:setVoiceHasPlay() --我说的话标示已读
      else
           pChatView = require("ElementText"):create("[Vip"..pInfo.vipLv.."]",nil,pInfo.name,nil,nil,nil,nil,cc.size(pWidth,1))  
           pChatView:setTouchEnabled(true)
      end
         self:setVoiceButtonState(pVoice,pInfo)
         self._tAutoPlayBtn[StrToLua(pInfo.content)[1]] = pVoice
         pVoice:setPosition(pChatView:getHeaderAndVipLength()+pVoice:getContentSize().width/2,pChatView:getHeight()/2)
         pChatView:addChild(pVoice)

   end
   
    local function textTouchCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            local pInfo = ChatManager:getInstance()._tdesRoleInfo[nTag]
            if pInfo == nil then
                print("本地没有这个人的信息")
            	return 
            end
            DialogManager:getInstance():showDialog("ChatPlayerDialog",{pInfo})
        end
    end
    print("View Width ... "..pChatView:getWidth())
    pChatView:setTag(pInfo.roleId)
    pChatView:setPosition(cc.p(0,0))
    pChatView:setAnchorPoint(cc.p(0,1.0))
    pChatView:addTouchEventListener(textTouchCallBack)
    return pChatView
end

--创建单个的item (ptempDate 临时数据目前只用来存对方的roleId来确定是私聊的那个界面)
function ChatDialog:setOneChatInfo(pType,pInfo,pListView,ptempDate)
    if pType == kChatType.kPrivate then --私聊特殊处理
      if ptempDate == nil then  --表示在私聊界面的第一目录
          for k,v in pairs(pInfo) do
              local nRoleId = k
               local pdesInfo = ChatManager:getInstance()._tdesRoleInfo[nRoleId]
               self:setPrivateChatItemByInfo(pdesInfo,pListView)
             
           end  
      
      else--表示进去了第二目录
        for k,v in pairs(pInfo) do
            local pItem = self:createListViewItem(v)
            pListView:pushBackCustomItem(pItem)  
        end
        self:setPrivateRoleName(ptempDate)
      end
    
    else
        local pSize = table.getn(pInfo)  
        for i=1,pSize do
            local pItem = self:createListViewItem(pInfo[i])
            pListView:pushBackCustomItem(pItem)    
        end
    end
    --每次添加成功item需要设置下位移
    self:setListViewParent()
    --设置每个界面的显示问题
    self:setUiVisibleByType(pType,ptempDate)
end

--手写私聊界面的item
function ChatDialog:createPrievateItem()

    local pSize = cc.size(736,120)
    --背景框
    local pBg = ccui.ImageView:create("PrivateChatRes/jlxt6.png",ccui.TextureResType.plistType)
    pBg:setTouchEnabled(true)
    pBg:setCapInsets(cc.rect(20,20,20,20))
    pBg:setName("Bg")
    pBg:setContentSize(pSize)
    pBg:setScale9Enabled(true)
    
    --头像背景框  
    local pIconBg = cc.Sprite:createWithSpriteFrameName("PrivateChatRes/HeadIconBg.png")
    pIconBg:setPosition(cc.p(80,pSize.height/2))
    pIconBg:setName("IconBg")
    pIconBg:setScale(0.7)
    pBg:addChild(pIconBg)
    
    --头像
    local pIcon = ccui.ImageView:create()
    pIcon:setPosition(cc.p(pIconBg:getContentSize().width/2-15,pIconBg:getContentSize().height/2+25.5))
    pIcon:setName("RoleIcon")
    pIconBg:addChild(pIcon)
    
    --玩家昵称
    local pName = cc.Label:createWithTTF("", strCommonFontName, 22)
    pName:setColor(cWhite)
    pName:setPosition(cc.p(152,pSize.height/2))
    pName:setName("RoleName")
    pName:setAnchorPoint(0,0.5)
    pBg:addChild(pName)
    
    --X条
    local pNotRead = cc.Label:createWithTTF("1条", strCommonFontName, 25)
    pNotRead:setColor(cRed)
    pNotRead:setPosition(cc.p(417,pSize.height/2))
    pNotRead:setName("NotRead")
    pNotRead:setAnchorPoint(1,0.5)
    pBg:addChild(pNotRead)
    
    --未读信息（lable）
    local pText = cc.Label:createWithTTF("未读信息", strCommonFontName, 22)
    pText:setPosition(cc.p(417,pSize.height/2))
    pText:setColor(cWhite)
    pText:setName("pText")
    pText:setAnchorPoint(0,0.5)
    pBg:addChild(pText)
    
    --时间戳
    local pTime = cc.Label:createWithTTF("14:30", strCommonFontName, 22)
    pTime:setPosition(cc.p(564,pSize.height/2))
    pTime:setName("Time")
    pBg:addChild(pTime)
    
    
    --删除历史
    local pDeleteButton = ccui.Button:create("PrivateChatRes/button4_normal.png","PrivateChatRes/button4_press.png",nil,ccui.TextureResType.plistType)
    pDeleteButton:setTouchEnabled(true)
    pDeleteButton:setTitleText("删除")
    pDeleteButton:setTitleFontName(strCommonFontName)
    pDeleteButton:setTitleFontSize(22.0)
    pDeleteButton:setName("DeleteButton")
    pDeleteButton:setPosition(660,pSize.height/2)
    pBg:addChild(pDeleteButton)
    return pBg
end


--创建私聊第一目录(对手的个人信息，对手的聊天信息，当前的listView)
function ChatDialog:setPrivateChatItemByInfo(pDesInfo,pListView)
    local pItem = nil
    if self._tPrivateListItem[pDesInfo.desRoleId] == nil then
       self._tPrivateListItem[pDesInfo.desRoleId] = self:createPrievateItem()
        pListView:insertCustomItem(self._tPrivateListItem[pDesInfo.desRoleId],0)
     end
    pItem = self._tPrivateListItem[pDesInfo.desRoleId]
        if pItem then
            --头像背景图
            local pHeadIconBg = pItem:getChildByName("IconBg")
            --头像本身
            local pHeadIcon = pHeadIconBg :getChildByName("RoleIcon")
            --玩家昵称
            local pName = pItem:getChildByName("RoleName")   
           --私聊最后发言时间
            local pLastTime = pItem:getChildByName("Time")    
           --删除与之历史记录
            local pDeleteButton = pItem:getChildByName("DeleteButton")    
            --未读条目数字
            local pUnreadNum = pItem:getChildByName("NotRead")  
            --未读信息(提示信息)
            local pText = pItem:getChildByName("pText")  
            --设置Tag
            pItem:setTag(pDesInfo.desRoleId)
            pDeleteButton:setTag(pDesInfo.desRoleId)
            --人物头像   
            pHeadIcon:loadTexture(pDesInfo.roleIcon,ccui.TextureResType.plistType)
            --人物名字  
            pName:setString(pDesInfo.name)  
            local nNotReadNum,pFinalTime = ChatManager:getInstance():getUnReadNumByType(pDesInfo.desRoleId)
            if nNotReadNum ~= nil and pFinalTime ~= nil then
                pUnreadNum:setString(nNotReadNum.."条")
            pLastTime:setString(self:timeToString(pFinalTime)) 
                if nNotReadNum == 0 then --没有未读信息了
                pUnreadNum:setVisible(false)
                pText:setVisible(false)
                else
                pUnreadNum:setVisible(true)
                pText:setVisible(true)
                end
                 	
            end 
             
           --删除消息的button  
          local onTouchDelButton = function (sender, eventType)
               if eventType == ccui.TouchEventType.ended then
                   local nTag = sender:getTag()
                   
                   local pListView = self._tChatTypeListView[nTag]      --聊天界面的每个界面的listview
                    if pListView then --删除这个消息
                       pListView:removeFromParent(true)
                       self._tChatTypeListView[nTag] = nil
                       ChatManager:getInstance():deletePrivateInfoById(nTag)
                   end
                    --删除私聊第一目录的item
                    local pIndex = self._tChatTypeListView[kChatType.kPrivate]:getIndex(self._tPrivateListItem[nTag])
                    self._tChatTypeListView[kChatType.kPrivate]:removeItem(pIndex)
                    self._tPrivateListItem[nTag] = nil
                    --更新提示信息
                    self:updateChatTypeNotice()
               elseif eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")          
               end
           end
       
           pDeleteButton:addTouchEventListener(onTouchDelButton)
           
           
           --点击某个消息框的背景
            local onTouchItemBg = function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local nTag = sender:getTag()
                    self:JumpPrivateDesRole(nTag)
                elseif eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")
                end
            end
            pItem:addTouchEventListener(onTouchItemBg)
        end  
end

--设置跳转到某个人的私聊
function ChatDialog:JumpPrivateDesRole(nRoleId)
    if nRoleId == nil then
       return
    end

    local listView = nil
    if self._tChatTypeListView[nRoleId] == nil then
        listView = self:createOneListView() --创建里面的每个单人的listView
        listView:setContentSize(cc.size(listView:getContentSize().width,listView:getContentSize().height-90))
        self._pListViewNode:addChild(listView)
        self._tChatTypeListView[nRoleId] = listView
    else
        listView = self._tChatTypeListView[nRoleId] 
    end
    self:updateChatTypeDate(kChatType.kPrivate,nRoleId)
    self:updateChatTypeNotice()
    --self:updatePrivateDate(nRoleId)
     
end

--点击私聊后刷新私聊第一目录中的数据信息
function ChatDialog:updatePrivateDate(nRoleId)
    local pListView = self._tPrivateListItem[nRoleId]
    local pdesInfo = ChatManager:getInstance()._tdesRoleInfo[nRoleId]
    self:setPrivateChatItemByInfo(pdesInfo,pListView)
end

--设置私聊上面的个人信息
function ChatDialog:setPrivateRoleName(nRoleId)
 local pRoleInfo =ChatManager:getInstance()._tdesRoleInfo[nRoleId]
 --私聊内层昵称 ：当前正在和玩家 “xxxxx” 聊天。
  if self._pPrivateName == nil then --如果没有就创建
        self._pPrivateName = require("ElementText"):create()
        self._pPrivateName:setPosition(cc.p(0,0))
        self._pPrivateName:setAnchorPoint(cc.p(0,1))
        self._pPrivateNameNode:addChild(self._pPrivateName)
 end
    self._pPrivateName:refresh("当前正在和玩家“ ",cWhite,pRoleInfo.name,cRed," ”聊天",cWhite,22,cc.size(500,22))
  --self._pPrivateName:setString(pRoleInfo.name)  

	
end

--设置listView的位移
function ChatDialog:setListViewParent()
    local actionCallBack = function()
        for k,v in pairs(self._tChatTypeListView ) do
            if table.getn(v:getItems()) > 2 then  --ios跟安卓listview跳转不一样，所以当有2个item的时候跳转
                if k == 3 then
                    v:scrollToTop(0.1,false)
                else
                    v:scrollToBottom(0.1,false)
                end
                    v:requestRefreshView()
            end

        end
    end

   self._pCCS:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(actionCallBack)))
	
end

--设置界面的状态(在那几个界面按钮显示和隐藏的问题)
function ChatDialog:setUiVisibleByType(nType,nRoleId)
    self._pTeamNotice:setVisible(false) --只有在组队跟系统界面显示
    self._pTextBg:setVisible(true)      --输入框所在的背景
    self._pSearchNode:setVisible(false) --私聊搜索玩家
    self._pHasUseHornBtn:setVisible(false)--喇叭按钮默认不显示(全服频道显示)
    self._pVoiceButton:setVisible(true)   --语音按钮默认显示
    self._pChatTextBG:setVisible(true)    --聊天界面的一个背景（私聊第一界面隐藏）

	if nType == kChatType.kPrivate then
    	if nRoleId == nil then --私聊的第一目录
           self._pTextBg:setVisible(false)
           self._pSearchNode:setVisible(true)
            self._pChatTextBG:setVisible(false) 
    	else --私聊的第一二目录
    	
    	end
    	
	elseif nType == kChatType.kAddTeam then 
        self._pTextBg:setVisible(false)      --输入框所在的背景
        self._pTeamNotice:setVisible(true)
    elseif nType == kChatType.kSystem then 
        self._pTextBg:setVisible(false)      --输入框所在的背景
    elseif nType == kChatType.kAll then 
        self._pHasUseHornBtn:setVisible(true)
        self._pVoiceButton:setVisible(not self._bHasUseHorn)   
    else --其他界面
      
	
	end
	
end

--发送聊天信息(聊天类型，聊天内容，语音聊天长度)
function ChatDialog:sendMessage(nContentType,pText,nLength)
	
    -- 对方id
    local pdesRoleId = ChatManager:getInstance()._pSelectPrivateRoldId
    if pdesRoleId == nil then
        pdesRoleId = 0
    end
    local bUesHorn = false
    if ChatManager:getInstance()._pSelectChatType == kChatType.kAll and nContentType ~= kContentType.kVoice then --如果是世界频道就使用喇叭。其他频道不用喇叭
       bUesHorn = self._bHasUseHorn 
       if bUesHorn == true then
            local nNum =  BagCommonManager:getInstance():getItemNumById(TableConstants.HornID.Value)
            if nNum <= 0 then 
                showConfirmDialog("您没有小喇叭，需要去商城购买吗？",function() 
                    DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop,kTagType.kTool})
                    end)  
                return
            end
       
       end
       
    end
    local pHornIcon = ""
    if bUesHorn then
        pHornIcon = "{^00}"
    end
    --聊天频道
    local pChatType = ChatManager:getInstance()._pSelectChatType
    --内容类型
    local pContentType = nContentType
    if pContentType == kContentType.kVoice  then
        pChatType = self._pVoiceHistoryType
        pdesRoleId = self._pVoiceHistoryRoleId 
         if pdesRoleId == nil then   --如果是语音需要特殊处理，类型跟对方的id都需要用缓存的
            pdesRoleId = 0
         end

        pText = "{'"..pText.."','"..nLength.."'}"
    else
        pText = "{'"..pHornIcon..pText.."'}"
        
    end
    
    local args = {pdesRoleId,bUesHorn,pChatType,pContentType,pText}
    ChatCGMessage:sendMessageChat21302(args)
    --把聊天的框清空数据
    self._pTextFild:setText("")
    self._pElementText:refresh()
    self._pElementText._strContent = ""
    --release_print("Message is Send")
end


-- 退出函数
function ChatDialog:onExitChatDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    ChatManager:getInstance()._bChatOpenView = false
    ChatManager:getInstance()._pSelectChatType = kChatType.kAll
    ResPlistManager:getInstance():removeSpriteFrames("ChatDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("PrivateChat.plist")
    ResPlistManager:getInstance():removeSpriteFrames("SearchPlayer.plist")
    ResPlistManager:getInstance():removeSpriteFrames("SpeekingEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("SpeakNowEffect.plist")
    
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function ChatDialog:update(dt)
    -- 放到循环中进行监控，把得到的语音id和时长发给服务器
    local id = mmo.DataHelper:getLastVoiceId()
    if id ~= "" then
        release_print("hahaha:"..id)
    end

    local duration = mmo.DataHelper:getLastVoiceDuration()
    if duration ~= 0 then
        release_print("bababa:"..duration)
        self:sendMessage(kContentType.kVoice,id,duration)
    end  
    if self._pButtonCdTime > 0 then
      self._pButtonCdTime =  self._pButtonCdTime - dt
      if self._pButtonCdTime <= 0 then
      	 self._pButtonCdTime = 0
      end
     end

     local sendFaild = mmo.DataHelper:getSendFaildCallBack()
     if sendFaild == true then
         NoticeManager:getInstance():showSystemMessage("发送失败")
     end
     
    return
end

--播放录音动画
function ChatDialog:playVoiceAni()
    self._pVoiceAniNode:setVisible(true)
    self._pdaojishi:setString(0)
    local pVoiceiAction = cc.CSLoader:createTimeline("SpeekingEffect.csb")
    pVoiceiAction:gotoFrameAndPlay(0,pVoiceiAction:getDuration(), true)
    self._pVoiceAniNode:stopAllActions()
    self._pVoiceAniNode:runAction(pVoiceiAction)
    
   local nMaxTime = TableConstants.SpeechMax.Value
   local timeCallBack = function(time,id)
   if  self._pdaojishi then 
       self._pdaojishi:setString(nMaxTime -time) 
       self._nVoiceCdTime = nMaxTime -time
   end
       if time == 0 then
          self:stopVoiceAni() --停止动画
        end
    end
    
    CDManager:getInstance():insertCD({cdType.kChatVoiceTime,nMaxTime,timeCallBack})

end

--停止播放动画
function ChatDialog:stopVoiceAni()
   self._pVoiceAniNode:setVisible(false)
   self._pVoiceAniNode:stopAllActions()
   CDManager:getInstance():deleteOneCdByKey(cdType.kChatVoiceTime)
end


--播放自动语音
function ChatDialog:playAutoVoice()
    local pInfo = ChatManager:getInstance()._tAutoPlayId
     if table.getn(pInfo) ~= 0 then 
        local pCallBack = function()
           table.remove(pInfo,1)
           self:playAutoVoice()
        end
    
        self._tAutoPlayBtn[pInfo[1]]:playVoid(pCallBack)
        
     else
      self._bHasAutoPlay = true
     end

end

--清空缓存播放的语音按钮
function ChatDialog:clearAutoPlayDate()
    ChatManager:getInstance()._tAutoPlayId = {}
    self._tAutoPlayBtn = {}   
end

--设置语音的状态（战斗中组队自动播放的语音需要手动设置为已读）
function ChatDialog:setVoiceButtonState(pVoiceBtn,pInfo)
  if ChatManager:getInstance()._pSelectChatType == kChatType.kTeam then  --如果是组队
        local pHisId = ChatManager:getInstance()._tAutoPlayTeamId
        for k,v in pairs(pHisId) do
            if v ==  StrToLua(pInfo.content)[1] then --如果id一样说明在战斗里面已经播放过这条语音
     	  	   pVoiceBtn:setVoiceHasPlay(true)
     	  	 break 
     	   end
        end

  end
     
end

--时间转化函数
function ChatDialog:timeToString(pTime)
 return  "("..string.sub(os.date("%X",pTime),0,5)..")"
end


-- 显示结束时的回调
function ChatDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function ChatDialog:doWhenCloseOver()
    return
end

return ChatDialog
