--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ReviveDialog.lua
-- author:    taoye
-- e-mail:    365667276@qq.com
-- created:   2015/06/17
-- descrip:   战斗复活弹框
--===================================================
local ReviveDialog = class("ReviveDialog",function()
	return require("Dialog"):create()
end)

-- 构造函数
function ReviveDialog:ctor()
    self._strName = "ReviveDialog"               -- 名字
    self._fCounter = 0                           -- 计时器
    self._pTextFreeRevive = nil                  -- 免费复活界面
    self._pTextCostRevive = nil                  -- 花销复活界面
    self._pTextFreeReviveNum = nil               -- 免费复活次数
    self._pTextCostReviveNum = nil               -- 需要花销钻石数量
    self._pSureButton = nil                      -- 立即复活按钮
    self._pLoadingBar = nil                      -- 倒计时进度条
    self._bSkip = false                          -- 是否忽略倒计时

end

-- 创建函数
function ReviveDialog:create()
    local layer = ReviveDialog.new()
	layer:dispose()
	return layer
end

-- 处理函数
function ReviveDialog:dispose()
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetErrorInfo ,handler(self, self.errorInfoNetBack)) -- 注册错误码回调：钻石不足 
    NetRespManager:getInstance():addEventListener(kNetCmd.kReviveResp, handler(self, self.reviveNetBack))
	
	-- 加载ui的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("FightRevived.plist")

	-- 初始化界面相关
	self:initUI()
    
	------------------节点事件------------------------------------
	local function onNodeEvent(event)
	    if event == "exit" then
            self:onExitReviveDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI
function ReviveDialog:initUI()
	-- 加载组件
	local params = require("FightRevivedParams"):create()
	self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pSureButton = params._pSureButton
    self._pLoadingBar = params._pLoadingBar
    self._pTextFreeRevive = params._pNode01
    self._pTextFreeReviveNum = params._pText0102
    self._pTextCostRevive = params._pNode02
    self._pTextCostReviveNum = params._pText0203
	self:disposeCSB()
	
	self._pTextFreeRevive:setVisible(false)
	self._pTextCostRevive:setVisible(false)
	
	-- 复活按钮
    local onSureButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            MessageRevive:sendMessageRevive21014()
            self._bSkip = true
        elseif eventType == ccui.TouchEventType.began then
             AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pSureButton:addTouchEventListener(onSureButton)

    local reviveTimes = self:getRolesManager()._pMainPlayerRole._pRoleInfo.reviveCount
    if reviveTimes < TableConstants.ReviveFreeTimes.Value then
        -- 显示剩余免费次数
        self._pTextFreeRevive:setVisible(true)
        self._pTextFreeReviveNum:setString(TableConstants.ReviveFreeTimes.Value - reviveTimes)
    else
        -- 显示当前复活需要花销钻石数
        self._pTextCostRevive:setVisible(true)
        self._pTextCostReviveNum:setString(TableConstants.ReviveCostFirst.Value + TableConstants.ReviveCostGrowth.Value*(reviveTimes - TableConstants.ReviveFreeTimes.Value))
    end

end

-- 退出函数
function ReviveDialog:onExitReviveDialog()
    self:onExitDialog()
    
    NetRespManager:getInstance():removeEventListenersByHost(self)
    
	-- 释放掉合图资源
    ResPlistManager:getInstance():removeSpriteFrames("FightRevived.plist")

end

-- 循环函数
function ReviveDialog:update(dt)
    -- 倒计时进度条
    if self._bSkip == false then
        self._fCounter = self._fCounter + dt
        self._pLoadingBar:setPercent((TableConstants.ReviveCD.Value - self._fCounter)/TableConstants.ReviveCD.Value*100)
        if self._fCounter >= TableConstants.ReviveCD.Value then
            self:close()
        end
    end

end

-- 钻石不足的网络回调
function ReviveDialog:errorInfoNetBack(event)
    self._bSkip = false
end

-- 成功复活的网络回调
function ReviveDialog:reviveNetBack(event)
    -- 复活成功！
    local role = RolesManager:getInstance()._pMainPlayerRole  
    role:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kAppear, true)
    role:setHp(role:getAttriValueByType(kAttribute.kHp),role:getAttriValueByType(kAttribute.kHp))
    role:addBuffByID(TableConstants.ReviveBuff.Value)  -- 添加一个虚影buff
    self:close()
    -- 复活次数+1
    self:getRolesManager()._pMainPlayerRole._pRoleInfo.reviveCount = self:getRolesManager()._pMainPlayerRole._pRoleInfo.reviveCount + 1
    
end



return ReviveDialog
