--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NpcRole.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   Npc角色
--===================================================
local NpcRole = class("NpcRole",function()
    return require("Role"):create()
end)

-- 构造函数
function NpcRole:ctor()
    ------------ 人物参数相关 ---------------------------------------
    self._kRoleType = kType.kRole.kNpc          -- 角色对象类型
    self._tTempleteInfo = nil                   -- 角色模板表数据
    self._pRoleInfo = nil  
    ------------ 人物名字标签 -----------------------------------------
    self._pName = nil                           -- 角色名字(pic或者label)(优先pic，pic没有时使用label)
    self._pMagicEffectAni = nil                 -- 角色脚下的法阵
    
end

-- 创建函数
function NpcRole:create(roleInfo, recBottom, recBody)
    local role = NpcRole.new()
    role:dispose(roleInfo, recBottom, recBody)
    return role
end

-- 处理函数
function NpcRole:dispose(roleInfo, recBottom, recBody)
    ------------------- 初始化 ------------------------  
    -- 设置角色信息
    self:initInfo(roleInfo)
    -- 初始化动画
    self:initAni()
    -- 初始化人物身上默认bottom和body矩形信息
    self:initRects(recBottom, recBody)
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitNpcRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function NpcRole:onExitNpcRole()
    -- 执行父类退出方法
    self:onExitRole()
end

-- 循环更新
function NpcRole:updateNpcRole(dt)
    self:updateRole(dt)
    self:refreshZorder()
    
end

-- 初始化信息
function NpcRole:initInfo(roleInfo)
    self._tTempleteInfo = TableTempleteNpcRoles[roleInfo.TempleteID]
    self._pRoleInfo = roleInfo
end

-- 初始化动画
function NpcRole:initAni()
    local tTempleteInfo = self._tTempleteInfo
    self._kAniType = tTempleteInfo.AniType
    self._strAniName = tTempleteInfo.AniResName

    local fullAniName = self._strAniName..".c3b"
    local fullTextureName = tTempleteInfo.Texture..".pvr.ccz"
    self._strBodyTexturePvrName = tTempleteInfo.Texture
    
    -- 记录并加载到纹理缓存中
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tTempleteInfo.Texture)
    self._pAni = cc.Sprite3D:create(fullAniName)
    self._pAni:setTexture(fullTextureName)
    self:addChild(self._pAni)
    self._pAni:setScale(tTempleteInfo.Scale)
    
    -- 脚底法阵
    if self._tTempleteInfo.MagicEffect ~= "none" and self._tTempleteInfo.MagicEffect ~= "" then
        self._pMagicEffectAni = cc.CSLoader:createNode(self._tTempleteInfo.MagicEffect..".csb")
        local pMagicEffectAction = cc.CSLoader:createTimeline(self._tTempleteInfo.MagicEffect..".csb")
        pMagicEffectAction:gotoFrameAndPlay(0, pMagicEffectAction:getDuration(), true)
        self._pMagicEffectAni:runAction(pMagicEffectAction)
        self._pMagicEffectAni:setScale(1.0)
        --self._pMagicEffectAni:setScale(0.8/tTempleteInfo.Scale)
        self:addChild(self._pMagicEffectAni)
    end

    -- 名字
    if self._tTempleteInfo.NamePic ~= "none" and self._tTempleteInfo.NamePic ~= "" then
        self._pName = cc.Sprite:createWithSpriteFrameName(self._tTempleteInfo.NamePic..".png")
        self._pName:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(3.0,cc.p(0,20))), cc.EaseSineInOut:create(cc.MoveBy:create(3.0,cc.p(0,-20))))))
    else
        self._pName = cc.Label:createWithTTF(self._tTempleteInfo.Name, strCommonFontName, 20)
    end
    self._pName:setPosition(cc.p(0,self:getHeight()+5))
    self:addChild(self._pName)
   
    
    --对话框
    self._pTalkBg = cc.Sprite:createWithSpriteFrameName("ccsComRes/dhjm2.png")
    self._pTalkBg:setPosition(cc.p(0,self:getHeight()+15))
    self:addChild( self._pTalkBg)
    self._pTalkBg:setVisible(false)
    
    local pDis = 20
    self._pTalkDec = cc.Label:createWithTTF("", strCommonFontName, 20)
    self._pTalkDec:setWidth(self._pTalkBg:getContentSize().width-pDis)
    self._pTalkDec:setAnchorPoint(0,1)
    self._pTalkDec:setPosition(cc.p(pDis/2,self._pTalkBg:getContentSize().height-pDis/2))
    self._pTalkBg:addChild(self._pTalkDec)
 
    
    -- 叠色
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        if self:getMapManager()._kCurSkyType == kType.kSky.kNightSunShine or 
           self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudy or 
           self:getMapManager()._kCurSkyType == kType.kSky.kNightRainy or 
           self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudyRainy then
            self._pAni:setColor(cPeopleNight)
        end
    end
    
end

-- 初始化人物身上默认bottom和body矩形信息
function NpcRole:initRects(recBottom, recBody)
    self._recBottomOnObj = recBottom
    self._recBodyOnObj = recBody
end

-- 刷新zorder和3d模型的positionZ
function NpcRole:refreshZorder()
    if self._bForceMinPositionZ == true then   -- 强制positionZ
        self:setPositionZ(self._nForceMinPositionZValue)
    else                                    -- 非强制positionZ
        self:setPositionZ(self:getPositionIndex().y*(self:getMapManager()._f3DZ))
    end
    self:setLocalZOrder(kZorder.kMinRole + self:getMapManager()._sMapRectPixelSize.height - self:getPositionY())
end

-- 获取身高
function NpcRole:getHeight()
    return self._tTempleteInfo.Height
end

-- 获取对象身上的底座bottom在地图中的绝对（位置）碰撞矩形
function NpcRole:getBottomRectInMap()
    return self._recBottomOnObj
end

-- 获取对象身上的主干body在地图中的绝对（位置）碰撞矩形
function NpcRole:getBodyRectInMap()
    return self._recBodyOnObj
end

-- 创建人物角色状态机
function NpcRole:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("WorldNpcRoleStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 播放站立动作
function NpcRole:playStandAction()
    -- 站立动作
    if self._tTempleteInfo.StandActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.StandActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.StandActFrameRegion[2]
        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        temp:setSpeed(self._tTempleteInfo.StandActFrameRegion[3])
        local stand = cc.RepeatForever:create(temp)
        self._pAni:stopActionByTag(nRoleActAction)
        stand:setTag(nRoleActAction)
        self._pAni:runAction(stand)
    end
end

-- 播放休闲动作
function NpcRole:playCasualAction()
    -- 休闲动作
    if self._tTempleteInfo.CasualActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.CasualActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.CasualActFrameRegion[2]
        local casual = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        casual:setSpeed(self._tTempleteInfo.CasualActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        casual:setTag(nRoleActAction)
        self._pAni:runAction(casual)        
    end
    
end

-- 获取休闲动作的时间间隔（单位：秒）
function NpcRole:getCasualActionTime()
    local duration = (self._tTempleteInfo.CasualActFrameRegion[2] - self._tTempleteInfo.CasualActFrameRegion[1])/30
    local speed = self._tTempleteInfo.CasualActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 显示npc的对话框
function NpcRole:showNpcTalkPanel(pString)
    self._pTalkBg:setVisible(true)
    self._pTalkDec:setString(pString)
end

--关闭npc的对话框
function NpcRole:closeNpcTalkPanel()
    if self._pTalkBg then
       self._pTalkBg:setVisible(false)
    end
   
end



return NpcRole
