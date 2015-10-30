--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RolesInfoDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2014/12/16
-- descrip:   人物角色信息
--===================================================
local RolesInfoDialog = class("RolesInfoDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function RolesInfoDialog:ctor()
    self._strName = "RolesInfoDialog"        -- 层名称

    self._pBg = nil
    self._pCloseButton = nil
    self._pRoleName = nil                      --角色名字 lable
    self._pRoleLevel = nil                     --角色等级 lable
    self._pFightingPower = nil                 --战斗力  lable
    self._pRoleLeftNode = nil                  --挂载人物的node
    self._pNodeRigh = nil                      --挂在左侧的属性node
    self._pPlayer = nil                        --人物的背景框
    self._pWeapon1 = nil                       --武器1
    self._pWeapon2 = nil                       --武器2
    self._pFashionBack = nil                   --时装翅膀
    self._pFashionHalo = nil                   --时装光环
    self._tEquALlNode = {}                     --所有的装备的挂载信息

    self._pCurSelectRoleType = RoleDialogTabType.RoleDialogTypeBag

    self._pPanelExchange  = true               -- 背包层和人物属性层标识  背包层 true ; 人物属性层 false
    self._pCheckBoxTable = {true, true, true}  -- 时装的默认都是显示的
    self._pCheckBoxHasVis = {false,false,false}-- 时装是否拥有，默认都是没有的
    self._pRolePlayer = nil                    --人物3d模型 sprite3d
    self._tTempletetInfo = nil                 -- 人物的信息表
    self._tAllActions = {}                     -- 角色所有的动作集合
    self._pArrayTableSprite = {}               -- 装备精灵集合
    self._nClickIndex = -1                     -- 点击时装的CheckBox的index
    self._tArrayCheckBox = {}                  -- 时装的CheckBox集合
    self._tRoleInfo = {}                       -- 人物的info
    self._pLastRoleAni = nil                   --记录上一次角色ani
    self._pRoleTexture = nil                   --角色的贴图
    self._pWeaPonTexture = nil                 --武器的贴图
    self._pFashionBackTexture = nil            --翅膀的贴图

    self._bRoleAniHasChange = false            --记录角色的ani是否改变

    self._pNodeRigh = nil
    self._pBagView = nil                       --背包view
    self._pDetailInfoView = nil                --详细属性view
    
    --选中特效相关
    self._pSelectedCell = nil
    self._tWaveEffectsInfo = {}                -- [1] 身的信息  [2]武器的信息  [3]背的信息    （每一项的格式为：{t模型集合, t特效UV位置集合, 特效类型}）
end

-- 创建函数
function RolesInfoDialog:create(args)
    local dialog = RolesInfoDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function RolesInfoDialog:dispose(args)
    -- 设置是否需要缓存
    self:setNeedCache(true)

    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateRoleInfo ,handler(self, self.updateRoleInfo))
    NetRespManager:getInstance():addEventListener(kNetCmd.kWareEquipment ,handler(self, self.updateEquipmentArray))
    NetRespManager:getInstance():addEventListener(kNetCmd.kFashionHasWare, handler(self, self.updateFashionHasVisable))
    NetRespManager:getInstance():addEventListener(kNetCmd.kWorldLayerTouch,handler(self, self.handleTouchable))
    NetRespManager:getInstance():addEventListener(kNetCmd.kEquipWarning ,handler(self, self.updateEquipWarning))
    ResPlistManager:getInstance():addSpriteFrames("PlayerRolesDialog.plist")

    self._pCurSelectRoleType = args[1]
    --初始化ui
    self:initUi()
    --加载数据
    self:initUiDate()
    --初始化角色的装备信息
    self:initRoleEquInfo()   
    --创建3d模型
    self:createRoleModel()   
    --设置背包跟详细信息的状态
    self:setTabBtnState()

   --self:addWaveEffect(kType.kBodyParts.kBody,3)
   --self:addWaveEffect(kType.kBodyParts.kWeapon,2)
   --self:addWaveEffect(kType.kBodyParts.kBack,2)
   --self:hideWaveEffect(kType.kBodyParts.kBody)
      -- 避免模型穿透
    RolesManager:getInstance():setForceMinPositionZ(true,-10000)
    PetsManager:getInstance():setForceMinPositionZ(true,-10000)

    local pTouchPostion = nil
    local bIsMove = false
    local pTouchRec = self._pPlayer:getBoundingBox()
    self.pTouchBeginP = nil
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        self.pTouchBeginP = location
        local pLocal = self._pRoleLeftNode:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(pTouchRec,pLocal) == true and self._pCurSelectRoleType == RoleDialogTabType.RoleDialogTypeBag then
            pTouchPostion = pLocal
        end

        print("touch begin 11".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
        end
        return true
    end
    local function onTouchMoved(touch,event)
        local location2 = touch:getLocation()
        if (math.abs(self.pTouchBeginP.x - location2.x)+math.abs(self.pTouchBeginP.y - location2.y) <= 2 )then
        	return 
        end
       local location = self._pRoleLeftNode:convertTouchToNodeSpace(touch)

        print("touch move ".."x="..location.x.."  y="..location.y)
        if self._pRolePlayer and pTouchPostion then
            bIsMove = true
            local pRotation = self._pRolePlayer:getRotation3D()
            local dist = location.x - pTouchPostion.x
            pRotation.y = pRotation.y+dist/5
            self._pRolePlayer:setRotation3D(pRotation)
            pTouchPostion = location
        end

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end a ".."x="..location.x.."  y="..location.y)

        local actionOverCallBack = function()  --动画播放完毕的回调 播放默认待机动作
            local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, self._tTempletetInfo.ReadyFightActFrameRegion[1],self._tTempletetInfo.ReadyFightActFrameRegion[2])
            pStandAnimate:setSpeed(self._tTempletetInfo.ReadyFightActFrameRegion[3])
            self._pRolePlayer:runAction(cc.RepeatForever:create(pStandAnimate))
        end

        if pTouchPostion and bIsMove == false and (cc.rectContainsPoint(pTouchRec,pTouchPostion) == true) then -- 如果点击有位移了播放动画
            if self._pRolePlayer then
                self._pRolePlayer:stopAllActions()
                local len = table.getn(self._tAllActions)
                local  nRundom = mmo.HelpFunc:gGetRandNumberBetween(1,len)
                local  tAction = self._tAllActions[nRundom]
                local  pAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,tAction[1],tAction[2])
                pAnimate:setSpeed(tAction[4])
                self._pRolePlayer:runAction(cc.Sequence:create(pAnimate,cc.CallFunc:create(actionOverCallBack)))
        end
        end
        pTouchPostion = nil
        bIsMove = false
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
            self:onExitRolesInfoDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
  
    
    return

