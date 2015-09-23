--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleSelectLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/24
-- descrip:   角色选择层
--===================================================
local RoleSelectLayer = class("RoleSelectLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function RoleSelectLayer:ctor()
    self._strName = "RoleSelectLayer"     -- 层名称
    
    self._pSRPanelCCS = nil               -- [选择角色]选择角色panel的ccs
    self._pSRCreateRoleNode = nil         -- [选择角色]创建角色按钮节点
    self._pSRCreateRoleButton1 = nil      -- [选择角色]创建角色按钮1
    self._pWarriorButton1 = nil           -- [选择角色]战士角色切换按钮1
    self._pMageButton1 = nil              -- [选择角色]法师角色切换按钮1
    self._pThugButton1 = nil              -- [选择角色]刺客角色切换按钮1
    self._tHasCreatedRoleButtons = {}     -- [选择角色]已经创建了的角色的button集合
    self._pSRSelectedParticle = nil       -- [选择角色]选中的按钮button的粒子特效
    self._pSRNameInfoNode = nil           -- [选择角色]名称信息节点
    self._pSRNameInfBg = nil              -- [选择角色]名称信息背景
    self._pSRLvInfText = nil              -- [选择角色]等级信息文本
    self._pSRNameInfText = nil            -- [选择角色]名称信息文本
    self._pSRReturnButton = nil           -- [选择角色]返回按钮
    self._pSRStartButtonNode = nil        -- [选择角色]开始按钮节点
    self._pSRStartButton = nil            -- [选择角色]开始按钮
    self._tSRRoleList = {}                -- [选择角色]当前持有的职业角色模型动画列表
    self._tSRWeaponList = {}              -- [选择角色]当前持有职业角色武器模型动画列表
    self._tSRBackList = {}                -- [选择角色]当前持有职业角色时装背模型动画列表
    self._tSRRoleActions = {}             -- [选择角色]当前持有的职业角色模型出场动画
    
    self._tBodyPvrNames = {}              -- [选择角色]当前持有的职业角色模型贴图名称列表
    self._tWeaponPvrNames = {}            -- [选择角色]当前持有职业角色武器模型贴图名称列表
    self._tBackPvrNames = {}              -- [选择角色]当前持有职业角色时装背模型贴图名称列表

    self._nCurRoleIndex = 0               -- [选择角色]当前选中的持有的职业角色index
    self._bToWorldLayer = false           -- [选择角色]是否进入到世界家园的标记位，用于切换场景时
    
    self._ttWaveEffectsInfo = {{},{},{}}  -- 每个职业中包括：[1] 身的信息  [2]武器的信息  [3]背的信息    （而这里每一项的格式为：{t模型集合, t特效位置集合}）
    self._tCurWaveEffectsInfo = {}        -- [1] 身的信息  [2]武器的信息  [3]背的信息    （每一项的格式为：{t模型集合, t特效位置集合}）
    
end

-- 创建函数
function RoleSelectLayer:create(roleIndexInQueue)
    local layer = RoleSelectLayer.new()
    layer:dispose(roleIndexInQueue)
    return layer
end

-- 处理函数
function RoleSelectLayer:dispose(roleIndexInQueue)

    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kEntryBattle ,handler(self, self.entryBattleCopy))
    NetRespManager:getInstance():addEventListener(kNetCmd.kOtherPlayerInfos, handler(self, self.enterGame))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected, handler(self, self.handleNetReconnected))
    
    -- 初始化人物
    self:initRoles()
    
    -- 初始化UI
    self:initUI(roleIndexInQueue)
    
    -- 处理控件回调相关
    self:disposeWidget()


    -- 测试：添加波纹特效
    --[[
    self:addWaveEffect(1,kType.kBodyParts.kBody,1)
    self:addWaveEffect(1,kType.kBodyParts.kWeapon,2)
    self:addWaveEffect(1,kType.kBodyParts.kBack,3)
    ]]
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRoleSelectLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function RoleSelectLayer:onExitRoleSelectLayer()    
    self:onExitLayer()
    
    -- 释放角色动作序列
    for k,v in pairs(self._tSRRoleActions) do
        v:release()
    end
    
    NetRespManager:getInstance():removeEventListenersByHost(self)
    
end

-- 循环更新
function RoleSelectLayer:update(dt)
    self._tCurWaveEffectsInfo = self._ttWaveEffectsInfo[self._nCurRoleIndex]
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
function RoleSelectLayer:doWhenShowOver()    
    return
