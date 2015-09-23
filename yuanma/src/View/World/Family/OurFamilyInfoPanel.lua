--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OurFamilyInfoPanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/7/14
-- descrip:   家族信息界面
--===================================================

local OurFamilyInfoPanel = class("OurFamilyInfoPanel",function()
    return require("BasePanel"):create()
end)

-- 构造函数
function OurFamilyInfoPanel:ctor()
    self._strName = "OurFamilyInfoPanel" -- 层名称
    self._pCCS  = nil
    self._pBg  = nil                                     --背景
    self._pFamilyName = nil                              --名字
    self._pFamilyPos = nil                               --职位
    self._pFamilyLevel = nil                             --等级
    self._pFamilyNum = nil                               --成员数量
    self._pFamilyTenet = nil                             --宗旨
    self._pPutInText = nil                               --宗旨的显示txt
    self._pEditNameBtn = nil                             --修改名字
    self._pSaveTenetBtn = nil                            --保存宗旨
    self._pDonationNum = nil                             --捐献次数
    self._pContributeNum = nil                           --工会贡献数目
    self._pContributeBar = nil                           --工会贡献进度条
    self._pContributeBtn = nil                           --工会贡献按钮

    self._pAssetNum = nil                                --工会资产数目
    self._pAssetBar = nil                                --工会资产进度条
    self._pAssetBtn = nil                                --工会资产按钮

    self._pFamilyCurNum = nil                            --家族人数
    self._pFamilyCurLevel = nil                          --家族等级
    self._pFamilyUpLevelBtn = nil                        --家族升级

    self._pExitFamilyBtn = nil                           --退出家族
    self._pFamilyRankingBtn = nil                        --家族排行
    self._pFamilyShopBtn = nil                           --家族商店
    self._pFamilyTaskBtn = nil                           --家族任务
    
    self._pHomeLvUpEffectAni = nil                       -- 家族升级特效的ani

  
    self._pWarningSprite = {}    -- 1: 捐献 红点  2: 升级红点
end

-- 创建函数
function OurFamilyInfoPanel:create(func)
    local layer = OurFamilyInfoPanel.new()
    layer:dispose(func)
    return layer
end

