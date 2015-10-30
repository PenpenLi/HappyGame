--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetCooperateCell.lua
-- author:    liyuhang
-- created:   2015/09/29
-- descrip:   宠物共鸣cell
--===================================================
local PetCooperateCell = class("PetCooperateCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function PetCooperateCell:ctor()
    -- 层名称
    self._strName = "PetCooperateCell"        

    -- 地图背景
    self._pParams = nil
    self._pBg = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

    self._pDataInfo = nil
end

-- 创建函数
function PetCooperateCell:create(dataInfo)
    local dialog = PetCooperateCell.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function PetCooperateCell:dispose(dataInfo)
    --注册（请求游戏副本列表）
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self, self.handleMsgFeedPet))

    self._pDataInfo = dataInfo

    self:initUI()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,pLocal) == false then

        end

        return false
    end
    local function onTouchMoved(touch,event)
        local location = self._pBg:convertTouchToNodeSpace(touch)

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)

    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetCooperateCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function PetCooperateCell:initUI()
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then

        end
    end

    --图标按钮
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            DialogManager:showDialog("PetDetailDialog",{self._pDataInfo,true})
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    -- 加载图片资源
    ResPlistManager:getInstance():addSpriteFrames("Gmlist.plist")
    -- 加载csb 组件
    local params = require("GmlistParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pGmListBg

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)

    self:updateData()
end

function PetCooperateCell:updateData()
    if self._pDataInfo == nil then
        return
    end

    local beActived = false
    for i=1,table.getn(self._pDataInfo.RequiredPet) do
        local petInfo = PetsManager:getInstance():getPetInfoWithId(self._pDataInfo.RequiredPet[i],
            1,
            1)
    
        self._pParams["_pIconPz"..i]:loadTexture(
            petInfo.templete.PetIcon..".png",
            ccui.TextureResType.plistType)
        
    end
    
    for i=1,table.getn(RolesManager:getInstance()._tMainPetCooperates) do
        if RolesManager:getInstance()._tMainPetCooperates[i].ResonanceID == self._pDataInfo.ResonanceID then
    		beActived = true
    	end
    end
    
    self._pParams["_pGmText"]:setString(kAttributeNameTypeTitle[self._pDataInfo.Property[1][1]] .. " +".. (self._pDataInfo.Property[1][2] * 100) .. "%")
    
    if beActived == true then
        self._pParams["_pJiHuoText1"]:setVisible(true)
        --未激活文字
        self._pParams["_pJiHuoText2"]:setVisible(false)
    else
        self._pParams["_pJiHuoText1"]:setVisible(false)
        --未激活文字
        self._pParams["_pJiHuoText2"]:setVisible(true)
    end
end

function PetCooperateCell:setInfo(info)
    self._pDataInfo = info

    self:updateData()
end

function PetCooperateCell:handleMsgFeedPet(event)

end

-- 退出函数
function PetCooperateCell:onExitPetCooperateCell()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("Gmlist.plist")
end

return PetCooperateCell