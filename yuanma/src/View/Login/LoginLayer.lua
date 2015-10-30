--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  LoginLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   登陆层
--===================================================
local LoginLayer = class("LoginLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function LoginLayer:ctor()
    self._strName = "LoginLayer"                    -- 层名称
    self._pTouchListener = nil                      -- 触摸监听器
    self._pBg = nil                                 -- 登录背景
    self._tPeoples = {}                             -- 四大天王
    self._pLightNode = nil                          -- 光照点对象
    self._pTitle = nil                              -- logo
    self._nTitleAniCounter = 1                      -- 标题动画时间计数
    self._nLightCount = 1                           -- 光照所在轨迹点计数
    self._posLightCircleCenter = nil                -- 光照椭圆形圆心
    self._fCircleR = 0                              -- 光照半径
    self._tCirclePoints = {}                        -- 光照轨迹点集合
    self._nWaterCircleCount = 1                     -- 水纹所在轨迹点计数
    self._posWaterCircleCenter = nil                -- 水纹椭圆圆形圆心
    self._fWaterCircleR = 0                         -- 水纹半径           
    self._tWaterCirclePoints={}                     -- 水纹轨迹点集合
    self._pStartGamePanelCCS = nil                  -- 开始游戏相关的CCS
    self._pServerBarNode = nil                      -- 服务器button节点
    self._pGameStartButtonNode = nil                -- 开始游戏button节点
    self._pVersionNode = nil                        -- 版本号文字节点
    self._pLastSeverStatusText = nil                -- 上次登录的服务器状态信息文字
    self._pLastSeverNameText = nil                  -- 上次登录的服务器名称文字
    self._pChangeServerButton = nil                 -- 切换服务器按钮
    self._pGameStartButton = nil                    -- 开始游戏按钮
    self._pVersionText = nil                        -- 版本号文本
    self._pServerListPanel = nil                    -- 服务器列表panel
    self._pAccountBg = nil                          -- 用户名输入框背景
    self._pAccountText = nil                        -- 用户名输入框
    self._pEnterButton = nil                        -- 确认登录按钮
    self._pSetButton = nil                          -- 设置按钮
    self._pUserCenterButton = nil                   -- 用户中心按钮
    self._pChangeAccountButton = nil                -- 切换账户按钮
    self._pQuitButton = nil                         -- 退出游戏按钮
    self._bWaitingForLoginZTOverParams = false      -- 等待母包登录参数
    self._bRefresh = false                          -- 是否从新连接地址
    
    
end

-- 创建函数
function LoginLayer:create()
    local layer = LoginLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function LoginLayer:dispose()
    
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kLoginAccount, handler(self, self.loginAccountNetBack))
    NetRespManager:getInstance():addEventListener(kNetCmd.kLoginAccountMother, handler(self, self.loginAccountNetBack))
    NetRespManager:getInstance():addEventListener(kNetCmd.kServerList, handler(self, self.serverListNetBack))
    NetRespManager:getInstance():addEventListener(kNetCmd.kLoginGame, handler(self, self.loginGameNetBack))
    NetRespManager:getInstance():addEventListener(kNetCmd.kSelectZoneResp, handler(self, self.selectZoneBack))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected ,handler(self, self.handleMsgReconnect))
    cc.Director:getInstance():getRunningScene()._bForceQuit = false
    tCountSeq = {}
 
    -- 初始化界面相关
    self:initUI()
    
    -- 处理控件回调相关
    self:disposeWidget()
    
    -- 初始化触摸相关
    self:initTouches()
    
    -- 刷新服务器
    self:refreshServerInfo()     
    
    if NewbieManager:getInstance():isShowingNewbie() == true then
        NewbieManager:getInstance():closeNewbie()
    end

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "enter" then
            self:checkConnecting()
        elseif event == "exit" then
            self:onExitLoginLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function LoginLayer:onExitLoginLayer()
    self:onExitLayer()
    
    NetRespManager:getInstance():removeEventListenersByHost(self)
    