-- 处理函数
function OurFamilyInfoPanel:dispose(func)
    --查找家族
    NetRespManager:getInstance():addEventListener(kNetCmd.kFindFamilyByIdResp ,handler(self, self.RespFindFamilyDate))
    --家族捐献
    NetRespManager:getInstance():addEventListener(kNetCmd.kDonateFamilyResp ,handler(self, self.RespDonateFamilyDate))
    --退出家族
    NetRespManager:getInstance():addEventListener(kNetCmd.kQuitFamilyResp ,handler(self, self.RespQuitFamily))
    --修改名字
    NetRespManager:getInstance():addEventListener(kNetCmd.kChangeFamilyNameResp ,handler(self, self.ChangeFamilyName))
    --修改宗旨
    NetRespManager:getInstance():addEventListener(kNetCmd.kChangeFamilyPurposeResp ,handler(self, self.ChangeFamilyPurpose))
    --工会升级
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpgradeFamilyResp ,handler(self, self.UpgradeFamilyDate))
    
    
    
    ResPlistManager:getInstance():addSpriteFrames("OurFamilyInfoPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("HomeLvUpEffect.plist")
    --初始化界面UI
    self:initFamilyInfo()


    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitOurFamilyInfoPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--初始化界面
function OurFamilyInfoPanel:initFamilyInfo()
    local params = require("OurFamilyInfoPanelParams"):create()
    self._pCCS = params._pCCS
    self._pFamilyName = params._pFamilyNameText          --名字
    self._pFamilyPos = params._pText_6                   --职位
    self._pFamilyLevel = params._pText_7                 --等级
    self._pFamilyNum = params._pText_8                   --成员数量
    self._pPutInTextNameNode = params._pPutInTextNameNode--宗旨
    self._pEditNameBtn = params._pChangeNameButton       --修改名字
    self._pSaveTenetBtn = params._pOkButton              --保存宗旨
    self._pPutInText = params._pPutInText               --宗旨的显示text
        
    self._pDonationNum =  params._pJxTextNum             --捐献次数
    self._pContributeNum = params._pGXText               --工会贡献数目
    self._pContributeBar = params._pGxBar                --工会贡献进度条
    self._pContributeBtn = params._pJxButton1            --工会贡献按钮

    self._pAssetNum = params._pZCText                    --工会资产数目
    self._pAssetBar = params._pZcBar                     --工会资产进度条
    self._pAssetBtn = params._pJxButton2                 --工会资产按钮

    self._pFamilyCurNum = params._pPNumText              --家族人数
    self._pFamilyCurLevel = params._pLvNumText           --家族等级
    self._pFamilyUpLevelBtn = params._pLvUpButton        --家族升级

    self._pExitFamilyBtn = params._pTuiChuButton         --退出家族
    self._pFamilyRankingBtn = params._pRakingButton      --家族排行
    self._pFamilyShopBtn = params._pShopButton           --家族商店
    self._pFamilyTaskBtn = params._pTaskButton           --家族任务

    self._pFamilyTenet = createEditBoxBySize(cc.size(360,180),TableConstants.FamilyPurposeMaxWord.Value,0)
    self._pPutInTextNameNode:addChild(self._pFamilyTenet)
    self:addChild(self._pCCS)

end

--初始化点击事件
function OurFamilyInfoPanel:initButtonFun()

  --修改名字
    local onTouchEditNameBtn = function (sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        if FamilyManager:getInstance():whetherHasPermission(kFamilyChiefType.kChangeName) then --是否有权限修改工会名字
           DialogManager:getInstance():showDialog("RolesChangeNameDialog",{kChangeNameType.kChangeFamilyName})
        end
    elseif eventType == ccui.TouchEventType.began then
        AudioManager:getInstance():playEffect("ButtonClick")
         
      end
   end
  
    self._pEditNameBtn:addTouchEventListener(onTouchEditNameBtn)

    --保存修改宗旨
    local onTouchSaveTenetBtn = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if FamilyManager:getInstance():whetherHasPermission(kFamilyChiefType.kChangePurpsoe) then --是否有权限修改宗旨
                local pString = self._pPutInText:getString()
                if strIsHaveMoji(pString) then
                   NoticeManager:getInstance():showSystemMessage("宗旨含有非法字符，请重新输入！")
                   return 
                end   
                if string.find(pString,"□") then
                    NoticeManager:getInstance():showSystemMessage("宗旨含有非法字符，请重新输入！")
                    return 
                end
               FamilyCGMessage:changeFamilyPurposeReq22312(pString) 
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pSaveTenetBtn:addTouchEventListener(onTouchSaveTenetBtn)

    --工会贡献按钮
    local onTouchContributeBtn = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if FamilyManager:getInstance()._nDonateCount == TableConstants.FamilyDonatePerDay.Value then 
                NoticeManager:getInstance():showSystemMessage("今日贡献次数已经用完")
               return 
            end
            DialogManager:getInstance():showDialog("FamilyContributeDialog",{kContributionType.kScore})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pContributeBtn:addTouchEventListener(onTouchContributeBtn)
    
    self._pWarningSprite[1] = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSprite[1]:setPosition(15,50)
    self._pWarningSprite[1]:setScale(0.2)
    self._pWarningSprite[1]:setVisible(true)
    self._pWarningSprite[1]:setAnchorPoint(cc.p(0.5, 0.5))
    self._pContributeBtn:addChild(self._pWarningSprite[1])

    -- 上下移动动画效果
    local actionMoveBy = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
    local actionMoveToBack = cc.ScaleTo:create(0.5,0.6,0.6)
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pWarningSprite[1]:stopAllActions()
    self._pWarningSprite[1]:runAction(cc.RepeatForever:create(seq1))

    --工会资产按钮
    local onTouchAssetBtn = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if FamilyManager:getInstance()._nDonateCount == TableConstants.FamilyDonatePerDay.Value then 
                NoticeManager:getInstance():showSystemMessage("今日贡献次数已经用完")
                return 
            end
            DialogManager:getInstance():showDialog("FamilyContributeDialog",{ kContributionType.KCash})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pAssetBtn:addTouchEventListener(onTouchAssetBtn)
    

    --升级家族
    local onTouchUpLevelBtn = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if FamilyManager:getInstance():whetherHasPermission(kFamilyChiefType.kUpgradeFamily) then --是否有权限升级家族
               DialogManager:getInstance():showDialog("FamilyUpLevelDialog",{kFamilyUpLevelType.kUpFamilyLevel})       
            end     
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    self._pFamilyUpLevelBtn:addTouchEventListener(onTouchUpLevelBtn)
    
    self._pWarningSprite[2] = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSprite[2]:setPosition(15,60)
    self._pWarningSprite[2]:setScale(0.2)
    self._pWarningSprite[2]:setVisible(true)
    self._pWarningSprite[2]:setAnchorPoint(cc.p(0.5, 0.5))
    self._pFamilyUpLevelBtn:addChild(self._pWarningSprite[2])

    -- 上下移动动画效果
    local actionMoveBy = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
    local actionMoveToBack = cc.ScaleTo:create(0.5,0.6,0.6)
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pWarningSprite[2]:stopAllActions()
    self._pWarningSprite[2]:runAction(cc.RepeatForever:create(seq1))
    
    --家族功能按钮
    local onTouchBtn = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            if nTag == 1000 then      --退出家族
                showConfirmDialog("您确定要将族长之位转让给他人？操作成功之后您将降为普通成员。",function() FamilyCGMessage:quitFamilyReq22328() end)   
            elseif nTag == 2000 then  --家族排行
                DialogManager:getInstance():showDialog("FamilyRankDialog")
                FamilyCGMessage:queryFamilyListReq22300(0,8)
            elseif nTag == 3000 then  --家族商店
                DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kFamilyShop})
            elseif nTag == 4000 then  --家族任务
                DialogManager:getInstance():showDialog("TaskDialog",{true})
            end
            
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    --退出家族
    self._pExitFamilyBtn:addTouchEventListener(onTouchBtn)   
    self._pExitFamilyBtn:setTag(1000)  
    --家族排行
    self._pFamilyRankingBtn:addTouchEventListener(onTouchBtn)
    self._pFamilyRankingBtn:setTag(2000)   
    --家族商店
    self._pFamilyShopBtn:addTouchEventListener(onTouchBtn) 
    self._pFamilyShopBtn:setTag(3000)   
    --家族任务
    self._pFamilyTaskBtn:addTouchEventListener(onTouchBtn) 
    self._pFamilyTaskBtn:setTag(4000)   
     

    local editBoxTextEventHandle = function(strEventName,pSender)
        local edit = pSender
        local strFmt 
        if strEventName == "began" then
         local pString = self._pPutInText:getString()
         self._pFamilyTenet:setText(pString)
        elseif strEventName == "ended" then
            --release_print("2")
        elseif strEventName == "return" then
           -- release_print("3")
        elseif strEventName == "changed" then
            --release_print("editBox changed")
            local pText = self._pFamilyTenet:getText()
            local pString = unicodeToUtf8(pText)
            --cclog("inputS:"..pString)
            self._pFamilyTenet:setText("")
            self._pPutInText:setString(pString)

        end
    end
    self._pFamilyTenet :registerScriptEditBoxHandler(editBoxTextEventHandle) 
