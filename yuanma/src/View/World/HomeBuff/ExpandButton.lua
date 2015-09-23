--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ExpandButton.lua
-- author:    yuanjiashun
-- created:   2015/5/18
-- descrip:   拓展的button
--===================================================

local ExpandButton = class("ExpandButton",function()
    return cc.Layer:create()
end)

-- 构造函数
function ExpandButton:ctor()
    self._strName = "ExpandButton"          --控件名称
    self._pBg = nil                         --背景
    self._pIconBtn = nil                    --item的显示button
    self._pCdBar = nil                      --如果 有cd的话cd Bar
    
    self._tBuffInfo = nil                  --buff的信息
    self._tBuffContSize = nil              --buff说明的Bg大小
    self._pBuffDescLableSize = 21          --lable的size
    self._nBuffDescDire = nil              --buff说明板子的方向，默认向右

end 

-- 创建函数{1:buff相关信息（图标，时间等）,2:buff的说明，3:buff说明板子的方向（kDirection）,4:其他信息}
function ExpandButton:create(args)
    local layer = ExpandButton.new()
    layer:dispose(args)
    return layer
end

-- 处理函数
function ExpandButton:dispose(args) 
    self._nButtonDire = kDirection.kDown
    if args ~= nil then
        self._tButtonInfo = args[1]
        if args[2] == nil then
            self._nButtonDire = kDirection.kRight
        end
    end
    NetRespManager:getInstance():addEventListener(kNetCmd.kHomeBuffTime ,handler(self, self.homeBuffTimeInform))

    self._pBg = ccui.ImageView:create("ccsComRes/BagItem.png",ccui.TextureResType.plistType)
    self:addChild(self._pBg)
    --图标按钮
    local  onTouchButton = function (sender, eventType)
    
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self._tButtonDescBg:setVisible(true)     
        elseif eventType == ccui.TouchEventType.ended then
            self._tButtonDescBg:setVisible(false)
        
        elseif eventType == ccui.TouchEventType.canceled then
            self._tButtonDescBg:setVisible(false)
        
        end
    end
    
    
    self._pIconBtn = nil
    self._pIconBtn = ccui.Button:create(
        "ccsComRes/qual_4_normal.png",
        "ccsComRes/qual_5_normal.png",
       nil,
        ccui.TextureResType.plistType)
    self._pIconBtn:setTouchEnabled(true)
    self._pIconBtn:setPosition(0,0)
    self:addChild(self._pIconBtn)
    self._pIconBtn:addTouchEventListener(onTouchButton)
    

    local pBarCd = cc.Sprite:createWithSpriteFrameName("ccsComRes/BagItem.png")
    --buff的图标进度条
    self._pCdBar = cc.ProgressTimer:create(pBarCd)
    self._pCdBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self._pCdBar:setMidpoint(cc.p(0.5,0.5))
    self._pCdBar:setBarChangeRate(cc.p(0,1))
    self._pCdBar:setScaleX(-1)
    self._pCdBar:setPercentage(0)
    self:addChild(self._pCdBar)
    
    --buff的背景
    self._tBuffContSize = cc.size(300,100)
    self._tButtonDescBg = ccui.ImageView:create("ccsComRes/tips01.png",ccui.TextureResType.plistType)
    self._tButtonDescBg:setContentSize(self._tBuffContSize)
    self._tButtonDescBg:setScale9Enabled(true)
    self._tButtonDescBg:setVisible(false)
    self:addChild(self._tButtonDescBg)
  
    --buff的描述信息
    self._pDescText = cc.Label:createWithTTF("", strCommonFontName,self._pBuffDescLableSize)
    self._pDescText:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self._pDescText:setWidth(self._tBuffContSize.width*0.8)
    self._pDescText:setPositionX(self._tBuffContSize.width/2)
    self._pDescText:setPositionY(self._tBuffContSize.height-20)
    self._pDescText:setAnchorPoint(0.5,1)
    self._tButtonDescBg:addChild(self._pDescText)
    
    --buff的剩余时间
    self._pRemainTime = cc.Label:createWithTTF("", strCommonFontName, self._pBuffDescLableSize)
    self._pRemainTime:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self._pRemainTime:setPositionX(self._tBuffContSize.width/2)
    self._pRemainTime:setPositionY(20)
    self._pRemainTime:setAnchorPoint(0.5,0)
    self._tButtonDescBg:addChild(self._pRemainTime)
    
    --设置button的信息
    self:updateButtonInfo(self._tButtonInfo)
    --设置cd信息
    self:startBtCD(self._tButtonInfo)
    
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBagItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--设置右侧的板子的坐标
function ExpandButton:setDescBgPos()
    local pSize = self._pBg:getContentSize()
    local pX,pY = self._pIconBtn:getPosition()
    local pDistance = 0     --背景跟button的间距
    local x,y = 0,0
    
    if self._nButtonDire == kDirection.kRight then
        x = pX+pSize.width/2+pDistance+self._tBuffContSize.width/2
        y = pY 
    elseif self._nButtonDire == kDirection.kLeft then
        x = pX-pSize.width/2-pDistance-self._tBuffContSize.width/2
        y = pY 
    elseif self._nButtonDire == kDirection.kUp then
        x = pX
        y = pY+pSize.height/2+pDistance+self._tBuffContSize.height/2
    elseif self._nButtonDire == kDirection.kDown then
        x = pX
        y = pY-pSize.height/2-pDistance-self._tBuffContSize.height/2
    end
    self._tButtonDescBg:setPosition(cc.p(x,y))
