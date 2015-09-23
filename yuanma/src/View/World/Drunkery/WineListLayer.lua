--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WineListLayer.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/06/26
-- descrip:   酒品的列表
--===================================================
local WineListLayer = class("WineListLayer",function ()
	 return ccui.ImageView:create()
end)

-- 构造函数
function WineListLayer:ctor()
	self._strName = "WineListLayer"
	self._pTouchListener = nil 
	self._pBg = nil 
	self._pScrollView = nil 
	self._pOkBtn = nil 
	-- 当前选中的酒Id
	self._nSelectedWineId = 0
	-- 是否发生滑动事件
	self._isTouchMoved = false
end

-- 创建函数
function WineListLayer:create()
	local layer = WineListLayer.new()
	layer:dispose()
	return layer
end 

-- 处理函数
function WineListLayer:dispose()
	-- 加载合图资源
	ResPlistManager:getInstance():addSpriteFrames("BearBg.plist")
	ResPlistManager:getInstance():addSpriteFrames("BearOne.plist")
	-- 初始化界面相关
	self:initUI()
	-- 初始化触摸相关
	self:initTouches()
	-- 初始化界面数据
	self:updateUI()
	--------------- 节点事件 ------------------
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitWineListLayer()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	return
end

function WineListLayer:initUI()
	-- 加载组件
	local params = require("BearBgParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pScrollView = params._pScrollView
	self._pOkBtn = params._pButton_1
	self:disposeCSB()
	-- 开始出售按钮事件
	local function touchEvent(sender,eventType) 
		if eventType == ccui.TouchEventType.ended then
			if self._nSelectedWineId <= 0 then
				NoticeManager:getInstance():showSystemMessage("请先选择出售的酒类.")
				return
			end
			local wineInfo = TableWineshop[self._nSelectedWineId]
			if wineInfo.RequiredLv > RolesManager:getInstance()._pMainRoleInfo.level then
				NoticeManager:getInstance():showSystemMessage("角色等级不够.")
				return
			end
			if BeautyManager:getInstance()._tBeautyModelList[wineInfo.BeautiesID].haveSeen == false then
				NoticeManager:getInstance():showSystemMessage("您还没有这个美人.")
				return
			end

			DrunkeryCGMessage:sellWineReq22106(self._nSelectedWineId)
			self:setVisible(false)
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pOkBtn:addTouchEventListener(touchEvent)
end

function WineListLayer:disposeCSB()
	-- 添加节点
	local sNode = self._pCCS:getContentSize()
	local sScreen = mmo.VisibleRect:getVisibleSize()
	self._pCCS:setPosition(sScreen.width/2,sScreen.height/2)
	self:addChild(self._pCCS)
	-- 初始化背景
	local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)
end

-- 刷新界面数据
function WineListLayer:updateUI()

	local innerWidth = 0
	local innerHeight = self._pScrollView:getContentSize().height
	-- 选择需要出售酒的类型
	local function touchEvent(sender,eventType)
	    if eventType == ccui.TouchEventType.moved then
	       self._isTouchMoved = true
		elseif eventType == ccui.TouchEventType.ended then
			self._nSelectedWineId = sender:getTag() - 10000
			-- 清除别的选项的选中状态
			local tWineRenders = self._pScrollView:getChildren()
			for wineRendr_idx,wineRender in ipairs(tWineRenders) do
				local pBgImg = wineRender:getChildByName("BearOneBg")
				if pBgImg == sender then 
					-- 设置背景图为选中状态
					pBgImg:loadTexture("BearOneRes/tytck2.png",ccui.TextureResType.plistType)
				else
					pBgImg:loadTexture("BearOneRes/jlxt6.png",ccui.TextureResType.plistType)
				end

			end
            self._isTouchMoved = false
        elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	for i,wineInfo in ipairs(TableWineshop) do
		local params = require("BearOneParams"):create()
		-- 需要的美人信息
		local beautyInfo = BeautyManager:getInstance()._tBeautyModelList[wineInfo.BeautiesID]
		-- 设置美人的头像
		params._pBeautyIcon:loadTexture(beautyInfo.templeteInfo.Icon.. ".png",ccui.TextureResType.plistType)
		if beautyInfo.haveSeen == false then
			darkNode(params._pBeautyIcon:getVirtualRenderer():getSprite())
		end
		-- 设置酒的图标
		params._pBearIcon:loadTexture(wineInfo.WineIcon..".png",ccui.TextureResType.plistType)
		-- 设置酒的名字
		params._pBearName:setString(wineInfo.Name)
		-- 要求玩家的等级
		params._pLv:setString("Lv:"..wineInfo.RequiredLv)
		-- 设置字体的颜色
		local fontColor = RolesManager:getInstance()._pMainRoleInfo.level < wineInfo.RequiredLv 
			and cRed or cWhite
		params._pLv:setColor(fontColor)
		-- 设置营业收入信息
		-- 经验
		params._pMoney0101:setString(wineInfo.ExpReward[1])
		params._pMoney0102:setString("+"..wineInfo.ExpReward[2].."*顾客" )
		-- 金币(有可能是两个)
		params._pMoney0201:setString(wineInfo.MoneyReward[1][2])
		params._pMoney0202:setString("+"..wineInfo.MoneyReward[1][3].."*顾客")
		-- 用时信息
		params._pTime0102:setString(gTimeToStr(wineInfo.ConsumeTime))
		params._pBearOneBg:setTouchEnabled(true)
		params._pBearOneBg:addTouchEventListener(touchEvent)
        params._pBearOneBg:setSwallowTouches(false)
		params._pBearOneBg:setTag(10000 + wineInfo.ID)
		-- 表示已经预见（拥有过）这个美人
		if beautyInfo.haveSeen == false or RolesManager:getInstance()._pMainRoleInfo.level < wineInfo.RequiredLv then
			-- 背景自灰
			darkNode(params._pBearOneBg:getVirtualRenderer():getSprite())
		end
		params._pCCS:setPosition(cc.p(innerWidth + params._pBearOneBg:getContentSize().width/2,innerHeight/2))
        innerWidth = innerWidth + params._pBearOneBg:getContentSize().width
		self._pScrollView:addChild(params._pCCS)
	end
	if innerWidth < self._pScrollView:getContentSize().width then
		self._pScrollView:setTouchEnabled(false)
		self._pScrollView:setBounceEnabled(false)
	else
		self._pScrollView:setInnerContainerSize(cc.size(innerWidth,innerHeight))
	end
end

-- 初始化触摸相关
function WineListLayer:initTouches()
	-- 触摸注册
    local function onTouchBegin(touch,event)
        return true   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:setVisible(false)
        end
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

-- 退出函数
function WineListLayer:onExitWineListLayer()
	-- 释放plist 合图资源
	ResPlistManager:getInstance():removeSpriteFrames("BearBg.plist")
	ResPlistManager:getInstance():removeSpriteFrames("BearOne.plist")

end

return WineListLayer