end


--初始化界面数据
function OurFamilyInfoPanel:updateFamilyDate(pInfo)
    if pInfo == nil then 
        return 
    end
    local pTableFamilyLevel = TableFamilyLevel[pInfo.level]
    --名字
    self._pFamilyName:setString(pInfo.familyName)
    --家族族长
    self._pFamilyPos:setString(pInfo.leaderName)
    --等级
    self._pFamilyLevel:setString(pInfo.level)     
    --成员数量                    
    self._pFamilyNum:setString(pInfo.memCount.."/"..pInfo.memTotal)        
    --宗旨                      
    self._pPutInText:setString(pInfo.purpose)      
    --工会捐献次数
    self._pDonationNum:setString(FamilyManager:getInstance()._nDonateCount.."/"..TableConstants.FamilyDonatePerDay.Value)
    --工会贡献数目
    self._pContributeNum:setString(pInfo.score)                          
    --工会资产数目
    self._pAssetNum:setString(pInfo.cash)                       
    --家族人数
    self._pFamilyCurNum:setString(pInfo.memCount)         
    --家族等级                 
    self._pFamilyCurLevel:setString(pInfo.level)       
    --工会贡献进度条                       
    self._pContributeBar:setPercent(pInfo.score/pTableFamilyLevel.ConstructionLimit*100)     
    --工会资产进度条                     
    self._pAssetBar:setPercent(pInfo.cash/pTableFamilyLevel.CapitalLimit*100)                                         
    --家族的地位
    local pTablePosInfo = TableFamilyPosition[FamilyManager:getInstance()._position] 
    
    --标示已经满级了
    if pTableFamilyLevel.UpgradeConstruction == 0 then
        self._pFamilyUpLevelBtn:setTitleText("已满级")
        self._pFamilyUpLevelBtn:setTouchEnabled(false)
        darkNode(self._pFamilyUpLevelBtn:getVirtualRenderer():getSprite())
    end
    --设置是否可以捐献的提示
    self:setContributeNoticeHasVisible(FamilyManager:getInstance()._nDonateCount)
    --设置是否可以升级提示
    self:setOurFamilyHasLvUp()
end


--获取家族信息
function OurFamilyInfoPanel:RespFindFamilyDate(event)
    --初始化点击事件
    self:initButtonFun()
    --初始化界面数据
    self:updateFamilyDate(event.familyInfo[1])
end

