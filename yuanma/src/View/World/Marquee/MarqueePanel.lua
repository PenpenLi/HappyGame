--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MarqueePanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/13
-- descrip:   跑马灯界面
--===================================================

local MarqueePanel = class("MarqueePanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function MarqueePanel:ctor()
    self._strName = "MarqueePanel" -- 层名称
    self._bStart = true
end

-- 创建函数
function MarqueePanel:create()
    local layer = MarqueePanel.new()
    layer:dispose()
    return layer
end

-- 处理函数
function MarqueePanel:dispose()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMarqueePanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--跑马灯的动画实现
function MarqueePanel:runMarqueeAction()

    local sScreen = mmo.VisibleRect:getVisibleSize()
    local sSize = cc.size(680,44)
    local pMarqueeBg1 = ccui.Layout:create()
    pMarqueeBg1:setBackGroundImage("ccsComRes/pmd.png",ccui.TextureResType.plistType)
    pMarqueeBg1:setBackGroundImageScale9Enabled(true)
    pMarqueeBg1:setClippingEnabled(true)
    pMarqueeBg1:setContentSize(sSize)
    pMarqueeBg1:setPosition(sScreen.width/2-sSize.width/2,sScreen.height*0.78)
    self:addChild(pMarqueeBg1)
    local pNode,pContentSize = nil 
    local pTempMarqueeInfo = NoticeManager:getInstance():getMarqueeMessage()[1]
    if pTempMarqueeInfo.mtp ==1 then   --私聊频道
        local pVipString = "[VIP"..pTempMarqueeInfo.args[1].."]"
        local pName = pTempMarqueeInfo.args[2].." :"
        local pContent = StrToLua(pTempMarqueeInfo.args[3])[1]
        pNode = require("ElementText"):create(pVipString,nil,pName,nil,pContent,nil,nil,cc.size(10000,1))
        pNode:setAnchorPoint(cc.p(0,0.5))

        pContentSize = pNode:getTotalWidth()
    else
        pNode,pContentSize = getMarqueeNode(pTempMarqueeInfo)
    end
   
    
    pNode:setPosition(cc.p(sSize.width,sSize.height/2-2))
    pMarqueeBg1:addChild(pNode)  

    local function doRemoveFromParentAndCleanup(sender)
        pMarqueeBg1:removeFromParent(true) 
        local pInfo = NoticeManager:getInstance():getMarqueeMessage()   
        table.remove(pInfo,1)
        if table.getn(pInfo) ~= 0 then
            self:runMarqueeAction()
        else
            self._bStart = true
        end

    end
    pNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(25,cc.p(-pContentSize,sSize.height/2-2)),cc.CallFunc:create(doRemoveFromParentAndCleanup))))

end


-- 循环更新
function MarqueePanel:update(dt)
    if self._bStart == true then
        self:runMarqueeAction()
        self._bStart = false
    end  
end

-- 退出函数
function MarqueePanel:onExitMarqueePanel()
    -- release合图资源
end

return MarqueePanel
