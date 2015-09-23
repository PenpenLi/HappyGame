--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyUpLevelDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/7/14
-- descrip:   家族升级界面
--===================================================
local FamilyUpLevelDialog = class("FamilyUpLevelDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FamilyUpLevelDialog:ctor()
    self._strName = "FamilyUpLevelDialog"               -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pRichNode = nil                               --富文本
    self._pSureBtn = nil                                --确定按钮
    self._pCancelButton = nil                           --取消按钮
    self._pTitleImage = nil                             --家族升级的title
    self._pClickType = nil
    self._pClickInfo = nil
end

-- 创建函数
function FamilyUpLevelDialog:create(args)
    local dialog = FamilyUpLevelDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function FamilyUpLevelDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("PromptLvUpDialog.plist")
    if args then
        self._pClickType = args[1]
        self._pClickInfo = args[2]
    end

    local params = require("PromptLvUpDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pRichNode = params._pTextNode             --富文本
    self._pSureBtn = params._pOkButton              --确定按钮
    self._pCancelButton = params._pCancelButton     --取消按钮
    self._pFamilyContributeNum = params._pText_6_1  --需要的工会的贡献度
    self._pFamilyAssetNum = params._pText_7_1       --需要的工会的基金
    self._pTitleImage = params._pTitleImage         --家族升级的title
    --初始化数据
    self:initDate()

    -- 初始化dialog的基础组件
    self:disposeCSB()
    --初始化触摸机制
    self:initTouches()

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFamilyUpLevelDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end

-- 初始化触摸机制
function FamilyUpLevelDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
        end
        return true   --可以向下传递事件
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

end


function FamilyUpLevelDialog:initDate()

    local msg = {}
    local pNeedScore = 0       --需要家族贡献度
    local pNeedCash = 0        --需要的家族资金
    local pCurFamilyInfo = FamilyManager:getInstance()._pFamilyInfo
    local pImage = ""

    if self._pClickType == kFamilyUpLevelType.kUpFamilyLevel then --升级家族

        local pUpLevelInfo = TableFamilyLevel[pCurFamilyInfo.level]
        pNeedScore = pUpLevelInfo.UpgradeConstruction
        pNeedCash = pUpLevelInfo.UpgradeCapital
        pImage = "PromptLvUpDialogRes/jzjm20.png"
        msg = {
            {title = "当前家族等级为"},
            {title = pCurFamilyInfo.level,fontColor = cGreen},
            {title = ",请您确定要将家族升级至"},
            {title = pCurFamilyInfo.level+1,fontColor = cGreen},
            {title = "级吗？"},
        }


    elseif self._pClickType == kFamilyUpLevelType.kUpTechLevel then -- 升级家族研究所

        pNeedScore = self._pClickInfo.UpgradeConstruction
        pNeedCash = self._pClickInfo.UpgradeCapital
        pImage = "PromptLvUpDialogRes/jzjm21.png"
        msg = {
            {title = "当前家族研究所等级为"},
            {title =  self._pClickInfo.Lv,fontColor = cGreen},
            {title = ",请您确定要将家族研究所升级至"},
            {title =  self._pClickInfo.Lv+1,fontColor = cGreen},
            {title = "级吗？"},
        }
    elseif self._pClickType == kFamilyUpLevelType.kUpBuff then  -- 升级Buff
        local pTableInfo = FamilyManager:getInstance():getTechInfoByIdAndLevel(self._pClickInfo.techId,self._pClickInfo.level)
        pNeedScore = pTableInfo.UpgradeConstruction
        pNeedCash = pTableInfo.UpgradeCapital
        pImage = "PromptLvUpDialogRes/jzjm21.png"
        msg = {
            {title = "当前"},
            {title = pTableInfo.Name,fontColor = cGreen},
            {title = "的效果是"},
            {title = self._pClickInfo.level,fontColor = cGreen},
            {title = "级"},
            {title = ",请您确定要将其升级至"},
            {title = self._pClickInfo.level+1,fontColor = cGreen},
            {title = "级吗？"},
        }

    elseif self._pClickType == kFamilyUpLevelType.kActiveBuff then  -- 激活buff
        local pTableInfo = FamilyManager:getInstance():getTechInfoByIdAndLevel(self._pClickInfo.techId,self._pClickInfo.level)
        pNeedScore = pTableInfo.ActivateConstruction
        pNeedCash = pTableInfo.ActivateCapital
        pImage = "PromptLvUpDialogRes/jzjm21.png"
        msg = {
            {title = "确认激活"},
            {title = pTableInfo.Name,fontColor = cGreen},
            {title = "效果,激活后不可撤销"},
        }

    end
    
    
    local goodRichText = ccui.RichText:create()
    goodRichText:ignoreContentAdaptWithSize(false)
    goodRichText:setContentSize(cc.size(360,60))
    for k,v in pairs(msg)do
        if v.fontColor == nil then 
           v.fontColor = cWhite
        end
        local re1 = ccui.RichElementText:create(1,v.fontColor, 255,v.title, strCommonFontName, 20)
        goodRichText:pushBackElement(re1)
    end  
    goodRichText:setAnchorPoint(cc.p(0,1))
    goodRichText:setPosition(cc.p(0,0))
    self._pRichNode:addChild(goodRichText)


    self._pFamilyContributeNum:setString(pNeedScore)      --需要的工会的贡献度
    self._pFamilyAssetNum:setString(pNeedCash)            --需要的工会资金
    
    self._pTitleImage:loadTexture(pImage,ccui.TextureResType.plistType)

    local bIsCanUpLevel = false
    if pCurFamilyInfo.score < pNeedScore then --家族贡献度不够
        self._pFamilyContributeNum:setColor(cRed)
        bIsCanUpLevel = false
    else
        self._pFamilyContributeNum:setColor(cWhite)
        bIsCanUpLevel = true
    end

    if pCurFamilyInfo.cash <pNeedCash then --家族资金不够
        self._pFamilyAssetNum:setColor(cRed)
        bIsCanUpLevel = false
    else
        self._pFamilyAssetNum:setColor(cWhite)
    end

    local  onTouchOkButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if bIsCanUpLevel then

                if self._pClickType == kFamilyUpLevelType.kUpFamilyLevel then --升级家族
                    FamilyCGMessage:upgradeFamilyReq22316()
                elseif self._pClickType == kFamilyUpLevelType.kUpTechLevel then -- 升级家族研究所
                    FamilyCGMessage:upgradeFamilyAcademyReq22334()
                elseif self._pClickType == kFamilyUpLevelType.kUpBuff then  -- 升级Buff
                    FamilyCGMessage:upgradeFamilyTechReq22338(self._pClickInfo.techId)

                elseif self._pClickType == kFamilyUpLevelType.kActiveBuff then  -- 激活buff
                    FamilyCGMessage:activateFamilyTechReq22336(self._pClickInfo.techId)
                end
                self:close()
            else
                NoticeManager:getInstance():showSystemMessage("资金或者贡献不足！")
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end

    end

    self._pSureBtn:addTouchEventListener(onTouchOkButton)    --确定按钮


    local  onTouchCancelButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pCancelButton:addTouchEventListener(onTouchCancelButton)


end

-- 退出函数
function FamilyUpLevelDialog:onExitFamilyUpLevelDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("PromptLvUpDialog.plist")
end

-- 循环更新
function FamilyUpLevelDialog:update(dt)
    return
end

-- 显示结束时的回调
function FamilyUpLevelDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function FamilyUpLevelDialog:doWhenCloseOver()
    return
end

return FamilyUpLevelDialog
