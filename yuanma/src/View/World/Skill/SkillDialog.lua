--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SkillDialog.lua
-- author:    liyuhang
-- created:   2015/3/10
-- descrip:   技能系统面板
--===================================================
local SkillDialog = class("SkillDialog",function()
	return require("Dialog"):create()
end)

local activeSkillNum = TableConstants.ActiveSkillNumber.Value + 1
local passiveSkillNum = TableConstants.PassiveSkillNumber.Value
local talentSkillNum = TableConstants.TalentNumber.Value

local activeSkillIdStart = 1
local passiveSkillIdStart = 1001
local talentSkillIdStart = 2001
      
-- 构造函数
function SkillDialog:ctor()
	-- 层名字
	self._strName = "SkillDialog" 
	-- 触摸监听器
	self._pTouchListener = nil 
	self._pParams = nil
	--  商城相关的PCCS
	self._pCCS = nil  
	-- 商城背景
	self._pBg = nil
	-- 关闭按钮
	self._pCloseButton = nil        
	
	self._pnumber = nil
    self._pnumberFight = nil
	
	self._pPassiveSkillsNode = nil
	self._pTalentSkillsNode = nil  
	self._pnodeskillbackground = nil
	
	self._pskillgenre01 = nil
	
	self._pSkillNodes = {}
	self._pSkillCell = {}
	
	self._nRoleId = 0
	
end

-- 创建函数
function SkillDialog:create(args)
	local layer = SkillDialog.new()
	layer:dispose(args)
	return layer
end

