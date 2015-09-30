--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleCreateLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/24
-- descrip:   角色创建层
--===================================================
local RoleCreateLayer = class("RoleCreateLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function RoleCreateLayer:ctor()
    self._strName = "RoleCreateLayer"     -- 层名称
    
    self._pCRPanelCCS = nil                     -- [创建角色]创建角色panel的CCS
    self._pCRJobSelectNode = nil                -- [创建角色]角色职业选择节点
    self._pCRRandomNameNode = nil               -- [创建角色]角色随机名称节点
    self._pCRInfoFrameNode = nil                -- [创建角色]信息详情节点
    self._pCRBackButton = nil                   -- [创建角色]返回按钮
    self._pCRRandomNameButton = nil             -- [创建角色]随机名字按钮
    self._pCROKButton = nil                     -- [创建角色]确定按钮
    self._pNameInPut = nil                      -- [创建角色]名称输入框
    self._pCRWarriorButton = nil                -- [创建角色]战士按钮
    self._pCRMageButton = nil                   -- [创建角色]法师按钮
    self._pCRThugButton = nil                   -- [创建角色]刺客按钮
    self._kCRCurCareer = kCareer.kWarrior       -- [创建角色]创建角色时默认显示的职业类型
    self._tCRInfoCareerNames = {}               -- [创建角色]信息面板上的职业名称
    self._tCRInfoCareerDifficults = {}          -- [创建角色]信息面板上的职业操作难易程度
    self._tCRInfoCareerGroupInfo = {}           -- [创建角色]信息面板上的职业成长方向图
    self._tCRCurCareerDifficultNum = {3,4,5}    -- [创建角色]当前信息面板上的职业操作难易程度在table中的index
    self._pCRSelectedCareerParticle = nil       -- [创建角色]选中的职业button的特效
    self._tCRRoleList = {}                      -- [创建角色]所有职业角色模型动画列表
    self._tCRWeaponList = {{},{},{}}            -- [创建角色]所有职业角色武器模型动画列表
    self._tCRBackList = {}                      -- [创建角色]所有职业角色时装背模型动画列表
    self._tCRRoleActions = {}                   -- [创建角色]所有职业角色模型出场动画
    self._bToWorldLayer = false                 -- [创建角色]是否进入到世界家园的标记位，用于切换场景时
    
    self._ttWaveEffectsInfo = {{},{},{}}        -- 每个职业中包括：[1] 身的信息  [2]武器的信息  [3]背的信息    （而这里每一项的格式为：{t模型集合, t特效位置集合}）
    self._tCurWaveEffectsInfo = {}              -- [1] 身的信息  [2]武器的信息  [3]背的信息    （每一项的格式为：{t模型集合, t特效位置集合}）
    
end

-- 创建函数
function RoleCreateLayer:create()
    local layer = RoleCreateLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function RoleCreateLayer:dispose()

    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kRandomName, handler(self, self.randomNameNetBack))
    NetRespManager:getInstance():addEventListener(kNetCmd.kCreateRole, handler(self, self.createRoleNetBack))
    NetRespManager:getInstance():addEventListener(kNetCmd.kOtherPlayerInfos, handler(self, self.enterGame))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected, handler(self, self.handleNetReconnected))
    
    -- 初始化人物
    self:initRoles()
    
    -- 初始化UI
    self:initUI()
    
    -- 处理控件回调相关
    self:disposeWidget()
    
    -- 自动随机昵称
    LoginCGMessage:sendMessageRandomName20002()
    
    -- 测试：添加波纹特效
    --[[
    self:addWaveEffect(1,kType.kBodyParts.kBody,1)
    self:addWaveEffect(1,kType.kBodyParts.kWeapon,1)
    self:addWaveEffect(1,kType.kBodyParts.kBack,3)
    self:addWaveEffect(2,kType.kBodyParts.kBody,2)
    self:addWaveEffect(2,kType.kBodyParts.kWeapon,2)
    self:addWaveEffect(2,kType.kBodyParts.kBack,2)
    self:addWaveEffect(3,kType.kBodyParts.kBody,3)
    self:addWaveEffect(3,kType.kBodyParts.kWeapon,3)
    self:addWaveEffect(3,kType.kBodyParts.kBack,1)
    ]]

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRoleCreateLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function RoleCreateLayer:onExitRoleCreateLayer()    
    self:onExitLayer()
    
    -- 释放角色动作序列
    for k,v in pairs(self._tCRRoleActions) do
        v:release()
    end  
    
    NetRespManager:getInstance():removeEventListenersByHost(self)
      