end


--注册点击回调
function ExpandButton:registerTouchEvent(func)
    if func ~= nil then
        self._pIconBtn:addTouchEventListener(func)
    end
end

-- 重载背景
function ExpandButton:loadBgWithFilename(filename ,textureType )
    if not textureType then
    textureType = ccui.TextureResType.plistType
    end
    self._pBg:loadTexture(filename,textureType)
end

-- 设置ItemCell 是否可以点击
function ExpandButton:setTouchEnabled(isEnable)
    self._pIconBtn:setTouchEnabled(isEnable)
end

--设置更新button的图片和描述信息
function ExpandButton:updateButtonInfo(args)
    local pInfo = TableHomeBuff[args.id]
    local pButtonTexture = pInfo.Icon..".png"
    local pText = pInfo.Text
    self._pIconBtn:loadTextures(pButtonTexture,pButtonTexture,nil,ccui.TextureResType.plistType)
    self._pDescText:setString(pText)
    local pBgHeight =  self._pDescText:getContentSize().height+ self._pBuffDescLableSize*4
    self:setDescBgContentSize(cc.size(self._tBuffContSize.width,pBgHeight))
end

--设置desc背景的宽度和高度
function ExpandButton:setDescBgContentSize(pSize)
	self._tBuffContSize = pSize
    self._tButtonDescBg:setContentSize(self._tBuffContSize)
    self._pDescText:setPosition(self._tBuffContSize.width/2,self._tBuffContSize.height-20)
    self._pRemainTime:setPosition(self._tBuffContSize.width/2,20)
    self:setDescBgPos()
end

function ExpandButton:startBtCD(args)
    self._tButtonInfo = args
    local nAllCDTime = TableHomeBuff[args.id].Duration
    local pTime,fCallBack = CDManager:getInstance():getOneCdTimeByKey(args.id)
    self._pCdBar:stopAllActions()
    self._pCdBar:setPercentage(pTime/nAllCDTime*100)
    self._pCdBar:runAction(cc.Sequence:create(cc.ProgressTo:create(pTime, 0)))
   
	
end

--设置字体的时间

function ExpandButton:setRemainTime(tTime)
    self._pRemainTime:setString("剩余时间："..gTimeToStr(tTime))
end

--时间倒计时通知
function ExpandButton:homeBuffTimeInform(event)
	if self._tButtonInfo.id == event[2] then --如果id一样
		self:setRemainTime(event[1])
	end
end

--设置背景的对其方向
function ExpandButton:setDescDirection(nDirection)
   self._nButtonDire = nDirection
   self:setDescBgPos()
end 

-- 退出函数
function ExpandButton:onExitBagItem()
  NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function ExpandButton:update(dt)
    return
end

-- 显示结束时的回调
function ExpandButton:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function ExpandButton:doWhenCloseOver()
    return
end

-- 获取尺寸
function ExpandButton:getContentSize()
    return self._pIconBtn:getContentSize()
end

return ExpandButton