end

-- 关闭结束时的回调
function RoleSelectLayer:doWhenCloseOver()
    if self._bToWorldLayer then
        BuffSystemCGMessage:sendMessageGetBuff23100()
        FamilyCGMessage:entryFamilyReq22302()
        
        --LayerManager:getInstance():transformToLoading()
        
    end
    return
end

-- 显示（带动画）
function RoleSelectLayer:showWithAni()
    self:setVisible(true)
    self:stopAllActions()
    return
end

-- 关闭（带动画）
function RoleSelectLayer:closeWithAni()
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
function RoleSelectLayer:initRoles()
    -- 玩家持有的职业动画初始化
    for k,v in pairs(LoginManager:getInstance()._tRoleDisplayInfosList) do

        -- 身体部位的装备
        local tRoleTempleteInfo = nil
        local templeteID = TableEquips[v.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[v.roleCareer]
        tRoleTempleteInfo = TableTempleteEquips[templeteID]
        
        -- 判断是否加载时装身
        if v.fashionOptions and v.fashionOptions[2] == true then -- 时装身
            for i=1,table.getn(v.equipemts) do --遍历装备集合
                local nPart = GetCompleteItemInfo(v.equipemts[i]).dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionBody then  -- 时装部位
                    local templeteID = TableEquips[v.equipemts[kEqpLocation.kFashionBody].id - 100000].TempleteID[v.roleCareer]
                    tRoleTempleteInfo = TableTempleteEquips[templeteID]
                    break
                end
            end
        end

        local pRole = nil
        if tRoleTempleteInfo ~= nil then
            local fullAniName = tRoleTempleteInfo.Model1..".c3b"
            local fullTextureName = tRoleTempleteInfo.Texture..".pvr.ccz"
            table.insert(self._tBodyPvrNames, tRoleTempleteInfo.Texture)
            -- 记录并加载到纹理缓存中
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tRoleTempleteInfo.Texture)
            -- 创建角色
            pRole = cc.Sprite3D:create(fullAniName)
            pRole:setTexture(fullTextureName)
            pRole:setScale(TableTempleteCareers[v.roleCareer].ScaleInLogin)
            pRole:setPosition(mmo.VisibleRect:width()/2,121)
            self:addChild(pRole)
            table.insert(self._tSRRoleList, pRole)
        end

        -- 武器模型
        local tWeaponTempleteInfo = nil
        for kEquip, vEquip in pairs(v.equipemts) do 
            if TableEquips[vEquip.id - 100000].Part == kEqpLocation.kWeapon then  -- 武器部位的装备
                local templeteID = TableEquips[vEquip.id - 100000].TempleteID[v.roleCareer]
                tWeaponTempleteInfo = TableTempleteEquips[templeteID]
            end
        end
        if tWeaponTempleteInfo ~= nil then
            local fullAniNameWeaponR = tWeaponTempleteInfo.Model1..".c3b"
            local fullAniNameWeaponL = nil
            if tWeaponTempleteInfo.Model2 then
                fullAniNameWeaponL = tWeaponTempleteInfo.Model2..".c3b"
            end
            local fullTextureName = tWeaponTempleteInfo.Texture..".pvr.ccz"
            table.insert(self._tWeaponPvrNames, tWeaponTempleteInfo.Texture)
            -- 记录并加载到纹理缓存中
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tWeaponTempleteInfo.Texture)
            local weapons = {}
            if fullAniNameWeaponR then
                local pWeaponR = cc.Sprite3D:create(fullAniNameWeaponR)
                pWeaponR:setTexture(fullTextureName)
                pWeaponR:setScale(tWeaponTempleteInfo.ModelScale1)
                local animation = cc.Animation3D:create(fullAniNameWeaponR)
                local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
                pWeaponR:runAction(act)
                pRole:getAttachNode("boneRightHandAttach"):addChild(pWeaponR)
                table.insert(weapons,pWeaponR)
            end
            if fullAniNameWeaponL then
                local pWeaponL = cc.Sprite3D:create(fullAniNameWeaponL)
                pWeaponL:setTexture(fullTextureName)
                pWeaponL:setScale(tWeaponTempleteInfo.ModelScale2)
                local animation = cc.Animation3D:create(fullAniNameWeaponL)
                local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
                pWeaponL:runAction(act)
                pRole:getAttachNode("boneLeftHandAttach"):addChild(pWeaponL)
                table.insert(weapons,pWeaponL)
            end
            
            table.insert(self._tSRWeaponList, weapons)
        end
        
        
        -- 判断是否加载时装背
        local tFashionBackTempleteInfo = nil
        if v.fashionOptions and v.fashionOptions[1] == true then            
            for i=1,table.getn(v.equipemts) do --遍历装备集合
                local nPart = GetCompleteItemInfo(v.equipemts[i]).dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                    local templeteID = TableEquips[v.equipemts[kEqpLocation.kFashionBack].id - 100000].TempleteID[v.roleCareer]
                    tFashionBackTempleteInfo = TableTempleteEquips[templeteID] 
                    break     
                end
            end
        end
        
        if tFashionBackTempleteInfo then
            local fullAniName = tFashionBackTempleteInfo.Model1..".c3b"
            local fullTextureName = tFashionBackTempleteInfo.Texture..".pvr.ccz"
            table.insert(self._tBackPvrNames, tFashionBackTempleteInfo.Texture)
            -- 记录并加载到纹理缓存中
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionBackTempleteInfo.Texture)
            local back = cc.Sprite3D:create(fullAniName)
            back:setTexture(fullTextureName)
            back:setScale(tFashionBackTempleteInfo.ModelScale1)
            local animation = cc.Animation3D:create(fullAniName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            back:runAction(act)
            pRole:getAttachNode("boneBackAttach"):addChild(back)
            table.insert(self._tSRBackList, back)
        end
        
        -- 动作初始化
        local animation = cc.Animation3D:create(tRoleTempleteInfo.Model1..".c3b")
        local function helloOver()
            local actStand = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, TableTempleteCareers[v.roleCareer].StandActFrameRegion[1], TableTempleteCareers[v.roleCareer].StandActFrameRegion[2]))
            pRole:runAction(actStand)
        end
        local actHello = cc.Animate3D:createWithFrames(animation, TableTempleteCareers[v.roleCareer].AppearActFrameRegion[1], TableTempleteCareers[v.roleCareer].AppearActFrameRegion[2])
        local act = cc.Sequence:create(actHello, cc.CallFunc:create(helloOver))
        act:retain()
        table.insert(self._tSRRoleActions,act)
    end
    
