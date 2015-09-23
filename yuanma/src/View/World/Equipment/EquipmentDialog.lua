--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EquipmentDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/5
-- descrip:   装备相关的管理器
--===================================================
local EquipmentDialog = class("EquipmentDialog",function ()
    return require("Dialog"):create()
end
)

-- 构造函数
function EquipmentDialog:ctor()
    self._strName = "EquipmentDialog"                -- 层名称
    self._pBg = nil
    self._sBgContSize = nil                          --背景框的size
    self._pCloseButton = nil
    self._pRightScrollView = nil                     --右侧的滑动ScrollView
    self._pListController = nil              --优化的ScrollView
    self._tTabButtonArray = {}                       --右侧的button按钮
    self._nClickTabType = EquipmentTabType.EquipmentTabTypeResolve --默认进来的是分解
    self._ntempItemDate = nil                        --有选中状态的时候，物品详细信息
    self._tTabUiArray = {}                           --各个界面的Ui
    self._tScrollViewAni = {}                        --宝石特效的ani
    self._nScrollViewClickIndex = nil                --ScrollView点击的item Index
    self._pEqResolveInfoView = nil                   --装备分解界面
    self._pEqIntensifyInfoView = nil                 --装备强化界面
    self._pGemSynthesisInfoView = nil                --宝石合成界面
    self._pGemInlayInfoView = nil                    --宝石的镶嵌界面
    self._pEqFoundryInfoView = nil                   --装备锻造界面
    self._tGemMountingButtonArray = {}               --宝石镶嵌界面的button  --身上，背包内，宝石
    self._kItemSrcType = 1                           --物品的来源  1：身上   2：背包内  3：宝石
    self._pGemMountingButtonArrayNode = nil          --宝石镶嵌界面的button挂载
    self._pHangingPoint = nil                        --左侧的挂载点
    self._pMoneyNumberLbl = nil                      --玩家钻石标签
    self._pMoneyIconBg = nil                         --钻石的背景图标
    self._pTabTextureAdd = {}                        --图片正常状态
    
    self._pWarningSprite = {}

end

-- 创建函数    nTabType： 分解 强化 镶嵌等     tEquipInfo：此装备的info  kItemSrcType:物品的来源 身上 ,背包,宝石
function EquipmentDialog:create(args)
    local dialog = EquipmentDialog.new()
    dialog:dispose(args)
    return dialog
