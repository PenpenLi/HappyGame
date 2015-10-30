--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FightRoleUINode.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/16
-- descrip:   角色UI控件Node
--===================================================
local FightRoleUINode = class("FightRoleUINode",function()
    return cc.Node:create()
end)

-- 构造函数
function FightRoleUINode:ctor()
    self._strName = "FightRoleUINode"          -- 名称
    self._nType = 1                            -- 类型：1用于主角  2用于宠物  3用于其他玩家
    self._pRootNode = nil                      -- 根节点
    self._strIconName = ""                     -- 头像纹理名称
    self._pHeadBg = nil                        -- 头像背景
    self._pNameBarBg = nil                     -- 名字背景bar
    self._pName = nil                          -- 名字
    self._pBloodBg = nil                       -- 血条背景
    self._pBloodFrame = nil                    -- 血条底框
    self._pBloodBar = nil                      -- 血条
    self._pBloodCache = nil                    -- 血条缓冲
    self._nCurBlood = 0                        -- 当前血量
    self._nMaxBlood = 0                        -- 血量最大值
    self._pBloodText = nil                     -- 血量数字
    self._pBuffIconsNode = nil                 -- Buff的icons节点

end

-- 创建函数
function FightRoleUINode:create(type,iconName,level,name,hp)
    local node = FightRoleUINode.new()
    node:dispose(type,iconName,level,name,hp)
    return node
end

-- 处理函数
function FightRoleUINode:dispose(type,iconName,level,name,hp)
    ResPlistManager:getInstance():addSpriteFrames("battle_main_role_ui.plist")
    
    -- ui类型
    self._nType = type

    -- 根节点
    self._pRootNode = cc.Node:create()
    self:addChild(self._pRootNode)

    -- 头像背景
    self._pHeadBg = cc.Sprite:createWithSpriteFrameName("MainRoleUIRes/zdjm1.png")
    self._pRootNode:addChild(self._pHeadBg,3)

    -- 头像纹理名称
    self._strIconName = iconName

    -- 头像
    self._pHeader = cc.Sprite:createWithSpriteFrameName(self._strIconName)
    self._pHeader:setAnchorPoint(cc.p(0.5,0))
    self._pHeader:setPosition(cc.p(0,-self._pHeadBg:getContentSize().height/2+16))
    self._pRootNode:addChild(self._pHeader,3)

    if self._nType == 1 then  -- 主角
        -- 名字背景
        self._pNameBarBg = cc.Sprite:createWithSpriteFrameName("MainRoleUIRes/zdjm2.png")
        self._pNameBarBg:setAnchorPoint(cc.p(0,0.5))
        self._pNameBarBg:setPosition(cc.p(self._pHeadBg:getPositionX()+self._pHeadBg:getContentSize().width/2-64, self._pHeadBg:getPositionY()+40))
        self._pRootNode:addChild(self._pNameBarBg,1)
        -- 名字
        self._pName = cc.Label:createWithTTF("Lv"..level.." "..name, strCommonFontName, 17)
        self._pName:setAnchorPoint(cc.p(0,0))
        self._pName:setTextColor(cFontWhite)
        self._pName:enableOutline(cFontOutline,2)
        self._pName:setPosition(cc.p(30+((self._pNameBarBg:getContentSize().width-30) - self._pName:getContentSize().width)/2,(self._pNameBarBg:getContentSize().height - self._pName:getContentSize().height)/2))
        self._pNameBarBg:addChild(self._pName)
    elseif self._nType == 2 then  --宠物
        self._pRootNode:setScale(0.67)
        self._pHeader:setScale(1.3)
        self._pHeader:setPositionY(self._pHeader:getPositionY() - 5)
    elseif self._nType == 3 then  --其他玩家
        self._pRootNode:setScale(0.67)
        self._pHeader:setPositionY(self._pHeader:getPositionY())
    end

    -- 血条背景
    self._pBloodBg = cc.Sprite:createWithSpriteFrameName("MainRoleUIRes/zdjm3.png")
    self._pBloodBg:setAnchorPoint(cc.p(0,0.5))
    self._pBloodBg:setPosition(cc.p(self._pHeadBg:getPositionX()+self._pHeadBg:getContentSize().width/2-56, self._pHeadBg:getPositionY()-2))
    self._pRootNode:addChild(self._pBloodBg,1)

    -- 血条底框
    self._pBloodFrame = cc.Sprite:createWithSpriteFrameName("MainRoleUIRes/zdjm5.png")
    self._pBloodFrame:setAnchorPoint(cc.p(0,0.5))
    self._pBloodFrame:setPosition(cc.p(self._pBloodBg:getPositionX()+22, self._pBloodBg:getPositionY()))
    self._pRootNode:addChild(self._pBloodFrame,1)

    -- 初始化血量值
    self._nCurBlood = hp
    self._nMaxBlood = hp

    -- 初始化主角血条
    local pBar = cc.Sprite:createWithSpriteFrameName("MainRoleUIRes/zdjmRed.png")
    local pBarCache = cc.Sprite:createWithSpriteFrameName("MainRoleUIRes/zdjmCache.png")
    self._pBloodCache = cc.ProgressTimer:create(pBarCache)
    self._pBloodCache:setAnchorPoint(0,0.5)
    self._pBloodCache:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pBloodCache:setMidpoint(cc.p(0,0))
    self._pBloodCache:setBarChangeRate(cc.p(1,0))
    self._pBloodCache:setPercentage(100)
    self._pBloodCache:setPosition(cc.p(self._pBloodFrame:getPositionX()+20,self._pBloodFrame:getPositionY()))
    self._pRootNode:addChild(self._pBloodCache,1)
    self._pBloodBar = cc.ProgressTimer:create(pBar)
    self._pBloodBar:setAnchorPoint(0,0.5)
    self._pBloodBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pBloodBar:setMidpoint(cc.p(0,0))
    self._pBloodBar:setBarChangeRate(cc.p(1,0))
    self._pBloodBar:setPercentage(100)
    self._pBloodBar:setPosition(cc.p(self._pBloodFrame:getPositionX()+20,self._pBloodFrame:getPositionY()))
    self._pRootNode:addChild(self._pBloodBar,1)

    -- 血条上的光照
    local lightOnBloodBar = cc.Sprite:createWithSpriteFrameName("MainRoleUIRes/zdjm6.png")
    lightOnBloodBar:setAnchorPoint(cc.p(0,0.5))
    lightOnBloodBar:setPosition(cc.p(self._pBloodBg:getPositionX()+23, self._pBloodBg:getPositionY()+8))
    self._pRootNode:addChild(lightOnBloodBar,1)

    -- 初始化血条上的血量数字
    self._pBloodText = cc.Label:createWithTTF(self._nCurBlood.."/"..self._nMaxBlood, strCommonFontName, 16)
    self._pBloodText:setAnchorPoint(cc.p(0,0))
    self._pRootNode:addChild(self._pBloodText,1)
    if self._nType == 1 then  -- 主角
        -- 血条字体颜色
        self._pBloodText:setTextColor(cFontMidYellow)
        self._pBloodText:enableOutline(cFontOutline2,2)
    elseif self._nType == 2 then  -- 宠物
        -- 血条字体颜色
        self._pBloodText:setTextColor(cFontWhite)
        self._pBloodText:enableOutline(cFontOutline,2)
    elseif self._nType == 3 then -- 其他玩家
        -- 血条字体颜色
        self._pBloodText:setTextColor(cFontMidYellow)
        self._pBloodText:enableOutline(cFontOutline2,2)
    end
    self._pBloodText:setPosition(cc.p(self._pBloodBar:getPositionX() + (self._pBloodBar:getContentSize().width - self._pBloodText:getContentSize().width)/2, self._pBloodBar:getPositionY() - self._pBloodBar:getContentSize().height/2 + (self._pBloodBar:getContentSize().height - self._pBloodText:getContentSize().height)/2))

    if self._nType == 1 then  -- 主角
        -- Buff图标
        self._pBuffIconsNode = require("BuffNode"):create()
        self._pBuffIconsNode:setPosition(cc.p(60,-60))
        self._pRootNode:addChild(self._pBuffIconsNode,3)
    end
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFightRoleUINode()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function FightRoleUINode:onExitFightRoleUINode()
    ResPlistManager:getInstance():removeSpriteFrames("battle_main_role_ui.plist")