end

-- 循环更新
function RoleCreateLayer:update(dt)
    self._tCurWaveEffectsInfo = self._ttWaveEffectsInfo[self._kCRCurCareer]
    for kItem, vItem in pairs(self._tCurWaveEffectsInfo) do
        if vItem[1] then
            for kAni, vAni in pairs(vItem[1]) do
                local glprogramstate = vAni:getGLProgramState()
                vItem[2][kAni].x = vItem[2][kAni].x + 0.01
                if vItem[2][kAni].x > 1.0 then
                    vItem[2][kAni].x = vItem[2][kAni].x - 1.0
                end
                vItem[2][kAni].y = vItem[2][kAni].y + 0.01
                if vItem[2][kAni].y > 1.0 then
                    vItem[2][kAni].y = vItem[2][kAni].y - 1.0
                end
                glprogramstate:setUniformVec2("v_animLight",vItem[2][kAni])
            end
        end
    end
end

-- 显示结束时的回调
function RoleCreateLayer:doWhenShowOver()    
    return
end
-- 关闭结束时的回调
function RoleCreateLayer:doWhenCloseOver()
    if self._bToWorldLayer then
        BuffSystemCGMessage:sendMessageGetBuff23100()  
        FamilyCGMessage:entryFamilyReq22302()

        --LayerManager:getInstance():transformToLoading()
        
    end
    
    return
end

-- 显示（带动画）
function RoleCreateLayer:showWithAni()
    self:setVisible(true)
    self:stopAllActions()
    return
end

-- 关闭（带动画）
function RoleCreateLayer:closeWithAni()
    if self._bToWorldLayer then
        if self._pTouchListener ~= nil then
            self._pTouchListener:setEnabled(false)
        end
        self:stopAllActions()
        local closeOver = function()
            self:doWhenCloseOver()
            self:removeFromParent(true)
        end
        local pPreposMask = cc.Layer:create()
        self:addChild(pPreposMask,kZorder.kPreposMaskLayer)
        pPreposMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(closeOver)))
    else
        self:stopAllActions()
        self:doWhenCloseOver()
        self:removeFromParent(true)
    end
    return
end