end


--初始化ui
function RolesInfoDialog:initUi()
 
    -- 加载dialog组件
    local params = require("PlayerRolesDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
   
    self._pCloseButton = params._pCloseButton
    self._pRoleName = params._pName                      --角色名字 lable
    self._pRoleLevel = params._pLevel_number             --角色等级 lable
    self._pFightingPower = params._pZhandouli_number     --战斗力   lable
    self._pPlayer = params._pPlayer                      --人物的背景框
    self._tEquALlNode = params._tEquALlNode              --装备
    self._pBagBtn = params._pBaoGuo                      --包裹按钮
    self._pRoleDetailBtn = params._pExchange             --人物信息按钮
    self._pNodeRigh = params._pNodeRight
    self._pRoleLeftNode = params._pRoleInfoNode          --角色的挂在node
    self._pAttack_number = params._pAttack_number        --人物的攻击力
    self._pHp_number = params._pHp_number                --人物的血
    self._pDefend_number = params._pDefend_number        --人物的防御
    -- 初始化dialog的基础组件
    self:disposeCSB()

    --背包
    self._pBagView = BagCommonManager:getInstance():getBagPanel()
    self._pBagView:setPosition(self._pBg:getContentSize().width/4-40,0)
    self._pRoleLeftNode:addChild(self._pBagView)
    --角色详细信息
    self._pDetailInfoView = require("PlayerDetailInfoPanel"):create({nil,false})
    self._pNodeRigh:addChild(self._pDetailInfoView)
    --角色详细信息左边的信息
    self._pDeatilInfoLeftView = require("RoleDetailLeftPanel"):create()
    self._pNodeRigh:addChild(self._pDeatilInfoLeftView)
end

--加载数据
function RolesInfoDialog:initUiDate()
   
    --设置人物的info
    self._tRoleInfo = RolesManager:getInstance()._pMainRoleInfo
    self._tTempletetInfo = TableTempleteCareers[self._tRoleInfo.roleCareer]
    self._pCheckBoxTable = self._tRoleInfo.fashionOptions --时装是否显示
    -- self._tTempletetInfo = TableTempleteCareers[1]
    -- 人物动画帧时间
    local pActionSize = table.getn(self._tTempletetInfo.AttackActFrameRegions)
    for i=pActionSize-3,pActionSize do
        table.insert(self._tAllActions,self._tTempletetInfo.AttackActFrameRegions[i])
    end
    self:setRoleBaseAttr()

end

--更新装备信息
function RolesInfoDialog:updateEquipmentArray(event)

    self._tRoleInfo = event.roleInfo
    self._pCheckBoxTable =self._tRoleInfo.fashionOptions
    for i=1,table.getn(self._tRoleInfo.equipemts) do --更新装备信息
        local pPart = GetCompleteItemInfo(self._tRoleInfo.equipemts[i]).dataInfo.Part -- 部位
        self._pArrayTableSprite[pPart]:setItemInfo(GetCompleteItemInfo(self._tRoleInfo.equipemts[i]))
        self._pArrayTableSprite[pPart]:setTouchEnabled(true)
        
        if BagCommonManager:getIsWarningEquipByPart() == true then
            redNode(self._pArrayTableSprite[pPart])
        end
    end

    --如果更换的是时装，则时装的复选框默认选择
    for i=1,#self._pCheckBoxTable do
        self._tArrayCheckBox[i]:setVisible(self._pCheckBoxTable[i]) --checkbox上面的对勾是否显示
    end
    self._pFightingPower:setString(self._tRoleInfo.roleAttrInfo.fightingPower)
    self:setRoleBaseAttr()
    self:createRoleModel()   --更新3d模型

end

--更新时装信息
function RolesInfoDialog:updateFashionHasVisable()
    local nTag = self._nClickIndex
    self._tArrayCheckBox[nTag]:setVisible(self._pCheckBoxTable[nTag]) --checkbox上面的对勾是否显示
    self:createRoleModel()   --更新3d模型
    RolesManager:getInstance():setMainRole( self._tRoleInfo)
end

--更新人物的基本属性信息
function RolesInfoDialog:updateRoleInfo(event)
    self._tRoleInfo = RolesManager:getInstance()._pMainRoleInfo
    self:setRoleBaseAttr()
    self:updateRoleEquipments()
    self._pDeatilInfoLeftView:refreshRoleInfo()
end

function RolesInfoDialog:updateRoleEquipments()
    for i=1,table.getn(self._tRoleInfo.equipemts) do --更新装备信息
        local pPart = GetCompleteItemInfo(self._tRoleInfo.equipemts[i]).dataInfo.Part -- 部位
        self._pArrayTableSprite[pPart]:setItemInfo(GetCompleteItemInfo(self._tRoleInfo.equipemts[i]))
    end
    
    self:updateEquipWarning({})
end

-- 设置触摸屏蔽
function RolesInfoDialog:handleTouchable(event)
    self:setTouchEnableInDialog(event[1])
end



--初始化角色的基本信息
function RolesInfoDialog:setTabBtnState()

    local setBagBtnState  = function()
        local pImage = {{"PlayerRolesDialogRes/baoguo01.png","PlayerRolesDialogRes/baoguo02.png"},{"PlayerRolesDialogRes/button5_normal.png","PlayerRolesDialogRes/button5_press.png"}}
        local tBtnArray = { self._pBagBtn, self._pRoleDetailBtn }
        for k ,v in pairs(tBtnArray) do
            if k == self._pCurSelectRoleType then
               v:loadTextures( pImage[k][2],pImage[k][2],nil,ccui.TextureResType.plistType)
            else
               v:loadTextures( pImage[k][1],pImage[k][2],nil,ccui.TextureResType.plistType)
            end
        end
        if self._pCurSelectRoleType == RoleDialogTabType.RoleDialogTypeBag then --背包
            self._pRoleLeftNode:setVisible(true)
            self._pNodeRigh:setVisible(false)
        else
            self._pRoleLeftNode:setVisible(false)
            self._pNodeRigh:setVisible(true)
        end
    end

    local ontouchTabChangeButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pTag = sender:getTag()
            self._pCurSelectRoleType = pTag
            --设置按钮选中状态
            setBagBtnState()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick") 

        end
    end

     --包裹按钮
    self._pBagBtn:addTouchEventListener(ontouchTabChangeButton)
    self._pBagBtn:setTag(1)
    --人物信息按钮
    self._pRoleDetailBtn:addTouchEventListener(ontouchTabChangeButton)
    self._pRoleDetailBtn:setTag(2)
    --设置按钮选中状态
    setBagBtnState()

end

--设置人物的基本属性信息 攻击力等级等
function RolesInfoDialog:setRoleBaseAttr()
    self._pRoleName:setString(self._tRoleInfo.roleName)
    self._pRoleLevel:setString("Lv"..self._tRoleInfo.level)
    self._pFightingPower:setString(self._tRoleInfo.roleAttrInfo.fightingPower)
    self._pAttack_number:setString(self._tRoleInfo.roleAttrInfo.attack)        --人物的攻击力
    self._pHp_number:setString(self._tRoleInfo.roleAttrInfo.hp)                --人物的血
    self._pDefend_number:setString(self._tRoleInfo.roleAttrInfo.defend)        --人物的防御
end

function RolesInfoDialog:updateEquipWarning(event)
    --设置默认装备信息
    for i=1, table.getn(self._pArrayTableSprite) do
        if BagCommonManager:getIsWarningEquipByPart(i) == true then
            --redNode(self._pArrayTableSprite[i])
            self._pArrayTableSprite[i]:setUpTipShow()
        end
    end
end

--初始化角色的装备信息
function RolesInfoDialog:initRoleEquInfo()

    --创建10个背景框
    for k,v in pairs(self._tEquALlNode) do
       local cell = require("BagItemCell"):create(kCalloutSrcType.kCalloutSrcEquip)
       cell:setPosition(cc.p(0,0))
       cell:openSelectedState()
       cell:setTouchEnabled(false)
       cell:setEquipDefIconByPart(k) 
       v:addChild(cell)
       table.insert( self._pArrayTableSprite,cell)
    end

    --给装备设置数据
    for i=1,table.getn(self._tRoleInfo.equipemts) do
        local pPart = GetCompleteItemInfo(self._tRoleInfo.equipemts[i]).dataInfo.Part -- 部位
        self._pArrayTableSprite[pPart]:setItemInfo(GetCompleteItemInfo(self._tRoleInfo.equipemts[i]))
        self._pArrayTableSprite[pPart]:setTouchEnabled(true)
    end

    self:updateEquipWarning({})


        --点击时装按钮
    local onTouchFashion = function(tag,pSende)
        if self._pCheckBoxHasVis[tag] == false then --如果是false说明该部位没有装备
           return  
        end
        print("tag is " .. tag)
        self._nClickIndex = tag
        self._pCheckBoxTable[tag] =  not self._pCheckBoxTable[tag]
        EquipmentCGMessage:sendMessageFashionOpt20110(tag,self._pCheckBoxTable[tag])
    end


    --创建三个时装的复选框
    for i=1,3 do
        local pMenuItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrameName("PlayerRolesDialogRes/jsjm_013_normal.png"),cc.Sprite:createWithSpriteFrameName("PlayerRolesDialogRes/jsjm_013_normal.png"))
        pMenuItem:registerScriptTapHandler(onTouchFashion)
        pMenuItem:setTag(i)
        local pMenu = cc.Menu:create(pMenuItem)
        pMenu:setPosition(50.5,0)
        self._pArrayTableSprite[7+i]:addChild(pMenu)
        local pCheckBoxBg = cc.Sprite:createWithSpriteFrameName("PlayerRolesDialogRes/jsjm_014.png")
        pCheckBoxBg:setPosition(pMenuItem:getContentSize().width/2,pMenuItem:getContentSize().height/2)
        pCheckBoxBg:setVisible(self._pCheckBoxTable[i])
        pMenuItem:addChild(pCheckBoxBg)
        table.insert( self._tArrayCheckBox,pCheckBoxBg)
    end

