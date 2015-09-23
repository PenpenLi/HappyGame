--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FairyLandCellDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2014/12/16
-- descrip:    境界系统弹出的cell
--===================================================
local FairyLandCellDialog = class("FairyLandCellDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FairyLandCellDialog:ctor()
    self._strName = "FairyLandCellDialog"        -- 层名称

    self._pBg = nil
    self._pBg = nil
    self._pCloseButton = nil

    self._pTextListView = nil                --文字描述的滑动层
    self._pAttrName = nil
    self._pItemName = nil                    --item的title
    self._pTextIntroText = nil               --item的描述
    self._pButtonListView = nil              --右侧功能的滑动层
    self._pTabButton = nil                   --滑动的按钮
    self._pSaleNumText =nil                  --售价

    self._pTitleText = nil                   --整体提升效果tips Title
    self._pAttributeText = nil               --提升的效果数值
    self._pAttributeNum  = nil

    self._pItemInfo = nil
    self._pTabType = nil

end

-- 创建函数
function FairyLandCellDialog:create(args)
    local dialog = FairyLandCellDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function FairyLandCellDialog:dispose(args)
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            return true
        end
        return false   --可以向下传递事件
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
            self:onExitFairyLandCellDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    self._pItemInfo = args[1]
    self._pTabType = args[2]
   
    -- 加载dialog组件
    if  self._pTabType == fairyLandTabType.fairyLandTabInlay  or  self._pTabType == fairyLandTabType.fairyLandTabDrop then  --镶嵌 or 卸下
        if self._pItemInfo.templeteInfo == nil then
           return
         end
        self:loadInlayOrDischargeUi()
    else --整体提升效果
        self:loadAllAttUpUi()
    end

    return

end

--加载镶嵌或者卸下的Ui
function FairyLandCellDialog:loadInlayOrDischargeUi()
    ResPlistManager:getInstance():addSpriteFrames("BladeSoulPanel.plist")
    local params = require("BladeSoulPanelParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pItemFrame
    self._pCloseButton = params._pCloseButton
    self._pTextListView = params._pTextListView     --文字描述的滑动层
    self._pAttrName = params._pTextIntroText2       --境界丹属性Name
    self._pAttr = params._pTextIntroText3             --境界丹属性
    self._pItemName = params._pItemName             --item的title
    self._pTextIntroText = params._pTextIntroText   --item的描述
    self._pButtonListView = params._pButtonListView --右侧功能的滑动层
    self._pTabButton = params._pListButtonTab       --滑动的按钮
    self._pSaleNumText = params._pSaleNumText       --售价
    self._pSaleNumText:setVisible(false)
    -- 初始化dialog的基础组件
    self:disposeCSB()
    self._pAttrName:setString("境界丹属性")
    self._pItemName:setString(self._pItemInfo.templeteInfo.Name)
    -- 根据品质设置物品名字字体的颜色
    if self._pItemInfo.dataInfo.Quality and self._pItemInfo.dataInfo.Quality ~= 0 then
        self._pItemName:setColor(kQualityFontColor3b[self._pItemInfo.dataInfo.Quality])
    end
    -- 物品的描述文本

    local strArr = ""
    for i=1, #self._pItemInfo.dataInfo.Property do
        local ptempPro = self._pItemInfo.dataInfo.Property[i] --取出基础属性 {type ， 值}
        local pLevelUup = self._pItemInfo.dataInfo.LevelUp[i]
        local pDate = ptempPro[2]+pLevelUup*self._pItemInfo.level
        local pStr = pDate>0 and " +" or " "
        --[[
        if ptempPro[1] == kAttribute.kCritChance        --暴击几率
            or ptempPro[1] == kAttribute.kCritDmage     --暴击伤害
            or ptempPro[1] == kAttribute.kDodgeChance   --闪避
            or ptempPro[1] == kAttribute.kLifePerSecond --再生
            or ptempPro[1] == kAttribute.kLifeSteal     --吸血比率
        then
            pDate = (pDate*100).."%"
        end
        ]]
        strArr = strArr..kAttributeNameTypeTitle[ptempPro[1]]..pStr..pDate.."\n" --基础属性+升级的属性*级数
    end
    self._pAttr:setString(strArr)
    self._pTextIntroText:setString(self._pItemInfo.templeteInfo.Instruction)

    local buttonTouchEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._pTabType == fairyLandTabType.fairyLandTabInlay then  --镶嵌
                print("镶嵌")
                FairyLandCGMessage:sendMessageInlayFairyPill20602(self._pItemInfo.index)
                self:close()
            else --卸下
                print("卸下")
                showConfirmDialog("卸下境界丹将直接被吞噬，是否确定卸下？" , function()
                    FairyLandCGMessage:sendMessageDropFairyPill20604(self._pItemInfo.index) --确认卸下
                    self:close()
                end)  
               
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

local pNomalIcon = ""
local pPressicon = ""
    if  self._pTabType == fairyLandTabType.fairyLandTabInlay then
        pNomalIcon = "BladeSoulPanelRes/tips11.png"
        pPressicon = "BladeSoulPanelRes/tips12.png"	
    else
        pNomalIcon = "BladeSoulPanelRes/tips27.png"
        pPressicon = "BladeSoulPanelRes/tips28.png"	
    end

    self._pTabButton:loadTextures(pNomalIcon,pPressicon,pPressicon,ccui.TextureResType.plistType)
    --self._pTabButton:setZoomScale(nButtonZoomScale)
    --self._pTabButton:setPressedActionEnabled(true)
    self._pTabButton:setTitleFontSize(16)
    self._pTabButton:setTitleColor(cWhite)
    self._pTabButton:addTouchEventListener(buttonTouchEvent)

end

--加载整体提升效果的Ui
function FairyLandCellDialog:loadAllAttUpUi()

    ResPlistManager:getInstance():addSpriteFrames("FairLandTipsDialog.plist")
    local params = require("FairLandTipsDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pAttributeText = params._pAttributeText  --提升的效果数值
    self._pAttributeNum =  params._pAttributeNum   
    
    -- 初始化dialog的基础组件
    self:disposeCSB()

    local nCountNum = #self._pItemInfo
    local strArr = ""
    local strArrNum = ""
    for i=1,nCountNum do
        local pAttrType = self._pItemInfo[i]["attrType"]
        local pAttrValue = self._pItemInfo[i]["attrValue"]
        local pStr = pAttrValue>0 and " +" or " "
        --[[
        if pAttrType == kAttribute.kCritChance        --暴击几率
            or pAttrType == kAttribute.kCritDmage     --暴击伤害
            or pAttrType == kAttribute.kDodgeChance   --闪避
            or pAttrType == kAttribute.kLifePerSecond --再生
            or pAttrType == kAttribute.kLifeSteal     --吸血比率
        then
            pAttrValue = (pAttrValue*100).."%"
        end
        ]]
        strArr = strArr..kAttributeNameTypeTitle[pAttrType].."\n"
        strArrNum = strArrNum..pStr..pAttrValue.."\n"
    end
    self._pAttributeText:setString(strArr)
    self._pAttributeNum:setString(strArrNum)
end



-- 退出函数
function FairyLandCellDialog:onExitFairyLandCellDialog()
    self:onExitDialog()
     if  self._pTabType == fairyLandTabType.fairyLandTabInlay  or  self._pTabType == fairyLandTabType.fairyLandTabDrop then  --镶嵌 or 卸下
        ResPlistManager:getInstance():removeSpriteFrames("BladeSoulPanel.plist")
     else
        ResPlistManager:getInstance():removeSpriteFrames("FairLandTipsDialog.plist")
     end
end

-- 循环更新
function FairyLandCellDialog:update(dt)
    return
end

-- 显示结束时的回调
function FairyLandCellDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function FairyLandCellDialog:doWhenCloseOver()
    return
end

return FairyLandCellDialog