-- 初始化角色
function RoleCreateLayer:initRoles()
    -- 三个职业动画初始化
    for i=1, kCareer.kTotoalNum do
        -- 以时装为准
        -- 人物模型 【身】
        local pRoleC3bName = TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[2]].Model1..".c3b"
        local pRoleTextureName = TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[2]].Texture..".pvr.ccz"
        -- 记录并加载到纹理缓存中
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[2]].Texture)
        -- 创建角色
        local pRole = cc.Sprite3D:create(pRoleC3bName)
        pRole:setTexture(pRoleTextureName)
        pRole:setScale(TableTempleteCareers[i].ScaleInLogin)
        pRole:setPosition(mmo.VisibleRect:width()/2,121)
        self:addChild(pRole)
        --设置材质信息
        setSprite3dMaterial(pRole,TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[2]].Material)
        table.insert(self._tCRRoleList, pRole)
        -- 武器模型
        local pWeaponRC3bName = TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].Model1..".c3b"
        local pWeaponLC3bName = nil
        if TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].Model2 then
            pWeaponLC3bName = TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].Model2..".c3b"
        end
        local pWeaponTextureName = TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].Texture..".pvr.ccz"
        -- 记录并加载到纹理缓存中
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].Texture)
        if pWeaponRC3bName then
            local pWeaponR = cc.Sprite3D:create(pWeaponRC3bName)
            pWeaponR:setTexture(pWeaponTextureName)
            pWeaponR:setScale(TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].ModelScale1)
            local animation = cc.Animation3D:create(pWeaponRC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            pWeaponR:runAction(act)
            pRole:getAttachNode("boneRightHandAttach"):addChild(pWeaponR)
            table.insert(self._tCRWeaponList[i], pWeaponR)
            --设置材质信息
            setSprite3dMaterial(pWeaponR,TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].Material)
        end
        if pWeaponLC3bName then
            local pWeaponL = cc.Sprite3D:create(pWeaponLC3bName)
            pWeaponL:setTexture(pWeaponTextureName)
            pWeaponL:setScale(TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].ModelScale2)
            local animation = cc.Animation3D:create(pWeaponLC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            pWeaponL:runAction(act)
            pRole:getAttachNode("boneLeftHandAttach"):addChild(pWeaponL)
            table.insert(self._tCRWeaponList[i], pWeaponL)
            setSprite3dMaterial(pWeaponL,TableTempleteEquips[TableTempleteCareers[i].WeaponEquTempleteID].Material)
        end
        -- 时装【背】
        if TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[1]].Model1 then
            local pBackC3bName = TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[1]].Model1..".c3b"
            local pBackTextureName = TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[1]].Texture..".pvr.ccz"
            -- 记录并加载到纹理缓存中
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[1]].Texture)
            -- 创建时装 背
            local pBack = cc.Sprite3D:create(pBackC3bName)
            pBack:setTexture(pBackTextureName)
            pBack:setScale(TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[1]].ModelScale1)
            local animation = cc.Animation3D:create(pBackC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            pBack:runAction(act)
            pRole:getAttachNode("boneBackAttach"):addChild(pBack)
            table.insert(self._tCRBackList, pBack)
            setSprite3dMaterial(pBack,TableTempleteEquips[TableTempleteCareers[i].FashionEquTempleteID[1]].Material)
        end
        
        -- 动作初始化
        local animation = cc.Animation3D:create(pRoleC3bName)
        local function appearOver()
            local actStand = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, TableTempleteCareers[i].StandActFrameRegion[1], TableTempleteCareers[i].StandActFrameRegion[2]))
            pRole:runAction(actStand)
        end
        local appear = cc.Animate3D:createWithFrames(animation, TableTempleteCareers[i].AppearActFrameRegion[1], TableTempleteCareers[i].AppearActFrameRegion[2])
        local act = cc.Sequence:create(appear, cc.CallFunc:create(appearOver))
        act:retain()
        table.insert(self._tCRRoleActions,act)
        
    end
end