end

--创建模型信息
function RolesInfoDialog:createRoleModel()
    local pRoleModelAni = nil
    local pRoleTexTure = nil
    local pWeaPonAni1 = nil
    local pWeaPonAni2 = nil
    local pWeaPonTexTure = nil
    local pFashionBackAni = nil
    local pFashionBackTure = nil
    local pFashionHaloAni = nil
    local pFashionHaloTure = nil
    local pModelScale = {}
    
    --根据装备初始化人物和model模型
    for i=1,table.getn(self._tRoleInfo.equipemts) do
        local pEquInfo = GetCompleteItemInfo(self._tRoleInfo.equipemts[i])
        local nPart = pEquInfo.dataInfo.Part -- 部位
        local ptempleteInfo  = pEquInfo.templeteInfo
        if nPart == kEqpLocation.kBody then -- 身
            pRoleModelAni =  ptempleteInfo.Model1  --角色的人物模型
            pRoleTexTure = ptempleteInfo.Texture

        elseif nPart == kEqpLocation.kWeapon then  -- 武器
            pWeaPonAni1 = ptempleteInfo.Model1
            pWeaPonAni2 = ptempleteInfo.Model2
            pWeaPonTexTure = ptempleteInfo.Texture
            pModelScale[nPart] = {ptempleteInfo.ModelScale1,ptempleteInfo.ModelScale2}

        elseif nPart == kEqpLocation.kFashionBody then --时装身可能会影响人物模型
                self._pCheckBoxHasVis[2] = true
            if self._pCheckBoxTable[2] == true then      --如果以时装的模型为主
                pRoleModelAni = ptempleteInfo.Model1
                pRoleTexTure = ptempleteInfo.Texture
            end

        elseif nPart == kEqpLocation.kFashionBack then  --时装背（翅膀）
            self._pCheckBoxHasVis[1] = true
            if self._pCheckBoxTable[1] == true then
                pFashionBackAni = ptempleteInfo.Model1
                pFashionBackTure = ptempleteInfo.Texture
                pModelScale[nPart] = ptempleteInfo.ModelScale1
            end

        elseif nPart == kEqpLocation.kFashionHalo then  --时装光环
            self._pCheckBoxHasVis[3] = true
            if self._pCheckBoxTable[3] == true then
                pFashionHaloAni = ptempleteInfo.Model1
                pFashionHaloTure = ptempleteInfo.Texture
                pModelScale[nPart] = ptempleteInfo.ModelScale1
            end
        end

    end

    local nScale = self._tTempletetInfo.ScaleInShow --放大缩小比例
    --判断模型跟上次的是否一样
    self._bRoleAniHasChange = (self._pLastRoleAni ~= pRoleModelAni) and true or false
    self._pLastRoleAni = pRoleModelAni
    local bBool = self._bRoleAniHasChange
    self:updateRoleBodyModel(pRoleModelAni,pRoleTexTure,nScale,bBool) --更换人物模型
    self:updateRoleWepanModel(pWeaPonAni1,pWeaPonAni2,pWeaPonTexTure,not bBool) --更换武器模型
    self:updateRoleFashionBackModel(pFashionBackAni,pFashionBackTure,not bBool) --更换翅膀模型
    self:updateRoleFashionHaloModel(pFashionHaloAni,pFashionHaloTure,nScale) --更换光环
    self._pRolePlayer:setRotation3D(cc.vec3(0,0,0))
    self:setModelScaleByInfo(pModelScale)
    --设置材质信息
    self:setMaterialInfo(self._tRoleInfo.equipemts)

    -- 穿戴物品成功就播放欢呼动画
    --local playRoleDefaultAction = function()
    self._pRolePlayer:stopAllActions()
    self._pRoleAnimation = cc.Animation3D:create(pRoleModelAni..".c3b")
    local actionOverCallBack = function ()
        local pRunActAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, self._tTempletetInfo.ReadyFightActFrameRegion[1],self._tTempletetInfo.ReadyFightActFrameRegion[2])
        pRunActAnimate:setSpeed(self._tTempletetInfo.ReadyFightActFrameRegion[3])
        self._pRolePlayer:runAction(cc.RepeatForever:create(pRunActAnimate))
    end

    local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,self._tTempletetInfo.ShowActFrameRegion[1],self._tTempletetInfo.ShowActFrameRegion[2])
    pStandAnimate:setSpeed(self._tTempletetInfo.ShowActFrameRegion[3])
    self._pRolePlayer:runAction(cc.Sequence:create(pStandAnimate,cc.CallFunc:create(actionOverCallBack)))
    --end
