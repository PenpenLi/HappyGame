--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SkillDetailDialog.lua
-- author:    liyuhang
-- created:   2015/3/11
-- descrip:   技能详情面板
--===================================================
local SkillDetailDialog = class("SkillDetailDialog",function()
	return require("Dialog"):create()
end)

-- 构造函数
function SkillDetailDialog:ctor()
	-- 层名字
	self._strName = "SkillDetailDialog" 
	-- 触摸监听器
	self._pTouchListener = nil 
	--  商城相关的PCCS
	self._pCCS = nil  
	-- 商城背景
	self._pBg = nil
	-- 关闭按钮
	self._pCloseButton = nil         
	
	self._pParmas = nil
	
	self._pSkillBtns = {} 
	self._pSkillData = nil
	self._pNextSkillData = nil
	self._pMountIcon = nil
    -- 是否只是查看（true 功能按钮不可用）
    self._isCheckOut = false
end

-- 创建函数
function SkillDetailDialog:create(args)
	local layer = SkillDetailDialog.new()
	layer:dispose(args)
	return layer
end

-- 处理函数
function SkillDetailDialog:dispose(args)
    -- 设置是否需要缓存
    self:setNeedCache(true)
    
    self._pSkillData = args[1]
    self._pNextSkillData = args[2]
    if args[3] ~= nil then
        self._isCheckOut = args[3]
    else
        self._isCheckOut = false
    end
	-- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpgradeSkill, handler(self,self.handleMsgUpgradeSkill))
    NetRespManager:getInstance():addEventListener(kNetCmd.kMountSkill, handler(self,self.handleMsgMountSkill))
	-- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("skilltips.plist")

	-- 初始化界面相关
    self:initUI()

	-- 初始化触摸相关
	self:initTouches()

	------------------节点事件------------------------------------
	local function onNodeEvent(event)
        if event == "exit" then
			self:onExitSkillDetailDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function SkillDetailDialog:initUI()
	-- 加载组件
	local params = require("SkillTipsParams"):create()
    self._pParmas = params
	self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

	self:disposeCSB()

    self:updateData()
end

function SkillDetailDialog:updateData()
    local params = self._pParmas
    params._plvupbutton:setTitleFontName(strCommonFontName)
    params._pskillchoicebutton:setTitleFontName(strCommonFontName)
    
    self._pParmas._plvupbutton:setVisible(true)
    self._pParmas._pskillchoicebutton:setVisible(true)
    --升级价格底板
    self._pParmas._plvuppriceBg:setVisible(true)
    --升级价格
    --self._pParmas._plvupprice:setVisible(true)
    --升级价格具体金币数值
    --self._pParmas._plvupprice02:setVisible(true)
    --升级价格具体斗魂数值
    --self._pParmas._plvupprice03:setVisible(true)
    --货币icon
    --self._pParmas._pcurrencyicon:setVisible(true)

    if self._pSkillData ~= nil then
        params._pskillicon:loadTexture(self._pSkillData.skillIcon..".png",ccui.TextureResType.plistType)
        params._pskillname:setString(self._pSkillData.SkillName)
        self._pParmas._plvupprice02:setString(self._pSkillData.GoldRequire)
        self._pParmas._plvupprice03:setString(self._pSkillData.FightingValue)
        params._pskilllv:setString("Lv: ".. self._pSkillData.Level)
        self._pParmas._pSkillDiscEffectLv01:setString("Lv:".. self._pSkillData.Level)
        -- 技能位置
        if self._pSkillData.SkillType ~= nil then
            params._pskillPos:setString("位置: ".. self._pSkillData.SkillType)
            params._pskillPos:setVisible(true)
        else
            params._pskillPos:setVisible(false)
        end
        
        local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(kFinance.kCoin)
        params._pcurrencyicon:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
        
        self._pParmas._pskilldepict01:setString(self._pSkillData.Describe)
        self._pParmas._pskilldepict01:setVisible(true)
        
        --升级技能按钮
        local  onUpgradeButton = function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local nextSkillData = SkillsManager:getInstance():getMainRoleSkillDataByID(self._pSkillData.ID,SkillsManager:getInstance():getMainRoleLevelByID(self._pSkillData.ID)+1)
                if nextSkillData~= nil and nextSkillData.RequiredLevel > RolesManager:getInstance()._pMainRoleInfo.level then
                    NoticeManager:getInstance():showSystemMessage("技能升到"..(SkillsManager:getInstance():getMainRoleLevelByID(nextSkillData.ID)+1).."级需要玩家等级达到"..nextSkillData.RequiredLevel.."级")
                    return
                end
                SkillCGMessage:sendMessageUpgradeSkill21402(self._pSkillData.ID)
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end

        --出战技能按钮
        local  onMountButton = function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                SkillCGMessage:sendMessageMountSkill21404(self._pSkillData.ID)
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end

        params._plvupbutton:addTouchEventListener(onUpgradeButton)

        if SkillsManager:getInstance():getMainRoleLevelByID(self._pSkillData.ID) == 0 then
            params._plvupbutton:setTitleText("激活")
            params._pskillchoicebutton:setVisible(false)
        else
            params._plvupbutton:setTitleText("升级")
        end
        params._pskillchoicebutton:addTouchEventListener(onMountButton)

        if self._pSkillData.ID >= 1000 or SkillsManager:getInstance():getMainRoleBeMountById(self._pSkillData.ID) == true then
            params._pskillchoicebutton:setVisible(false)
        end
        --满级 
        if self._pSkillData.GoldRequire == 0 then
            params._plvupbutton:setVisible(false)
            self._pParmas._plvupprice02:setString("")
            self._pParmas._plvupprice03:setString("")
            self._pParmas._pcurrencyicon:setVisible(false)
            -- self._pParmas._plvupprice:setString("已经升至满级")
            -- darkNode(self._pParmas._plvupbutton:getVirtualRenderer():getSprite())
        end
    else
        
    end
    
    if self._pNextSkillData ~= nil then
        self._pParmas._pskilldepict02:setString(self._pNextSkillData.Describe)
        self._pParmas._pskilldepict02:setVisible(true)
        
        local depictStr = nil
        if self._pNextSkillData ~= nil then
            depictStr = "角色Lv" .. self._pNextSkillData.RequiredLevel .. "\n"
        end

        if self._pSkillData.Precondition ~= nil and table.getn(self._pSkillData.Precondition) > 0 then
            for i=1,table.getn(self._pSkillData.Precondition) do
                local level = self._pSkillData.Precondition[i][2]
                local skillName = SkillsManager:getMainRoleSkillDataByID(self._pSkillData.Precondition[i][1],1).SkillName

                depictStr = depictStr .. skillName .. "Lv" .. level .. "\n"
            end
        end
        
        self._pParmas._pskilldepict03:setString(depictStr)
        
        self._pParmas._pskilldepict03:setVisible(true)
        self._pParmas._pSkillDiscEffectLv02:setString("Lv:".. self._pNextSkillData.Level)
        
        self._pParmas._pSkillTitleBg02:setVisible(true)
        self._pParmas._pSkillTitleBg03:setVisible(true)
    else    
        self._pParmas._pskilldepict02:setVisible(false)
        self._pParmas._pskilldepict03:setVisible(false)
        self._pParmas._pSkillTitleBg02:setVisible(false)
        self._pParmas._pSkillTitleBg03:setVisible(false)
    end
    
    self:updateBtnStatus()