end

-- 遍历
function FightRoleUINode:update(dt)
    if self._pBuffIconsNode then
        self._pBuffIconsNode:update(dt)
    end
end

-- 设置等级和名字
function FightRoleUINode:setLevelAndName(level,name)
    if self._pName then
        self._pName:setString("Lv"..level.." "..name)
        self._pName:setPosition(cc.p((self._pNameBarBg:getContentSize().width - self._pName:getContentSize().width)/2,(self._pNameBarBg:getContentSize().height - self._pName:getContentSize().height)/2))
    end
end

-- 设置头像
function FightRoleUINode:setHeadInfo(headName)
    if self._pHeader then
        -- 头像
        self._pHeader:removeFromParent(true)
        self._strIconName = headName
        self._pHeader = cc.Sprite:createWithSpriteFrameName(self._strIconName)
        self._pHeader:setAnchorPoint(cc.p(0.5,0))
        self._pHeader:setPosition(cc.p(0,-self._pHeadBg:getContentSize().height/2+16))
        self._pRootNode:addChild(self._pHeader,3)
        if self._nType == 2 then
            self._pRootNode:setScale(0.67)
            self._pHeader:setScale(1.3)
            self._pHeader:setPositionY(self._pHeader:getPositionY() - 5)
        end
    end
end

-- 设置血量当前值
function FightRoleUINode:setCurHp(hpCur,bSkipAni)
    self._nCurBlood = hpCur
    self._pBloodText:setString(self._nCurBlood.."/"..self._nMaxBlood)
    self._pBloodBar:setPercentage(self._nCurBlood/self._nMaxBlood*100.0)
    if bSkipAni then
        self._pBloodCache:setPercentage(self._nCurBlood/self._nMaxBlood*100.0)
    else
        self._pBloodCache:stopAllActions()
        self._pBloodCache:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.EaseSineOut:create(cc.ProgressTo:create(0.3, self._nCurBlood/self._nMaxBlood*100.0))))
    end
end

-- 设置血量最大值
function FightRoleUINode:setMaxHp(hpMax)
    self._nMaxBlood = hpMax
    self._pBloodText:setString(self._nCurBlood.."/"..self._nMaxBlood)
    self._pBloodBar:setPercentage(self._nCurBlood/self._nMaxBlood*100.0)
    self._pBloodCache:setPercentage(self._nCurBlood/self._nMaxBlood*100.0)
end

return FightRoleUINode
