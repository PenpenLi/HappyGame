--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TeamMatchDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/10/27
-- descrip:   组队匹配界面
--===================================================
local TeamMatchDialog = class("TeamMatchDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function TeamMatchDialog:ctor()
    self._strName = "TeamMatchDialog"       -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._tOtherRoleInfo = {}         --其他玩家信息


end

-- 创建函数
function TeamMatchDialog:create(args)
    local dialog = TeamMatchDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function TeamMatchDialog:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kFormTeamInfo ,handler(self, self.formTeamInfoUpdate))
    RolesManager:getInstance():setForceMinPositionZ(true,-10000)
    PetsManager:getInstance():setForceMinPositionZ(true,-10000)
    self._pArgs = args
    self:initUI()
    --初始化自己的模型
    self:initSelfRoleInfo()
    MessageGameInstance:sendMessageFormTeam21020(args[1])   

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return true   --可以向下传递事件
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
            self:onExitTeamMatchDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end


--初始化界面
function TeamMatchDialog:initUI()
    ResPlistManager:getInstance():addSpriteFrames("MultiplayerShow.plist")
    local params = require("MultiplayerShowParams"):create()
    self._pCCS = params._pCCS
    self._pCloseButton = params._pCloseButton
    self._pBg = params._pBackGround
    self._tMountNode = params._tNodeMount
    self._pTotalTime = params._pTotalTime     --总时间
    self._pRemainTime = params._pRemainTime   --剩余时间
    -- 初始化dialog的基础组件
    self:disposeCSB()
end

--刷新自己的个人信息
function TeamMatchDialog:initSelfRoleInfo()
  local pRoleInfo = RolesManager:getInstance()._pMainRoleInfo
  self:initRoleModelByInfo(self._tMountNode[1],pRoleInfo)
end

