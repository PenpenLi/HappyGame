--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FightPowerUpTip.lua
-- author:    wuqd
-- created:   2015/09/14
-- descrip:   等级提升后战斗力超过全服玩家
--===================================================
local FightPowerUpTip = class("FightPowerUpTip",function()
	return require("Layer"):create()
end)

function FightPowerUpTip:ctor()
	self._strName = "FightPowerUpTip"
	self._pCCS = nil 
	self._pBg = nil 
	self._pPercentFntText = nil 
	------------------------------------
	-- 战斗力在全服的百分比
	self._pPrevFightPercentInServer = 10
	self._nCurFightPercentInServer = 10
end

function FightPowerUpTip:create(nPrevPercent,nCurPercent)
	local imageView = FightPowerUpTip.new()
	imageView:dispose(nPrevPercent,nCurPercent)
	return imageView
end

function FightPowerUpTip:dispose(nPrevPercent,nCurPercent)
	-- 加载合图
	ResPlistManager:getInstance():addSpriteFrames("PowerUp.plist")

	self._pPrevFightPercentInServer = nPrevPercent
	self._nCurFightPercentInServer = nCurPercent

	self:initUI()
	--------------节点事件------------------------
	local function onNodeEvent(event)
		if event == "exit" then 
			self:onEixtFightPowerUpTip()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

function FightPowerUpTip:initUI()
	-- 加载组件
	local params = require("PowerUpParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pTiShiBg
	self._pPercentFntText = params._pPowerUpFnts 
	self:disposeCSB()

	--self._pPercentFntText:setString(self._pPrevFightPercentInServer.."%")

    local function showCurPercent()
    	self._pPercentFntText:setString(self._nCurFightPercentInServer.."%")
    end

    local function showOver()
    	self:close()
    end

    --local seq = cc.Sequence:create(cc.DelayTime:create(0.5),cc.EaseOut:create(cc.FadeOut:create(0.3),1), cc.CallFunc:create(showCurPercent),cc.EaseIn:create(cc.FadeIn:create(0.3),3),cc.DelayTime:create(2),cc.CallFunc:create(showOver))
    local seq = cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(showOver))
    self._pPercentFntText:runAction(seq)
end

function FightPowerUpTip:disposeCSB()
	-- 添加节点
	local sScreen = mmo.VisibleRect:getVisibleSize()
    self._pCCS:setPosition(sScreen.width/2, sScreen.height/2)
    self:addChild(self._pCCS)
end

function FightPowerUpTip:onEixtFightPowerUpTip()
	-- cleanup
	ResPlistManager:getInstance():removeSpriteFrames("PowerUp.plist")
end

return FightPowerUpTip