-- 初始化UI
function RoleCreateLayer:initUI()
    -- 加载组件
    local params = require("CreatRolePanelParams"):create()
    self._pCRPanelCCS = params._pCCS
    self._pCRJobSelectNode = params._pJobSlect
    self._pCRRandomNameNode = params._pRandomNamePoint
    self._pCRInfoFrameNode = params._pInfPoint
    self._pCRBackButton = params._pBackButton
    self._pCRRandomNameButton = params._pNameFrame
    self._pCROKButton = params._pOKFrame
    self._pCRWarriorButton = params._pWarriorButton
    self._pCRMageButton = params._pMasterButton
    self._pCRThugButton = params._pThugButton
    self._pNameNode = params._pNameNode
    self._pNameInPut = createEditBoxBySize(cc.size(300,43),TableConstants.NameMaxLenWord.Value)
    self._pNameNode:addChild(self._pNameInPut)
    
    -- 九宫格
    local pStartGameBg = params._pStartGameBg
    pStartGameBg:setContentSize(cc.size(mmo.VisibleRect:width(),137))

    self._pCRSelectedCareerParticle = params._pEdging
    self._pCRSelectedCareerParticle:setPositionType(cc.POSITION_TYPE_GROUPED)

    table.insert(self._tCRInfoCareerNames, params._pZhanShiIcon1)
    table.insert(self._tCRInfoCareerNames, params._pFaShiIcon2)
    table.insert(self._tCRInfoCareerNames, params._pCiKeIcon3)

    table.insert(self._tCRInfoCareerGroupInfo, params._pZhanShiCz1)
    table.insert(self._tCRInfoCareerGroupInfo, params._pFaShiCz2)
    table.insert(self._tCRInfoCareerGroupInfo, params._pCiKeCz3)

    table.insert(self._tCRInfoCareerDifficults, params._pStartImage006)
    table.insert(self._tCRInfoCareerDifficults, params._pStartImage007)
    table.insert(self._tCRInfoCareerDifficults, params._pStartImage008)
    table.insert(self._tCRInfoCareerDifficults, params._pStartImage009)
    table.insert(self._tCRInfoCareerDifficults, params._pStartImage010)

    self:addChild(self._pCRPanelCCS)
    
    self._pCRBackButton:setZoomScale(nButtonZoomScale)  
    self._pCRBackButton:setPressedActionEnabled(true)
    
    self._pCRRandomNameButton:setZoomScale(nButtonZoomScale)  
    self._pCRRandomNameButton:setPressedActionEnabled(true)
    
    self._pCROKButton:setZoomScale(nButtonZoomScale)  
    self._pCROKButton:setPressedActionEnabled(true)
    
    self._pCRWarriorButton:setZoomScale(nButtonZoomScale)  
    self._pCRWarriorButton:setPressedActionEnabled(true)
    
    self._pCRMageButton:setZoomScale(nButtonZoomScale)  
    self._pCRMageButton:setPressedActionEnabled(true)
    
    self._pCRThugButton:setZoomScale(nButtonZoomScale)
    self._pCRThugButton:setPressedActionEnabled(true)   
    

    -- 设置同类按钮的tag
    self._pCRWarriorButton:setTag(kCareer.kWarrior)
    self._pCRMageButton:setTag(kCareer.kMage)
    self._pCRThugButton:setTag(kCareer.kThug)

    -- 设置控件位置
    self._pCRJobSelectNode:setPosition(0,mmo.VisibleRect:height())
    self._pCRRandomNameNode:setPosition(mmo.VisibleRect:width()/2,0)
    self._pCRInfoFrameNode:setPosition(mmo.VisibleRect:width(),mmo.VisibleRect:height())
    
    self._pCROKButton:setPositionX(mmo.VisibleRect:width()/2 - self._pCROKButton:getContentSize().width*0.5 - 10)
    self._pCRBackButton:setPositionX(-mmo.VisibleRect:width()/2 + 10 + self._pCRBackButton:getContentSize().width*0.5)
    
    -- 设置默认职业选项
    self:showCRCareerInfoByIndex(self._kCRCurCareer)
   
end

