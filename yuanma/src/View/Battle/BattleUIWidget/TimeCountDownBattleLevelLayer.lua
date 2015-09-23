--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TimeCountDownBattleLevelLayer.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/8/26
-- descrip:   根据时间显示战斗评级的层
--===================================================
local TimeCountDownBattleLevelLayer = class("TimeCountDownBattleLevelLayer",function() 
	return cc.Node:create()
end)

function TimeCountDownBattleLevelLayer:ctor()
	self._strName = "TimeCountDownBattleLevelLayer"
	self._pCCS = nil  
	self._pLevelImg = nil 
	self._pLoadingBar = nil 
	self._pTimeText = nil 
	------------------------------------------------------------------
	self._tLevelImgTexture = {"LevelStarTipsRes/star01.png","LevelStarTipsRes/star02.png","LevelStarTipsRes/star03.png","LevelStarTipsRes/star04.png","LevelStarTipsRes/star05.png"}
	self._tCurStageInfo = StagesManager:getInstance():getCurStageDataInfo()
	self._tBattleLevelText = {"OneStarGrade","TwoStarGrade","ThreeStarGrade","FourStarGrade","FiveStarGrade"}
	
end

function TimeCountDownBattleLevelLayer:create()
	local layer = TimeCountDownBattleLevelLayer.new()
	layer:dispose()
	return layer
end

function TimeCountDownBattleLevelLayer:dispose()
	ResPlistManager:getInstance():addSpriteFrames("LevelStarTips.plist")

	-- 加载组件
	local params = require("LevelStarTipsParams"):create()
	self._pCCS = params._pCCS 
	self._pLevelImg = params._pstart
	self._pLoadingBar = params._pLoadingBarBack
	self._pTimeText = params._pText
	self:addChild(self._pCCS)

	self:initUI()

	-----------------节点事件-------------------------------
	local function onNodeEvent(event)
		if event == "exit" then 
			self:onExitTimeCountDownLayer()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

function TimeCountDownBattleLevelLayer:initUI()
	-- 获取评星为5 时间
	local nRemainSec = self._tCurStageInfo[self._tBattleLevelText[5]]
	self:timeCountDown(nRemainSec)
	self._pLevelImg:loadTexture(self._tLevelImgTexture[5],ccui.TextureResType.plistType)
	self._pLoadingBar:setVisible(false)
end

-- 根据战斗的评级更新评级图片
function TimeCountDownBattleLevelLayer:updateImgByBattleLevel(nBattleLevel)
	self._pLevelImg:loadTexture(self._tLevelImgTexture[nBattleLevel],ccui.TextureResType.plistType)
end

-- 根据剩余的秒数显示时间
function TimeCountDownBattleLevelLayer:timeCountDown(nRemainSecc)
	local minute = mmo.HelpFunc:gGetMinuteStr(nRemainSecc)
    local second = mmo.HelpFunc:gGetSecondStr(nRemainSecc)
	local strMsg = string.format("剩余时间 %s:%s",minute,second)
	self._pTimeText:setString(strMsg)
end

-- 获得5星评级消耗时间
function TimeCountDownBattleLevelLayer:getMaxSecByLevel(nLevel)
	return self._tCurStageInfo[self._tBattleLevelText[nLevel]] 
end

function TimeCountDownBattleLevelLayer:onExitTimeCountDownLayer()
	ResPlistManager:getInstance():removeSpriteFrames("LevelStarTips.plist")
end

return TimeCountDownBattleLevelLayer