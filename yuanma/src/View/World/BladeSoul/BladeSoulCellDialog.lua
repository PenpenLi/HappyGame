--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BladeSoulCellDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2014/12/16
-- descrip:    剑灵系统弹出的cell
--===================================================
local BladeSoulCellDialog = class("BladeSoulCellDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BladeSoulCellDialog:ctor()
    self._strName = "BladeSoulCellDialog"        -- 层名称

    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pTextListView = nil
    self._pItemName = nil                --item的名字
    self._pTextIntroText = nil           --剑魂属性
    self._pTextIntroText2 = nil          --攻击力 +49
    self._pTextIntroText3 = nil          --描述信息
    self._pButtonListView = nil          --butotnlistView
    self._pSaleNumText = nil             --sell金额
    self._pTabButton = nil           --单个button
    self._pUseMultiItemBtn = nil

    self._pItemInfo = nil
    self._nIndex = nil
    self._bHasMax = nil


end

-- 创建函数
function BladeSoulCellDialog:create(args)
    local dialog = BladeSoulCellDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function BladeSoulCellDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("BladeSoulPanel.plist")
    self._pItemInfo = args[1]
    self._nIndex = args[2]
    self._bHasMax = args[3]
        -- 设置是否需要缓存
    self:setNeedCache(true)
    local params = require("BladeSoulPanelParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pItemFrame
    self._pCloseButton = params._pCloseButton
    self._pTextListView = params._pTextListView
    self._pItemName = params._pItemName             --item的名字
    self._pTextIntroText = params._pTextIntroText   --剑魂属性
    self._pTextIntroText2 = params._pTextIntroText2 --攻击力 +49
    self._pTextIntroText3 = params._pTextIntroText3 --描述信息
    self._pButtonListView = params._pButtonListView --butotnlistView
    self._pSaleNumText = params._pSaleNumText       --sell金额
    self._pTabButton = params._pListButtonTab   --单个button
    self:disposeCSB()
    self:initBladeSoulUi()
    self:updateCellInfo()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
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
            self:onExitBladeSoulCellDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end

--初始化界面
function BladeSoulCellDialog:initBladeSoulUi()

    self._pTabButton:loadTextures("BladeSoulPanelRes/tips31.png","BladeSoulPanelRes/tips32.png",nil,ccui.TextureResType.plistType)
    --self._pTabButton:setZoomScale(nButtonZoomScale)
    --self._pTabButton:setPressedActionEnabled(true)
    self._pTabButton:setTitleFontSize(16)
    self._pTabButton:setTitleColor(cWhite)
 
    self._pUseMultiItemBtn = self._pTabButton:clone()
    self._pUseMultiItemBtn:loadTextures("BladeSoulPanelRes/tips17.png","BladeSoulPanelRes/tips18.png",nil,ccui.TextureResType.plistType)
    self._pButtonListView:addChild( self._pUseMultiItemBtn)

end

function BladeSoulCellDialog:updateCellInfo()

    self._pItemName:setString(self._pItemInfo.templeteInfo.Name)           --item的名字
    self._pTextIntroText2:setString("剑魂属性")   --剑魂属性
    self._pTextIntroText:setString(self._pItemInfo.templeteInfo.Instruction)--描述信息
    self._pSaleNumText:setString(self._pItemInfo.price)      --sell金额


    local strArr = " "
    for i=1,#self._pItemInfo.attrbs do
        local pAttrType = self._pItemInfo.attrbs[i]["attrType"]   
        local pDate = self._pItemInfo.attrbs[i]["attrValue"]
        local pStr = pDate > 0 and " +" or ""
        --[[
        if pAttrType == kAttribute.kCritChance        --暴击几率
        or pAttrType == kAttribute.kCritDmage     --暴击伤害
        or pAttrType == kAttribute.kDodgeChance   --闪避
        or pAttrType == kAttribute.kLifePerSecond --再生
        or pAttrType == kAttribute.kLifeSteal     --吸血比率
        then
        pDate = (pDate*100).."%"
        end
        ]]
        strArr = strArr..kAttributeNameTypeTitle[pAttrType]..pStr..pDate.."\n "

    end

    self._pTextIntroText3:setString(strArr)
    
    
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            if nTag == 1 then
                print("吞噬")
                if self._bHasMax then
                    showConfirmDialog("此次吞噬后，剑灵属性会超出当前等级限制，多余部分将被废弃，仍然确认进行吞噬？",function()
                        BladeSoulCGMessage:sendMessageDevourBladeSoul20710(self._nIndex)
                        self:close()end)            
                else
                    BladeSoulCGMessage:sendMessageDevourBladeSoul20710(self._nIndex) --吞噬剑魂请求
                    self:close()
                end


            else

                local nItemName = self._pItemInfo.templeteInfo.Name
                local nItemPrice =  self._pItemInfo.dataInfo.Price
                showConfirmDialog("是否确定出售 "..nItemName.." 出售后不可回收\n\n您将获得"..nItemPrice.."金币",function()
                    BladeSoulCGMessage:sendMessageSellBladeSoul20712(self._nIndex)
                    self:close()end)  --（背包中的下表，数量）  
                self._pTabButton:setTouchEnabled(true)
                self._pUseMultiItemBtn:setTouchEnabled(true)
                print("出售")
            end

        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pTabButton:setTag(1)
    self._pTabButton:addTouchEventListener(onTouchButton)
    self._pUseMultiItemBtn:setTag(2)
    self._pUseMultiItemBtn:addTouchEventListener(onTouchButton)
end


function BladeSoulCellDialog:updateCacheWithData(args)
    self._pItemInfo = args[1]
    self._nIndex = args[2]
    self._bHasMax = args[3]
    self:updateCellInfo()
end

-- 退出函数
function BladeSoulCellDialog:onExitBladeSoulCellDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("BladeSoulPanel.plist")

end

-- 循环更新
function BladeSoulCellDialog:update(dt)
    return
end

-- 显示结束时的回调
function BladeSoulCellDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BladeSoulCellDialog:doWhenCloseOver()
    return
end

return BladeSoulCellDialog