-- 处理控件回调相关
function RoleCreateLayer:disposeWidget()
    -- 给返回按钮添加回调函数
    local function onReturnButton(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
         if self:getGameScene():getLayerByName("RoleLayer")._nOperateType == 2 then
            self:getGameScene():getLayerByName("RoleLayer")._nOperateType = 1
            self:getGameScene():showLayer(require("RoleSelectLayer"):create())
            self:close()
         else
            -- 禁用按钮
            self:setAllButtonsTouchEnable(false)
            -- 创建登录层
            self:getGameScene():showLayer(require("LoginLayer"):create())
            local loginLayer = self:getGameScene():getLayerByName("LoginLayer")
            loginLayer:setPositionX(-loginLayer._pBg:getContentSize().width)
            loginLayer:hideAllAccountWidgets()
            -- 创建动画过度
            local act = cc.Sequence:create(cc.EaseExponentialInOut:create(cc.MoveBy:create(1.0, cc.p(loginLayer._pBg:getContentSize().width, 0))), cc.CallFunc:create(self.close))
            local actCopy1 = cc.Sequence:create(cc.EaseExponentialInOut:create(cc.MoveBy:create(1.0, cc.p(loginLayer._pBg:getContentSize().width, 0))), cc.CallFunc:create(self.close))
            local actCopy2 = cc.Sequence:create(cc.EaseExponentialInOut:create(cc.MoveBy:create(1.0, cc.p(loginLayer._pBg:getContentSize().width, 0))))
            self:runAction(act)
            self:getGameScene():getLayerByName("RoleLayer"):runAction(actCopy1)
            loginLayer:runAction(actCopy2)      
            -- 断开网络
            loginLayer:refreshConnect()
          
         end
       elseif eventType == ccui.TouchEventType.began then
         AudioManager:getInstance():playEffect("ButtonClick")
       end
    end
    self._pCRBackButton:addTouchEventListener(onReturnButton)

    -- 随机名字按钮回调函数
    local function getRandomName(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            LoginCGMessage:sendMessageRandomName20002()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pCRRandomNameButton:addTouchEventListener(getRandomName)

    -- 确定按钮回调函数
    local function confirmEnter(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- 如果昵称中存在空格，则提示非法格式！
            for i=1, string.len(self._pNameInPut:getText()) do 
                if string.byte(self._pNameInPut:getText(), i) == 32 then
                    NoticeManager:getInstance():showSystemMessage("昵称中不能存在空格！")
                    return
                end
            end
            
            if strIsHaveMoji(self._pNameInPut:getText()) then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
            end   
            if string.find(self._pNameInPut:getText(),"□") then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
            end
            
            local nMainLen = TableConstants.NameMinLen.Value
            local nMaxLen = TableConstants.NameMaxLen.Value
            local nameLenth = string.len(self._pNameInPut:getText())
            if nameLenth == 0 then
                NoticeManager:getInstance():showSystemMessage("昵称不能为空！")
            elseif nameLenth < nMainLen then
                NoticeManager:getInstance():showSystemMessage("昵称过短！")
            elseif nameLenth > nMaxLen then
                NoticeManager:getInstance():showSystemMessage("昵称过长！")
            else
                LoginCGMessage:sendMessageCreateRole20004({roleCareer = self._kCRCurCareer, roleName = self._pNameInPut:getText(), zoneId = LoginManager:getInstance()._tLastServer.zoneId})
            end

        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pCROKButton:addTouchEventListener(confirmEnter)
    -- 角色按钮回调函数
    local function roleButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self._kCRCurCareer = sender:getTag()
            self:showCRCareerInfoByIndex(self._kCRCurCareer)     
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pCRWarriorButton:addTouchEventListener(roleButtonCallBack)
    self._pCRMageButton:addTouchEventListener(roleButtonCallBack)
    self._pCRThugButton:addTouchEventListener(roleButtonCallBack)
end

-- 随机名字获取
function RoleCreateLayer:randomNameNetBack(event)
    self._pNameInPut:setText(event.name)
end

-- 创建角色网络回调
function RoleCreateLayer:createRoleNetBack(event)    
    -- 是否允许进入（是否是预创建）
    local canEnter = event.isService
    if canEnter ~= 0 then   -- 允许进入        
        -- 记录玩家主角详细信息
        self:getRolesManager()._pMainRoleInfo = event.roleInfo

        -- 设置宠物信息
        for i=1,table.getn(event.roleInfo.pets) do
            PetsManager:getInstance()._tMainPetRoleInfosInQueue[i] = event.roleInfo.pets[i].petInfo
        end
        
        -- 记录玩家金融信息
        local finances = event.roleInfo.finances
        for k,v in pairs(finances) do
            FinanceManager:getInstance()._tCurrency[v.finance] = v.amount
        end

        -- 请求邮件列表
        EmailManager:getInstance():clearCache()
        EmailCGMessage:sendMessageGetMailList22200()
        
        -- 请求在线玩家
        local args = nil
        if OptionManager:getInstance()._nPlayersRoleShowLevel == 3 then
            args = {count=TableConstants.SameScreenMin.Value}
        elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 2 then
            args = {count=TableConstants.SameScreenMid.Value}
        elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 1 then
            args = {count=TableConstants.SameScreenMax.Value}
        end
        OtherPlayersCGMessage:sendMessageOtherPlayers(args)
        
    else  -- 不允许进入，此时进入预创建逻辑，切换到选择角色界面
    
        -- 记录玩家主角详细信息
        self:getRolesManager()._pMainRoleInfo = event.roleInfo
        table.insert(LoginManager:getInstance()._tRoleDisplayInfosList, event.displayInfo)
        
        local roleIndexInQueue = table.getn(LoginManager:getInstance()._tRoleDisplayInfosList)
        self:getGameScene():getLayerByName("RoleLayer")._nOperateType = 3
        self:getGameScene():showLayer(require("RoleSelectLayer"):create(roleIndexInQueue))
        self:close()
    end

end

-- 进入游戏
function RoleCreateLayer:enterGame(event)

    -- 禁用按钮
    self:setAllButtonsTouchEnable(false)
    
    -- 设置进入世界家园的标记位
    print_lua_table(self:getRolesManager()._pMainRoleInfo)
    self._bToWorldLayer = true

    -- 读取上一次中断的新手ID
    NewbieManager:getInstance():getSkipStory()
    if NewbieManager:getInstance()._bSkipGuide == false then
        isFirstLoginMain = false
        LayerManager:getInstance():gotoRunningSenceLayer(GUIDE_SENCE_LAYER)
    else
        isFirstLoginMain = true
        LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
    end
    NewbieManager:getInstance():setMainFuncLevel(2)

    -- 初始化嘟嘟语音模块
    mmo.HelpFunc:initDuduVoice(LoginManager:getInstance()._tLastServer.zoneId, self:getRolesManager()._pMainRoleInfo.roleId)

    if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
        local info = LoginManager:getInstance()._tLastServer
        -- 母包登录完成数据统计接口
        mmo.HelpFunc:loginOKZTGame(self:getRolesManager()._pMainRoleInfo.roleId, self:getRolesManager()._pMainRoleInfo.roleName, self:getRolesManager()._pMainRoleInfo.level, info.zoneId, info.zoneName)
        -- 母包创建角色数据统计接口   
        mmo.HelpFunc:createRoleZTGame(self:getRolesManager()._pMainRoleInfo.roleId, self:getRolesManager()._pMainRoleInfo.roleName, self:getRolesManager()._pMainRoleInfo.level, info.zoneId, info.zoneName)
    end
    
    
    
end


-- 创建角色界面中显示信息面板上的信息
function RoleCreateLayer:showCRCareerInfoByIndex(CareerIndex)
    -- 显示人物模型
    for n = 1, table.getn(self._tCRRoleList) do
        self._tCRRoleList[n]:setVisible(false)
    end
    self._tCRRoleList[CareerIndex]:setVisible(true)
    self._tCRRoleList[CareerIndex]:stopAllActions()
    self._tCRRoleList[CareerIndex]:runAction(self._tCRRoleActions[CareerIndex])
    
    -- 人物声音
    local voiceIndex = getRandomNumBetween(1,table.getn(TableTempleteCareers[CareerIndex].Voice))
    AudioManager:getInstance():playEffect(TableTempleteCareers[CareerIndex].Voice[voiceIndex])
    
    -- 显示难易程度
    self:showCRDifficultInfo(self._tCRCurCareerDifficultNum[CareerIndex])
    
    -- 显示职业名称
    for n=1, kCareer.kTotoalNum do
        self._tCRInfoCareerNames[n]:setVisible(false)
    end
    self._tCRInfoCareerNames[CareerIndex]:setVisible(true)
    
    -- 显示职业成长
    for n=1, kCareer.kTotoalNum do
        self._tCRInfoCareerGroupInfo[n]:setVisible(false)
    end
    self._tCRInfoCareerGroupInfo[CareerIndex]:setVisible(true)
    
    -- 粒子选中特效和按钮选中状态
    self._pCRSelectedCareerParticle:resetSystem()
    self._pCRWarriorButton:setBright(true)
    self._pCRMageButton:setBright(true)
    self._pCRThugButton:setBright(true)
    if CareerIndex == kCareer.kWarrior then
        self._pCRSelectedCareerParticle:setPosition(cc.p(self._pCRWarriorButton:getPositionX(), self._pCRWarriorButton:getPositionY()))
        self._pCRWarriorButton:setBright(false)
    elseif CareerIndex == kCareer.kMage then
        self._pCRSelectedCareerParticle:setPosition(cc.p(self._pCRMageButton:getPositionX(), self._pCRMageButton:getPositionY()))
        self._pCRMageButton:setBright(false)
    elseif CareerIndex == kCareer.kThug then
        self._pCRSelectedCareerParticle:setPosition(cc.p(self._pCRThugButton:getPositionX(), self._pCRThugButton:getPositionY()))
        self._pCRThugButton:setBright(false)
    end
    
    
end

-- 创建角色界面中显示信息面板上的难易程度
function RoleCreateLayer:showCRDifficultInfo(num)
    for n=1, 5 do
        self._tCRInfoCareerDifficults[n]:setVisible(true)
    end
    for n=1, num do
        self._tCRInfoCareerDifficults[n]:setVisible(false)
    end
end

-- 添加波纹特效
-- 参数1：位置类型，如身、背、武器
-- 参数2：特效类型
function RoleCreateLayer:addWaveEffect(career, posType, type)
    local tAniPvrNames = {}
    local tAnis = {}
    local strEffectPvrName = "" 
    local color = cc.vec4(1,1,1,1)

    if posType == kType.kBodyParts.kBody then
        table.insert(tAniPvrNames,TableTempleteEquips[TableTempleteCareers[career].FashionEquTempleteID[2]].Texture)
        table.insert(tAnis,self._tCRRoleList[career])
    elseif posType == kType.kBodyParts.kWeapon then
        if self._tCRWeaponList[career][1] then           
            table.insert(tAniPvrNames,TableTempleteEquips[TableTempleteCareers[career].WeaponEquTempleteID].Texture)
            table.insert(tAnis,self._tCRWeaponList[career][1])
        end
        if self._tCRWeaponList[career][2] then           
            table.insert(tAniPvrNames,TableTempleteEquips[TableTempleteCareers[career].WeaponEquTempleteID].Texture)
            table.insert(tAnis,self._tCRWeaponList[career][2])
        end
    elseif posType == kType.kBodyParts.kBack then
        table.insert(tAniPvrNames,TableTempleteEquips[TableTempleteCareers[career].FashionEquTempleteID[1]].Texture)
        table.insert(tAnis,self._tCRBackList[career])
    end

    if type == 1 then
        strEffectPvrName = "caustics"
        color = cc.vec4(1,1,1,1)
    elseif type == 2 then
        strEffectPvrName = "caustics"
        color = cc.vec4(1,0,0,1)
    elseif type == 3 then
        strEffectPvrName = "caustics"
        color = cc.vec4(0,0,1,1)
    end

    for k, v in pairs(tAnis) do 
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(strEffectPvrName)
        mmo.HelpFunc:addWaveEffectByShader(tAnis[k], tAniPvrNames[k]..".pvr.ccz", strEffectPvrName..".pvr.ccz", color)
    end

    local tWaveEffectsInfo = self._ttWaveEffectsInfo[career]
    tWaveEffectsInfo[posType] = {}
    tWaveEffectsInfo[posType][1] = tAnis -- 正在显示波纹shader特效的3d模型集合   
    tWaveEffectsInfo[posType][2] = {}
    for k, v in pairs(tWaveEffectsInfo[posType][1]) do
        table.insert(tWaveEffectsInfo[posType][2],cc.p(0,0)) -- 波纹shader特效在模型上的UV坐标集合        
    end
    self._ttWaveEffectsInfo[career] = tWaveEffectsInfo

end

-- 断线重连
function RoleCreateLayer:handleNetReconnected(event)
    if self:getRolesManager()._pMainRoleInfo ~= nil then
        -- 请求在线玩家
        local args = nil
        if OptionManager:getInstance()._nPlayersRoleShowLevel == 3 then
            args = {count=TableConstants.SameScreenMin.Value}
        elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 2 then
            args = {count=TableConstants.SameScreenMid.Value}
        elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 1 then
            args = {count=TableConstants.SameScreenMax.Value}
        end
        OtherPlayersCGMessage:sendMessageOtherPlayers(args)
    end
end

function RoleCreateLayer:setAllButtonsTouchEnable(enable)
    self._pCRBackButton:setTouchEnabled(enable)
    self._pCRRandomNameButton:setTouchEnabled(enable)
    self._pCROKButton:setTouchEnabled(enable)
    self._pNameInPut:setTouchEnabled(enable)
    self._pCRWarriorButton:setTouchEnabled(enable)
    self._pCRMageButton:setTouchEnabled(enable)
    self._pCRThugButton:setTouchEnabled(enable)
end

return RoleCreateLayer