end

-- 显示结束时的回调
function LoginLayer:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function LoginLayer:doWhenCloseOver()
    return
end

function LoginLayer:checkConnecting()
    if isConnect() == false then
        -- 连接服务器
        cclog("开始连接服务器地址："..SERVER_IP.." 端口号："..SERVER_PORT)
        connectTo(SERVER_IP,SERVER_PORT)
        if isConnect() == true then
            cclog("服务器连接成功！")
        end
        --链接成功打开公告板子
       -- DialogManager:getInstance():showDialog("AnnouncementDialog")
        -- 请求服务器列表
        LoginCGMessage:sendMessageServerList10002()
     if self._bRefresh then
        local serverInfo = LoginManager:getInstance():getLastServerInfo()
        if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
         
        else
           local args = {}
           args.verify_key = LoginManager:getInstance()._strVerifyKeyForDeviceID
           args.deviceToken = LoginManager:getInstance()._strDeviceToken
           args.theDeviceInfo = LoginManager:getInstance()._tDeviceInfo
           args.theAppInfo = LoginManager:getInstance()._tAppInfo
           LoginCGMessage:sendMessageLoginAccount10000(args)  
        end
        self._bRefresh = false
     end     
   
    end
end

-- 显示（带动画）
function LoginLayer:showWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:setVisible(true)
    self:stopAllActions()

    local pPreposMask = cc.LayerColor:create(cc.c4b(0,0,0,255))
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)

    local showOver = function()
        self:doWhenShowOver()
        if self._pTouchListener ~= nil then
            self._pTouchListener:setEnabled(true)
        end
        pPreposMask:removeFromParent(true)
    end
    pPreposMask:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(showOver)))
    
    return
end

