--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BuyStrengthDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/09/23
-- descrip:   购买体力或者购买战斗（副本）次数弹框
--===================================================
local BuyStrengthDialog = class("BuyStrengthDialog",function () 
	return require("Dialog"):create()
end)

function BuyStrengthDialog:ctor()
	self._strName = "BuyStrengthDialog"
	self._pCloseButton = nil 
	self._pCCS = nil 
	self._pBg = nil 
	-- 确定按钮
	self._pOkBtn = nil 
	---------------- 【购买体力的节点】-----------------------------
	self._pBuyStrengthNode = nil 
	-- 体力自动恢复的信息
	self._pAutoAddStrengthInfoText = nil 
	-- 购买体力描述信息
	self._pBuyStrengthInfoText = nil 
	-- 今日可购买的体力数量
	self._pBuyStrengthNumText = nil 
	---------------- 【玉璧不足的节点】------------------------------
	self._pLackDiamondNode = nil 
	---------------- 【购买次数不足的节点】--------------------------
	self._pLackBuyNumNode = nil 
	-- 购买次数的文本
	self._pBuyNumText = nil 
	---------------- 【购买副本次数的节点】--------------------------
	self._pBuyBattleNumNode = nil 
	-- 消耗的玉璧数量
	self._pBuyBattleConstDiamondNumText = nil 
	-- 今日可购买的副本次数
	self._pBuyBatttleNumText = nil
	-------------------------------
	-- 购买的类型：
	--	1 购买体力 
	--	2 购买挑战次数 
	self._kBuyType = 1
	-- 购买副本的类型
	self._kCopyType = 0
	-- 购买副本的Id
	self._nCopyId = 0
	-- 消耗货币的数量
	self._nConstDiamondNum = 0
	-- 已经购买的次数
	self._nCurBuyNum = 0
	-- 最大购买的次数
	self._nMaxBuyNum = 0
	-- 角色的信息
	self._pRoleInfo = RolesManager._pMainRoleInfo
	-- 角色玉璧数量
	self._nDiamondNum = FinanceManager:getInstance()._tCurrency[kFinance.kDiamond]
end

-- 创建函数
-- args {kBuyType,kCopyType,nCopyId}
function BuyStrengthDialog:create(args)
	local dialog = BuyStrengthDialog.new()
	dialog:dispose(args)
	return dialog
end

function BuyStrengthDialog:dispose(args)
	-- 添加合图资源
	ResPlistManager:getInstance():addSpriteFrames("BuyPorT.plist")

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitBuyStrengthDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	-------------- 【设置数据】-----------------------------
	self._kBuyType = args[1]
	if self._kBuyType == 2 then
		-- 如果是购买副本次数 
		self._kCopyType = args[2]
		self._nCopyId = args[3]
	end

	self:initUI()
end