end


--更换模型 人物身和时装身
function RolesInfoDialog:updateRoleBodyModel(pAni,pTexture,nScale,bBool)

    if self._pRolePlayer and bBool then   -- 如果不是第一次加载需要从新清除一下工程文件
        self._pRolePlayer:stopAllActions()
        self._pRolePlayer:removeFromParent(true) 
        self._pRolePlayer = nil
    end
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
    if bBool then
        self._pRolePlayer = cc.Sprite3D:create(pAni..".c3b")
        self._pRolePlayer:setScale(nScale)
        self._pRolePlayer:setPosition(cc.p(self._pPlayer:getContentSize().width/2,self._pPlayer:getContentSize().height/2-self._pRolePlayer:getBoundingBox().height/3-40))
        self._pPlayer:addChild(self._pRolePlayer,3) 
    end
    self._pRolePlayer:setTexture(pTexture..".pvr.ccz")
    
end

-- 避免模型遮挡问题
function RolesInfoDialog:setRoleModelVisible(isVisible)
    if isVisible then 
        self._pRolePlayer:setPositionZ(0)
    else
        self._pRolePlayer:setPositionZ(-10000)
    end
end

--更换武器
function RolesInfoDialog:updateRoleWepanModel(pAni1,pAni2,pTexture,bBool)
    self._pRolePlayer:stopAllActions()
   
    if self._pWeapon1 and bBool then
        self._pWeapon1:removeFromParent(true)
        self._pWeapon1 = nil
    end

    if self._pWeapon2 and bBool then
        self._pWeapon2:removeFromParent(true)
        self._pWeapon2 = nil
    end

    --武器1
    if pAni1 then
        local pFashionRighWeapon =self._pRolePlayer:getAttachNode("boneRightHandAttach")
        if pFashionRighWeapon then
            self._pWeapon1 = cc.Sprite3D:create(pAni1..".c3b")
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
            self._pWeapon1:setTexture(pTexture..".pvr.ccz")
            pFashionRighWeapon:addChild( self._pWeapon1)
            local animation = cc.Animation3D:create(pAni1..".c3b")
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self._pWeapon1:runAction(act)
            
        end
    end
 
    if pAni2 then --如果 有第二个模型
        local pFashionLeftWeapon =self._pRolePlayer:getAttachNode("boneLeftHandAttach")
        if pFashionLeftWeapon then
            self._pWeapon2 = cc.Sprite3D:create(pAni2..".c3b")
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
            self._pWeapon2:setTexture(pTexture..".pvr.ccz")
            pFashionLeftWeapon:addChild(self._pWeapon2)
            local animation = cc.Animation3D:create(pAni2..".c3b")
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self._pWeapon2:runAction(act)
            
        end
    end
  