end

-- 初始化UI
function RoleSelectLayer:initUI(roleIndexInQueue)
    -- 加载组件
    local params = require("RoleSlectPanelParams"):create()
    self._pSRPanelCCS = params._pCCS
    self._pSRCreateRoleNode = params._pCreatRolePoint
    self._pSRCreateRoleButton1 = params._pCreatRoleButton001
    self._pWarriorButton1 = params._pZhanShiButton1
    self._pMageButton1 = params._pFaShiButton1
    self._pThugButton1 = params._pCiKeButton1
    self._pSRSelectedParticle = params._pEdging
    self._pSRNameInfoNode = params._pNameInfPoint
    self._pSRNameInfBg = params._pInfBg
    self._pSRLvInfText = params._pLvText
    self._pSRNameInfText = params._pNameText
    self._pSRReturnButton = params._pReturnButton
    self._pSRStartButtonNode = params._pStartPoint
    self._pSRStartButton = params._pStartGameButton
    self:addChild(self._pSRPanelCCS)
    
    self._pSRSelectedParticle:setPositionType(cc.POSITION_TYPE_GROUPED)
    
    -- 九宫格
    local pStartGameBg = params._pStartGameBg
    pStartGameBg:setContentSize(cc.size(mmo.VisibleRect:width(),137))
    
    self._pSRCreateRoleButton1:setZoomScale(nButtonZoomScale)  
    self._pSRCreateRoleButton1:setPressedActionEnabled(true)
    self._pWarriorButton1:setZoomScale(nButtonZoomScale)  
    self._pWarriorButton1:setPressedActionEnabled(true)
    self._pMageButton1:setZoomScale(nButtonZoomScale)
    self._pMageButton1:setPressedActionEnabled(true)
    self._pThugButton1:setZoomScale(nButtonZoomScale)
    self._pThugButton1:setPressedActionEnabled(true)
    self._pSRReturnButton:setZoomScale(nButtonZoomScale)
    self._pSRReturnButton:setPressedActionEnabled(true)
    self._pSRStartButton:setZoomScale(nButtonZoomScale)
    self._pSRStartButton:setPressedActionEnabled(true)    
    
    self._pWarriorButton1:setVisible(false)
    self._pMageButton1:setVisible(false)
    self._pThugButton1:setVisible(false)

    if LoginManager:getInstance()._tRoleDisplayInfosList[1] ~= nil then
        if LoginManager:getInstance()._tRoleDisplayInfosList[1].roleCareer == kCareer.kWarrior then
            self._pWarriorButton1:setVisible(true)
            self._pSRCreateRoleButton1:setVisible(false)
            self._tHasCreatedRoleButtons[1] = self._pWarriorButton1
        elseif LoginManager:getInstance()._tRoleDisplayInfosList[1].roleCareer == kCareer.kMage then
            self._pMageButton1:setVisible(true)
            self._pSRCreateRoleButton1:setVisible(false)
            self._tHasCreatedRoleButtons[1] = self._pMageButton1
        elseif LoginManager:getInstance()._tRoleDisplayInfosList[1].roleCareer == kCareer.kThug then
            self._pThugButton1:setVisible(true)
            self._pSRCreateRoleButton1:setVisible(false)
            self._tHasCreatedRoleButtons[1] = self._pThugButton1
        end
    end
    
    
    -- 设置控件位置
    self._pSRCreateRoleNode:setPosition(0,mmo.VisibleRect:height())
    self._pSRNameInfoNode:setPosition(mmo.VisibleRect:width(),mmo.VisibleRect:height())
    self._pSRStartButtonNode:setPosition(mmo.VisibleRect:width()/2,0)
    
    self._pSRReturnButton:setPositionX(-mmo.VisibleRect:width()/2 + 10 + self._pSRReturnButton:getContentSize().width*0.5)
    
    -- 显示默认第一个持有职业
    self:showSRRoleInfo(roleIndexInQueue)   
