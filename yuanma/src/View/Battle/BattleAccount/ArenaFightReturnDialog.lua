--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ArenaFightReturnDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/05/07
-- descrip:   竞技场战斗回来确认面板
--===================================================
local ArenaFightReturnDialog = class("ArenaFightReturnDialog",function ()
	return require("Dialog"):create()
end)

function ArenaFightReturnDialog:ctor()
	self._strName = "ArenaFightReturnDialog"
	self._pCloseButton = nil 
	self._pCCS = nil 
	self._pBg = nil 
	-- 确定按钮
	self._pOkBtn = nil  
	-- 金融控件集合(最多三个)
	self._tFinanceNodeArry = {}
	-- 排名文字
	self._pRankTextTitle = nil 
	-- 胜利/失败的图标 
	self._pFlagImg = nil
	-- 具体排名值 
	self._pRankTextNum = nil 
	-- 奖励货币
	self._tFinanceInfoArry = {}
	--  最新竞技场排名
	self._nCurRankNum = 0
	-- 挑战是否成功
	self._isWin = false
end

function ArenaFightReturnDialog:create(args)
	local dialog = ArenaFightReturnDialog.new()
	dialog:dispose(args)
	return dialog
end

function ArenaFightReturnDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("PvpFinishDialog.plist")
    
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitArenaFightReturnDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

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
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    if args ~= nil then
        self._tFinanceInfoArry = args.finances
        self._nCurRankNum = args.currRank
        self._isWin = args.isWin
    end

    self:initUI()
end

function ArenaFightReturnDialog:initUI()
    local params = require("PvpFinishDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._tFinanceNodeArry[1] = params._pMoneyNode
	self._tFinanceNodeArry[2] = params._pRmbNode
	self._tFinanceNodeArry[3] = params._pToukonNode
	self._pRankTextTitle = params._pTextRankInfo
	self._pFlagImg = params._pFlagImg
	self._pRankTextNum = params._pText2
	self._pOkBtn = params._pOkButton
	self:disposeCSB()

    local function touchEvent(sender,eventType)
	    if eventType == ccui.TouchEventType.ended then
            --关闭当前打开的Dialog
            BattleManager:getInstance()._bIsTransforingFromEndBattle = true
            self:getParent():closeDialogByNameWithNoAni("ArenaFightReturnDialog")
            LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
        elseif eventType == ccui.TouchEventType.began then
        	AudioManager:getInstance():playEffect("ButtonClick")
	    end
    end
    self._pOkBtn:addTouchEventListener(touchEvent)
    
 	if self._nCurRankNum < ArenaManager:getInstance()._nCurPvpRank then
 		self._pRankTextTitle:setString("战斗胜利您的排名提升至,第 ")
 		self._pRankTextNum:setString(self._nCurRankNum.. "名")
 		ArenaManager:getInstance()._nCurPvpRank = self._nCurRankNum	
	else
		local strMsg = self._isWin == true and "战斗胜利您的排名未发生变化" or "战斗失败您的排名未发生变化"
		self._pRankTextTitle:setString(strMsg)
 		self._pRankTextNum:setString("")		
	end
	local imgName = self._isWin == true and "PvpFinishDialog/zdjs22.png" or "PvpFinishDialog/zdjs21.png"
	self._pFlagImg:loadTexture(imgName,ccui.TextureResType.plistType)
    self:setFinceInfo()
end

-- 设置获得金融信息
function ArenaFightReturnDialog:setFinceInfo()
	for i,finceNode in ipairs(self._tFinanceNodeArry) do
		if i <= #self._tFinanceInfoArry then
			finceNode:setVisible(true)
			local financeIconInfo = FinanceManager:getInstance():getIconByFinanceType(self._tFinanceInfoArry[i].finance)
			finceNode:getChildByName("Icon"):loadTexture(financeIconInfo.filename,financeIconInfo.textureType)
			finceNode:getChildByName("TextNum"):setString(self._tFinanceInfoArry[i].amount)
		else
			finceNode:setVisible(false)
		end
	end
end

function ArenaFightReturnDialog:onExitArenaFightReturnDialog()
	self:onExitDialog()

    ResPlistManager:getInstance():removeSpriteFrames("PvpFinishDialog.plist")	
end

function ArenaFightReturnDialog:closeWithAni()
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

return ArenaFightReturnDialog