--更新家族的贡献度
function OurFamilyInfoPanel:RespDonateFamilyDate(event)

    NoticeManager:getInstance():showSystemMessage("捐献成功")

    local pInfo = FamilyManager:getInstance()._pFamilyInfo
    --家族建设度
    pInfo.score = event.construction
    --家族资金
    pInfo.cash = event.cash
    --个人贡献度
    local pRoleCons = event.contribution
    --捐献次数
    FamilyManager:getInstance()._nDonateCount = event.donateCount
    
    local pTableFamilyLevel = TableFamilyLevel[pInfo.level]
    --工会捐献次数
    self._pDonationNum:setString(event.donateCount.."/"..TableConstants.FamilyDonatePerDay.Value)
     --工会贡献数目
    self._pContributeNum:setString(event.construction)                          
    --工会资产数目
    self._pAssetNum:setString(event.cash)       
    --工会贡献进度条                       
    self._pContributeBar:setPercent(event.construction/pTableFamilyLevel.ConstructionLimit*100)     
    --工会资产进度条                     
    self._pAssetBar:setPercent(event.cash/pTableFamilyLevel.CapitalLimit*100)  
    --设置是否可以捐献的提示
    self:setContributeNoticeHasVisible(event.donateCount)
    --设置是否可以升级提示
    self:setOurFamilyHasLvUp()
    
    --标示已经满级了
    if pTableFamilyLevel.UpgradeConstruction == 0 then
        self._pFamilyUpLevelBtn:setTitleText("已满级")
        self._pFamilyUpLevelBtn:setTouchEnabled(false)
        darkNode(self._pFamilyUpLevelBtn:getVirtualRenderer():getSprite())
    end
end

-- 播放家族升级特效
function OurFamilyInfoPanel:playFamilyUpLevelAni()
    if not self._pHomeLvUpEffectAni then
       self._pHomeLvUpEffectAni = cc.CSLoader:createNode("HomeLvUpEffect.csb")
       local pPos = cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2)
       self._pHomeLvUpEffectAni:setPosition(cc.p(0,0))
       self:addChild( self._pHomeLvUpEffectAni,2)
    end
       self._pHomeLvUpEffectAni:stopAllActions()
       local pAction = cc.CSLoader:createTimeline("HomeLvUpEffect.csb")
       pAction:gotoFrameAndPlay(0,pAction:getDuration(), false)
       self._pHomeLvUpEffectAni:runAction(pAction)
    
end


--退出家族
function OurFamilyInfoPanel:RespQuitFamily(event)
   DialogManager:getInstance():closeDialogByName("FamilyDialog")
   FamilyManager:getInstance()._bOwnFamily = false
end

--修改名字
function OurFamilyInfoPanel:ChangeFamilyName(event)
    self._pFamilyName:setString(event.strName)
end

--修改宗旨
function OurFamilyInfoPanel:ChangeFamilyPurpose(event)
    self._pPutInText:setString(event.strPurpose)
end

--工会升级
function OurFamilyInfoPanel:UpgradeFamilyDate(event)

    --播放家族升级特效
    self:playFamilyUpLevelAni()
	--更新信息
    self:updateFamilyDate(event)
    --设置是否可以升级提示
    self:setOurFamilyHasLvUp()
end

--捐献按钮红点是否显示
function OurFamilyInfoPanel:setContributeNoticeHasVisible(pCurCount)
    --捐献按钮是否可以捐献
    local pCanContribute = false
    if  pCurCount < TableConstants.FamilyDonatePerDay.Value then
        pCanContribute = true
    end
    ------下面写那个红点是否显示
    --NoticeNode：setVisible(pCanContribute)
    self._pWarningSprite[1]:setVisible(pCanContribute)
    
end

--设置是否可以升级的提示
function OurFamilyInfoPanel:setOurFamilyHasLvUp()
  local  pCurFamilyInfo = FamilyManager:getInstance()._pFamilyInfo
  local pUpLevelInfo = TableFamilyLevel[pCurFamilyInfo.level]
  local pNeedScore = pUpLevelInfo.UpgradeConstruction
  local pNeedCash = pUpLevelInfo.UpgradeCapital
    
    local bIsCanUpLevel = false
    if pCurFamilyInfo.score < pNeedScore then --家族贡献度不够
        bIsCanUpLevel = false
    else
        bIsCanUpLevel = true
    end

    if pCurFamilyInfo.cash <pNeedCash then --家族资金不够
        bIsCanUpLevel = false
    end
    ------下面写那个红点是否显示
    --NoticeNode：setVisible(bIsCanUpLevel)
    self._pWarningSprite[2]:setVisible(bIsCanUpLevel)
    
end


--清空中间数据(必须实现)
function OurFamilyInfoPanel:clearPanelDateInfo()

end

-- 退出函数
function OurFamilyInfoPanel:onExitOurFamilyInfoPanel()
    -- release合图资源
    ResPlistManager:getInstance():removeSpriteFrames("OurFamilyInfoPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("HomeLvUpEffect.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end


return OurFamilyInfoPanel
