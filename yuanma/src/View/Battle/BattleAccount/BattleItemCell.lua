--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleItemCell.lua
-- author:    yuanjiashun
-- created:   2015/4/7
-- descrip:   战斗背包格子
--===================================================

local BattleItemCell = class("BattleItemCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function BattleItemCell:ctor()
    self._strName = "BattleItemCell"        -- 层名称
    self._pBg = nil                         --背景
    self._pIconBtn = nil                    --item的显示button
    self._pItemNum = nil                    --item的数量
  
end 

-- 创建函数
function BattleItemCell:create()
    local layer = BattleItemCell.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleItemCell:dispose() 
    self._pBg = ccui.ImageView:create("ccsComRes/BagItem.png",ccui.TextureResType.plistType)
    self._pBg:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pBg)
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- 如果物品类型是装备
            if self._pItemInfo.baseType == kItemType.kEquip then  
              DialogManager:getInstance():showDialog("EquipCallOutDialog",{nil,self._pItemInfo,kCalloutSrcType.kCalloutSrcEquip,false})      
            else
                DialogManager:getInstance():showDialog("BagCallOutDialog",{self._pItemInfo,kCalloutSrcType.KCalloutSrcTypeUnKnow,{},false,false})
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pIconBtn = nil
    self._pIconBtn = ccui.Button:create(
        "ccsComRes/BagItem.png",
        "ccsComRes/BagItem.png",
        "ccsComRes/BagItem.png",
        ccui.TextureResType.plistType)
    self._pIconBtn:setTouchEnabled(true)
    self._pIconBtn:setPosition(0,0)
    self._pIconBtn:setAnchorPoint(cc.p(0, 0))
    self:addChild(self._pIconBtn)
    self._pIconBtn:addTouchEventListener(onTouchButton)
    self._pIconBtn:setVisible(false)
    

    --数量
    self._pItemNum = cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pItemNum:setLineHeight(20)
    self._pItemNum:setAdditionalKerning(-2)
    self._pItemNum:setTextColor(cc.c4b(255, 255, 255, 255))
    self._pItemNum:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self._pItemNum:setPositionX(0)
    self._pItemNum:setPositionY(36)
    self._pItemNum:setWidth(85)
    --self._pItemNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pNameLbllbl:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pItemNum:setAnchorPoint(0,1)
    self:addChild(self._pItemNum)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBagItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--注册点击回调
function BattleItemCell:registerTouchEvent(func)
    if func ~= nil then
        self._pIconBtn:addTouchEventListener(func)
    end
end


-- 重载背景
function BattleItemCell:loadBgWithFilename(filename ,textureType )
    if not textureType then
    textureType = ccui.TextureResType.plistType
    end
    self._pBg:loadTexture(filename,textureType)
end

function BattleItemCell:setItemInfo(info)
    if not info then
        self._pItemInfo = nil
        self._pIconBtn:setVisible(false)
        self._pItemNum:setString("")
        if self._pEquipQualityBg then
            self._pEquipQualityBg:setVisible(false)
        end
        return
    end
    
    self._pItemInfo = info
    self._pIconBtn:setVisible(true)
    self._pIconBtn:loadTextures(
        self._pItemInfo.templeteInfo.Icon ..".png",
        self._pItemInfo.templeteInfo.Icon ..".png",
        self._pItemInfo.templeteInfo.Icon ..".png",
        ccui.TextureResType.plistType)

    if self._pItemInfo.baseType == kItemType.kEquip then  --只有装备不可叠加
        self._pItemNum:setString("")   
    else
        self._pItemNum:setString(self._pItemInfo.value)
    end
   
    if self._pItemInfo.dataInfo.Quality ~= nil and self._pItemInfo.dataInfo.Quality ~= 0 then
        if self._pEquipQualityBg == nil then
            self._pEquipQualityBg = ccui.ImageView:create()
            self._pEquipQualityBg:setAnchorPoint(cc.p(0,0))
            self._pBg:addChild(self._pEquipQualityBg)
        end
        local nEquipQuality = self._pItemInfo.dataInfo.Quality
        self._pEquipQualityBg:loadTexture("ccsComRes/qual_" ..nEquipQuality.."_normal.png",ccui.TextureResType.plistType)
        self._pEquipQualityBg:setVisible(true)
    end

end

function BattleItemCell:setFinanceInfo(info)
    if not info then
        self._pItemInfo = nil
        self._pIconBtn:setVisible(false)
        self._pItemNum:setString("")
        if self._pEquipQualityBg then
            self._pEquipQualityBg:setVisible(false)
        end
        return
    end
    self._pItemInfo = info
    self._pIconBtn:setVisible(true)
    self._pIconBtn:setTouchEnabled(false)
    self._pIconBtn:loadTextures(
        info.fileBigName ,
        info.fileBigName,
        info.fileBigName ,
        ccui.TextureResType.plistType)
        self._pItemNum:setString(info.amount)
    if self._pEquipQualityBg then
        self._pEquipQualityBg:setVisible(false)
    end
	
end


-- 设置ItemCell 是否可以点击
function BattleItemCell:setTouchEnabled(isEnable)
    self._pIconBtn:setTouchEnabled(isEnable)
end


-- 设置数量标签是否可以显示
function BattleItemCell:setItemNumHasVisible(isVisible)
    self._pItemNum:setVisible(isVisible)
end

--设置数量
function BattleItemCell:setItemNum(nNum)
    self._pItemNum:setString(nNum)
end


-- 退出函数
function BattleItemCell:onExitBagItem()

end

-- 循环更新
function BattleItemCell:update(dt)
    return
end

-- 显示结束时的回调
function BattleItemCell:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BattleItemCell:doWhenCloseOver()
    return
end

-- 获取尺寸
function BattleItemCell:getContentSize()
    return self._pIconBtn:getContentSize()
end

function BattleItemCell:getBoundingBox()
    return self._pIconBtn:getBoundingBox()
end

return BattleItemCell
