--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  VoiceView.lua
-- author:    yuanjiashun
-- created:   2015/7/3
-- descrip:   语音播放按钮
--===================================================

local VoiceView = class("VoiceView",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function VoiceView:ctor()
    self._strName = "VoiceView"             -- 层名称
    self._pVoidBtn = nil                    --语音
    self._pLableLength = nil                 --时长
    self._pVoidNotice = nil                 --语音上面的没有播放的提示
    self._pTimePoke = nil                   --时间戳
    self._pHasListen = false                --是否听过此条语音
    self._pVoiceDate = nil                  --语音数据
    self._pVoicePlayId = nil                --第三方播放id
    self._pVoicePlayLength = nil            --语音的时间长度
    self._pCurPlayId = nil
  
end 

-- 创建函数
function VoiceView:create(args)
    local layer = VoiceView.new()
    layer:dispose(args)
    return layer
end

-- 处理函数(语音id)
function VoiceView:dispose(args) 
    ResPlistManager:getInstance():addSpriteFrames("SpeekPlayEffect.plist")
    NetRespManager:getInstance():addEventListener(kNetCmd.kStopVoice, handler(self,self.stopVoicePlayAni))
    local  onTouchButton = function (sender, eventType)
           if eventType == ccui.TouchEventType.ended then 
              self:playVoid()
           elseif eventType == ccui.TouchEventType.began then
              AudioManager:getInstance():playEffect("ButtonClick")
           end
            
    end
    self._pVoiceDate = args
    --初始化数据
    self:initVoiceDate()
    local pMainLength = 120 --最小的语音超度
    local pHeight = 30      --语音的高度
    local pLength = self._pVoicePlayLength       --语音的长度（实际值）
    local pSize = cc.size(pMainLength+pLength*7,pHeight)
    self:ignoreContentAdaptWithSize(false)
    self:setContentSize(pSize)

    --语音
    self._pVoidBtn = ccui.Button:create("ChatDialogRes/voice.png","ChatDialogRes/voice.png",nil,ccui.TextureResType.plistType)
    self._pVoidBtn:setTouchEnabled(true)
    self._pVoidBtn:setScale9Enabled(true)
    self._pVoidBtn:setAnchorPoint(cc.p(0,1.0))
    self._pVoidBtn:setContentSize(pSize)
    self._pVoidBtn:setPosition(0,pSize.height)
    self._pVoidBtn:setCapInsets(cc.rect(10, 2, 25,10))
    self:addChild(self._pVoidBtn)
    self._pVoidBtn:addTouchEventListener(onTouchButton)
    


    --动画
    self._pVoiceAniNode = cc.CSLoader:createNode("SpeekPlayEffect.csb")
    self._pVoiceAniNode:setPosition(cc.p(30,pSize.height/2))
    self._pVoidBtn:addChild( self._pVoiceAniNode)

    --播放时长
    self._pLableLength = cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pLableLength:setAnchorPoint(0,0.5)
    self._pLableLength:setPosition(cc.p(pSize.width-40,pSize.height/2))
    self._pVoidBtn:addChild(self._pLableLength)


    --语音上面的没有播放的提示
    self._pVoidNotice =  cc.Sprite:createWithSpriteFrameName("ChatDialogRes/Notice.png")
    self._pVoidNotice:setPosition(cc.p(pSize.width+30,pSize.height/2))
    self._pVoidNotice:setScale(0.75)
    self._pVoidBtn:addChild(self._pVoidNotice)
   
   --时间戳
    self._pTimePoke = cc.Label:createWithTTF("", strCommonFontName, 30)
    self._pTimePoke:setAnchorPoint(0,0.5)
    self._pTimePoke:setPosition(cc.p(pSize.width+120,pSize.height/2))
    self._pVoidBtn:addChild(self._pTimePoke)
 
    --设置数据
    local pString =  "("..string.sub(os.date("%X",self._pVoiceDate.timestamp),0,5)..")"
    self._pTimePoke:setString(pString)    --时间戳
    self._pLableLength:setString( self._pVoicePlayLength.."'")              --语音长度   
    

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitVoiceView()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--初始化数据
function VoiceView:initVoiceDate()
    local pContent = StrToLua( self._pVoiceDate.content)
    self._pVoicePlayId = pContent[1]                                        --第三方播放id
    self._pVoicePlayLength = pContent[2]                                    --语音的时间长度

end

--标记此条信息已读
function VoiceView:setVoiceHasPlay()
   self._pVoidNotice:setVisible(false)
end

function VoiceView:stopVoicePlayAni(event)
    self._pCurPlayId = event
end


--播放此条信息
function VoiceView:playVoid(fCallBack)

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end1" then
          if self._pCurPlayId ~= nil and  self._pCurPlayId ~= self._pVoicePlayId then
             self._pVoiceAniNode:stopAllActions()
           end
            local isOver = mmo.DataHelper:getPlayVoiceOver()
            if isOver == true  then
                self._pVoiceAniNode:stopAllActions()
                if fCallBack then --播放结束的回调   
                    fCallBack()
                end
            end
        end
    end
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kStopVoice,self._pVoicePlayId)
    release_print("playId:"..self._pVoicePlayId)
    mmo.HelpFunc:playVoice(self._pVoicePlayId)
    self._pVoidNotice:setVisible(false)
    local pVoiceiAction = cc.CSLoader:createTimeline("SpeekPlayEffect.csb")
    pVoiceiAction:setFrameEventCallFunc(onFrameEvent)
    pVoiceiAction:gotoFrameAndPlay(0,pVoiceiAction:getDuration(),true)
    self._pVoiceAniNode:stopAllActions()
    self._pVoiceAniNode:runAction(pVoiceiAction)

end

-- 退出函数
function VoiceView:onExitVoiceView()
    ResPlistManager:getInstance():removeSpriteFrames("SpeekPlayEffect.plist")
end

-- 循环更新
function VoiceView:update(dt)
    return
end

-- 显示结束时的回调
function VoiceView:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function VoiceView:doWhenCloseOver()
    return
end



return VoiceView