end

-- 处理控件回调相关
function RoleSelectLayer:disposeWidget()
    -- 给返回按钮添加回调函数
    local function onReturnButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
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
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end   
    self._pSRReturnButton:addTouchEventListener(onReturnButton)

    -- 进入游戏按钮回调函数
    local function onStartButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then   
            self:enterToWordUiLayer()              
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pSRStartButton:addTouchEventListener(onStartButton)

    -- 角色创建按钮回调函数
    local function onCreateRoleButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:getGameScene():getLayerByName("RoleLayer")._nOperateType = 2
            self:getGameScene():showLayer(require("RoleCreateLayer"):create())
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pSRCreateRoleButton1:addTouchEventListener(onCreateRoleButton)

    -- 已经创建好的角色按钮回调函数
    local function onExistRoleButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self._pWarriorButton1 or sender == self._pMageButton1 or sender == self._pThugButton1 then
                self:showSRRoleInfo(1)
            elseif sender == self._pWarriorButton2 or sender == self._pMageButton2 or sender == self._pThugButton2 then
                self:showSRRoleInfo(2)
            elseif sender == self._pWarriorButton3 or sender == self._pMageButton3 or sender == self._pThugButton3 then
                self:showSRRoleInfo(3)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pWarriorButton1:addTouchEventListener(onExistRoleButton)
    self._pMageButton1:addTouchEventListener(onExistRoleButton)
    self._pThugButton1:addTouchEventListener(onExistRoleButton)
end

-- 选择角色界面中显示角色相关信息
function RoleSelectLayer:showSRRoleInfo(index)
    if index == nil then
        index = 1
    end
    -- 设置当前选中的持有角色index
    self._nCurRoleIndex = index
    
    -- 角色等级+名称
    self._pSRLvInfText:setString("Lv"..LoginManager:getInstance()._tRoleDisplayInfosList[index].level)
    self._pSRLvInfText:setColor(cGreen)
    --self._pSRLvInfText:enableShadow(cc.c4b(0, 0, 0, 255))
    --self._pSRLvInfText:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    
    self._pSRNameInfText:setString(LoginManager:getInstance()._tRoleDisplayInfosList[index].roleName)
    self._pSRNameInfText:setColor(cWhite)
    --self._pSRNameInfText:enableShadow(cc.c4b(0, 0, 0, 255))
    --self._pSRNameInfText:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    
    -- 人物声音
    local voiceIndex = getRandomNumBetween(1,table.getn(TableTempleteCareers[LoginManager:getInstance()._tRoleDisplayInfosList[index].roleCareer].Voice))
    AudioManager:getInstance():playEffect(TableTempleteCareers[LoginManager:getInstance()._tRoleDisplayInfosList[index].roleCareer].Voice[voiceIndex])
    
    -- 显示人物模型
    for n = 1, table.getn(self._tSRRoleList) do
        self._tSRRoleList[n]:setVisible(false)
    end
    self._tSRRoleList[index]:setVisible(true)
    self._tSRRoleList[index]:stopAllActions()
    self._tSRRoleList[index]:runAction(self._tSRRoleActions[index])
    
    -- 粒子选中特效和按钮选中状态
    for k,v in pairs(self._tHasCreatedRoleButtons) do 
        v:setBright(true)
    end
    self._tHasCreatedRoleButtons[index]:setBright(false)
    self._pSRSelectedParticle:setPosition(cc.p(self._tHasCreatedRoleButtons[index]:getPositionX(), self._tHasCreatedRoleButtons[index]:getPositionY()))