-- 处理控件回调相关
function LoginLayer:initUI()
    -- 登录系统背景
    self._pBg = mmo.HelpFunc:createRippleNode("CoverBgRes/dljm_bg.png")
    self._pBg:setPosition(mmo.VisibleRect:center())
    self._pBg:setScaleX(1400/self._pBg:getContentSize().width)
    self._pBg:setScaleY(780/self._pBg:getContentSize().height)
    self:addChild(self._pBg)

    -- 背景滚云
    local tCloudPos = {
                        cc.p(0,mmo.VisibleRect:height()*5/6),
                        cc.p(0,mmo.VisibleRect:height()*3/6),
                        cc.p(0,mmo.VisibleRect:height()*1/6),
                      }
    local time = 10
    local tCloudFrontAction = {
                     cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-1366,0)),cc.MoveBy:create(0,cc.p(1366,0)))),
                     cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-1366,0)),cc.MoveBy:create(0,cc.p(1366,0)))),
                     cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-1366,0)),cc.MoveBy:create(0,cc.p(1366,0))))
                    }
    local tCloudBackAction = {
                     cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-1366,0)),cc.MoveBy:create(0,cc.p(1366,0)))),
                     cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-1366,0)),cc.MoveBy:create(0,cc.p(1366,0)))),
                     cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-1366,0)),cc.MoveBy:create(0,cc.p(1366,0))))
                    }
    for i = 1, 3 do
        local cloudFront = cc.Sprite:createWithSpriteFrameName("LoginBgRes/cloud"..i..".png")
        cloudFront:setAnchorPoint(cc.p(0,0.5))
        cloudFront:setScaleX(1366/cloudFront:getContentSize().width)
        cloudFront:setScaleY(mmo.VisibleRect:height()*0.35/cloudFront:getContentSize().height)
        cloudFront:setPosition(tCloudPos[i])
        cloudFront:runAction(tCloudFrontAction[i])

        local cloudBack = cc.Sprite:createWithSpriteFrameName("LoginBgRes/cloud"..i..".png")
        cloudBack:setAnchorPoint(cc.p(0,0.5))
        cloudBack:setScaleX(1366/cloudBack:getContentSize().width)
        cloudBack:setScaleY(mmo.VisibleRect:height()*0.35/cloudBack:getContentSize().height)
        cloudBack:setPosition(cc.p(cloudFront:getPositionX()+cloudFront:getBoundingBox().width,cloudFront:getPositionY()))
        cloudBack:runAction(tCloudBackAction[i])

        self:addChild(cloudFront)
        self:addChild(cloudBack)
    end

    -- 四大天王
    local tPeoplePos = {cc.p(210,-2),cc.p(mmo.VisibleRect:width()/2 - 190,-2),cc.p(mmo.VisibleRect:width()/2 + 80,-2),cc.p(mmo.VisibleRect:width() - 220,-2)}
    local tPeopleZorder = {10,7,8,9}
    local time = 4
    local tAction = {
                     cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(-40,0))),cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(40,0))))),
                     cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(-25,0))),cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(25,0))))),
                     cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(25,0))),cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(-25,0))))),
                     cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(40,0))),cc.EaseSineInOut:create(cc.MoveBy:create(time,cc.p(-40,0)))))
                    }
    for i = 1, 4 do
        local people = cc.Sprite:createWithSpriteFrameName("LoginBgRes/people"..i..".png")
        people:setAnchorPoint(cc.p(0.5, 0))
        people:setPosition(tPeoplePos[i])
        people:runAction(tAction[i])
        self:addChild(people,tPeopleZorder[i])
        self._tPeoples[i] = people
    end

    -- 柱子
    local post = cc.Sprite:createWithSpriteFrameName("LoginBgRes/post.png")
    post:setAnchorPoint(cc.p(1.0, 0))
    post:setPosition(mmo.VisibleRect:width()+2, 0)
    self:addChild(post,20)
    
    -- 游戏logo
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr("light")
    self._pLightNode = mmo.HelpFunc:createLightNode("light.pvr.ccz")
    self._pLightNode:setScale(1.5)
    self._pLightNode:setOpacity(100)
    self._pLightNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(2,20),cc.FadeTo:create(2,100))))
    self:addChild(self._pLightNode,20)

    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr("title")
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr("title_mask")
    self._pTitle = mmo.HelpFunc:createNormalMappedNode(self._pLightNode, "title.pvr.ccz", "title_mask.pvr.ccz","light.pvr.ccz",4) --cc.Sprite:createWithSpriteFrameName("LoginBgRes/title.png")
    self._pTitle:setAnchorPoint(cc.p(0.5,1.0))
    self._pTitle:setScale(0.5)
    self._pTitle:setPosition(mmo.VisibleRect:width()/2, mmo.VisibleRect:height()+4)
    self._pTitle:runAction(cc.EaseElasticOut:create(cc.ScaleTo:create(3,1.1)))
    self:addChild(self._pTitle,20)

    -- 计算椭圆形水纹轨迹
    self._nWaterCircleCount = 1
    self._posWaterCircleCenter = cc.p(mmo.VisibleRect:width()/2, mmo.VisibleRect:height()/2)
    self._fWaterCircleR = 300
    self._tWaterCirclePoints={}
    local dx = 0.05
    for a = 0, 2*math.pi, dx do
        table.insert(self._tWaterCirclePoints,{x=self._posWaterCircleCenter.x+math.cos(a)*self._fWaterCircleR,y=self._posWaterCircleCenter.y+math.sin(a)*self._fWaterCircleR})
    end

    -- 计算椭圆形光点轨迹
    self._nLightCount = 1
    self._posLightCircleCenter = cc.p(mmo.VisibleRect:width()/2, mmo.VisibleRect:height() - 110)
    self._fCircleR = 180
    self._tCirclePoints={}
    local dx = 0.1
    for a = 0, 2*math.pi, dx do
        table.insert(self._tCirclePoints,{x=self._posLightCircleCenter.x+math.cos(a)*self._fCircleR*2,y=self._posLightCircleCenter.y+math.sin(a)*self._fCircleR})
    end

    -- 加载组件
    local params = require("StartGamePanelParams"):create()
    self._pStartGamePanelCCS = params._pCCS
    self._pServerBarNode = params._pSeverInfPoint
    self._pGameStartButtonNode = params._pGameStartPoint
    self._pVersionNode = params._pVersionPoint
    self._pLastSeverStatusText =  params._pStateSeverText
    self._pLastSeverNameText = params._pSeverNameText 
    self._pChangeServerButton = params._pChangeServerButton
    self._pGameStartButton = params._pGameStartButton
    self._pVersionText = params._pVersionText
    self._pAccountBg = params._pAccountBg
    self._pAccountText = params._pAccountText
    self._pAccountText:setString("")
    self._pEnterButton = params._pEnterButton
    
    -- 移动平台：隐藏登录按钮
    if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
        self._pEnterButton:setVisible(false)
        self._pAccountBg:setVisible(false)
        self._pAccountText:setVisible(false)
    end
    
    self._pSetButton = params._pSetButton
    self._pStartGamePanelCCS:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()*0.30)
    self:addChild(self._pStartGamePanelCCS,30)
    
    self._pChangeServerButton:setZoomScale(nButtonZoomScale)
    self._pChangeServerButton:setPressedActionEnabled(true)
    --self._pChangeServerButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255))

    self._pGameStartButton:setZoomScale(nButtonZoomScale)  
    self._pGameStartButton:setPressedActionEnabled(true)
    
    -- 初始化版本号
    --[[
    local nMainID = LoginManager:getInstance()._tAppInfo.major_version
    local nMinorID = LoginManager:getInstance()._tAppInfo.minor_version
    self._pVersionText:setString("Ver "..nMainID.."."..nMinorID)
    self._pVersionText:enableShadow(cc.c4b(0, 0, 0, 255))
    ]]
    self._pVersionText:setString("内部开发版本")
    
    --shareButton
    local pShareBtn = self._pSetButton:clone()
    pShareBtn:setPosition(cc.p(100,384))
    self:addChild(pShareBtn)

    local enterShareCallback = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pImagePath = "http://a2.att.hudong.com/24/93/01300000432220133281935327167.jpg"
            local pUrl = "http://www.baidu.com"
            --（ 标题 ，要分享的内容，注意在文档中content对应的是text字段，分享的图片路径,内容简要，分享的网页）
            --
            mmo.HelpFunc:share("2222","33333",pImagePath,"dddd",pUrl)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    pShareBtn:addTouchEventListener(enterShareCallback)
    
    
    -- 设置按钮
    self._pSetButton:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then     -- 抬起发送
            DialogManager:getInstance():showDialog("OptionDialog",{kOptionType.LoginOption})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self._pUserCenterButton = params._pUserCenterButton
    self._pChangeAccountButton = params._pChangeAccountButton
    self._pQuitButton = params._pQuitButton
    
    self._pUserCenterButton:setVisible(false)
    self._pChangeAccountButton:setVisible(false)
    self._pQuitButton:setVisible(false)
    
    -- 判断是否需要显示渠道相关按钮
    if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
        -- 用户中心按钮
        if mmo.HelpFunc:isHasCenterZTGame() == true then
            local enterUserCenterCallback = function()
            	mmo.HelpFunc:enterCenterZTGame()
            end
            self._pUserCenterButton:setVisible(true)
            self._pUserCenterButton:addTouchEventListener(enterUserCenterCallback)
        end
        -- 切换账户按钮
        if mmo.HelpFunc:isHasSwitchAccountZTGame() == true then
            local changeAccountCallback = function()
                mmo.HelpFunc:switchAccountZTGame()
            end
            self._pChangeAccountButton:setVisible(true)
            self._pChangeAccountButton:addTouchEventListener(changeAccountCallback)
        end
        -- 退出游戏按钮
        if mmo.HelpFunc:isHasQuitDialog() == true then
            local quitCallback = function()
                mmo.HelpFunc:quitZTGame()
            end
            self._pQuitButton:setVisible(true)
            self._pQuitButton:addTouchEventListener(quitCallback)
        end
    end

