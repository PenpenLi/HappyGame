--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StrongerDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/09/21
-- descrip:   我要变强的界面
--===================================================
local StrongerDialog = class("StrongerDialog",function ()
	return require("Dialog"):create()
end)

-- 构造函数
function StrongerDialog:ctor()
	self._strName = "StrongerDialog"	-- "名字"
	self._pCCS = nil 
	self._pBg = nil 
	self._pCloseButton = nil 
	self._pFightPowerText = nil 
	self._pScrollView = nil
	self._pListController = nil 
	------------------------------------------
	self._tDataSource = {}
end

function StrongerDialog:create()
	local dialog = StrongerDialog.new()
	dialog:dispose()
	return dialog
end

function StrongerDialog:dispose()
	-- 添加资源纹理
	ResPlistManager:getInstance():addSpriteFrames("PowerUpGuideDialog.plist")
	ResPlistManager:getInstance():addSpriteFrames("GuideNr.plist")

	-- 监听角色升级 
	NetRespManager:getInstance():addEventListener(kNetCmd.kRoleLevelUp, handler(self,self.handleMsgRoleLevelUp29515))

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitStrongerDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	self:initTouches()

	self._tDataSource = self:getDataSource()
	self:initUI()
end

function StrongerDialog:initUI()
	local params = require("PowerUpGuideDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pFightPowerText = params._pPowerFnt
	self._pScrollView = params._pScrollView
	self:disposeCSB()

	self._pListController = require("ListController"):create(self,
		self._pScrollView,listLayoutType.LayoutType_vertiacl,360,100)
	self._pListController:setVertiaclDis(10)
	self._pListController:setHorizontalDis(3)
	-- 获取集合的个数
	self._pListController._pNumOfCellDelegateFunc = function () 
		return #self._tDataSource
	end
	-- 设置集合的render
	self._pListController._pDataSourceDelegateFunc = function (delegate,controller,index)
		local cell = controller:dequeueReusableCell()
		if not cell then 
			cell = require("StrongerItemRender"):create()
			cell:setData(self._tDataSource[index])
		else
			cell:setData(self._tDataSource[index])
		end
		return cell
	end
	self._pListController:setDataSource(self._tDataSource)

end

-- 获取条目信息
function StrongerDialog:getDataSource()
	local temp = {}
	-- 当前玩家的等级
	local nCurLevel =  RolesManager:getInstance()._pMainRoleInfo.level
	for i,pNewFunctionInfo in ipairs(TableNewFunction) do
		-- 角色等级、是否需要isGuid
		if nCurLevel >= pNewFunctionInfo.Level and pNewFunctionInfo.IsGuide == 1 then 
			table.insert(temp,pNewFunctionInfo)
		end
	end
	table.sort( temp, function (a,b) 
		return a.GuideSortNumber < b.GuideSortNumber -- 排序的规则
	end)
	return temp
end

-- 触摸注册
function StrongerDialog:initTouches() 	
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

function StrongerDialog:handleMsgRoleLevelUp29515(event)
	self._tDataSource = self:getDataSource()
	self._pListController:setDataSource(self._tDataSource)
end

function StrongerDialog:onExitStrongerDialog()
	self:onExitDialog()
	NetRespManager:getInstance():removeEventListenersByHost(self)
	-- 删除资源纹理
	ResPlistManager:getInstance():removeSpriteFrames("PowerUpGuideDialog.plist")
	ResPlistManager:getInstance():removeSpriteFrames("GuideNr.plist")
end

return StrongerDialog