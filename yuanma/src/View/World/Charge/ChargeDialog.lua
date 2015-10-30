--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChargeDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/06
-- descrip:   充值弹框
--===================================================
local ChargeDialog = class("ChargeDialog",function() 
	return require("Dialog"):create()
end)

function ChargeDialog:ctor()
	self._strName = "ChargeDialog"
	self._pVipFntText = nil 
	--  eg 500/900
	self._pLoadingText = nil
	-- eg 还差400 即可升级
	self._pLoadingTip = nil
	self._pVipLoadingBar = nil 
	self._pVipInfoBtn = nil
	self._pVipInfoBtn1 = nil 
	self._pGoodsScrollView = nil
	--------------------------
	self._tChargeItem = {}
	self._pVipInfo = nil 
end

function ChargeDialog:create(args)
	local dialog = ChargeDialog.new()
	dialog:dispose(args)
	return dialog
end

function ChargeDialog:dispose(args)
    -- 注册事件回调
    NetRespManager:getInstance():addEventListener(kNetCmd.kRechargeNotice ,handler(self, self.handleRechargeNotice))

	ResPlistManager:getInstance():addSpriteFrames("RechargeBG.plist")
	ResPlistManager:getInstance():addSpriteFrames("RmbBG.plist")
	self:initUI()
	self:initTouches()
	------------节点事件-------------------------------
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitChargeDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	self._tChargeItem = args
	self:updateChargeItem()
	self:UpdateVipInfo()
end

function ChargeDialog:initUI()
	local params = require("RechargeBGParams"):create()
	self._pBg = params._pBackGround
	self._pCCS = params._pCCS
	self._pCloseButton = params._pCloseButton
	self._pVipFntText = params._pVipFnt
	self._pVipLoadingBar = params._pLoadingBar
	self._pVipInfoBtn = params._pVipButton
	self._pVipInfoBtn1 = params._pPrivilegeButton
	self._pLoadingText = params._pVipText01
	self._pLoadingTip = params._pVipText02
	self._pGoodsScrollView = params._pScrollView

	self:disposeCSB()

	-- vip 升级进度条
	local pSprite = cc.Sprite:createWithSpriteFrameName("RechargeBGRes/czjm2.png")
    local pLoadingBar = cc.ProgressTimer:create(pSprite)
    pLoadingBar:setPosition(self._pVipLoadingBar:getPosition())
    pLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pLoadingBar:setMidpoint(cc.p(0, 0))
    pLoadingBar:setBarChangeRate(cc.p(1, 0))
    pLoadingBar:setPercentage(0)
    self._pVipLoadingBar:getParent():addChild(pLoadingBar)
    self._pVipLoadingBar:removeFromParent()
    self._pVipLoadingBar = nil 
    self._pVipLoadingBar = pLoadingBar

	local function touchEvent(sneder,eventType)
		if eventType == ccui.TouchEventType.ended then
			DialogManager:getInstance():showDialog("VipDialog")
			self:close()
		elseif eventType == ccui.TouchEventType.began then
     	    AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pVipInfoBtn:addTouchEventListener(touchEvent)
	self._pVipInfoBtn1:addTouchEventListener(touchEvent)
end

-- 初始化触摸相关
function ChargeDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        --self:deleteItem(1)
        --self:deleteAllItems()
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

function ChargeDialog:updateChargeItem()
	local innerWidht = 0
	local innerHeight = self._pGoodsScrollView:getInnerContainerSize().height
	self._pGoodsScrollView:removeAllChildren(true)
	for i,v in ipairs(self._tChargeItem) do
		local render = require("ChargeItemRender"):create(v)
		render:setPosition(cc.p(innerWidht + render._pBg:getContentSize().width/2,render._pBg:getContentSize().height/2))
		innerWidht = innerWidht + render._pBg:getContentSize().width
		self._pGoodsScrollView:addChild(render)
	end
	if innerWidht > self._pGoodsScrollView:getInnerContainerSize().width then 
		self._pGoodsScrollView:setInnerContainerSize(cc.size(innerWidht,innerHeight))
	end
end