end

-- 进入游戏
function RoleSelectLayer:enterGame(event)
    -- 禁用按钮
    self:setAllButtonsTouchEnable(false)
    -- 是否演示剧情动画
    local temp = NewbieManager:getBePlayStoryAniOrNot()
    -- 获取是否跳过引导
    NewbieManager:getInstance():getSkipStory()
    -- 获取引导存档id
    local guideId = NewbieManager:getInstance():loadMainID()

    if temp == true then
        if guideId ~= nil and guideId == "Guide_1_1" and NewbieManager:getInstance()._bSkipGuide == false then
            -- 进入新手第一关卡
            self._bToWorldLayer = true
            self._pSelectedCopysFirstMapInfo = TableStoryCopysMaps[TableStoryCopys[1].MapID]
            MessageGameInstance:sendMessageEntryBattle21002(TableStoryCopys[1].ID,0) 
        else
            -- 进入主城界面
            self._bToWorldLayer = true
            isFirstLoginMain = true
            LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
        end
    elseif temp == false and NewbieManager:getInstance()._bSkipGuide == false and self:getRolesManager()._pMainRoleInfo.level == 1 then
        self._bToWorldLayer = true
        isFirstLoginMain = false
        LayerManager:getInstance():gotoRunningSenceLayer(GUIDE_SENCE_LAYER)

    else
        self._bToWorldLayer = true
        isFirstLoginMain = true
        LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
    end

    -- 初始化嘟嘟语音模块
    mmo.HelpFunc:initDuduVoice(LoginManager:getInstance()._tLastServer.zoneId, self:getRolesManager()._pMainRoleInfo.roleId)

    if isMobilePlatform() == true and bOpenMobileAndWinMacSameLoginWay == false then
        local info = LoginManager:getInstance()._tLastServer
        -- 母包登录完成数据统计接口
        mmo.HelpFunc:loginOKZTGame(self:getRolesManager()._pMainRoleInfo.roleId, self:getRolesManager()._pMainRoleInfo.roleName, self:getRolesManager()._pMainRoleInfo.level, info.zoneId, info.zoneName)
    end
end

-- 添加波纹特效
-- 参数1：位置类型，如身、背、武器
-- 参数2：特效类型
function RoleSelectLayer:addWaveEffect(index, posType, type)
    local tAniPvrNames = {}
    local tAnis = {}
    local strEffectPvrName = "" 
    local color = cc.vec4(1,1,1,1)

    if posType == kType.kBodyParts.kBody then
        table.insert(tAniPvrNames,self._tBodyPvrNames[index])
        table.insert(tAnis,self._tSRRoleList[index])
    elseif posType == kType.kBodyParts.kWeapon then
        if self._tSRWeaponList[index][1] then           
            table.insert(tAniPvrNames,self._tWeaponPvrNames[index])
            table.insert(tAnis,self._tSRWeaponList[index][1])
        end
        if self._tSRWeaponList[index][2] then           
            table.insert(tAniPvrNames,self._tWeaponPvrNames[index])
            table.insert(tAnis,self._tSRWeaponList[index][2])
        end
    elseif posType == kType.kBodyParts.kBack then
        table.insert(tAniPvrNames,self._tBackPvrNames[index])
        table.insert(tAnis,self._tSRBackList[index])
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

    local tWaveEffectsInfo = self._ttWaveEffectsInfo[index]
    tWaveEffectsInfo[posType] = {}
    tWaveEffectsInfo[posType][1] = tAnis -- 正在显示波纹shader特效的3d模型集合   
    tWaveEffectsInfo[posType][2] = {}
    for k, v in pairs(tWaveEffectsInfo[posType][1]) do
        table.insert(tWaveEffectsInfo[posType][2],cc.p(0,0)) -- 波纹shader特效在模型上的UV坐标集合        
    end
    self._ttWaveEffectsInfo[index] = tWaveEffectsInfo