end
-- 处理函数
function EquipmentDialog:dispose(args)
    -- 注册装备分解的网络回调
    NetRespManager:getInstance():addEventListener(kNetCmd.kResolveEquipment ,handler(self, self.updateScrollViewItemDate)) --分解装备tip
    --注册宝石合成的网络事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kGemSynthesis, handler(self, self.updateScrollViewGemInfo))
    -- 注册合成背包装背上宝石
    NetRespManager:getInstance():addEventListener(kNetCmd.kBagEqpStoneSynthesis, handler(self, self.handleMsgGemSynthesis20117))
    -- 注册合成身上装备宝石
    NetRespManager:getInstance():addEventListener(kNetCmd.kRoleEqpStoneSynthesis, handler(self, self.handleMsgGemSynthesis20119))
    -- 注册镶嵌背包装备
    NetRespManager:getInstance():addEventListener(kNetCmd.kInlayBagEquip, handler(self, self.handleMsgInlayBagEquip20121))
    -- 注册镶嵌身上装备
    NetRespManager:getInstance():addEventListener(kNetCmd.kInlayRoleEquip, handler(self, self.handleMsgInlayRoleEquip20123))
    -- 注册购买商品的回调函数
    NetRespManager:getInstance():addEventListener(kNetCmd.kBuyGoods, handler(self,self.handleMsgBuyGoods20505))
    --锻造装备的回调函数
    NetRespManager:getInstance():addEventListener(kNetCmd.kForgingEquip ,handler(self, self.handleMsgForgingEquip20131))
    --断线从链接更新
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected ,handler(self, self.respNetReconnected))      
    --装备可强化或镶嵌提示 
    NetRespManager:getInstance():addEventListener(kNetCmd.kEquipWarning ,handler(self, self.handleEquipWarning))      
      
    ResPlistManager:getInstance():addSpriteFrames("EqiupRightDialog.plist")
    --锻造
    ResPlistManager:getInstance():addSpriteFrames("ForgeEquipEffect.plist")
    -- 加载dialog组件
    local params = require("EqiupRightDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pHangingPoint = params._pHangingPoint
    self._sBgContSize =self._pBg:getContentSize()
    self._pCloseButton = params._pCloseButton
    self._pRightScrollView = params._pRightScrollView
    self._pGemMountingButtonArrayNode = params._pThreePoint
    self._pGemMountingButtonArrayNode:setVisible(false)
    self._pMoneyNumberLbl = params._pMoneyNumber
    self._pMoneyIconBg = params._pMoneyBg
    -- 玩家钻石信息默认不显示
    self:setDiamondVisible(false)
    -- 玩家的钻石数量
    local diamondNum = FinanceManager:getInstance()._tCurrency[kFinance.kDiamond]
    self._pMoneyNumberLbl:setString(diamondNum)
    -- 初始化dialog的基础组件
    self:disposeCSB()

    --判断是否是通过点击某个tip进来的
    if args[1] ~=nil then
        self._nClickTabType = args[1]
        self._ntempItemDate = args[2]
    end

    if args[3] then
        self._kItemSrcType = args[3]
    end
    --tab的图片地址
    self._pTabTextureAdd = {{"fenjie01.png","qianghua01.png","xiangqian01.png","hecheng01.png","duanzao01.png"},{"fenjie02.png","qianghua02.png","xiangqian02.png","hecheng02.png","duanzao02.png"}}
    --强化 镶嵌 分解 合成 洗练 传承
    self._tTabButtonArray = {params._pTabButton1 ,params._pTabButton2 ,params._pTabButton3 ,params._pTabButton4 ,params._pTabButton7,params._pTabButton5 ,params._pTabButton6}
   
    for i=1 ,table.getn(self._tTabButtonArray) do
        self._pWarningSprite[i] = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
        self._pWarningSprite[i]:setPosition(85,85)
        self._pWarningSprite[i]:setScale(0.2)
        self._pWarningSprite[i]:setVisible(false)
        self._pWarningSprite[i]:setAnchorPoint(cc.p(0.5, 0.5))
        self._tTabButtonArray[i]:addChild(self._pWarningSprite[i])

        -- 上下移动动画效果
        local actionMoveBy = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
        local actionMoveToBack = cc.ScaleTo:create(0.5,0.6,0.6)
        local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
        self._pWarningSprite[i]:stopAllActions()
        self._pWarningSprite[i]:runAction(cc.RepeatForever:create(seq1))
    end
    
    if table.getn(BagCommonManager:getInstance()._tCanInlayEquips) > 0 then
        self._pWarningSprite[3]:setVisible(true)
    end
    
    if table.getn(BagCommonManager:getInstance()._tCanIntensifyEquips) > 0 then
        self._pWarningSprite[2]:setVisible(true)
    end

    -- 判断是否有可合成的宝石
    self._pWarningSprite[4]:setVisible(BagCommonManager:getInstance():isCanGemSynthesis())
    
    --镶嵌界面的  身上，背包内，宝石
    self._tGemMountingButtonArray = {params._pBagTabButton1 ,params._pBagTabButton2 ,params._pBagTabButton3}
    
    -- 初始化列表管理
    self._pListController = require("ListController"):create(self,self._pRightScrollView,listLayoutType.LayoutType_rows,100,100)
    self._pListController:setVertiaclDis(6)
    self._pListController:setHorizontalDis(3)
    
    self:initTabButtonUi()                       --初始化左侧的button点击事件
    self:initAllEquipArrayUI()                   --加載右侧所有的界面ui
    self:selectOneUiByType(self._nClickTabType)  --选择要加载的某个界面通过界面类型

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
        end
        return true
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

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEquipmentDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end

function EquipmentDialog:handleEquipWarning(event)
    if table.getn(BagCommonManager:getInstance()._tCanInlayEquips) > 0 then
        self._pWarningSprite[3]:setVisible(true)
    else
        self._pWarningSprite[3]:setVisible(false)
    end

    if table.getn(BagCommonManager:getInstance()._tCanIntensifyEquips) > 0 then
        self._pWarningSprite[2]:setVisible(true)
    else
        self._pWarningSprite[2]:setVisible(false)
    end
    -- 判断是否有可合成的宝石
    self._pWarningSprite[4]:setVisible(BagCommonManager:getInstance():isCanGemSynthesis())
end

--分解装备回调
function EquipmentDialog:updateScrollViewItemDate(event)

    if self._nClickTabType == EquipmentTabType.EquipmentTabTypeResolve then --如果是在分解界面
        self._ntempItemDate = nil --假如点击某个装备弹出的界面，当发分解协议之后需要把这个装备信息赋值为空
        if self._pEqResolveInfoView._bHasHaveStone then --如果分解的装备里面有宝石
            NoticeManager:getInstance():showSystemMessage("装备上的宝石已卸下存入背包内")
        end

        self._pEqResolveInfoView:clearResolveUiDateInfo()
        self:selectOneUiByType(self._nClickTabType)   --从新刷新界面
    end
end

-- 宝石合成回调函数
function EquipmentDialog:updateScrollViewGemInfo(event)
    if self._nClickTabType == EquipmentTabType.EquipmentTabTypeGemCompound then
        local function callback() 
            self:selectOneUiByType(self._nClickTabType)      
            self._tTabUiArray[EquipmentTabType.EquipmentTabTypeGemCompound]:setDataSource("update")
            -- 更新玩家的钻石数量
            self:updateDiamonNum()
        end
        self._pGemSynthesisInfoView:playeSuccessAni(callback)
    end
end

-- 合成背包里装备宝石回调函数
function EquipmentDialog:handleMsgGemSynthesis20117(event)
    -- 更新镶嵌面板数据
    self._ntempItemDate = BagCommonManager:getInstance():getItemInfoByIndex(event.index)
    self._pGemInlayInfoView:setDataSource(self._ntempItemDate,kCalloutSrcType.kCalloutSrcBagCommon)
    -- 更新玩家的钻石数量
    self:updateDiamonNum()
    -- 刷新物品列表
    self:selectOneUiByType(self._nClickTabType)
end

-- 合成身上装备宝石信息回调函数
function EquipmentDialog:handleMsgGemSynthesis20119(event)
    -- 更新镶嵌面板数据
    self._ntempItemDate = RolesManager:getInstance():selectHasEquipmentByType(event.loction)
    self._pGemInlayInfoView:setDataSource(self._ntempItemDate,kCalloutSrcType.kCalloutSrcEquip)
    -- 更新玩家的钻石数量
    self:updateDiamonNum()
    -- 刷新物品列表
    self:selectOneUiByType(self._nClickTabType)
end

-- 镶嵌背包装备回调函数
function EquipmentDialog:handleMsgInlayBagEquip20121(event)
    -- 更新镶嵌面板数据
    self._ntempItemDate = BagCommonManager:getInstance():getItemInfoByIndex(event.index)
    self._pGemInlayInfoView:setDataSource(self._ntempItemDate,kCalloutSrcType.kCalloutSrcBagCommon,event.stoneId)
    -- 更新玩家的钻石数量
    self:updateDiamonNum()
    -- 刷新物品列表
    self:selectOneUiByType(self._nClickTabType)
end

-- 镶嵌身上装备的回调函数
function EquipmentDialog:handleMsgInlayRoleEquip20123(event)
    -- 更新镶嵌面板数据
    self._ntempItemDate = RolesManager:getInstance():selectHasEquipmentByType(event.loction)
    self._pGemInlayInfoView:setDataSource(self._ntempItemDate,kCalloutSrcType.kCalloutSrcEquip,event.stoneId)
    -- 更新玩家的钻石数量
    self:updateDiamonNum()
    -- 刷新物品列表
    self:selectOneUiByType(self._nClickTabType)
end

-- 注册购买物品回调
function EquipmentDialog:handleMsgBuyGoods20505(event)
    -- 更新玩家的钻石数量
    self:updateDiamonNum()
    -- 刷新物品列表
    self:selectOneUiByType(self._nClickTabType)
end

--锻造装备的回调
function EquipmentDialog:handleMsgForgingEquip20131(event)

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
            -- self._pEqFoundryInfoView:clearResolveUiDateInfo()
            --local pItemInfo = self._pEqFoundryInfoView:getItemInfo()
            self:selectOneUiByType(self._nClickTabType)
            self._pEqFoundryInfoView:updateEquipmentFoundryUi()
            DialogManager:getInstance():showDialog("GetItemsDialog",{items = {GetCompleteItemInfo(event.proItemList[1])}})
            self._pEqFoundryInfoView._pFoundryButton:setTouchEnabled(true)
            self:setTouchEnableInDialog(false)
        end
    end
    if not self._pForgingAniNode then
        self._pForgingAniNode = cc.CSLoader:createNode("ForgeEquipEffect.csb")
        self._pForgingAniNode:setPosition(0,15)
        self._pHangingPoint:addChild(self._pForgingAniNode)
   
    end
   local pForgingAniAction = cc.CSLoader:createTimeline("ForgeEquipEffect.csb")
    pForgingAniAction:setFrameEventCallFunc(onFrameEvent)
    self._pForgingAniNode:stopAllActions()
    pForgingAniAction:gotoFrameAndPlay(0,pForgingAniAction:getDuration(), false)
    self._pForgingAniNode:runAction(pForgingAniAction)

end

--断线重连的更新
function EquipmentDialog:respNetReconnected(event)
    self:setTouchEnableInDialog(false)
    self._pEqFoundryInfoView._pFoundryButton:setTouchEnabled(true) --锻造界面防止连点在点击第一次的时候设置不可点
end

--初始化右侧的button点击事件
function EquipmentDialog:initTabButtonUi()
    -- 标签选择按钮的回调
    local onTypeSelectButton = function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:setDiamondVisible(false)
            local nTag = sender:getTag()
            -- 获得玩家等级
            local nRoleLevel = RolesManager:getInstance()._pMainRoleInfo.level

            if nTag == EquipmentTabType.EquipmentTabTypeResolve then --分解
                if nRoleLevel < TableNewFunction[8].Level then
                    NoticeManager:getInstance():showSystemMessage("分解功能"..TableNewFunction[8].Level.."级开放")
                    return
                end
            elseif nTag ==  EquipmentTabType.EquipmentTabTypeIntensify then --强化
                if nRoleLevel < TableNewFunction[6].Level then
                    NoticeManager:getInstance():showSystemMessage("装备强化功能"..TableNewFunction[6].Level.."级开放")
                    return
                end
            elseif nTag ==  EquipmentTabType.EquipmentTabGemTypeGemInlay then --宝石镶嵌
                if nRoleLevel < TableNewFunction[16].Level then
                    NoticeManager:getInstance():showSystemMessage("宝石镶嵌功能"..TableNewFunction[16].Level.."级开放")
                    return
                end
                self:setDiamondVisible(true)
                -- 更新玩家的钻石数量
                self:updateDiamonNum()
            elseif nTag == EquipmentTabType.EquipmentTabTypeGemCompound then --宝石合成
                if nRoleLevel < TableNewFunction[17].Level then
                    NoticeManager:getInstance():showSystemMessage("宝石合成功能"..TableNewFunction[17].Level.."级开放")
                    return
                end
                self:setDiamondVisible(true)
                -- 更新玩家的钻石数量
                self:updateDiamonNum()
            elseif (nTag == EquipmentTabType.EquipmentTabTypeRefine) or (nTag == EquipmentTabType.EquipmentTabTypeInherit) then --宝石合成
                NoticeManager:getInstance():showSystemMessage("功能未开放")
                return
                
            elseif nTag == EquipmentTabType.EquipmentTabTypeEquFoundry then --锻造
              if nRoleLevel < TableNewFunction[26].Level then
                 NoticeManager:getInstance():showSystemMessage("锻造功能"..TableNewFunction[26].Level.."级开放")
                 return
              end
            
            end

            self._tTabButtonArray[self._nClickTabType]:loadTextures("EqiupRightDialogRes/"..self._pTabTextureAdd[1][self._nClickTabType],"EqiupRightDialogRes/"..self._pTabTextureAdd[2][self._nClickTabType],"EqiupRightDialogRes/"..self._pTabTextureAdd[1][self._nClickTabType],ccui.TextureResType.plistType)
            self._nClickTabType = nTag
            self._tTabButtonArray[self._nClickTabType]:loadTextures("EqiupRightDialogRes/"..self._pTabTextureAdd[2][self._nClickTabType],"EqiupRightDialogRes/"..self._pTabTextureAdd[2][self._nClickTabType],"EqiupRightDialogRes/"..self._pTabTextureAdd[2][self._nClickTabType],ccui.TextureResType.plistType)

            self._ntempItemDate = nil   --如果从新点击分解 强化等按钮的，把默认传过来的itemInfo设置为空
            self._nScrollViewClickIndex = nil
            self._tTabUiArray[self._nClickTabType ]:clearResolveUiDateInfo() --清理界面的缓存有需要的可以在自己的panel里面添加一下

            self:updateGemMountingButtonArrayTexture(kCalloutSrcType.kCalloutSrcEquip) -- --如果是有小标签（身上，装备，宝石）默认选择身上
            -- 默认选中一个标签
            self:selectOneUiByType(self._nClickTabType)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    -- end 标签选择按钮的回调

    for i = 1,#self._tTabButtonArray do
        self._tTabButtonArray[i]:setTag(i)
        self._tTabButtonArray[i]:addTouchEventListener(onTypeSelectButton)
        if self._nClickTabType == i then --当前button是选中的button
            self._tTabButtonArray[i]:loadTextures("EqiupRightDialogRes/"..self._pTabTextureAdd[2][i],"EqiupRightDialogRes/"..self._pTabTextureAdd[2][i],nil,ccui.TextureResType.plistType)
        end
    end

    local onGemMountingButtonTouch = function ( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            self:updateGemMountingButtonArrayTexture(sender:getTag())
            self:selectOneUiByType(self._nClickTabType)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    --宝石镶嵌界面的button
    for i = 1,#self._tGemMountingButtonArray do
        self._tGemMountingButtonArray[i]:setTag(i)
        self._tGemMountingButtonArray[i]:addTouchEventListener(onGemMountingButtonTouch)
        --self._tGemMountingButtonArray[i]:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
        --self._tGemMountingButtonArray[i]:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        if self._kItemSrcType == i then --当前button是选中的button
            self._tGemMountingButtonArray[i]:loadTextures("EqiupRightDialogRes/EqiupRightButton02.png","EqiupRightDialogRes/EqiupRightButton02.png",nil,ccui.TextureResType.plistType)
        end
    end

end

-- 宝石镶嵌界面小标签的选中状态（身上,背包,宝石）
function EquipmentDialog:updateGemMountingButtonArrayTexture(nIndex)
    for k,v in pairs(self._tGemMountingButtonArray) do
        self._tGemMountingButtonArray[k]:loadTextures("EqiupRightDialogRes/EqiupRightButton01.png","EqiupRightDialogRes/EqiupRightButton02.png",nil,ccui.TextureResType.plistType)
     end
    self._kItemSrcType = nIndex
    self._tGemMountingButtonArray[self._kItemSrcType]:loadTextures("EqiupRightDialogRes/EqiupRightButton02.png","EqiupRightDialogRes/EqiupRightButton02.png",nil,ccui.TextureResType.plistType)
end

--初始化各个界面UI
function EquipmentDialog:initAllEquipArrayUI()
    -- 
    local fEquipCallBack = function(tResolveEquDate)
        -- body
        if tResolveEquDate and self.pScrollViewDate then
            --去掉ScrollView的灰色
            local bHasCanResolveEqu = false
            for i,v1 in pairs(self.pScrollViewDate) do
                for k ,v2 in pairs(tResolveEquDate) do
                    if v1 == v2 then --如果这个装备在分解材料里面，则变成灰色
                        bHasCanResolveEqu = true
                        break
                    end
                end
                self:setScrollViewItemHasSelectByIndex(i,bHasCanResolveEqu)
                bHasCanResolveEqu = false
            end
        else
            --如果此处没有数据则进行特殊处理
            if self._nClickTabType == EquipmentTabType.EquipmentTabTypeIntensify then --强化 then
                if self._pEqIntensifyInfoView._nSmallType == self._kItemSrcType then  --如果强化的是当前页面里面的装备。需要刷新界面
                    --self:selectOneUiByType(self._nClickTabType)
                    self:setScrollViewDataSource(self._nClickTabType)
            end
            end
        end
    end

    --所有panel下必须有SetRightScrollViewClickByIndex方法。当点击右侧的ScrollView时传入index
    --设置屏幕是否可以点击
    local setUiTouchEnabled = function(bBool)
        self:setTouchEnableInDialog(bBool)
    end

    --宝石界面点击宝石孔需要切换宝石界面
    local fGemInlayCallBack = function()
        self._kItemSrcType = 3 --宝石
        self:updateGemMountingButtonArrayTexture(self._kItemSrcType)
        self:selectOneUiByType(self._nClickTabType)
    end


    --local pPostion = cc.p(self._sBgContSize.width*0.378,self._sBgContSize.height*0.517)
    local pPostion = cc.p(0,0)
    --装备分解
    self._pEqResolveInfoView = require("EquipmentResolvePanel"):create(fEquipCallBack)
    self._pEqResolveInfoView:setPosition(pPostion)
    self._pEqResolveInfoView:setTouchLayerEnabled(setUiTouchEnabled)
    self._pHangingPoint:addChild(self._pEqResolveInfoView)
    table.insert(self._tTabUiArray,self._pEqResolveInfoView)

    --装备强化
    self._pEqIntensifyInfoView = require("EquipmentIntensifyPanel"):create(fEquipCallBack)
    self._pEqIntensifyInfoView:setPosition(pPostion)
    self._pEqIntensifyInfoView:setTouchLayerEnabled(setUiTouchEnabled)
    self._pHangingPoint:addChild(self._pEqIntensifyInfoView)
    table.insert(self._tTabUiArray,self._pEqIntensifyInfoView)

    --宝石镶嵌
    self._pGemInlayInfoView = require("GemInlayLayer"):create(fEquipCallBack,fGemInlayCallBack)
    self._pGemInlayInfoView:setPosition(pPostion)
    self._pHangingPoint:addChild(self._pGemInlayInfoView)
    table.insert(self._tTabUiArray,self._pGemInlayInfoView)

    --宝石合成
    self._pGemSynthesisInfoView = require("GemSynthesisLayer"):create(fEquipCallBack)
    self._pGemSynthesisInfoView:setPosition(pPostion)
    self._pHangingPoint:addChild(self._pGemSynthesisInfoView)
    table.insert(self._tTabUiArray,self._pGemSynthesisInfoView)
    
    --装备锻造
    self._pEqFoundryInfoView = require("EquipmentFoundryPanel"):create(fEquipCallBack)
    self._pEqFoundryInfoView:setPosition(pPostion)
    self._pEqFoundryInfoView:setTouchLayerEnabled(setUiTouchEnabled)
    self._pHangingPoint:addChild(self._pEqFoundryInfoView)
    table.insert(self._tTabUiArray,self._pEqFoundryInfoView)


    for i=1 ,#self._tTabUiArray do
        if i == self._nClickTabType then
            self._tTabUiArray[i]:setDataSource(self._ntempItemDate,self._kItemSrcType)
        else
            self._tTabUiArray[i]:setDataSource(nil)
        end
    end
end

--设置ScrollView某个item是否是选中状态
--nIndex是item下表 ，bBool = true 选中 ；bBool = false 正常
function EquipmentDialog:setScrollViewItemHasSelectByIndex(nIndex,bBool,cell)
    -- 切换小标签有可能出现数据为空的现象
    local pItemCell = self._pListController:cellWithIndex(nIndex)
    if cell then --刚刚开始创建的时候，底层的ScrollView还没有添加成功，所以用传下来的cell
        pItemCell = cell
    end
    if not pItemCell then
        return
    end
    if bBool then
        pItemCell._pIconBtn:setColor(cc.c3b(136,136,136))
        if pItemCell._pEquipQualityBg then
            pItemCell._pEquipQualityBg:setColor(cc.c3b(136,136,136))
        end
    else
        pItemCell._pIconBtn:setColor(cWhite)
        if pItemCell._pEquipQualityBg then
            pItemCell._pEquipQualityBg:setColor(cWhite)
        end
    end
end

--选择要进入的tab指针
function EquipmentDialog:selectOneUiByType(nType)
    for k,v in pairs(self._tTabUiArray) do
        v:setVisible(false)
        if(nType == k) then
            v:setVisible(true)
        end
    end

    self._pGemMountingButtonArrayNode:setVisible(false)
   
    --ScrollView Item点击事件
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then --如果是强化界面是单选需要先把上一个赋值为高亮
            if self._nClickTabType == EquipmentTabType.EquipmentTabTypeIntensify            --强化
                or self._nClickTabType == EquipmentTabType.EquipmentTabGemTypeGemInlay      --宝石镶嵌
                or self._nClickTabType == EquipmentTabType.EquipmentTabTypeGemCompound      --宝石合成
                or self._nClickTabType == EquipmentTabType.EquipmentTabTypeEquFoundry then --宝石合成
                    if self._nScrollViewClickIndex then
                        self:setScrollViewItemHasSelectByIndex(self._nScrollViewClickIndex,false)
                    end
            end
            self._nScrollViewClickIndex = sender:getTag()
            self:setScrollViewItemHasSelectByIndex(self._nScrollViewClickIndex,true)
            --  如果点击是镶嵌标签下的宝石则不需要选中状态
            if self._nClickTabType == EquipmentTabType.EquipmentTabGemTypeGemInlay and self._kItemSrcType == kCalloutSrcType.kCalloutSrcGem then
                self:setScrollViewItemHasSelectByIndex(self._nScrollViewClickIndex,false)
            end
            
            --如果是装备强化界面需要单独处理需要把装备cell传下去
            if self._nClickTabType == EquipmentTabType.EquipmentTabTypeIntensify then --强化
                local cell = self._pListController:cellWithIndex(self._nScrollViewClickIndex)
                self._tTabUiArray[self._nClickTabType]:setScrollCellState(cell)
            end
            -- 物品列表选中改变事件
            self._tTabUiArray[self._nClickTabType]:SetRightScrollViewClickByIndex(self.pScrollViewDate[self._nScrollViewClickIndex],self._kItemSrcType)  
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    
    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local pInfo =   self.pScrollViewDate[index]
        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("BagItemCell"):create()
            cell._pIconBtn:setTag(index)
            cell._pIconBtn:addTouchEventListener(onTouchButton)
        end
        cell:setItemInfo(pInfo)
         
        if (self.pScrollViewDate [index] == self._ntempItemDate) and self._ntempItemDate then --如果是点击某个装备进来的，需要默认显示
            self._nScrollViewClickIndex = index
        end
        --如果是镶嵌和强化界面需要检测一下中间数据
        if self.pScrollViewDate ~= nil and self.pScrollViewDate[index] ~= nil then
            self:setScrollViewItemHasSelectByIndex(index,false,cell)
            local tTempInfoArray = self._tTabUiArray[nType]:getItemInfo()
            for k = 1 ,#tTempInfoArray do
                if self.pScrollViewDate[index].position == tTempInfoArray[k].position and self.pScrollViewDate[index].id == tTempInfoArray[k].id   then
                    self:setScrollViewItemHasSelectByIndex(index,true,cell)
                   if nType == EquipmentTabType.EquipmentTabTypeIntensify then --强化
                      self._tTabUiArray[nType]:setScrollCellState(cell)
                   end                            
                end
            end
        end

        return cell
    end

    --设置ScrollView的数据
    self:setScrollViewDataSource(nType) 
    --获取size的大小
    local nDateNum = table.getn(self.pScrollViewDate)
    local nRow  = math.ceil(nDateNum/4)
    nDateNum = 4*nRow
    local nDefNum = 20                                  --默认创建的背景个数 需要填满一屏 4*5 20个
    nDefNum = nDefNum > nDateNum and nDefNum or nDateNum

    self._pListController._pNumOfCellDelegateFunc = function ()
        return nDefNum
    end
    
    self._pListController:setDataSource(self.pScrollViewDate)
    
    self:deleteGemCanSynthesisAni()
    if nType == EquipmentTabType.EquipmentTabTypeGemCompound then --宝石合成
        -- 显示宝石可合成的特效
        self:showGemCanSynthesisAni()
    end
end

-- 设置物品列表的数据源
function EquipmentDialog:setScrollViewDataSource(nType)
    self.pScrollViewDate = {} --ScrollView数据
    if nType == EquipmentTabType.EquipmentTabTypeResolve then --分解
        self.pScrollViewDate = BagCommonManager:getInstance()._tArrayAllResolveEqu[4]
    elseif nType == EquipmentTabType.EquipmentTabTypeIntensify then --强化
        self._pGemMountingButtonArrayNode:setVisible(true)--设置镶嵌界面的三个button显示
        self._tGemMountingButtonArray[kCalloutSrcType.kCalloutSrcGem]:setVisible(false)

        if self._kItemSrcType == kCalloutSrcType.kCalloutSrcEquip then --身上的装备数据
            self.pScrollViewDate =  self:getWearEquInfo()
        elseif self._kItemSrcType == kCalloutSrcType.kCalloutSrcBagCommon then --背包里面的装备数据
            self.pScrollViewDate = BagCommonManager:getInstance()._tEquipArry
        end
    elseif nType == EquipmentTabType.EquipmentTabGemTypeGemInlay then --宝石镶嵌
        self._pGemMountingButtonArrayNode:setVisible(true)--设置镶嵌界面的三个button显示
        self._tGemMountingButtonArray[kCalloutSrcType.kCalloutSrcEquip]:setVisible(true)
        self._tGemMountingButtonArray[kCalloutSrcType.kCalloutSrcGem]:setVisible(true)
        -- 如果点击的是身上的装备
        if self._kItemSrcType == kCalloutSrcType.kCalloutSrcEquip then
            self:updateGemMountingButtonArrayTexture(1)
            self.pScrollViewDate = BagCommonManager:getInstance():getHasGemInlaidHoleEquipArry(BagCommonManager:getInstance():getWearEquInfo())
        elseif self._kItemSrcType == kCalloutSrcType.kCalloutSrcBagCommon then --如果点击的是背包里的装备
            self:updateGemMountingButtonArrayTexture(2)
            self.pScrollViewDate =  BagCommonManager:getInstance():getHasGemInlaidHoleEquipArry(BagCommonManager:getInstance()._tEquipArry)
        elseif self._kItemSrcType == kCalloutSrcType.kCalloutSrcGem then --如果点击的是宝石
            -- 默认显示身上的标签(数据默认为第一个装备)
            self:updateGemMountingButtonArrayTexture(3)
            self.pScrollViewDate =  BagCommonManager:getInstance()._tGemArry
        end
    elseif nType ==EquipmentTabType.EquipmentTabTypeGemCompound then --宝石合成
        self.pScrollViewDate = BagCommonManager:getInstance()._tGemArry
    elseif nType ==EquipmentTabType.EquipmentTabTypeEquFoundry then --装备锻造
        self.pScrollViewDate =  BagCommonManager:getInstance():getFoundryItemInfo()
    elseif nType ==EquipmentTabType.EquipmentTabTypeRefine then --洗练

    elseif nType ==EquipmentTabType.EquipmentTabTypeInherit then --传承

    end
end

-- 添加宝石可合成的特效
function EquipmentDialog:showGemCanSynthesisAni()
    for k,gemCell in pairs(self.pScrollViewDate) do
        local isGemCanSynthesis = true
       -- 获得下级宝石的信息
        local nextLevelGemInfo = GemManager:getInstance():getGemDataInfoByGemId(gemCell.dataInfo.MixResult)
        -- 判断是否达到最大级 
        if not nextLevelGemInfo or nextLevelGemInfo.dataInfo.RequiredLevel > RolesManager:getInstance()._pMainRoleInfo.level  then 
           isGemCanSynthesis = false
        end
        if gemCell.value < TableConstants.GemMixRequire.Value then
            isGemCanSynthesis = false
        end
        if isGemCanSynthesis == true then
            local paricle = cc.ParticleSystemQuad:create("BaoshiKehecheng.plist")
            local parent = cc.ParticleBatchNode:createWithTexture(paricle:getTexture())
            paricle:setPositionType(cc.POSITION_TYPE_GROUPED)
            parent:addChild(paricle)
            paricle:setPosition(45,47)
            paricle:setDuration(-1) --  -1 表示粒子持续播放
            self._pListController:cellWithIndex(k):addChild(parent)
            self._tScrollViewAni[k] = parent
        end
    end
end

--删除合成的宝石特效
function EquipmentDialog:deleteGemCanSynthesisAni()
    for k,v in pairs(self._tScrollViewAni) do
        self._pListController:cellWithIndex(k):removeChild(v,true)
    end
    self._tScrollViewAni = {}
end


--得到身上装备的info
function EquipmentDialog:getWearEquInfo()

    local tRoleInfo = RolesManager:getInstance()._pMainRoleInfo.equipemts

    for i=1,table.getn(tRoleInfo) do
        tRoleInfo[i] = GetCompleteItemInfo(tRoleInfo[i])
    end
    return tRoleInfo
end

-- 退出函数
function EquipmentDialog:onExitEquipmentDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("EqiupRightDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("ForgeEquipEffect.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)

end


-- 循环更新
function EquipmentDialog:update(dt)
    return
end

-- 显示结束时的回调

function EquipmentDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function EquipmentDialog:doWhenCloseOver()
    return
end

-- 显示当前玩家的钻石数量
function EquipmentDialog:updateDiamonNum()
    -- 玩家的钻石数量
    local diamondNum = FinanceManager:getInstance()._tCurrency[kFinance.kDiamond]
    self._pMoneyNumberLbl:setString(diamondNum)
end

--  设置宝石信息是否可见
function EquipmentDialog:setDiamondVisible(isDiamondInfoVisible)
    self._pMoneyIconBg:setVisible(isDiamondInfoVisible)
end

return EquipmentDialog