end

--更换翅膀
function RolesInfoDialog:updateRoleFashionBackModel(pAni,pTexture,bBool)
    if bBool == nil then 
       bBool = true
    end


    if self._pFashionBack and bBool then
        self._pFashionBack:removeFromParent(true)
        self._pFashionBack = nil
    end
    if pAni then
        self._pFashionBack = cc.Sprite3D:create(pAni..".c3b")
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
        self._pFashionBack:setTexture(pTexture..".pvr.ccz")
        local animation = cc.Animation3D:create(pAni..".c3b")
        local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
        self._pFashionBack:runAction(act)
        self._pRolePlayer:getAttachNode("boneBackAttach"):addChild(self._pFashionBack)
    end

end

--更换光环
function RolesInfoDialog:updateRoleFashionHaloModel(pAni,pTexture,nScale)
    if self._pFashionHalo then
        self._pFashionHalo:removeFromParent(true)
        self._pFashionHalo = nil
    end
    if pAni then
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
        self._pFashionHalo = cc.CSLoader:createNode(pAni..".csb")
        self._pFashionHalo:setScale(nScale)
        self._pFashionHalo:setPosition(cc.p(self._pPlayer:getContentSize().width/2,self._pPlayer:getContentSize().height/2-self._pRolePlayer:getBoundingBox().height/3-40))
        self._pPlayer:addChild(self._pFashionHalo,1)
        local act = cc.CSLoader:createTimeline(pAni..".csb")
        act:gotoFrameAndPlay(0, act:getDuration(), true)
        self._pFashionHalo:stopAllActions()
        self._pFashionHalo:runAction(act)
    end


