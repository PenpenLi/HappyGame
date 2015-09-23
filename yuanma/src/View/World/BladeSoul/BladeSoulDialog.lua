--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BladeSoulDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2014/12/16
-- descrip:   剑灵系统
--===================================================
local BladeSoulDialog = class("BladeSoulDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BladeSoulDialog:ctor()
    self._strName = "BladeSoulDialog"        -- 层名称
    self._pBg = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._tButtonArray = nil                 --吞噬和炼化按钮集合
    self._pArtificeNodeUi = nil              --炼化层
    self._pTabDevourNodeUi = nil             --吞噬层
    self._tArtificeArrayUi = nil             --正在炼化的剑灵ui
    self._pOwnMoney = nil                    --拥有的钻石数
    self._pScrollView = nil                  --右侧的ScrollView
    self._pListController = nil              --优化的ScrollView
    self._pBladeSoulNumber = nil             --拥有的剑魂数
    self._tAttrLodingBar = {}                --后面的属性进度条
    self._tCurrUpAttr = {}                   --当前属性的属性加成
    self._tMaxupAttr = {}                    --最大属性加成
    self._tTitleLable = {}                   --每个板子的名字
    self._tBackMount = {}                    --动画帧挂载
    self._tJumpDevourBtn = nil               --跳转到吞噬界面的btn
    self._tAutoDevourBtn = nil               --一键吞噬按钮
    self._tAutoArtificeBtn = nil             --一键炼化按钮
    self._tBladeSoulInfo = nil               --界面数据

    self._pCdTimeLable = nil                 --需要刷新的lable
    self._pCdTimeBar = nil                   --需要cd的bar
    self._nAllDateTime = 0                   --cd总时间
    self._nCdTime = 0                        --剩余时间
    self._bTempBool = false                  --是否进行cd

    self._pClickType = 2                     --按钮点击的type 1：炼化  2：吞噬
    self._tScrollViewItemDate = {}           --ScrollView数据
    self._tScrollViewItemArray = {}          --ScrollView 的item

    self._tChangeIndex ={}                   --记录属性的改变值
    self._pWarningSprite = {}

end

-- 创建函数
function BladeSoulDialog:create(tBladeSoulInfo)
    local dialog = BladeSoulDialog.new()
    dialog:dispose(tBladeSoulInfo)
    return dialog
end


-- 处理函数
function BladeSoulDialog:dispose(tBladeSoulInfo)
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "剑灵按钮" , value = false})

    -- 剑灵丹炼化[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kRefineItem ,handler(self, self.RefineItemResp))
    -- 收取剑灵丹[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kCollectBladeSoul ,handler(self, self.CollectBladeSoulResp))
    -- 取消剑灵丹[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kCancelRefine ,handler(self, self.CancelRefineResp))
    -- 加速剑灵丹[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kBoostRefine ,handler(self, self.BoostRefineResp))
    -- 吞噬剑魂[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kDevourBladeSoul ,handler(self, self.DevourBladeSoulResp))
    -- 出售剑魂[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kSellBladeSoul ,handler(self, self.SellBladeSoulResp))
    -- 一键炼化[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kAutoRefineItem ,handler(self, self.RefineItemResp))
    -- 一键吞噬剑魂[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kAutoDevourBladeSoul ,handler(self, self.DevourBladeSoulResp))
    -- 更新背包[回复]
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateBagItemList, handler(self, self.respUpdateBagItemList)) 


    self._tBladeSoulInfo = tBladeSoulInfo
    ResPlistManager:getInstance():addSpriteFrames("BladeSoulDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("BladeSoulEatPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("BladeSoulQueueNone.plist")
    ResPlistManager:getInstance():addSpriteFrames("BladeSoulQueuePanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("PromoteEffect.plist")

    local params = require("BladeSoulDialogParams.lua"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._tButtonArray ={params._pTabButton1, params._pTabButton2 }            --炼化按钮 吞噬按钮
    self._pArtificeNodeUi = params._pNodeQueue                                 --炼化层
    self._pTabDevourNodeUi = params._pBladeSoulEat                             --吞噬层
    self._tArtificeArrayUi = {params._pQueuePoint1, params._pQueuePoint2, params._pQueuePoint3, params._pQueuePoint4} --正在炼化的剑灵ui
    self._pOwnMoney = params._pMoneyText                                       --拥有的钻石数
    self._pScrollView = params._pRightScrollView                               --ScrollView
    self._pBladeSoulNumber = params._pBladeSoulNumber                          --拥有的剑魂数
    self._pSellBladeSoulButton = params._pTabButtonBuy                         --购买剑灵丹的按钮
    self._tJumpDevourBtn = params._pGetJhButton                                --跳转到吞噬i界面的btn
    self._tAutoDevourBtn = params._pOneKeySwallow                              --一键吞噬按钮
    self._tAutoArtificeBtn = params._pOneKeyRefinery                           --一键炼化按钮
    
    for i=1,7 do
        local pLoadingBar = self:createFairyLandDishBar()
        params["_pLoadingBack"..i]:addChild(pLoadingBar)
        table.insert(self._tAttrLodingBar,pLoadingBar)                         --后面的属性进度条
        table.insert(self._tCurrUpAttr,params["_pCurrAttr"..i])                --当前属性的属性加成
        --params["_pCurrAttr"..i]:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        table.insert(self._tMaxupAttr,params["_pMaxAttr"..i])                  --最大属性加成
        --params["_pMaxAttr"..i]:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        table.insert(self._tTitleLable,params["_pTitle"..i])                   --每个板子的Title
        table.insert(self._tBackMount,params["_pBack"..i])                   --每个板子的Title
    end
    
    -- 初始化列表管理
    self._pListController = require("ListController"):create(self,self._pScrollView,listLayoutType.LayoutType_rows,100,100)
    self._pListController:setVertiaclDis(6)
    self._pListController:setHorizontalDis(3)

    self:disposeCSB()
    self:initUiButton() --初始化左侧炼化按钮的点击事件
    self:initScrollViewItemDate()  --初始化ScrollView的数据
    self:initRefineItem()          --初始化界面正在炼化的数据
    self:setBladeSoulAttr()        --设置剑灵属性信息
    self:JumpUiByType(self._pClickType)    
    
    for i=1 ,table.getn(self._tButtonArray) do
        self._pWarningSprite[i] = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
        self._pWarningSprite[i]:setPosition(20,85)
        self._pWarningSprite[i]:setScale(0.2)
        self._pWarningSprite[i]:setVisible(false)
        self._pWarningSprite[i]:setAnchorPoint(cc.p(0.5, 0.5))
        self._tButtonArray[i]:addChild(self._pWarningSprite[i])

        -- 上下移动动画效果
        local actionMoveBy = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
        local actionMoveToBack = cc.ScaleTo:create(0.5,0.6,0.6)
        local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
        self._pWarningSprite[i]:stopAllActions()
        self._pWarningSprite[i]:runAction(cc.RepeatForever:create(seq1))
    end
    
    self:getShowNoitceHasVisible()
    
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
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


    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBladeSoulDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

--剑灵丹炼化[回复]
function BladeSoulDialog:RefineItemResp(event)
    self._tBladeSoulInfo.refineList = event.refineList
    self:initScrollViewItemDate()  --初始化ScrollView的数据
    self:initRefineItem()          --初始化界面正在炼化的数据

    self:getShowNoitceHasVisible()
end

--收取剑灵丹[回复]
function BladeSoulDialog:CollectBladeSoulResp(event)
    self._bTempBool = false
    self._tBladeSoulInfo.refineList = event.refineList
    table.insert( self._tBladeSoulInfo.baldeSoulList,event.baldeSole)
    self:setBladeSoulNameMessageByInfo(event.baldeSole)
    self:initRefineItem()   --初始化界面正在炼化的数据
    
    self:getShowNoitceHasVisible()
end

--取消剑灵丹[回复]
function BladeSoulDialog:CancelRefineResp(event)
    self._bTempBool = false
    self._tBladeSoulInfo.refineList = event.refineList
    self:initRefineItem()   --初始化界面正在炼化的数据
    
    self:getShowNoitceHasVisible()
end

--加速剑灵丹[回复]
function BladeSoulDialog:BoostRefineResp(event)
    self._bTempBool = false
    self._tBladeSoulInfo.refineList = event.refineList
    table.insert( self._tBladeSoulInfo.baldeSoulList,event.baldeSole)
    self:setBladeSoulNameMessageByInfo(event.baldeSole)
    self:initRefineItem()   --初始化界面正在炼化的数据
    
    self:getShowNoitceHasVisible()
end

--吞噬剑魂[回复]
function BladeSoulDialog:DevourBladeSoulResp(event)
    local nChangePower =event.roleAttr.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
    self._tBladeSoulInfo.roleAttrExt = event.addRoleAttr
    local tempRoleInfo =  RolesManager:getInstance()._pMainRoleInfo

    self._tChangeIndex ={}
    local tTempNewAtt = { event.roleAttr.hp ,event.roleAttr.attack ,event.roleAttr.defend ,event.roleAttr.critRate ,event.roleAttr.critDmage ,event.roleAttr.resilience ,event.roleAttr.resistance}
    local tTempOldAtt = {tempRoleInfo.roleAttrInfo.hp ,tempRoleInfo.roleAttrInfo.attack ,tempRoleInfo.roleAttrInfo.defend ,tempRoleInfo.roleAttrInfo.critRate ,tempRoleInfo.roleAttrInfo.critDmage ,tempRoleInfo.roleAttrInfo.resilience ,tempRoleInfo.roleAttrInfo.resistance }

    for i=1,#tTempNewAtt do
        if tTempNewAtt[i] ~= tTempOldAtt[i]  then --发现不一样的属性
            table.insert(self._tChangeIndex,i)
        end
    end
    tempRoleInfo.roleAttrInfo = event.roleAttr

    RolesManager:getInstance():setMainRole(tempRoleInfo)
    if nChangePower ~= 0 then
        NoticeManager:getInstance():showFightStrengthChange(nChangePower)
    end
        
    if table.getn(self._tBladeSoulInfo.baldeSoulList) then
       table.remove(self._tBladeSoulInfo.baldeSoulList,event.argsBody.index) --先删除这个剑魂
    end
    self._pBladeSoulNumber:setString(#self._tBladeSoulInfo.baldeSoulList)                           --设置剑魂数目
    self:initScrollViewItemDate()  --初始化ScrollView的数据
    self:setBladeSoulAttr()        --设置剑灵属性信息
    
    self:getShowNoitceHasVisible()
end

--出售剑魂[回复]
function BladeSoulDialog:SellBladeSoulResp(event)
    table.remove(self._tBladeSoulInfo.baldeSoulList,event.argsBody.index) --先删除这个剑魂
    self._pBladeSoulNumber:setString(#self._tBladeSoulInfo.baldeSoulList)                           --设置剑魂数目
    self:initScrollViewItemDate()  --初始化ScrollView的数据
    
    self:getShowNoitceHasVisible()
end


function BladeSoulDialog:respUpdateBagItemList(event)
    self:initScrollViewItemDate() --如果有更新背包列表 本地刷新右侧的ScrollView数据
    self._pOwnMoney:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kDiamond))--设置钻石数目
end

--直接跳转吞噬界面 1:炼化  2：吞噬
function BladeSoulDialog:JumpUiByType(nType)
 if nType == nil  then
 	return 
 end

    local pImageTexture = {{"BladeSoulDialogRes/jlxt1.png","BladeSoulDialogRes/jlxt2.png"},{"BladeSoulDialogRes/jlxt3.png","BladeSoulDialogRes/jlxt4.png"}}
    for i=1,2 do
        self._tButtonArray[i]:loadTextures(pImageTexture[i][2],pImageTexture[i][1],nil,ccui.TextureResType.plistType)
    end 
    self._pClickType = nType
    self._tButtonArray[self._pClickType]:loadTextures(pImageTexture[nType][1],pImageTexture[nType][1],nil,ccui.TextureResType.plistType)

    if self._pClickType == 1 then --炼化按钮
        self._pArtificeNodeUi:setVisible(true)     --炼化层
        self._pTabDevourNodeUi:setVisible(false)    --吞噬层
    else -- 吞噬按钮
        self._pArtificeNodeUi:setVisible(false)     --炼化层
        self._pTabDevourNodeUi:setVisible(true)    --吞噬层
    end
    self:initScrollViewItemDate()
end

--初始化Ui的Button点击事件
function BladeSoulDialog:initUiButton()
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then 
           self:JumpUiByType(sender:getTag())

        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    for i=1,#self._tButtonArray do
        self._tButtonArray[i]:addTouchEventListener(onTouchButton)         --炼化按钮
        self._tButtonArray[i]:setTag(i)
    end

    local  onTouchSellBladeButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("购买剑灵丹")
            DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop,kTagType.kTool})

        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    --购买剑灵丹按钮
    self._pSellBladeSoulButton:addTouchEventListener(onTouchSellBladeButton)
    self._pSellBladeSoulButton:setZoomScale(nButtonZoomScale)
    self._pSellBladeSoulButton:setPressedActionEnabled(true)
    --self._pSellBladeSoulButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pSellBladeSoulButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    local  onTouchJumpDevourButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           self:JumpUiByType(1)
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    self._tJumpDevourBtn:addTouchEventListener(onTouchJumpDevourButton)
    self._tJumpDevourBtn:setZoomScale(nButtonZoomScale)
    self._tJumpDevourBtn:setPressedActionEnabled(true)
    --self._tJumpDevourBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    
    --一键吞噬按钮
    local  onTouchAutoDevourButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
        
        if table.getn(self._tBladeSoulInfo.baldeSoulList) == 0 then 
           NoticeManager:getInstance():showSystemMessage("您一个剑魂都没有，请先炼化剑魂")
           return
        end
            showConfirmDialog("确认一次性吞噬所有剑魂？(超出当前属性上限部分将被舍去）" , function()
                BladeSoulCGMessage:sendMessageAutoDevourBladeSoul20716() --吞噬剑魂请求
                self._tBladeSoulInfo.baldeSoulList = {}
         end)
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._tAutoDevourBtn:addTouchEventListener(onTouchAutoDevourButton)
    self._tAutoDevourBtn:setZoomScale(nButtonZoomScale)
    self._tAutoDevourBtn:setPressedActionEnabled(true)


    --一键炼化按钮
    local  onTouchAutoArtificeButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then

           local pItemList,tEquipItem,tSoulItem = BagCommonManager:getInstance():getBladeSoulItemInfo()
           local pTempNum = 4-table.getn(self._tBladeSoulInfo.refineList)
          
           if table.getn(pItemList) == 0 then --背包里面没有可以吞噬的装备
              NoticeManager:getInstance():showSystemMessage("背包里面没有可以吞噬的装备")
              return
           end
          if pTempNum == 0 then 
             NoticeManager:getInstance():showSystemMessage("没有可以供吞噬的位置")
             return
           end
             local tPos = self:getPosByEquipAndSouleInfo(tEquipItem,tSoulItem)
             showConfirmDialog("确认消耗材料进行炼化？" , function()
                    BladeSoulCGMessage:sendMessageAutoRefineItem20714(tPos) --炼化请求
             end)
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._tAutoArtificeBtn:addTouchEventListener(onTouchAutoArtificeButton)
    self._tAutoArtificeBtn:setZoomScale(nButtonZoomScale)
    self._tAutoArtificeBtn:setPressedActionEnabled(true)
                                             
 

end

--算出可以吞噬的装备或者剑灵丹的数组下表
function BladeSoulDialog:getPosByEquipAndSouleInfo(tEquipItem,tSoulItem)

    local pPos = {}
    local nMainNum = 8 --一次多发几个，防止数据不一致
    local nEquipNum = table.getn(tEquipItem)
    local SoulNum = table.getn(tSoulItem)
    
    local pNum1 = nEquipNum > nMainNum and nMainNum or nEquipNum --装备循环的次数
    local pNum2 = nMainNum - pNum1  --剑灵丹循环的次数
   
   for i=1,pNum1 do
        table.insert(pPos,tEquipItem[i].position)
   end
   
   for k,v in pairs(tSoulItem) do
      for i=1,v.value do
          if table.getn(pPos) == nMainNum then
             return pPos
          end
          table.insert(pPos,v.position)	
      end
   end
    return pPos
end




function BladeSoulDialog:initScrollViewItemDate()
    if self._pClickType == 1 then --炼化的数据
        self._tScrollViewItemDate =  BagCommonManager:getInstance():getBladeSoulItemInfo()
    elseif self._pClickType == 2 then --吞噬的剑灵丹的数据
        for i=1,#self._tBladeSoulInfo.baldeSoulList  do
            self._tBladeSoulInfo.baldeSoulList[i] = GetCompleteItemInfoById(self._tBladeSoulInfo.baldeSoulList[i],2)
        end
    self._tScrollViewItemDate = self._tBladeSoulInfo.baldeSoulList
    end
    
    
    --button的点击事件
    local onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            if self._pClickType == 1 then --炼化的数据
                if #self._tBladeSoulInfo.refineList >= 4 then
                    NoticeManager:getInstance():showSystemMessage("队列已满，请进行加速或进行收取")
                    return
            end
            local pPos = self._tScrollViewItemDate[nTag].position
            showConfirmDialog("确认消耗材料进行炼化？" , function()
                BladeSoulCGMessage:sendMessageRefineItem20702(pPos) --炼化请求
            end)

            else
                local bHasMax = self:attrIsBeyond(self._tBladeSoulInfo.baldeSoulList[nTag].attrbs) --增加的属性是否超出最大值
                --DialogManager:getInstance():showDialog(require("BladeSoulCellDialog"):create(self._tBladeSoulInfo.baldeSoulList[nTag],nTag))
                DialogManager:getInstance():showDialog("BladeSoulCellDialog",{self._tBladeSoulInfo.baldeSoulList[nTag],nTag,bHasMax})
            end
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
     self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local pInfo =   self._tScrollViewItemDate[index]
        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("BagItemCell"):create()
        end
        cell:setItemInfo(pInfo)
        cell._pIconBtn:setTag(index)
        cell._pIconBtn:addTouchEventListener(onTouchButton)
        
        return cell
     end
     
     
    --获取size的大小
    local nDateNum = table.getn(self._tScrollViewItemDate)
    local nRow  = math.ceil(nDateNum/4)
    nDateNum = 4*nRow
    local nDefNum = 20                                  --默认创建的背景个数 需要填满一屏 4*5 20个
    nDefNum = nDefNum > nDateNum and nDefNum or nDateNum
    
    self._pListController._pNumOfCellDelegateFunc = function ()
        return nDefNum
    end
    self._pListController:setDataSource(self._tScrollViewItemDate)

end

--判断增加的属性是否增加
function BladeSoulDialog:attrIsBeyond(args)
	
    local nRoleAttr = TableLevel[RolesManager:getInstance()._pMainRoleInfo.level]
    local pCurrattr = self._tBladeSoulInfo.roleAttrExt
    local tTempMaxAtt = { nRoleAttr.BSHp ,nRoleAttr.BSAttack ,nRoleAttr.BSDefend ,nRoleAttr.BSCriticalChance ,nRoleAttr.BSCriticalDmage ,nRoleAttr.BSResilience ,nRoleAttr.BSResistance }
    local tTempCurrAtt = { pCurrattr.hp ,pCurrattr.attack ,pCurrattr.defend ,pCurrattr.critRate ,pCurrattr.critDmage ,pCurrattr.resilience ,pCurrattr.resistance }

    for i=1,#args do
    	local pType = args[i].attrType
        local nValue = args[i].attrValue
        if (tTempCurrAtt[pType]+nValue) > tTempMaxAtt[pType] then 
        	return true
        end
    	
    end
	return false
end



--初始化左侧的炼化列表
function BladeSoulDialog:initRefineItem()
    self._pBladeSoulNumber:setString(#self._tBladeSoulInfo.baldeSoulList)                           --设置剑魂数目
    self._pOwnMoney:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kDiamond))--设置钻石数目
    for i=1,#self._tArtificeArrayUi do
        self._tArtificeArrayUi[i]:removeAllChildren(true)
        if i > #self._tBladeSoulInfo.refineList then --如果炼化列表的长度小于i的话返回，说明下面没有可以炼化的item
            local pNullItem = cc.CSLoader:createNode("BladeSoulQueueNone.csb")
            self._tArtificeArrayUi[i]:addChild(pNullItem)
        else
            local pDateInfo = GetCompleteItemInfo( self._tBladeSoulInfo.refineList[i] )
            local pItemCell = require("BladeSoulQueuePanelParams"):create()
            local pIconCell = require("BagItemCell"):create()
            pIconCell:setTouchEnabled(false)
            pIconCell:setItemInfo(pDateInfo)
            pIconCell:setAnchorPoint(cc.p(0,0))
            pItemCell._pIcon:addChild(pIconCell)
            self._tArtificeArrayUi[i]:addChild(pItemCell._pCCS)

            pItemCell._pCollectButton:setTag(i) --收取按钮
            pItemCell._pCollectButton:setZoomScale(nButtonZoomScale)
            pItemCell._pCollectButton:setPressedActionEnabled(true)
            --pItemCell._pCollectButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
            pItemCell._pSpeedButton:setTag(i)  --加速按钮
            pItemCell._pSpeedButton:setZoomScale(nButtonZoomScale)
            pItemCell._pSpeedButton:setPressedActionEnabled(true)

           -- pItemCell._pSpeedButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
            pItemCell._pCancelButtom:setTag(i) --取消按钮
            pItemCell._pCancelButtom:setZoomScale(nButtonZoomScale)
            pItemCell._pCancelButtom:setPressedActionEnabled(true)
           -- pItemCell._pCancelButtom:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

            --收取按钮
            local onTouchCollectButton = function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local nTag = sender:getTag()
                    if #self._tBladeSoulInfo.baldeSoulList>=TableConstants.BladeSoulMaxBox.Value then
                        NoticeManager:getInstance():showSystemMessage("您已经有很多剑魂了，先吞噬或出售已有剑魂再来炼化新的剑魂。")
                        return
                    end
                    BladeSoulCGMessage:sendMessageCollectBladeSoul20704(nTag)
                elseif eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")
                end
            end

            --加速按钮
            local onTouchSpeedButton = function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local nTag = sender:getTag()
                    if #self._tBladeSoulInfo.baldeSoulList>=TableConstants.BladeSoulMaxBox.Value then
                        NoticeManager:getInstance():showSystemMessage("您已经有很多剑魂了，先吞噬或出售已有剑魂再来炼化新的剑魂。")
                        return
                    end
                    local nConst = getConstDiamondByTime(self._nCdTime)
                    
                    local tMsg = {
                        {type = 2,title = "确认消耗",fontColor = cWhite},           
                        {type = 2,title = nConst.."玉璧",fontColor = cGreen},
                        {type = 2,title = "进行加速？",fontColor = cWhite},
                        {type =1},
                        {type = 2,title = "加速后可直接获得剑魂",fontColor = cWhite},
                    }
                    showConfirmDialog(tMsg , function()
                        BladeSoulCGMessage:sendMessageBoostRefine20708(nTag)
                    end)
                elseif eventType == ccui.TouchEventType.began then
                   AudioManager:getInstance():playEffect("ButtonClick")

                end
            end

            --取消按钮
            local onTouchCancelButton = function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local nTag = sender:getTag()
                    showConfirmDialog("确认取消本次炼化？\n已消耗的材料不返还" , function()
                        BladeSoulCGMessage:sendMessageCancelRefine20706(nTag)
                    end)
                elseif eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")

                end
            end

            pItemCell._pCollectButton:addTouchEventListener(onTouchCollectButton) --收取按钮
            pItemCell._pSpeedButton:addTouchEventListener(onTouchSpeedButton)  --加速按钮
            pItemCell._pCancelButtom:addTouchEventListener(onTouchCancelButton) --取消按钮


            if pDateInfo.state == kRefineState.kFinish then        --炼化完成

                pItemCell._pCollectButton:setVisible(true) --收取按钮显示
                pItemCell._pSpeedButton:setVisible(false)  --加速按钮隐藏
                pItemCell._pCancelButtom:setVisible(false) --取消按钮隐藏
                pItemCell._pState:setString("已完成")      --当前状态说明   已完成   排队中  进行中
                pItemCell._pState:setColor(cGreen)
                pItemCell._pLoadingBar:setPercent(100)     --进度条
                pItemCell._pRemainingTime:setString("") --进度条上显示的字

            elseif pDateInfo.state == kRefineState.kRefining then  --炼化中

                pItemCell._pCollectButton:setVisible(false) --收取按钮显示
                pItemCell._pSpeedButton:setVisible(true)  --加速按钮隐藏
                pItemCell._pCancelButtom:setVisible(true) --取消按钮隐藏
                pItemCell._pState:setString("炼化中...")      --当前状态说明   已完成   排队中  进行中
                pItemCell._pState:setColor(cWhite)
                --yuanjs add
                --pItemCell._pSpeedButton:setVisible(false)  --加速按钮隐藏

                self._pCdTimeLable = pItemCell._pRemainingTime          --需要刷新的lable
                self._pCdTimeBar = pItemCell._pLoadingBar               --需要cd的bar
                self._nAllDateTime = pDateInfo.total                    --cd总时间
                self._nCdTime = pDateInfo.remain                        --剩余时间
                self._bTempBool = true                                  --是否进行cd

            elseif pDateInfo.state == kRefineState.kWait then      --等待炼化

                pItemCell._pCollectButton:setVisible(false) --收取按钮显示
                pItemCell._pSpeedButton:setVisible(false)  --加速按钮隐藏
                pItemCell._pCancelButtom:setVisible(true) --取消按钮隐藏
                pItemCell._pState:setString("排队中...")      --当前状态说明   已完成   排队中  进行中
                pItemCell._pState:setColor(cGrey)
                pItemCell._pLoadingBar:setPercent(0)     --进度条
                local pFormat = gTimeToStr(pDateInfo.total)
                -- local second = mmo.HelpFunc:gGetSecondStr(pDateInfo.total)
                pItemCell._pRemainingTime:setString("剩余"..pFormat) --进度条上显示的字
            end
        end
    end