end

-- 初始化触摸相关
function LoginLayer:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        
        print("===========================================================================")
        print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        print("===========================================================================")

    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

end

-- 处理控件回调相关
function LoginLayer:disposeWidget()
    -- 切换服务器回调函数
    local function serverButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._pServerListPanel == nil then
                if table.getn(LoginManager:getInstance()._tServerList) ~= 0 then
                    -- 显示服务器列表内容
                    self:showServerList()
                end
            else
                -- 关闭服务器列表内容
                self:closeServerList()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ServerButton")
        end
    end
    -- 给切换服务器按钮添加监听机制
    self._pChangeServerButton:addTouchEventListener(serverButtonCallBack)

    -- 确认登录按钮回调函数
    if isMobilePlatform() == false or bOpenMobileAndWinMacSameLoginWay == true then
        local function accountEnterButtonCallBack(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local strAccountName = self._pAccountText:getString()
                local nLength = string.len(strAccountName)
                if nLength >= 5 then
                    self:checkConnecting()
                    if isConnect() == true then
                        -- 登录账户
                        LoginManager:getInstance()._tDeviceInfo.device_id = strAccountName
                        LoginManager:getInstance()._strVerifyKeyForDeviceID = mmo.HelpFunc:gXorCoding(strAccountName)
                        LoginManager:getInstance()._strDeviceToken = ""
                        local args = {}
                        args.verify_key = LoginManager:getInstance()._strVerifyKeyForDeviceID
                        args.deviceToken = LoginManager:getInstance()._strDeviceToken
                        args.theDeviceInfo = LoginManager:getInstance()._tDeviceInfo
                        args.theAppInfo = LoginManager:getInstance()._tAppInfo
                        LoginCGMessage:sendMessageLoginAccount10000(args)                    
                    end

                end
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end
        -- 给确认登录按钮添加监听机制
        self._pEnterButton:addTouchEventListener(accountEnterButtonCallBack)
    end
    
    -- 开始游戏按钮回调函数
    local function startGameButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._pEnterButton:isVisible() == true then
                return
            end            
            if table.getn(LoginManager:getInstance()._tServerList) ~= 0 then
                local serverInfo = LoginManager:getInstance():getLastServerInfo()
                if serverInfo.zoneStatus == kZoneStateType.SST_STOP then    -- 当前服务器是维护状态
                    showSystemAlertDialog("服务器维护中。")
                    return
                end
                if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
                    -- 移动平台登录时，需要向SDK服务器请求登录
                    mmo.HelpFunc:loginZTGame(tostring(serverInfo.zoneId), serverInfo.zoneName, true)
                    self._bWaitingForLoginZTOverParams = true
                else
                    cclog("ZoneId"..serverInfo.zoneId)
                    LoginCGMessage:sendMessageSelectZone(serverInfo.zoneId)
                end
            end
            
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("StartGameButton")
        end
    end
    -- 给开始游戏按钮添加监听机制
    self._pGameStartButton:addTouchEventListener(startGameButtonCallBack)  

end

-- 循环更新
function LoginLayer:update(dt)

    -- 刷新背景水纹位置
    mmo.HelpFunc:doRippleNodeTouch(self._pBg, self._tWaterCirclePoints[self._nWaterCircleCount], 1024, 12)
    self._nWaterCircleCount = self._nWaterCircleCount + 1
    if self._nWaterCircleCount > table.getn(self._tWaterCirclePoints) then
        self._nWaterCircleCount = 1
    end

    -- 刷新光照点的椭圆形位置
    self._pLightNode:setPosition(self._tCirclePoints[self._nLightCount])
    self._nLightCount = self._nLightCount + 1
    if self._nLightCount > table.getn(self._tCirclePoints) then
        self._nLightCount = 1
    end

    --------------------------------- logo shake ----------------------------------------------
    local rand_x = 0.07*math.sin(math.rad(self._nTitleAniCounter*0.5+4356))
    local rand_y = 0.07*math.sin(math.rad(self._nTitleAniCounter*0.37+5436)) 
    local rand_z = 0.07*math.sin(math.rad(self._nTitleAniCounter*0.2+54325))
    self._pTitle:setRotation3D({x=math.deg(rand_x),y=math.deg(rand_y),z=math.deg(rand_z)})
    self._nTitleAniCounter = self._nTitleAniCounter+1
    --------------------------------------------------------------------------------------------

    self:checkConnecting()
    if self._bWaitingForLoginZTOverParams == true then      -- 监测母包登录成功后的返回参数集合
        local tLoginOverParams = nil
        tLoginOverParams = mmo.DataHelper:getLoginOverParams()
        if tLoginOverParams.ip ~= "" and tLoginOverParams.ip ~= nil then
            -- cclog("mobile_type = "..tLoginOverParams.mobile_type.." token = "..tLoginOverParams.token.." accid = "..tLoginOverParams.accid.." imei = "..tLoginOverParams.imei.." mac = "..tLoginOverParams.mac.." channel = "..tLoginOverParams.channel.." ip = "..tLoginOverParams.ip)
            -- 母包成功后，开始游戏登录账户
            LoginManager:getInstance()._strAccid = tLoginOverParams.accid
            LoginManager:getInstance()._strToken = tLoginOverParams.token
            LoginManager:getInstance()._strDeviceToken = "" -- 推送
            LoginManager:getInstance()._strVerifyKeyForDeviceID = mmo.HelpFunc:gXorCoding(tLoginOverParams.imei)
            LoginManager:getInstance()._tDeviceInfo.device_id = tLoginOverParams.imei
            LoginManager:getInstance()._tDeviceInfo.model = tLoginOverParams.mobile_type
            LoginManager:getInstance()._tDeviceInfo.width_pixels = mmo.VisibleRect:width()
            LoginManager:getInstance()._tDeviceInfo.high_pixels = mmo.VisibleRect:height()
            LoginManager:getInstance()._tDeviceInfo.ip = tLoginOverParams.ip
            LoginManager:getInstance()._tDeviceInfo.mac = tLoginOverParams.mac
            LoginManager:getInstance()._tAppInfo.platform = tLoginOverParams.channel
            local args = {}
            args.openId = LoginManager:getInstance()._strAccid
            args.token = LoginManager:getInstance()._strToken       
            args.verify_key = LoginManager:getInstance()._strVerifyKeyForDeviceID
            args.deviceToken = LoginManager:getInstance()._strDeviceToken
            args.theDeviceInfo = LoginManager:getInstance()._tDeviceInfo
            args.theAppInfo = LoginManager:getInstance()._tAppInfo
            LoginCGMessage:sendMessageLoginAccount10004(args)           -- 向CP的账户服务器发起登录请求
            self._bWaitingForLoginZTOverParams = false
        end
    end

end

-- 网络登录账户回调
function LoginLayer:loginAccountNetBack(event)
    -- 隐藏掉所有debug按钮
    self:hideAllAccountWidgets()
    --用户Id唯一标示用户（静态）
    LoginManager:getInstance()._strUserId = tostring(event.userId)
    mmo.HelpFunc:setUserIDForBugly(LoginManager:getInstance()._strUserId)
    -- 得到用户唯一标示ID（动态）
    LoginManager:getInstance()._strSerialCode = event.serialCode
    -- 账户的扩展字段
    LoginManager:getInstance()._strExtData = event.extData
    -- ----------------------------------------------------------------------------------
    -- 重新刷新服务器列表（用于白名单中用户的服务器列表实际状态的刷新）
    if event.serverList and table.getn(event.serverList) ~= 0 then
        LoginManager:getInstance()._tServerList = event.serverList
    end
    -- 获取当前角色所创建的角色在服务器上的分步信息
    LoginManager:getInstance()._tZoneFlags = event.zoneFlags
    -- 刷新服务器提示信息
    self:refreshServerInfo()
    -- -----------------------------------------------------------------------------------
    -- 如果是移动平台，则自动进入角色界面
    if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
        local serverInfo = LoginManager:getInstance():getLastServerInfo()
        cclog("ZoneId"..serverInfo.zoneId)
        --发送查询是否需要排队协议
        LoginCGMessage:sendMessageSelectZone(serverInfo.zoneId)
    end

    return
end

-- 网络登录游戏回调
function LoginLayer:loginGameNetBack(event)
    -- 母包刷新zoneId
    if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
        mmo.HelpFunc:setZoneId(LoginManager:getInstance()._tLastServer.zoneId)
    end
    
    -- 禁用该按钮
    self._pGameStartButton:setTouchEnabled(false)

    -- 角色操作层
    local roleLayer = nil
    local roleOperateLayer = nil
    

    -- 账号登录的sessionId 用于创建跟断线从连用
    local tRoleInfo = event.roleInfo
    LoginManager:getInstance()._tRoleDisplayInfosList = tRoleInfo
    -- 如果角色列表长度为0，则直接切换到角色创建界面，否则切换到角色选择界面
    LoginManager:getInstance()._tLoginSessionId = event.sessionId
    --是否可进(为0为不可进;非0可进)
    LoginManager:getInstance()._nIsService = event.isService
    --print_lua_table(LoginManager:getInstance()._tRoleDisplayInfosList)
    if table.getn(LoginManager:getInstance()._tRoleDisplayInfosList) == 0 then
        self:getGameScene():showLayer(require("RoleLayer"):create(0))
    else
        self:getGameScene():showLayer(require("RoleLayer"):create(1))
    end
    roleLayer = self:getGameScene():getLayerByName("RoleLayer")
    if table.getn(tRoleInfo) == 0 then
        self:getGameScene():showLayer(require("RoleCreateLayer"):create())
        roleOperateLayer = self:getGameScene():getLayerByName("RoleCreateLayer")
    else
        self:getGameScene():showLayer(require("RoleSelectLayer"):create())
        roleOperateLayer = self:getGameScene():getLayerByName("RoleSelectLayer")
    end

    roleLayer:setPositionX(self._pBg:getBoundingBox().width)
    roleOperateLayer:setPositionX(self._pBg:getBoundingBox().width)

    -- 创建动画过度
    local act = cc.Sequence:create(cc.EaseExponentialInOut:create(cc.MoveBy:create(1.0, cc.p(-self._pBg:getBoundingBox().width, 0))), cc.CallFunc:create(self.close))
    local actCopy = cc.Sequence:create(cc.EaseExponentialInOut:create(cc.MoveBy:create(1.0, cc.p(-self._pBg:getBoundingBox().width, 0))))
    self:runAction(act)
    roleLayer:runAction(actCopy)
    local actCopy1 = cc.Sequence:create(cc.EaseExponentialInOut:create(cc.MoveBy:create(1.0, cc.p(-self._pBg:getBoundingBox().width, 0))))
    roleOperateLayer:runAction(actCopy1)
   
    return
end


--选择分区回复
function LoginLayer:selectZoneBack(event)
    local pCurRank = event.currRank         --当前排名
    local pTotalCount = event.totalCount    --总排名
    if pCurRank > 0 then -- 需要排队
      local pDialog = DialogManager:getInstance():getDialogByName("QueueUpDialog")
      if pDialog == nil then --如果是空代表需要打开排队dialog
            local serverInfo = LoginManager:getInstance():getLastServerInfo()
            DialogManager:getInstance():showDialog("QueueUpDialog",{serverInfo.zoneName,pCurRank,pTotalCount,event.argsBody.zoneId})
      end
    
    else --不需要排队直接进入游戏
        DialogManager:getInstance():closeDialogByName("QueueUpDialog")
        
    	self:sendLoginGameMessage()
    end
    
    
end

--断线从连回调
function LoginLayer:handleMsgReconnect(event)
    if LoginManager:getInstance()._tCurSessionId == nil then --代表还在验证服务器
        --self:refreshConnect()
    end
end


function LoginLayer:sendLoginGameMessage()
    -- 断开网络
    disconnect()
    -- 重新连接网络
    local info = LoginManager:getInstance()._tLastServer
    cclog("开始连接服务器地址："..info.ipAddr.." 端口号："..info.port)
    connectTo(info.ipAddr,info.port)
    if isConnect() == true then
        cclog("服务器连接成功！")
        -- 登录游戏服务器
        LoginCGMessage:sendMessageLoginGame20000()
    end
end


-- 获取服务器列表回调
function LoginLayer:serverListNetBack(event)
    LoginManager:getInstance()._tServerList = event.serverList

    -- 刷新服务器提示信息
    self:refreshServerInfo()
    
    return
end

-- 刷新服务器提示信息
function LoginLayer:refreshServerInfo()    
    -- 获取当前服务器默认选中信息
    local info = LoginManager:getInstance():getLastServerInfo()
    if info.zoneStatus == kZoneStateType.SST_UNKONWN then
        self._pLastSeverStatusText:setString("")
    elseif info.zoneStatus == kZoneStateType.SST_NORMAL then
        self._pLastSeverStatusText:setString("普通")
        self._pLastSeverStatusText:setTextColor(cFontGreen)
    elseif info.zoneStatus == kZoneStateType.SST_HOT then
        self._pLastSeverStatusText:setString("火爆")
        self._pLastSeverStatusText:setTextColor(cFontRed)
    elseif info.zoneStatus == kZoneStateType.SST_STOP then
        self._pLastSeverStatusText:setString("维护")
        self._pLastSeverStatusText:setTextColor(cFontGrey)
    end
    
    if info.zoneName == "" then
        self._pLastSeverNameText:setString("")
    else
        self._pLastSeverNameText:setString(info.zoneName)
    end
    self._pLastSeverNameText:setTextColor(cFontGrey)
    
    return
end

--点击返回或者断线重连了，从游戏刚刚开始登陆之后发送协议
function LoginLayer:refreshConnect()
     -- 断开网络
    self._bRefresh = true
    LoginManager:getInstance()._tCurSessionId = nil
    disconnect()
end


-- 显示服务器列表界面
function LoginLayer:showServerList()
    self._pServerListPanel = require("ServerListPanel"):create()
    self._pServerListPanel:setPosition(cc.p(self._pStartGamePanelCCS:getPositionX(), self._pStartGamePanelCCS:getPositionY() + 60))
    self:addChild(self._pServerListPanel,100)
    -- 更改按钮上的文字信息
    self._pChangeServerButton:setTitleText("点击收回")
end

-- 关闭服务器列表界面
function LoginLayer:closeServerList()
    self:removeChild(self._pServerListPanel)
    self._pServerListPanel = nil
    self._pChangeServerButton:setTitleText("切换服务器")

end

-- 隐藏掉所有debug部件（登录输入等控件）
function LoginLayer:hideAllAccountWidgets()
    self._pAccountBg:setVisible(false)
    self._pAccountText:setVisible(false)
    self._pEnterButton:setVisible(false)
end

return LoginLayer
