--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GameObj.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   所有游戏对象基类
--===================================================
local GameObj = class("GameObj",function()
    return cc.Node:create()
end)

-- 构造函数
function GameObj:ctor()
    self._strName = "GameObj"                   -- 游戏对象名称
    self._strAniName = ""                       -- 动画资源名称
    self._kAniType = kType.kAni.kNone           -- 动画展现类型
    self._pAni = nil                            -- 动画
    self._bActive = true                        -- 是否为有效活跃状态（为false时会被自动删除）
    self._pStateMachineDelegate = nil           -- 状态机组代理器
    self._pControllerMachineDelegate = nil      -- 控制机组代理器
    self._recBottomOnObj = cc.rect(0,0,0,0)     -- 底座矩形，用于检测行走碰撞（相对于obj上的矩形）cc.rect
    self._recBodyOnObj = cc.rect(0,0,0,0)       -- 主干矩形，用于检测主干攻击的碰撞检测（相对于obj上的矩形）cc.rect
    self._kGameObjType = kType.kGameObj.kNone   -- 游戏对象类型
end

-- 创建函数
function GameObj:create()
    local obj = GameObj.new()
    obj:dispose()
    return obj
end

-- 处理函数
function GameObj:dispose()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitGameObj()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function GameObj:onExitGameObj()
   -- print(self._strName.." onExit!")
    
end

-- 循环更新
function GameObj:updateGameObj(dt)
    if self._pStateMachineDelegate ~= nil then
        self._pStateMachineDelegate:procAllStateMachines(dt)
    end
    if self._pControllerMachineDelegate ~= nil then
        self._pControllerMachineDelegate:procAllControllerMachines(dt)
    end

end

-- 获取对象身上的底座bottom在地图中的绝对（位置）碰撞矩形
function GameObj:getBottomRectInMap()
    local posX, posY = self:getPosition()
    local rec = cc.rect(0,0,0,0)
    if self._kAniType == kType.kAni.k2D then
        rec = cc.rect(posX - self._pAni:getContentSize().width/2 + self._recBottomOnObj.x, posY + self._recBottomOnObj.y, self._recBottomOnObj.width, self._recBottomOnObj.height)
    elseif self._kAniType == kType.kAni.k3D then
        rec = cc.rect(posX - self._pAni:getBoundingBox().width/2 + (self._pAni:getBoundingBox().width - self._recBottomOnObj.width)/2, posY + self._recBottomOnObj.y, self._recBottomOnObj.width, self._recBottomOnObj.height)
    end
    return rec
end

-- 获取对象身上的主干body在地图中的绝对（位置）碰撞矩形
function GameObj:getBodyRectInMap()
    local posX, posY = self:getPosition()
    local rec = cc.rect(0,0,0,0)
    if self._kAniType == kType.kAni.k2D then
        rec = cc.rect(posX - self._pAni:getContentSize().width/2 + self._recBodyOnObj.x, posY + self._recBodyOnObj.y, self._recBodyOnObj.width, self._recBodyOnObj.height)
    elseif self._kAniType == kType.kAni.k3D then
        rec = cc.rect(posX - self._pAni:getBoundingBox().width/2 + (self._pAni:getBoundingBox().width - self._recBodyOnObj.width)/2, posY + self._recBodyOnObj.y, self._recBodyOnObj.width, self._recBodyOnObj.height)
    end
    return rec
end
    
-- 通过索引值设置位置
function GameObj:setPositionByIndex(index)
    local pos = self:getMapManager():convertIndexToPiexl(index)
    self:setPosition(pos)
end

-- 获取当前的索引位置
function GameObj:getPositionIndex()
    local posX, posY = self:getPosition()
    local index = self:getMapManager():convertPiexlToIndex(cc.p(posX,posY))
    return index
end

-- 获取身高
function GameObj:getHeight()
    local height = 0
    if self._kAniType == kType.kAni.k2D then
        height = self._pAni:getChildByName("Default"):getContentSize().height
    elseif self._kAniType == kType.kAni.k3D then
        height = self._pAni:getBoundingBox().height
    end
    return height
end

-- 获取宽度
function GameObj:getWidth()
    local width = 0
    if self._kAniType == kType.kAni.k2D then
        width = self._pAni:getChildByName("Default"):getContentSize().width
    elseif self._kAniType == kType.kAni.k3D then
        width = self._pAni:getBoundingBox().width
    end
    return width
end

-- 判定是否发生本身Body与指定矩形上的碰撞（返回碰撞的方向集合 和 碰撞产生的矩形区域）
function GameObj:isCollidingBodyOnRect(recObjBody)
    local body = self:getBodyRectInMap()
    return mmo.HelpFunc:getCollidingDirections(body, recObjBody), cc.rectIntersection(body, recObjBody)
end

-- 判定是否发生本身Body与指定点的碰撞（返回true和false）
function GameObj:isCollidingBodyOnPoint(pos)
    local body = self:getBodyRectInMap()
    return cc.rectContainsPoint(body, pos)
end

-- 判定是否发生本身Bottom与指定矩形上的碰撞（返回碰撞的方向集合 和 碰撞产生的矩形区域）
function GameObj:isCollidingBottomOnRect(recObjBody)
    local bottom = self:getBottomRectInMap()
    return mmo.HelpFunc:getCollidingDirections(bottom, recObjBody), cc.rectIntersection(bottom, recObjBody)
end

-- 获取状态机
function GameObj:getStateMachineByTypeID(id)
    return self._pStateMachineDelegate:getStateMachineByTypeID(id)
end

-- 获取控制机
function GameObj:getControllerMachineByTypeID(id)
    return self._pControllerMachineDelegate:getControllerMachineByTypeID(id)
end

-- 刷新相机
function GameObj:refreshCamera() 
    self:getMapManager()._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function GameObj:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function GameObj:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function GameObj:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function GameObj:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function GameObj:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function GameObj:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function GameObj:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function GameObj:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function GameObj:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取对话管理器
function GameObj:getTalksManager() 
    if self._pTalksManager == nil then
        self._pTalksManager = TalksManager:getInstance()
    end
    return self._pTalksManager
end

-- 获取邮件管理器
function GameObj:getEmailManager() 
    if self._pEmailManager == nil then
        self._pEmailManager = EmailManager:getInstance()
    end
    return self._pEmailManager
end

-- 获取Buff管理器
function GameObj:getBuffManager() 
    if self._pBuffManager == nil then
        self._pBuffManager = BuffManager:getInstance()
    end
    return self._pBuffManager
end

-- 获取战斗AI管理器
function GameObj:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

-- 获取CD管理器
function GameObj:getCDManager() 
    if self._pCDManager == nil then
        self._pCDManager = CDManager:getInstance()
    end
    return self._pCDManager
end

-- 获取聊天管理器
function GameObj:getChatManager() 
    if self._pChatManager == nil then
        self._pChatManager = ChatManager:getInstance()
    end
    return self._pChatManager
end

-- 获取剧情的管理器
function GameObj:getStoryGuideManager() 
    if self._pStoryGuideManager == nil then
        self._pStoryGuideManager = StoryGuideManager:getInstance()
    end
    return self._pStoryGuideManager
end

--------------------------------------------------------------------------------------------------------------
return GameObj