end


--设置剑灵提供的属性
function BladeSoulDialog:setBladeSoulAttr()
    local nRoleAttr = TableLevel[RolesManager:getInstance()._pMainRoleInfo.level]
    local pCurrattr = self._tBladeSoulInfo.roleAttrExt
    local tTempMaxAtt = { nRoleAttr.BSHp ,nRoleAttr.BSAttack ,nRoleAttr.BSDefend ,nRoleAttr.BSCriticalChance ,nRoleAttr.BSCriticalDmage ,nRoleAttr.BSResilience ,nRoleAttr.BSResistance }
    local tTempCurrAtt = { pCurrattr.hp ,pCurrattr.attack ,pCurrattr.defend ,pCurrattr.critRate ,pCurrattr.critDmage ,pCurrattr.resilience ,pCurrattr.resistance }
    for i=1,7 do
        self:setFairyLandDishBarPercent(self._tAttrLodingBar[i],(tTempCurrAtt[i]/tTempMaxAtt[i])*100)   --后面的属性进度条
        --[[
        if i == 4 or i==5 then --如果是暴击几率，暴击伤害是百分比
            self._tCurrUpAttr[i]:setString((tTempCurrAtt[i]*100).."%")                      --当前属性的属性加成
            self._tMaxupAttr[i]:setString(("/"..tTempMaxAtt[i]*100).."%")                        --最大属性加成
        else
        ]]
            self._tCurrUpAttr[i]:setString(tTempCurrAtt[i])                                      --当前属性的属性加成
            self._tMaxupAttr[i]:setString("/"..tTempMaxAtt[i])                                   --最大属性加成
        --end
    end


    local nIndex = 1 --引用计数 算出特效总共播放了多少次
    local function onFrameEvent(frame,tTable)
        if nil == frame then
            return
        end

        local str = frame:getEvent()
        if str == "end" then
            if #self._tChangeIndex <= 0 then --假如没有点击数据则返回
                return
            end
            self._tTitleLable[self._tChangeIndex[nIndex]]:removeAllChildren(true)
            if nIndex == #self._tChangeIndex  then --如果是最后一次了
                self._tChangeIndex = {}
                nIndex = 1
                return
            end
            nIndex = nIndex +1
        end
    end

    for i=1,#self._tChangeIndex do

        local pUpAttrAniNode = cc.CSLoader:createNode("PromoteEffect.csb")
        pUpAttrAniNode:setPosition(self._tBackMount[1]:getContentSize().width/2,self._tBackMount[1]:getContentSize().height/2)
        self._tBackMount[self._tChangeIndex[i]]:addChild(pUpAttrAniNode)
        local pUpAttrAniAction = cc.CSLoader:createTimeline("PromoteEffect.csb")
        pUpAttrAniAction:setFrameEventCallFunc(onFrameEvent)
        pUpAttrAniAction:gotoFrameAndPlay(0,pUpAttrAniAction:getDuration(), false)
        pUpAttrAniNode:runAction(pUpAttrAniAction)
    end

