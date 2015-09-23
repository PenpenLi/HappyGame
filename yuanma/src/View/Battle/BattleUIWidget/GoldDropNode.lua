--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GoldDropNode.lua
-- author:    taoye
-- e-mail:    870428198@qq.com
-- created:   2015/9/1
-- descrip:   金钱副本金币掉落的控件Node
--===================================================
local GoldDropNode = class("GoldDropNode",function()
    return cc.Node:create()
end)

-- 构造函数
function GoldDropNode:ctor()
    self._strName = "GoldDropNode"             -- 层名称
    self._pGoldIcon = nil                      -- 金币icon
    self._pGoldNum = nil                       -- 金币数量
end

-- 创建函数
function GoldDropNode:create()
    local node = GoldDropNode.new()
    node:dispose()
    return node
end

-- 处理函数
function GoldDropNode:dispose()
    ResPlistManager:getInstance():addSpriteFrames("GoldDropNode.plist")
    
    -- 加载组件
    local params = require("GoldDropNodeParams"):create()
    self._pGoldIcon = params._pgold             -- 金币icon
    self._pGoldNum = params._pText              -- 金币数量
    self:addChild(params._pCCS)
    
    -- 初始化数量
    self._pGoldNum:setString("x0")

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitGoldDropNode()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function GoldDropNode:onExitGoldDropNode()
    ResPlistManager:getInstance():removeSpriteFrames("GoldDropNode.plist")
    print(self._strName.." onExit!")

end

-- 显示动画
function GoldDropNode:showAniWithNum(num)
    
    self._pGoldIcon:stopAllActions()
    self._pGoldIcon:runAction(cc.Spawn:create(cc.Sequence:create(cc.RotateTo:create(0.1,45), cc.RotateTo:create(0.1,0)), cc.Sequence:create(cc.ScaleTo:create(0.1,1.2), cc.ScaleTo:create(0.1,1.0))))
    
    self._pGoldNum:stopAllActions()
    self._pGoldNum:setString("x"..num)
    self._pGoldNum:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1.1), cc.ScaleTo:create(0.05,1.0)))
    
end

return GoldDropNode
