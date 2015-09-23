--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetItemCell.lua
-- author:    liyuhang
-- created:   2015/04/23
-- descrip:   宠物itemcell
--===================================================
local PetItemCell = class("PetItemCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function PetItemCell:ctor()
    -- 层名称
    self._strName = "PetItemCell"        
   
    -- 地图背景
    self._pParams = nil
    self._pBg = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形
    
    self._pDataInfo = nil
    self._nStep = 1
    self._nLevel = 1
end

-- 创建函数
function PetItemCell:create(dataInfo)
    local dialog = PetItemCell.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function PetItemCell:dispose(dataInfo)
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
            self:onExitPetItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function PetItemCell:initUI()
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            
        end
    end

    --图标按钮
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            DialogManager:showDialog("PetFoodDialog",{self._pDataInfo,true})
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    
    -- 加载csb 组件
    local params = require("OnePetParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pOnePetBg
    
    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)
    
    self._pParams["_pIcon"]:addTouchEventListener(onTouchBg)
    
    self._pParams["_pUpButton"]:addTouchEventListener(function(sender, eventType)
        if self._pDataInfo ~= nil then
            if eventType == ccui.TouchEventType.ended then
                if table.getn( PetsManager:getInstance()._tMainPetRoleInfosInQueue) >= 3 then
                    NoticeManager:showSystemMessage(TableNetError["e20211"].Desc)
                else
                    PetCGMessage:sendMessageField21502(self._pDataInfo.id)
                end
            end
        end
     end)
    
    self:updateData()
end

function PetItemCell:updateData()
    if self._pDataInfo == nil then
    	return
    end
    
    self._pParams["_pUpUpUp"]:setVisible(PetsManager:getInstance():isPetField(self._pDataInfo.id) == true)
    self._pParams["_pUpButton"]:setVisible(PetsManager:getInstance():isPetField(self._pDataInfo.id) == false)


    self._pParams["_pName"]:setString(self._pDataInfo.templete.PetName)
    self._pParams["_pName"]:setColor(kQualityFontColor3b[self._pDataInfo.step])
    self._pParams["_pIcon"]:loadTextures(
        self._pDataInfo.templete.PetIcon ..".png",
        self._pDataInfo.templete.PetIcon ..".png",
        self._pDataInfo.templete.PetIcon ..".png",
        ccui.TextureResType.plistType)
        
    self._pParams["_pLv02"]:setString(self._pDataInfo.level)
    
    self._pParams["_pIconP"]:loadTexture("ccsComRes/qual_" ..self._pDataInfo.step.."_normal.png",ccui.TextureResType.plistType)
    
    self._pParams["_pQuality"]:setString(self._pDataInfo.step .. "阶")
    self._pParams["_pAttack02"]:setString(math.ceil(self._pDataInfo.data.Attack + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.AttackGrowth[self._pDataInfo.step]))
    self._pParams["_pDefend02"]:setString(math.ceil(self._pDataInfo.data.Defend + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DefendGrowth[self._pDataInfo.step]))
    self._pParams["_pHp02"]:setString(math.ceil(self._pDataInfo.data.Hp + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.HpGrowth[self._pDataInfo.step]))
    self._pParams["_pLv02"]:setString(self._pDataInfo.level)
    self._pParams["_pType"]:setString(petTypeColorDef[self._pDataInfo.data.PetFunction].name)
    self._pParams["_pType"]:setColor(petTypeColorDef[self._pDataInfo.data.PetFunction].color)
    
    local levelIndex  = math.modf(self._pDataInfo.level/10) 
    local skillArry = self._pDataInfo.data.SkillIDs[levelIndex+1]
    for i=1,3 do
        self._pParams["_pPetSkill0"..i]:setString(TableTempleteSkills[TablePetsSkills[skillArry[i]].TempleteID].SkillName)
    end
    
    for i=1,3 do
        local type = self._pDataInfo.data["SpecialType"..i]
        local value = self._pDataInfo.data["SpecialValue"..i]
        self._pParams["_pRoleAttribute0"..i.."02"]:setString(TablePetsLevel[self._pDataInfo.level].PetSpecialGrowth * value[self._pDataInfo.step] )
        self._pParams["_pRoleAttribute0"..i.."01"]:setString(kAttributeNameTypeTitle[type])
    end
end

function PetItemCell:setInfo(info)
	self._pDataInfo = info
	
	self:updateData()
end

function PetItemCell:handleMsgFeedPet(event)
	
end

-- 退出函数
function PetItemCell:onExitPetItem()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return PetItemCell
