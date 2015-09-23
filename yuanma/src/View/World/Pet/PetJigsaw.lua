--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetJigsaw.lua
-- author:    liyuhang
-- created:   2015/04/23
-- descrip:   宠物碎片itemcell
--===================================================
local PetJigsaw = class("PetJigsaw",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function PetJigsaw:ctor()
    -- 层名称
    self._strName = "PetJigsaw"        

    -- 地图背景
    self._pBg = nil
    self._pParams = nil

    self._pDataInfo = nil
    self._nLevel = 1
end

-- 创建函数
function PetJigsaw:create(dataInfo)
    local dialog = PetJigsaw.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function PetJigsaw:dispose(dataInfo)
    --注册（请求游戏副本列表）
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self, self.handleAdvancePet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self, self.handleCompoundPet)) -- 合成宠物
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
            self:onExitPetJigsaw()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function PetJigsaw:initUI()
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then

        end
    end

    --图标按钮
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            NewbieManager:showOutAndRemoveWithRunTime()
            if self._pDataInfo.step == 0 then
                DialogManager:showDialog("PetFoodDialog",{self._pDataInfo,false})
            else
                DialogManager:showDialog("PetFoodDialog",{self._pDataInfo,true})
            end
        elseif eventType == ccui.TouchEventType.moved then

        elseif eventType == ccui.TouchEventType.began then
            
            
        end
    end
    -- 加载csb 组件
    local params = require("JigsawPetParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pJigsawPetBg

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)
    
    
    local onTouchMerge = function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                PetCGMessage:sendMessageCompound21506(self._pDataInfo.data.PieceID)
            elseif eventType == ccui.TouchEventType.moved then

            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
          end
          
    local onTouchLvUp = function(sender, eventType) 
            if eventType == ccui.TouchEventType.ended then
                DialogManager:getInstance():showDialog("PetEvolutionDialog",{self._pDataInfo})
            elseif eventType == ccui.TouchEventType.moved then

            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
                
            end
         end
    
    self._pParams["_pIcon"]:addTouchEventListener(onTouchBg)
    self._pParams["_pMergeButton"]:addTouchEventListener(onTouchMerge)
    self._pParams["_pLvUpButton"]:addTouchEventListener(onTouchLvUp)
    
    self:updateData()
end

function PetJigsaw:setInfo(info)
    self._pDataInfo = info
    
    self:updateData()
end

function PetJigsaw:updateData()
    if self._pDataInfo == nil then
    	return
    end
    
    local step = self._pDataInfo.step == 0 and 1 or self._pDataInfo.step

    self._pParams["_pName"]:setString(self._pDataInfo.templete.PetName)
    self._pParams["_pName"]:setColor(kQualityFontColor3b[step])
    if self._pDataInfo.step == 0 then
        local icon = TableTempleteItems[TableItems[self._pDataInfo.data.PieceID-200000].TempleteID].Icon
        self._pParams["_pIcon"]:loadTextures(
            icon ..".png",
            icon ..".png",
            icon ..".png",
            ccui.TextureResType.plistType)
    else
        self._pParams["_pIcon"]:loadTextures(
            self._pDataInfo.templete.PetIcon ..".png",
            self._pDataInfo.templete.PetIcon ..".png",
            self._pDataInfo.templete.PetIcon ..".png",
            ccui.TextureResType.plistType)
    end
    
        
    self._pParams["_pIconP"]:loadTexture("ccsComRes/qual_" ..step.."_normal.png",ccui.TextureResType.plistType)    
        
    self._pParams["_pQuality"]:setString(self._pDataInfo.step.."阶")
    self._pParams["_pLv"]:setString(self._pDataInfo.level)
    self._pParams["_pPetType"]:setString(petTypeColorDef[self._pDataInfo.data.PetFunction].name)
    self._pParams["_pPetType"]:setColor(petTypeColorDef[self._pDataInfo.data.PetFunction].color)
    
    local chipCount = BagCommonManager:getInstance():getItemNumById(self._pDataInfo.data.PieceID)
    if self._pDataInfo.step == 0 then
        self._pParams["_pLoadingBarText"]:setString(chipCount .. "/" .. self._pDataInfo.data.PieceNum)
        self._pParams["_pLoadingBar"]:setPercent(chipCount/self._pDataInfo.data.PieceNum * 100)
        
        self._pParams["_pMergeButton"]:setVisible(true)
        self._pParams["_pLvUpButton"]:setVisible(false)
        
    elseif self._pDataInfo.step == 5 then
        self._pParams["_pLoadingBarText"]:setString("满阶")
        self._pParams["_pMergeButton"]:setVisible(false)
        self._pParams["_pLvUpButton"]:setVisible(false)
        self._pParams["_pLoadingBar"]:setVisible(false)
        self._pParams["_pLoadingBarBg"]:setVisible(false)
    else
        self._pParams["_pLoadingBarText"]:setString(chipCount .. "/" .. self._pDataInfo.data["MaterialRequired"..self._pDataInfo.step][1][2])
        self._pParams["_pLoadingBar"]:setPercent(chipCount/self._pDataInfo.data["MaterialRequired"..self._pDataInfo.step][1][2] * 100)
        
        self._pParams["_pMergeButton"]:setVisible(false)
        self._pParams["_pLvUpButton"]:setVisible(true)
    end
end

function PetJigsaw:handleAdvancePet(event)
    
end

function PetJigsaw:handleCompoundPet(event)
    for i=1,table.getn(PetsManager:getInstance()._tMainPetsInfos) do
        if PetsManager:getInstance()._tMainPetsInfos[i].petId == self._pDataInfo.id then
            local info = PetsManager:getInstance():getPetInfoWithId(PetsManager:getInstance()._tMainPetsInfos[i].petId,
                PetsManager:getInstance()._tMainPetsInfos[i].step,
                PetsManager:getInstance()._tMainPetsInfos[i].level)

            self:setInfo(info)
        end
	end
end

-- 退出函数
function PetJigsaw:onExitPetJigsaw()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return PetJigsaw