end

-- 初始化触摸相关
function SkillDetailDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            return true
        end
        return false
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
function SkillDetailDialog:onExitSkillDetailDialog()
    self:onExitDialog()
	-- 释放网络监听事件
	NetRespManager:getInstance():removeEventListenersByHost(self)
	-- 释放掉shop合图资源
    ResPlistManager:getInstance():removeSpriteFrames("skilltips.plist")
end

function SkillDetailDialog:handleMsgUpgradeSkill(event)
    if event.data.id == self._pSkillData.ID then
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(event.data.id,event.data.level) 
        self._pNextSkillData = nil
        self._pNextSkillData = SkillsManager:getInstance():getMainRoleSkillDataByID(event.data.id,event.data.level+1) 
        self._pSkillData = skillData
        self:updateData()
    end
end

function SkillDetailDialog:handleMsgMountSkill(event)
    if self._pSkillData.ID >= 1000 or SkillsManager:getInstance():getMainRoleBeMountById(self._pSkillData.ID) == true then
        self._pParmas._pskillchoicebutton:setVisible(false)
    end
end

function SkillDetailDialog:updateBtnStatus()
    if self._isCheckOut == true then
        self._pParmas._plvupbutton:setVisible(false)
        self._pParmas._pskillchoicebutton:setVisible(false)
         --升级价格底板
        self._pParmas._plvuppriceBg:setVisible(false)
        --升级价格
        self._pParmas._plvupprice:setVisible(false)
        --升级价格具体金币数值
        self._pParmas._plvupprice02:setVisible(false)
        --升级价格具体斗魂数值
        self._pParmas._plvupprice03:setVisible(false)
        --货币icon
        self._pParmas._pcurrencyicon:setVisible(false)
    end
end

--界面做了缓存再次打开的需要进行的操作
function SkillDetailDialog:updateCacheWithData(args)
    self._pSkillData = args[1]
    self._pNextSkillData = args[2]
    if args[3] ~= nil then
        self._isCheckOut = args[3]
    else
        self._isCheckOut = false
    end
    
    self:updateData()
end

return SkillDetailDialog