-- 处理函数
function SkillDialog:dispose(args)
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "技能按钮" , value = false})
	-- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpgradeSkill, handler(self,self.handleMsgUpgradeSkill))
    NetRespManager:getInstance():addEventListener(kNetCmd.kMountSkill, handler(self,self.handleMsgMountSkill))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFisance, handler(self,self.handleMsgUpdateFisance))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateSkill, handler(self,self.handleMsgUpdateSkill))
	-- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("skillpanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("SkillSet.plist")

    self._nRoleId = RolesManager:getInstance()._pMainRoleInfo.roleCareer
    
    SkillCGMessage:sendMessageQuerySkillList21400()
	-- 初始化界面相关
	self:initUI()

	-- 初始化触摸相关
	self:initTouches()
	
    if SkillsManager:getInstance()._bGetInitData == false then
        SkillCGMessage:sendMessageQuerySkillList21400()
	end

	------------------节点事件------------------------------------
	local function onNodeEvent(event)
        if event == "exit" then
			self:onExitSkillDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function SkillDialog:initUI()
	-- 加载组件
	local params = require("SkillPanelParams"):create()
	self._pCCS = params._pCCS
	self._pParams = params
	self._pBg = params._pbackground
	self._pCloseButton = params._pclosebutton
    self._pnodeskillbackground = params._pnodeskillbackground
    self._pnumber = params._pnumber
    self._pnumberFight = params._pnumberFight
    
    self._pskillgenre01 = params._pSkillButton01
    self._pskillgenre02 = params._pSkillButton02
    self._pskillgenre03 = params._pSkillButton03
    
    self:disposeCSB()
    
    local icon = FinanceManager:getInstance():getIconByFinanceType(kFinance.kSP)
    params._pcurrencyicon:loadTexture(
        icon.filename,
        ccui.TextureResType.plistType)
        
    for i=1,3 do
        self._pSkillCell[i] = {}
        self._pSkillNodes[i] = require("SkillSet01Params"):create()
        params._pnodeskillbackground:addChild(self._pSkillNodes[i]._pCCS)
        self._pSkillNodes[i]._pCCS:setPosition(0,-200)
        
        local infoData = TableRoleSkillsTree[3*(self._nRoleId-1)+ i]
        for j=1,table.getn(infoData.SkillsID) do
        	self._pSkillCell[i][j] = require("SkillCell"):create()
            self._pSkillNodes[i]["_pNode0" .. j]:addChild(self._pSkillCell[i][j])
        end
    end

    local x = params._pnodeskillbackground:getPositionX()
    local y = params._pnodeskillbackground:getPositionY()
	
    self:updateSkillDatas()
    
    local function tabClickCallback (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            
            self._pSkillNodes[1]._pCCS:setVisible(tag == 1 and true or false)
            self._pSkillNodes[2]._pCCS:setVisible(tag == 2 and true or false)
            self._pSkillNodes[3]._pCCS:setVisible(tag == 3 and true or false)
            
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    	
    params._pSkillButton01:addTouchEventListener(tabClickCallback)
    params._pSkillButton01:setTag(1)
    params._pSkillButton02:addTouchEventListener(tabClickCallback)
    params._pSkillButton02:setTag(2)
    params._pSkillButton03:addTouchEventListener(tabClickCallback)
    params._pSkillButton03:setTag(3)
    
    self._pSkillNodes[1]._pCCS:setVisible(1 == 1 and true or false)
    self._pSkillNodes[2]._pCCS:setVisible(1 == 2 and true or false)
    self._pSkillNodes[3]._pCCS:setVisible(1 == 3 and true or false)
    
end

-- 更新技能列表
function SkillDialog:updateSkillDatas()
    for j=1,3 do
        local infoData = TableRoleSkillsTree[3*(self._nRoleId-1)+j]
        for i=1,table.getn(infoData.SkillsID) do
            local icon = SkillsManager:getInstance():getMainRoleSkillIconByID(infoData.SkillsID[i])
            local level = SkillsManager:getInstance():getMainRoleLevelByID(infoData.SkillsID[i])
            local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(infoData.SkillsID[i] , level)

            if self._pSkillCell[j][i] ~= nil then
                self._pSkillCell[j][i]:setSkillInfo(skillData,infoData.SkillsID[i],level,icon)
            end
        end
    end
    
    for i=1,5 do
        self._pParams["_pTextLv0".. i]:setVisible(false)
        self._pParams["_pSkillIcon0".. i]:setVisible(false)
    end
    
    for i=1,table.getn(SkillsManager:getInstance()._tMainRoleMountSkills) do
        local level = SkillsManager:getInstance():getMainRoleLevelByID(SkillsManager:getInstance()._tMainRoleMountSkills[i].id)
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(SkillsManager:getInstance()._tMainRoleMountSkills[i].id , level)

        self._pParams["_pTextLv0".. skillData.SkillType]:setVisible(true)
        self._pParams["_pSkillIcon0".. skillData.SkillType]:setVisible(true)
        
        self._pParams["_pTextLv0".. skillData.SkillType]:setString("Lv:" .. level)
        self._pParams["_pSkillIcon0".. skillData.SkillType]:loadTexture(skillData.skillIcon..".png",ccui.TextureResType.plistType)
    end
end

-- 初始化触摸相关
function SkillDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

-- 退出函数
function SkillDialog:onExitSkillDialog()
    self:onExitDialog()
	-- 释放网络监听事件
	NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("skillpanel.plist")
end

function SkillDialog:handleMsgUpgradeSkill(event)
    self:updateSkillDatas()
    --不开启
    return
end

-- 处理购买商品的网络回调
function SkillDialog:handleMsgMountSkill(event)
    for i=1,5 do
        self._pParams["_pTextLv0".. i]:setVisible(false)
        self._pParams["_pSkillIcon0".. i]:setVisible(false)
    end

    for i=1,table.getn(SkillsManager:getInstance()._tMainRoleMountSkills) do
        local level = SkillsManager:getInstance():getMainRoleLevelByID(SkillsManager:getInstance()._tMainRoleMountSkills[i].id)
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(SkillsManager:getInstance()._tMainRoleMountSkills[i].id , level)
        
        self._pParams["_pTextLv0".. skillData.SkillType]:setVisible(true)
        self._pParams["_pSkillIcon0".. skillData.SkillType]:setVisible(true)
        
        self._pParams["_pTextLv0".. skillData.SkillType]:setString("Lv:" .. level)
        self._pParams["_pSkillIcon0".. skillData.SkillType]:loadTexture(skillData.skillIcon..".png",ccui.TextureResType.plistType)
    end
end 

function SkillDialog:handleMsgUpdateFisance(event)
    local value = FinanceManager:getInstance():getValueByFinanceType(kFinance.kCoin)
    self._pnumber:setString(value)
    local fightValue = FinanceManager:getInstance():getValueByFinanceType(kFinance.kSP)
    self._pnumberFight:setString(fightValue)
end

function SkillDialog:handleMsgUpdateSkill(event)
    self:updateSkillDatas()
end

return SkillDialog