function BuyStrengthDialog:initUI()
    local params = require("BuyStrengthParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBuyP
	self._pOkBtn = params._pYes
	self._pCloseButton = params._pNo
	self._pBuyStrengthNode = params._pNode_1
	self._pAutoAddStrengthInfoText = params._pAutoAddStrengthText
	self._pBuyStrengthInfoText = params._pBuyStrengthInfoText
	self._pBuyStrengthNumText = params._pBuyStrengthNumText
	self._pLackDiamondNode = params._pNode_2
	self._pBuyBattleNumNode = params._pNode_3
	self._pBuyBattleConstDiamondNumText = params._pBuyBattleConstDiamondText
	self._pBuyBatttleNumText = params._pBuyBattleNumText
	self._pLackBuyNumNode = params._pLackBuyNumNode
	self._pBuyNumText = params._pCurBuyNumText

	-- 确定按钮的点击事件
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        elseif eventType == ccui.TouchEventType.ended then
       		if sender:getName() == "lackDiamond" then 
       			-- 前往充值
       			ShopSystemCGMessage:queryChargeListReq20506()
    			self:close()
       		elseif sender:getName() == "lackBuyNum" then 
       			-- 查看Vip特权
       			DialogManager:getInstance():showDialog("VipDialog")
    			self:close()
   			elseif sender:getName() == "buyStrength" then
   				-- 购买体力
   				ShopSystemCGMessage:BuyStrengthReq21314()
   				self:close()
			elseif sender:getName() == "buyBattle" then
				-- 购买战斗次数
				ShopSystemCGMessage:BuyBattleReq21316 (self._kCopyType,self._nCopyId)
				self:close()
   			end 
        end
	end
	self._pOkBtn:addTouchEventListener(touchEvent)

	self:disposeCSB()

	-- 默认隐藏所有的节点
	self:clearUI()

	if self._kBuyType == 1 then 	-- 表示购买体力
		-- 已经购买体力的次数
		self._nCurBuyNum = self._pRoleInfo.vipInfo.addStrength + 1
		
		-- 允许购买体力的最大次数
		self._nMaxBuyNum = TableVIP[self._pRoleInfo.vipInfo.vipLevel + 1].BuyPowerNum
		-- 花费玉璧数量
		self._nConstDiamondNum = TableConstants["BuyPowerNumCost" ..self._nCurBuyNum].Value
		-- 购买次数
		if self._nCurBuyNum > self._nMaxBuyNum then 
			self:showLackBuyNumInfo()
			return
		end
		-- 玩家的玉璧不足
		if self._nConstDiamondNum > self._nDiamondNum then 
			self:showLackDiamondInfo()
			return
		end
		self:showBuyStrengthInfo()
	elseif self._kBuyType == 2 then		-- 表示购买战斗次数 
		-- 已经购买的次数
		self._nCurBuyNum = self:getBattleBuyNum()
		-- 允许购买的最大次数
		self._nMaxBuyNum = TableVIP[self._pRoleInfo.vipInfo.vipLevel + 1]["BuyCopyTimes" ..self._kCopyType]
		-- 花费玉璧的数量
		self._nConstDiamondNum = TableBuyCopyTimes[self._nCurBuyNum]["CopyType" ..self._kCopyType]
		-- 购买次数
		if self._nCurBuyNum > self._nMaxBuyNum then 
			self:showLackBuyNumInfo()
			return
		end
		-- 玩家的玉璧不足
		if self._nConstDiamondNum > self._nDiamondNum then 
			self:showLackDiamondInfo()
			return
		end
		self:showBuyBattleInfo()
	end
end

-- 显示购买体力的信息
function BuyStrengthDialog:showBuyStrengthInfo(nConstDiamond)
	-- 单位恢复体力的信息
	local strTime = gOneTimeToStr(TableConstants.PowerNumRecoveryCD.Value)
	local strMsg = string.format("%s恢复 %d点",strTime,TableConstants.PowerNumRecovery.Value)
	self._pAutoAddStrengthInfoText:setString(strMsg)
	-- 购买体力的描述信息
	self._pBuyStrengthInfoText:setString(string.format("%d玉璧购买 %d体力？",self._nConstDiamondNum,TableConstants.BuyPowerNum.Value))
	-- 已经购买体力的次数
	self._pBuyStrengthNumText:setString(self._nCurBuyNum - 1  .."/" ..self._nMaxBuyNum)
	self._pOkBtn:setName("buyStrength")
	self._pBuyStrengthNode:setVisible(true)
end

-- 显示购买挑战次数的信息
function BuyStrengthDialog:showBuyBattleInfo()
	-- 消耗的玉璧
	self._pBuyBattleConstDiamondNumText:setString(string.format("%d玉璧购买次数？",self._nConstDiamondNum))
	-- 已经购买的次数
	self._pBuyBatttleNumText:setString(self._nCurBuyNum - 1 .."/" .. self._nMaxBuyNum)
	self._pOkBtn:setName("buyBattle")
	self._pBuyBattleNumNode:setVisible(true)
end

-- 显示购买次数不足信息
function BuyStrengthDialog:showLackBuyNumInfo()
	self._pOkBtn:setName("lackBuyNum")
	self._pOkBtn:setTitleText("查看特权")
	self._pBuyNumText:setString(self._nCurBuyNum - 1 .."/" .. self._nMaxBuyNum)
	self._pLackBuyNumNode:setVisible(true)
end

-- 显示玉璧不足信息
function BuyStrengthDialog:showLackDiamondInfo()
	self._pOkBtn:setName("lackDiamond")
	self._pLackDiamondNode:setVisible(true)
end

-- 界面重置
function BuyStrengthDialog:clearUI()
	self._pBuyStrengthNode:setVisible(false)
	self._pBuyBattleNumNode:setVisible(false)
	self._pLackDiamondNode:setVisible(false)
	self._pLackBuyNumNode:setVisible(false)
end

-- 获取对应副本的购买次数
function BuyStrengthDialog:getBattleBuyNum()
	-- 获取副本的购买记录
	local temp = self._pRoleInfo.vipInfo.addBattles
	for i,pVipAddBattleInfo in ipairs(temp) do
		if self._nCopyId == pVipAddBattleInfo.copyId 
			and self._kCopyType == pVipAddBattleInfo.copyTp then
			return pVipAddBattleInfo.buyCount + 1
		end
	end
    return 1 -- 表示本地没有记录 认为是第一次购买
end

function BuyStrengthDialog:onExitBuyStrengthDialog()
	-- cleanup
	ResPlistManager:getInstance():removeSpriteFrames("BuyPorT.plist")
end

return BuyStrengthDialog