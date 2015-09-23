--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryCopyItem.lua
-- author:    yuanjiashun
-- created:   2015/4/15
-- descrip:   每个关卡的小icon
--===================================================

local StoryCopyItem = class("StoryCopyItem",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function StoryCopyItem:ctor()
    self._strName = "StoryCopyItem"        -- 层名称
    self._pBg = nil                         --背景
    self._pIconBtn = nil                    --item的显示button
    self._tStartItem = {}                   --星星的ui
    self._pItemInfo = nil
    self._tAssessImage = {}                 --评估的图片地址 狂 斩
    self._fCallBack = nil

end

-- 创建函数
function StoryCopyItem:create(func)
    local layer = StoryCopyItem.new()
    layer:dispose(func)
    return layer
end

-- 处理函数
function StoryCopyItem:dispose(func)
    self._fCallBack = func
    self._tAssessImage = {"StoryCopysCom/jqfb30.png","StoryCopysCom/jqfb31.png","StoryCopysCom/jqfb32.png","StoryCopysCom/jqfb33.png","StoryCopysCom/jqfb34.png"}
    local pStartPos = {{-51.5,6},{-49.5,-14},{-41.5,-33},{-23,-45},{-1.5,-52}} --星星的坐标

    self._pBg = ccui.ImageView:create("StoryCopysCom/BagItem.png",ccui.TextureResType.plistType)
    self:addChild(self._pBg)
    --图标按钮
    local nSize = self._pBg:getContentSize()
    self._pIconBtn = nil
    self._pIconBtn = ccui.Button:create(
        "StoryCopysCom/BagItem.png",
        "StoryCopysCom/BagItem.png",
        nil,
        ccui.TextureResType.plistType)
    self._pIconBtn:setTouchEnabled(true)
    self:addChild(self._pIconBtn)
    self._pIconBtn:setVisible(false)

    --创建星星
    for i=1,table.getn(pStartPos)do
        local pStart = ccui.ImageView:create("StoryCopysCom/jqfb7.png",ccui.TextureResType.plistType)
        pStart:setPosition(cc.p(pStartPos[i][1],pStartPos[i][2]))
        pStart:setVisible(false)
        self:addChild(pStart)
        table.insert(self._tStartItem,pStart)
    end

    --评估图片  狂 强
    self._pAssessImage = ccui.ImageView:create("StoryCopysCom/jqfb30.png",ccui.TextureResType.plistType)
    self._pAssessImage:setPosition(cc.p(38,-17))
    self._pAssessImage:setVisible(false)
    self:addChild(self._pAssessImage)


    --首次通关奖励背景
    self._pFirstClearBg = ccui.ImageView:create("StoryCopysCom/jqfb6.png",ccui.TextureResType.plistType)
    self._pFirstClearBg:setPosition(cc.p(50,60))
    self._pFirstClearBg:setVisible(false)
    self:addChild(self._pFirstClearBg)

    --首次通关奖励
    self._pFirstClearImage = ccui.ImageView:create("StoryCopysCom/rwjm19.png",ccui.TextureResType.plistType)
    self._pFirstClearImage:setPosition(cc.p(50,55))
    self._pFirstClearBg:addChild(self._pFirstClearImage)


    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitStoryCopyItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--注册点击回调
function StoryCopyItem:registerTouchEvent(func)
    if func ~= nil then
        self._pIconBtn:addTouchEventListener(func)
    end
end

function StoryCopyItem:setItemInfo(info)
    self._pItemInfo = info
    if info == nil then
    	return 
    end
    
    --设置关卡的图标
    self._pIconBtn:setVisible(true)
    local pIconAdd = "StoryCopysCom/"..info.MapIcon ..".png"
    self._pIconBtn:loadTextures(pIconAdd,pIconAdd,nil,ccui.TextureResType.plistType)
    
    --设置额外奖励
    local pFirstClear = info.FirstClear
    if pFirstClear ~= nil and table.getn(pFirstClear) ~= 0 then
        self._pFirstClearBg:setVisible(true)
    end
  
end

--设置评星等级
function StoryCopyItem:setStartNum(nNum)
    if nNum <= 0 then
        return
    end
    for i=1,5 do
        local bHasVis = (i <= nNum and true or false)
        self._tStartItem[i]:setVisible(bHasVis)
    end

    --加载评价图片
    self._pAssessImage:loadTexture(self._tAssessImage[nNum],ccui.TextureResType.plistType)
    self._pAssessImage:setVisible(true)

end

--设置置灰色
function StoryCopyItem:setItemGray(info)
    self._pItemInfo = info
    if info == nil then
        return 
    end

    --设置关卡的图标
    self._pIconBtn:setVisible(true)
    local pIconAdd = "StoryCopysCom/"..info.MapLockIcon ..".png"
    self._pIconBtn:loadTextures(pIconAdd,pIconAdd,nil,ccui.TextureResType.plistType)

 
end



-- 设置ItemCell 是否可以点击
function StoryCopyItem:setTouchEnabled(isEnable)
    self._pIconBtn:setTouchEnabled(isEnable)
end
--设置首次奖励框是否显示
function StoryCopyItem:setFirstClearBgHasVisible(bBool)
    self._pFirstClearBg:setVisible(bBool)
end


-- 退出函数
function StoryCopyItem:onExitStoryCopyItem()

end

-- 循环更新
function StoryCopyItem:update(dt)
    return
end

-- 显示结束时的回调
function StoryCopyItem:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function StoryCopyItem:doWhenCloseOver()
    return
end

return StoryCopyItem