end

-- 退出函数
function BladeSoulDialog:onExitBladeSoulDialog()
    self:onExitDialog()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("BladeSoulDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BladeSoulEatPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BladeSoulQueueNone.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BladeSoulQueuePanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("PromoteEffect.plist")

end

-- 循环更新
function BladeSoulDialog:update(dt)

    if  self._bTempBool then
        self._nCdTime =  self._nCdTime - dt
        --[[
        local minute = mmo.HelpFunc:gGetMinuteStr(self._nCdTime)
        local second = mmo.HelpFunc:gGetSecondStr(self._nCdTime)
        local format = minute..":"..second
        ]]
        local format = gTimeToStr(self._nCdTime)
       -- local format = mmo.HelpFunc:gTimeToStr(self._nCdTime)
        self._pCdTimeLable:setString("剩余"..format)
        self._pCdTimeBar:setPercent((1-self._nCdTime/ self._nAllDateTime)*100)
        if self._nCdTime < 0 then
            self._bTempBool = false
            self:RefiningOver()
        end
    end
    return
end

--cd走完后进行数据刷新
function BladeSoulDialog:RefiningOver()

    for i=1,#self._tBladeSoulInfo.refineList do
        if self._tBladeSoulInfo.refineList[i].state == kRefineState.kRefining then --如果是炼化中，显示炼化完成
            self._tBladeSoulInfo.refineList[i].state = kRefineState.kFinish
            break
        end
    end
    for i=1,#self._tBladeSoulInfo.refineList do
        if self._tBladeSoulInfo.refineList[i].state == kRefineState.kWait then  --如果是排队中，显示正在炼化
            self._tBladeSoulInfo.refineList[i].state = kRefineState.kRefining
            self._tBladeSoulInfo.refineList[i].remain = self._tBladeSoulInfo.refineList[i].total
            break
        end
    end
    DialogManager:getInstance():closeDialogByName("AlertDialog")
    self:initRefineItem() --从新刷新列表

end

--创建一个剑灵人物属性 最下面的
function BladeSoulDialog:createFairyLandDishBar()
    -- 进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName("BladeSoulDialogRes/jlxt8.png")
    local pLoadingBar = cc.ProgressTimer:create(pSprite)
    pLoadingBar:setPosition(cc.p(1,1))
    pLoadingBar:setAnchorPoint(0, 0)
    pLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pLoadingBar:setMidpoint(cc.p(0, 0))
    pLoadingBar:setBarChangeRate(cc.p(1, 0))
    pLoadingBar:setPercentage(0)
    return pLoadingBar
end

--设置境界盘的比例
function BladeSoulDialog:setFairyLandDishBarPercent(pLoadingBar,nPercent)
    pLoadingBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, nPercent)))