end


-- 退出函数
function RolesInfoDialog:onExitRolesInfoDialog()
    self:onExitDialog()

    NetRespManager:getInstance():removeEventListenersByHost(self)
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("PlayerRolesDialog.plist")

end

-- 循环更新
function RolesInfoDialog:update(dt)
    self:procWaveEffect(dt) 
    return
end
function RolesInfoDialog:procWaveEffect(dt)
    for kItem, vItem in pairs(self._tWaveEffectsInfo) do
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

-- 添加波纹特效
-- 参数1：位置类型，如身、背、武器
-- 参数2：特效类型
function RolesInfoDialog:addWaveEffect(posType, type)
    local tAniPvrNames = {}
    local tAnis = {}
    local strEffectPvrName = "" 
    local color = cc.vec4(1,1,1,1)
    
    if posType == kType.kBodyParts.kBody then
        table.insert(tAniPvrNames,self._pRoleTexture)
        table.insert(tAnis,self._pRolePlayer)
    elseif posType == kType.kBodyParts.kWeapon then
        local pWeaponL = self._pRolePlayer:getAttachNode("boneLeftHandAttach")
        if pWeaponL then
            table.insert(tAniPvrNames,self._pWeaPonTexture)
            table.insert(tAnis, self._pWeapon1)
        end
        local WeaponR = self._pRolePlayer:getAttachNode("boneRightHandAttach")
        if WeaponR then
            table.insert(tAniPvrNames,self._pWeaPonTexture)
            table.insert(tAnis, self._pWeapon2)
        end
    elseif posType == kType.kBodyParts.kBack then
        table.insert(tAniPvrNames,self._pFashionBackTexture)
        table.insert(tAnis,self._pFashionBack)
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

    self._tWaveEffectsInfo[posType] = {}
    self._tWaveEffectsInfo[posType][1] = tAnis -- 正在显示波纹shader特效的3d模型集合   
    self._tWaveEffectsInfo[posType][2] = {}     -- UV坐标集合
    self._tWaveEffectsInfo[posType][3] = nil     -- 特效的type集合
    for k, v in pairs(self._tWaveEffectsInfo[posType][1]) do
        table.insert(self._tWaveEffectsInfo[posType][2],cc.p(0,0)) -- 波纹shader特效在模型上的UV坐标集合 
        self._tWaveEffectsInfo[posType][3] = type  -- 波纹shader特效在模型上的特效type
    end

