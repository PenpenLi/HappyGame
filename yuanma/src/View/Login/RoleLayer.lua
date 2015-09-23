--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/24
-- descrip:   角色层
--===================================================
local RoleLayer = class("RoleLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function RoleLayer:ctor()
    self._strName = "RoleLayer"           -- 层名称
    self._pTouchListener = nil            -- 触摸监听器
    self._pBg = nil                       -- 大背景
    self._nOperateType = -1               -- 操作模式，0直接进入的创建角色界面     1直接进入的选择角色界面  2由选择角色界面进入的创建角色界面  3由创建角色界面进入选择角色界面
end

-- 创建函数
function RoleLayer:create(operateType)
    local layer = RoleLayer.new()
    layer:dispose(operateType)
    return layer
end

-- 处理函数
function RoleLayer:dispose(operateType)
    -- 加载合图资源
    ResPlistManager:getInstance():addSpriteFrames("LoginBg.plist")
    -- 操作模式
    self._nOperateType = operateType
    
    -- 初始化BG
    self:initBG()

    -- 初始化触摸
    self:initTouches()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRoleLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function RoleLayer:onExitRoleLayer()    
    self:onExitLayer()
    
end

-- 循环更新
function RoleLayer:update(dt)

end

-- 初始化触摸相关
function RoleLayer:initTouches()
    local posTouchBeginX = -1
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        posTouchBeginX = location.x

        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
        if self._nOperateType == 0 or self._nOperateType == 2 then  -- 创建角色模式
            local layer = self:getGameScene():getLayerByName("RoleCreateLayer")
            local rotation = layer._tCRRoleList[layer._kCRCurCareer]:getRotation3D()
            local dist = location.x - posTouchBeginX
            layer._tCRRoleList[layer._kCRCurCareer]:setRotation3D(cc.vec3(rotation.x, rotation.y+dist/5, rotation.z))
        elseif self._nOperateType == 1 then  -- 选择角色模式
            local layer = self:getGameScene():getLayerByName("RoleSelectLayer")
            local rotation = layer._tSRRoleList[layer._nCurRoleIndex]:getRotation3D()
            local dist = location.x - posTouchBeginX
            layer._tSRRoleList[layer._nCurRoleIndex]:setRotation3D(cc.vec3(rotation.x, rotation.y+dist/5, rotation.z))
        end
        posTouchBeginX = location.x
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("===========================================================================")
        print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        print("===========================================================================")
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

end

-- 初始化BG
function RoleLayer:initBG()
    -- 登录系统背景
    self._pBg = cc.Sprite:createWithSpriteFrameName("LoginBgRes/jscj_bg.png")
    self._pBg:setPosition(mmo.VisibleRect:center())
    self:addChild(self._pBg)

    local paricle = cc.ParticleSystemQuad:create("SetEffect01.plist")
    local parent = cc.ParticleBatchNode:createWithTexture(paricle:getTexture())
    paricle:setPositionType(cc.POSITION_TYPE_GROUPED)
    parent:setScale(2)
    parent:addChild(paricle)
    parent:setPosition(self._pBg:getContentSize().width/2, self._pBg:getContentSize().height/2)
    self._pBg:addChild(parent)
    
end

-- 显示（带动画）
function RoleLayer:showWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:setVisible(true)
    self:stopAllActions()

    local pPreposMask = cc.Layer:create()
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)

    local showOver = function()
        self:doWhenShowOver()
        if self._pTouchListener ~= nil then
            self._pTouchListener:setEnabled(true)
        end
        pPreposMask:removeFromParent(true)
    end
    pPreposMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(showOver)))
    return
end


-- 关闭（带动画）
function RoleLayer:closeWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:stopAllActions()

    local closeOver = function()
        self:doWhenCloseOver()
        self:removeFromParent(true)
    end
    local pPreposMask = cc.Layer:create()
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)
    pPreposMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(closeOver)))

    return
end

-- 显示结束时的回调
function RoleLayer:doWhenShowOver()    
    return
end

-- 关闭结束时的回调
function RoleLayer:doWhenCloseOver()
    if cc.Director:getInstance():getRunningScene()._bForceQuit == true then
        --LayerManager:getInstance():transformToLoading()
    end
    return
end

return RoleLayer