end

function RoleSelectLayer:entryBattleCopy(event)
    --战斗数据组装
    -- 【战斗数据对接】
    local args = {}
    args._strNextMapName = self._pSelectedCopysFirstMapInfo.MapsName
    args._strNextMapPvrName = self._pSelectedCopysFirstMapInfo.MapsPvrName
    args._nNextMapDoorIDofEntity = self._pSelectedCopysFirstMapInfo.Doors[1][1]
    --require("TestMainRoleInfo")    --roleInfo  
    args._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo
    args._nMainPlayerRoleCurHp = nil      -- 从副本进入时，这里为无效值
    args._nMainPlayerRoleCurAnger = nil   -- 从副本进入时，这里为无效值
    args._nMainPetRoleCurHp = nil         -- 从副本进入时，这里为无效值
    args._nCurCopyType =TableStoryCopys[1].CopysType
    args._nCurStageID = TableStoryCopys[1].ID
    args._nCurStageMapID = TableStoryCopys[1].MapID
    args._nBattleId = TableStoryCopys[1].ID
    args._fTimeMax = TableStoryCopys[1].Timeing
    args._bIsAutoBattle = false
    args._tMonsterDeadNum = {}
    args._nIdentity = 0
    args._tTowerCopyStepResultInfos = {}
    args._pPvpRoleInfo = nil
    args._tPvpRoleMountAngerSkills = {}
    args._tPvpRoleMountActvSkills = {}
    args._tPvpPasvSkills = {}
    args._tPvpPetRoleInfosInQueue = {}

    --切换战斗场景
    isFirstLoginMain = false
    LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
end

function RoleSelectLayer:setAllButtonsTouchEnable(enable)
    self._pSRCreateRoleButton1:setTouchEnabled(enable)
    self._pWarriorButton1:setTouchEnabled(enable)
    self._pMageButton1:setTouchEnabled(enable)
    self._pThugButton1:setTouchEnabled(enable)
    for k, v in pairs(self._tHasCreatedRoleButtons) do
        v:setTouchEnabled(enable)
    end
    self._pSRReturnButton:setTouchEnabled(enable)
    self._pSRStartButton:setTouchEnabled(enable)
end

function RoleSelectLayer:handleNetReconnected(event)
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

function RoleSelectLayer:enterToWordUiLayer()
    LoginManager:getInstance()._nRoleId = LoginManager:getInstance()._tRoleDisplayInfosList[self._nCurRoleIndex].roleId
    local pRoleInfo = LoginManager:getInstance()._tRoleDisplayInfosList[self._nCurRoleIndex]
    PetCGMessage:sendMessageGetPetsList21500()
    BagCommonCGMessage:sendMessageGetBagList20100()
    SkillCGMessage:sendMessageQuerySkillList21400()  
    FriendCGMessage:sendMessageQueryFriendList22000()
    MessageGameInstance:sendMessageQueryStoryBattleList21008(0)
    TaskCGMessage:sendMessageQueryTasks21700()
    MessageCommonUtil:sendMessageQueryNewerPro21310()

    local canEnter =  LoginManager:getInstance()._nIsService
    if canEnter ~= 0 then   -- 允许进入
        -- 记录玩家主角详细信息
        self:getRolesManager():setMainRole(pRoleInfo)

        -- 设置宠物信息
        -- 清空一下缓存数据
        PetsManager:getInstance()._tMainPetRoleInfosInQueue = nil 
        PetsManager:getInstance():clearCache()
        for i=1,table.getn(pRoleInfo.pets) do
            PetsManager:getInstance()._tMainPetRoleInfosInQueue[i] = pRoleInfo.pets[i].petInfo
        end
        
        -- 记录玩家金融信息
        local finances = pRoleInfo.finances
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
        
    else  -- 不允许进入，则给出提示
        showSystemMessage("服务器暂未开放，敬请期待哦  亲~")
    end
	
end


return RoleSelectLayer
