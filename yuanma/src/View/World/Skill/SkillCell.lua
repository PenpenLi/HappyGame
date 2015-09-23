--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SkillCell.lua
-- author:    liyuhang
-- created:   2014/12/16
-- descrip:   技能
--===================================================



local SkillCell = class("SkillCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function SkillCell:ctor()
    self._strName = "SkillCell"        -- 层名称
    self._pBg = nil    
        
    self._pSkillInfo = nil
    self._nLevel = 0
    self._sIconName = nil
    self._nSkillId = 0
    
    self._bTouchAble = true
    
    self._pParams = nil
end 

-- 创建函数
function SkillCell:create()
    local layer = SkillCell.new()
    layer:dispose()
    return layer
end


-- 处理函数
function SkillCell:dispose() 
    -- 加载资源
    ResPlistManager:getInstance():addSpriteFrames("SkillOne.plist")
    
    -- 加载csb 组件
    local params = require("SkillOneParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pBG

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)
    
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()    

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
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)

        if event == "exit" then
            self:onExitSkillCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function SkillCell:setSkillInfo(info,id,level,icon)
    self._pSkillInfo = info
    self._nLevel = level
    self._sIconName = icon
    self._nSkillId = id
    
    --bg
   
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(self._nSkillId,1)
        if skillData.SkillType == nil then
            self._pParams._pBG:loadTexture(
                "SkillOneRes/006.png",
                ccui.TextureResType.plistType)
        else
            self._pParams._pBG:loadTexture(
                "SkillOneRes/00" .. skillData.SkillType ..".png",
            ccui.TextureResType.plistType)
        end
    -- level
    self._pParams._pLv:setString("Lv:"..((self._nLevel > -1) and self._nLevel or 0))
    
    local nextSkillData = nil
    if skillData.GoodRequire ~= 0 then
        nextSkillData = SkillsManager:getInstance():getMainRoleSkillDataByID(self._nSkillId,self._nLevel+1)
        if nextSkillData.RequiredLevel <= RolesManager:getInstance()._pMainRoleInfo.level then
            self._pParams._pUpIcon:setVisible(true)
        else
            self._pParams._pUpIcon:setVisible(false)
        end
    end
    
    self._pParams._pSkillEdgeButton:loadTextures(
        icon ..".png",
        icon ..".png",
        icon ..".png",
     ccui.TextureResType.plistType)
    self._pParams._pSkillEdgeButton:setVisible(true)
     
    local function skillIconClick( sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()

            local skillLevel = SkillsManager:getInstance():getMainRoleLevelByID(tag)
            local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(tag,skillLevel)

            if skillData == nil then
                skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(tag,1)
                NoticeManager:getInstance():showSystemMessage(skillData.RequiredLevel.."级开启")
            else
                local nextSkillData = nil
                if skillData.GoodRequire ~= 0 then
                    nextSkillData = SkillsManager:getInstance():getMainRoleSkillDataByID(tag,skillLevel+1)
                end
            
                DialogManager:getInstance():showDialog("SkillDetailDialog",{skillData,nextSkillData,false})
                NewbieManager:showOutAndRemoveWithRunTime()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pParams._pSkillEdgeButton:addTouchEventListener(skillIconClick)
    
    self._pParams._pSkillEdgeButton:setTag(self._nSkillId)
    
    if level < 1 then
        darkNode(self._pParams._pSkillEdgeButton:getVirtualRenderer():getSprite())
        
        local canOpen = true
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(self._nSkillId,1)
        local requireLevel = skillData.RequiredLevel
        if requireLevel > RolesManager:getInstance()._pMainRoleInfo.level then
        	canOpen = false
        end
        
        if skillData.Precondition ~= nil and table.getn(skillData.Precondition) > 0 then
            for i=1,table.getn(skillData.Precondition) do
        	   local level = SkillsManager:getMainRoleLevelByID(skillData.Precondition[i][1])
               if level < skillData.Precondition[i][2] then
        	   	   canOpen = false
        	   end
        	end
        end
        
        if canOpen == true then
            self._pParams._pLock:setVisible(false)
            self._pParams._pLv:setVisible(true)
        else
            self._pParams._pLock:setVisible(true)
            self._pParams._pLv:setVisible(false)
        end
    else
        unDarkNode(self._pParams._pSkillEdgeButton:getVirtualRenderer():getSprite())
        self._pParams._pLock:setVisible(false)
        self._pParams._pLv:setVisible(true)
    end
end

-- 退出函数
function SkillCell:onExitSkillCell()
    --self:onExitLayer()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return SkillCell