end

--通过 人物信息 打印获取了xxx剑魂
function BladeSoulDialog:setBladeSoulNameMessageByInfo(pBaldeSole)
    local pBaldeSolInfo = GetCompleteItemInfoById(pBaldeSole ,2)
    
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2)

    local _pResolveAniNode = cc.CSLoader:createNode("NovicegGuideFunction.csb")
    local _pResolveAniAction = cc.CSLoader:createTimeline("NovicegGuideFunction.csb")
    _pResolveAniNode:setScale(1)
    _pResolveAniNode:setPosition(pAniPostion)
    self:addChild( _pResolveAniNode)

    local icon = cc.Sprite:createWithSpriteFrameName(pBaldeSolInfo.templeteInfo.Icon.. ".png")
    icon:setPosition(pAniPostion)

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
           icon:removeFromParent(true)
           _pResolveAniNode:removeFromParent(true)
            
        end
    end
    _pResolveAniAction:setFrameEventCallFunc(onFrameEvent)
    _pResolveAniAction:gotoFrameAndPlay(0,_pResolveAniAction:getDuration(), false)
    _pResolveAniNode:stopAllActions()
    _pResolveAniNode:runAction(_pResolveAniAction)

    self:addChild(icon)
     
end

--返回button上是否有红点

function BladeSoulDialog:getShowNoitceHasVisible()
    if self:getCanHaveBoadeSoule() == true then
        self._pWarningSprite[1]:setVisible(true)
    end

    if self:getCanDevourBladeSoul() == true then
        self._pWarningSprite[2]:setVisible(true)
    end
end

--判断是否有可收取的剑魂
function BladeSoulDialog:getCanHaveBoadeSoule()
    if self._tBladeSoulInfo.refineList then
       return false
    end
	
    for k,v in pairs( self._tBladeSoulInfo.refineList) do
       if v.state == kRefineState.kFinish then
    	return true
       end
	end
	return false
end

--判断是否有可以吞噬的剑魂
function BladeSoulDialog:getCanDevourBladeSoul()
	if self._tBladeSoulInfo.baldeSoulList == nil or table.getn(self._tBladeSoulInfo.baldeSoulList) == 0 then 
	   return false
	end
	return true
end

-- 显示结束时的回调
function BladeSoulDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BladeSoulDialog:doWhenCloseOver()
    return
end

return BladeSoulDialog
