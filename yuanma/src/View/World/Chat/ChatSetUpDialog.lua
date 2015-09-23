--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChatSetUpDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/6/29
-- descrip:   聊天的设置界面
--===================================================
local ChatSetUpDialog = class("ChatSetUpDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function ChatSetUpDialog:ctor()
    self._strName = "ChatSetUpDialog"        -- 层名称

    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._tCheckBox ={}
    self._pBlockNum = nil        --屏蔽人数显示 （x/50)
    self._pListView = nil        --下方列表
    self._pBlockBg = nil         --屏蔽玩家的背景
    self._pRemoveIndex = nil     --删除的黑名单下表
    self._tAutoPlayButton = {}   --自动播放语音的按钮
    self._tAutoPlayNotice = {}   --自动播放语音的提示

end

-- 创建函数
function ChatSetUpDialog:create()
    local dialog = ChatSetUpDialog.new()
    dialog:dispose()
    return dialog
end

-- 处理函数
function ChatSetUpDialog:dispose()
    ResPlistManager:getInstance():addSpriteFrames("ChatOption.plist")
    NetRespManager:getInstance():addEventListener(kNetCmd.kSetBlackList, handler(self,self.updaeBlackList))
    local params = require("ChatOptionParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._tCheckBox = {params._pCheckBox1,params._pCheckBox2,params._pCheckBox3}
    self._pBlockNum = params._pBlockNum         --屏蔽人数显示 （x/50)
    self._pListView = params._pListView         --下方列表
    self._pBlockBg = params._pBlockBg --屏蔽玩家的背景
    self._pBlockBg:setVisible(false)
    self._tAutoPlayButton = {params._pCheckBox1,params._pCheckBox2,params._pCheckBox3}
    self._tAutoPlayNotice = {params._pPick1,params._pPick2,params._pPick3}
    -- 初始化dialog的基础组件
    self:disposeCSB()
    --初始化自动化播放问题
    self:initAutoPlay()
    self:updateBlackRole()
   
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
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
            self:onExitChatSetUpDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end

function ChatSetUpDialog:updateBlackRole()
    local pBlackInfo = ChatManager:getInstance()._tBlacklist
     local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            self._pRemoveIndex = nTag
            ChatCGMessage:sendMessageSetBlackList21306(pBlackInfo[nTag].roleId) 
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end


    for k,v in pairs(pBlackInfo) do
        local pBlockBg = nil      --屏蔽玩家的背景
        local pHeadIcon = nil     --头像本身
        local pBlockName = nil    --黑名单名字
        local pDelButton = nil    --黑名单按钮
        if k==1 then
           pBlockBg = self._pBlockBg
           pBlockBg:setVisible(true)
        else
            pBlockBg = self._pBlockBg:clone()
           self._pListView:pushBackCustomItem(pBlockBg)
        end                                         
        local pHeadIconBg = pBlockBg:getChildByName("HeadIconBg") 
        pHeadIcon =  pHeadIconBg:getChildByName("HeadIcon")
        pBlockName = pBlockBg:getChildByName("BlockName")
        pDelButton = pBlockBg:getChildByName("DelButton")
        
        
        pHeadIcon:loadTexture(kRoleIcons[v.roleCareer],ccui.TextureResType.plistType)
        pBlockName:setString(v.name)	
        
        pDelButton:setTag(k)	
        pDelButton:addTouchEventListener(onTouchButton)

    end
    
    local nNum = table.getn(ChatManager:getInstance()._tBlacklist)
    self._pBlockNum:setString("("..nNum.."/"..TableConstants.BlacklistMax.Value..")")
    

end

--初始化自动化播放问题
function ChatSetUpDialog:initAutoPlay()
    --自动播放世界语音
    local autoPlayWoldVoice = cc.UserDefault:getInstance():getIntegerForKey("autoPlayWoldVoice")
    --自动播放家族
    local autoPlayFamilyVoice = cc.UserDefault:getInstance():getIntegerForKey("autoPlayFamilyVoice")
    --自动播放组队语音
    local autoPlayTeamVoice = cc.UserDefault:getInstance():getIntegerForKey("autoPlayTeamVoice")
    
    local pKay = {"autoPlayWoldVoice","autoPlayFamilyVoice","autoPlayTeamVoice"}
    
    
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            ChatManager:getInstance():setChatAutoPlayVoice(nTag)
            local pVisible =  ChatManager:getInstance()._tAutoPlayVoice[nTag]
            self._tAutoPlayNotice[nTag]:setVisible(pVisible)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    
    for i=1,3 do
        self._tAutoPlayButton[i]:setTag(i)
        self._tAutoPlayButton[i]:addTouchEventListener(onTouchButton)
        local pVisible =  ChatManager:getInstance()._tAutoPlayVoice[i]
        self._tAutoPlayNotice[i]:setVisible(pVisible)
    end  
end


--设置黑名单
function ChatSetUpDialog:updaeBlackList(event)
    --删除
    self._pListView:removeItem(self._pRemoveIndex-1)
    local nNum = table.getn(ChatManager:getInstance()._tBlacklist)
    self._pBlockNum:setString("("..nNum.."/"..TableConstants.BlacklistMax.Value..")")
end

-- 退出函数
function ChatSetUpDialog:onExitChatSetUpDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("ChatOption.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function ChatSetUpDialog:update(dt)
    return
end

-- 显示结束时的回调
function ChatSetUpDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function ChatSetUpDialog:doWhenCloseOver()
    return
end

return ChatSetUpDialog