function ChargeDialog:UpdateVipInfo()
	self._pVipInfo = RolesManager:getInstance()._pMainRoleInfo.vipInfo
	self._pVipFntText:setString(self._pVipInfo.vipLevel)
	local needReachNum = TableVIP[self._pVipInfo.vipLevel + 1].RechargeNum
	-- 判断Vip 等级是否达到最高级
	if not TableVIP[self._pVipInfo.vipLevel + 1] or TableVIP[self._pVipInfo.vipLevel + 1].RechargeNum == 0 then 
		self._pLoadingText:setString(self._pVipInfo.totalCharge.."/"..self._pVipInfo.totalCharge)
		self._pLoadingTip:setString("Vip以达到满级")
		self._pVipLoadingBar:setPercentage(100)
	else
		self._pLoadingText:setString(self._pVipInfo.totalCharge.."/"..needReachNum)
		self._pLoadingTip:setString("还差"..needReachNum - self._pVipInfo.totalCharge.."即可升级")
        self._pVipLoadingBar:setPercentage(self._pVipInfo.totalCharge / needReachNum * 100)	
	end	
end

function ChargeDialog:onExitChargeDialog()
	self:onExitDialog()
	ResPlistManager:getInstance():removeSpriteFrames("RechargeBG.plist") 
	ResPlistManager:getInstance():removeSpriteFrames("RmbBG.plist") 
	NetRespManager:getInstance():removeEventListenersByHost(self)
end

function ChargeDialog:closeWithAni()
	self:stopAllActions()
    if self._pTouchListener then
        self._pTouchListener:setEnabled(false)
        self._pTouchListener:setSwallowTouches(false)
    end
    self:setTouchEnableInDialog(true)
    self:doWhenCloseOver()
    self:removeAllChildren(true)
    self:removeFromParent(true)
end

function ChargeDialog:handleRechargeNotice(event)
	-- 缓存上次Vip 信息
	local pPrevVipInfo = RolesManager:getInstance()._pMainRoleInfo.vipInfo 
    RolesManager:getInstance()._pMainRoleInfo.vipInfo = event.vipInfo 
    self._pVipInfo = RolesManager:getInstance()._pMainRoleInfo.vipInfo

    local vipLevelDif = self._pVipInfo.vipLevel > pPrevVipInfo.vipLevel 

    if vipLevelDif > 0 then 
    	local tPercent = {}
    	for i = 1, vipLevelDif  do
    		tPercent[i] = {100,pPrevVipInfo.vipLevel + i}
    	end
    	self:playVipUpgradeAni(tPercent)
    end
   
    NoticeManager:showSystemMessage("充值成功，购买"..event.addDiamond .. "玉璧")
end

--  {{100,1},{100,2}}
function ChargeDialog:playVipUpgradeAni(nPercent)
    local nSize = table.getn(nPercent)
    for i=1,nSize do
        local callBack = function()
            self._pVipFntText:setString("Lv"..nPercent[i][2])
            if i < nSize then
                self._pVipLoadingBar:setPercentage(0)
            else
            	self._pVipFntText:setString(self._pVipInfo.vipLevel)
				local needReachNum = TableVIP[self._pVipInfo.vipLevel + 1].RechargeNum
				-- 判断Vip 等级是否达到最高级
				if not TableVIP[self._pVipInfo.vipLevel + 1] or TableVIP[self._pVipInfo.vipLevel + 1].RechargeNum == 0 then 
					self._pLoadingText:setString(self._pVipInfo.totalCharge.."/"..self._pVipInfo.totalCharge)
					self._pLoadingTip:setString("Vip以达到满级")
					self._pVipLoadingBar:setPercentage(100)
				else
					self._pLoadingText:setString(self._pVipInfo.totalCharge.."/"..needReachNum)
					self._pLoadingTip:setString("还差"..needReachNum - self._pVipInfo.totalCharge.."即可升级")
					self._pVipLoadingBar:setPercentage(self._pVipInfo.totalCharge / needReachNum * 100)	
				end	
            end
        end

       self._pVipLoadingBar:runAction(
    			cc.Sequence:create(cc.DelayTime:create(0.5*i),
    			cc.ProgressTo:create(0.2, nPercent[i][1]),
			    cc.CallFunc:create(callBack)))
    end
end

return ChargeDialog