end

-- 移除波纹特效
-- 参数：位置类型，如身、背、武器
function RolesInfoDialog:removeWaveEffect(posType)
    local item = self._tWaveEffectsInfo[posType]
    if item[1] then
        for kAni, vAni in pairs(item[1]) do 
            mmo.HelpFunc:removeWaveEffectByShader(vAni) 
        end
    end
    self._tWaveEffectsInfo[posType] = nil
end

-- 显示波纹特效
-- 参数：位置类型，如身、背、武器
function RolesInfoDialog:showWaveEffect(posType)
    if self._tWaveEffectsInfo[posType] then
        for kAni,vAni in pairs(self._tWaveEffectsInfo[posType][1]) do
            mmo.HelpFunc:showWaveEffectByShader(vAni)
        end
    end
end

-- 隐藏波纹特效
-- 参数：位置类型，如身、背、武器
function RolesInfoDialog:hideWaveEffect(posType)
    if self._tWaveEffectsInfo[posType] then
        for kAni,vAni in pairs(self._tWaveEffectsInfo[posType][1]) do
            mmo.HelpFunc:hideWaveEffectByShader(vAni)
        end
    end
end



-- 隐藏 （带动画）
function RolesInfoDialog:hiddenWithAni()

    NetRespManager:getInstance():dispatchEvent(kNetCmd.kBagSelectedCell, {cell = nil})
    self._pTouchListener:setEnabled(false)
    self._pTouchListener:setSwallowTouches(false)
    
    self:stopAllActions()
    local closeOver = function()
        self:setVisible(false)
        self:getGameScene():checkMaskBg()
        self._pBagView:clear()
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