function TeamMatchDialog:initRoleModelByInfo(pNode,pRoleInfo)
    
    local tBodyTempleteInfo = nil            --身
    local tWeaponTempleteInfo = nil          --武器
    local tFashionBackTempleteInfo = nil     --时装背(翅膀)
    local tFashionHaloTempleteInfo = nil     --光环
    --先初始化人物信息
     for i=1,table.getn(pRoleInfo.equipemts) do --遍历装备集合
        GetCompleteItemInfo(pRoleInfo.equipemts[i],pRoleInfo.roleCareer)
     end

     --装备身
      for i=1,table.getn(pRoleInfo.equipemts) do --遍历装备集合
            local nPart = pRoleInfo.equipemts[i].dataInfo.Part -- 部位
           if nPart == kEqpLocation.kBody then       -- 时装身部位
                tBodyTempleteInfo = pRoleInfo.equipemts[i].templeteInfo
            elseif nPart == kEqpLocation.kWeapon then        -- 武器
                tWeaponTempleteInfo = pRoleInfo.equipemts[i].templeteInfo
            elseif nPart == kEqpLocation.kFashionBack then   -- 时装背(翅膀)
                tFashionBackTempleteInfo = pRoleInfo.equipemts[i].templeteInfo
            elseif nPart == kEqpLocation.kFashionHalo then   --光环 
                tFashionHaloTempleteInfo = pRoleInfo.equipemts[i].templeteInfo
            end
        end

    -- 判断是否加载时装身
    if pRoleInfo.fashionOptions and pRoleInfo.fashionOptions[2] == true then -- 时装身        
        for i=1,table.getn(pRoleInfo.equipemts) do --遍历装备集合
            local nPart = pRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                tBodyTempleteInfo = pRoleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end
  if tBodyTempleteInfo ~= nil then
        -- 3D模型
        local fullAniName = tBodyTempleteInfo.Model1..".c3b"
        local fullTextureName = tBodyTempleteInfo.Texture..".pvr.ccz"
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tBodyTempleteInfo.Texture)
        local pAni = cc.Sprite3D:create(fullAniName)
        pAni:setTexture(fullTextureName)
        pNode:addChild(pAni)
        setSprite3dMaterial(pAni,tBodyTempleteInfo.Material)

    --武器
      local pWeaponRC3bName = tWeaponTempleteInfo.Model1..".c3b"
        local pWeaponLC3bName = nil
        if tWeaponTempleteInfo.Model2 then
           pWeaponLC3bName = tWeaponTempleteInfo.Model2..".c3b"
        end
        local pWeaponTextureName = tWeaponTempleteInfo.Texture..".pvr.ccz"
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tWeaponTempleteInfo.Texture)
        if pWeaponRC3bName then     
            local pWeaponR = cc.Sprite3D:create(pWeaponRC3bName)
            pWeaponR:setTexture(pWeaponTextureName)
            pWeaponR:setScale(tWeaponTempleteInfo.ModelScale1)
            local animation = cc.Animation3D:create(pWeaponRC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            pWeaponR:runAction(act)
            pAni:getAttachNode("boneRightHandAttach"):addChild(pWeaponR)
            setSprite3dMaterial(pWeaponR,tWeaponTempleteInfo.Material)
        end
        if pWeaponLC3bName then
            pWeaponL = cc.Sprite3D:create(pWeaponLC3bName)
            pWeaponL:setTexture(pWeaponTextureName)
            pWeaponL:setScale(tWeaponTempleteInfo.ModelScale2)
            local animation = cc.Animation3D:create(pWeaponLC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            WeaponL:runAction(act)
            pAni:getAttachNode("boneLeftHandAttach"):addChild(pWeaponL)
            setSprite3dMaterial(pWeaponL,tWeaponTempleteInfo.Material)
        end


        --时装背(翅膀)
       if tFashionBackTempleteInfo then
            local fullAniName = tFashionBackTempleteInfo.Model1..".c3b"
            local fullTextureName = tFashionBackTempleteInfo.Texture..".pvr.ccz"
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionBackTempleteInfo.Texture)
            local pBack = cc.Sprite3D:create(fullAniName)
            pBack:setTexture(fullTextureName)
            pBack:setScale(tFashionBackTempleteInfo.ModelScale1)
            local animation = cc.Animation3D:create(fullAniName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            pBack:runAction(act)
            pAni:getAttachNode("boneBackAttach"):addChild(pBack)
            setSprite3dMaterial(pBack,tFashionBackTempleteInfo.Material)
        end

        --光环
        if tFashionHaloTempleteInfo then
            local fullAniName = tFashionHaloTempleteInfo.Model1..".csb"
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionHaloTempleteInfo.Texture)
            local pHalo = cc.CSLoader:createNode(fullAniName)
            pAni:addChild(pHalo,-1)
            local act = cc.CSLoader:createTimeline(fullAniName)
            act:gotoFrameAndPlay(0, act:getDuration(), true) 
            pHalo:stopAllActions()
            pHalo:runAction(act)
            pHalo:setScale(tFashionHaloTempleteInfo.ModelScale1)
        end
        --人物缩放
        pAni:setScale(1)
        local tCareersTempletetInfo = TableTempleteCareers[pRoleInfo.roleCareer].ReadyFightActFrameRegion
        self._pRoleAnimation = cc.Animation3D:create(tBodyTempleteInfo.Model1..".c3b")
        local pRunActAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,tCareersTempletetInfo[1],tCareersTempletetInfo[2])
        pRunActAnimate:setSpeed(tCareersTempletetInfo[3])
        pAni:runAction(cc.RepeatForever:create(pRunActAnimate))
 end

end


function TeamMatchDialog:formTeamInfoUpdate(event)
 self._tOtherRoleInfo = event.memberList
end

-- 退出函数
function TeamMatchDialog:onExitTeamMatchDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("MultiplayerShow.plist")
end

-- 循环更新
function TeamMatchDialog:update(dt)
    return
end

-- 显示结束时的回调
function TeamMatchDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function TeamMatchDialog:doWhenCloseOver()
    return
end

return TeamMatchDialog