--设置身上3d模型的大小
function RolesInfoDialog:setModelScaleByInfo(pScale)
    if self._pFashionBack then
        self._pFashionBack:setScale(pScale[kEqpLocation.kFashionBack])
    end
    
    if self._pFashionHalo then
        self._pFashionHalo:setScale(pScale[kEqpLocation.kFashionHalo])
    end
    if self._pWeapon1 then
        self._pWeapon1:setScale(pScale[kEqpLocation.kWeapon][1])
    end
    if self._pWeapon2 then
        self._pWeapon2:setScale(pScale[kEqpLocation.kWeapon][2])
    end
	
end


--设置材质信息
function RolesInfoDialog:setMaterialInfo(tEquipemts)
    for k, v in pairs(tEquipemts) do
        local pEquInfo = v
        local nPart = pEquInfo.dataInfo.Part -- 部位
        local ptempleteInfo  = pEquInfo.templeteInfo
        if nPart == kEqpLocation.kBody then -- 身
               setSprite3dMaterial(self._pRolePlayer,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kWeapon then  -- 武器
               setSprite3dMaterial(self._pWeapon1,ptempleteInfo.Material)
               setSprite3dMaterial(self._pWeapon2,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kFashionBody then --时装身可能会影响人物模型
               setSprite3dMaterial(self._pRolePlayer,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kFashionBack then  --时装背（翅膀）
               setSprite3dMaterial(self._pFashionBack,ptempleteInfo.Material)

        elseif nPart == kEqpLocation.kFashionHalo then  --时装光环
        
        end
    end

end

--界面做了缓存再次打开的需要进行的操作
function RolesInfoDialog:updateCacheWithData(args)
    self._pRolePlayer:setRotation3D(cc.vec3(0,0,0))
    RolesManager:getInstance():setForceMinPositionZ(true,-10000)
    PetsManager:getInstance():setForceMinPositionZ(true,-10000)
    self._pCurSelectRoleType = args[1]
    self:setTabBtnState()
    self._pDeatilInfoLeftView:refreshRoleInfo()

    self._pBagView:showCache()
end

-- 显示结束时的回调
function RolesInfoDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function RolesInfoDialog:doWhenCloseOver()
    return
end

return RolesInfoDialog
