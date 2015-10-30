--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RankItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/10/14
-- descrip:   排行榜模板
--===================================================
local RankItemRender = class("RankItemRender",function () 
	return ccui.ImageView:create()
end)

function RankItemRender:ctor()
	self._strName = "RankItemRender"
	-- 挂载节点
	self._pCCS = nil
	-- 背景图片 
	self._pBg = nil 
	-- 排名
	self._pRankText = nil 
	-- 昵称
	self._pNickText = nil 
	-- 等级
	self._pLevelText = nil 
	-- 职业
	self._pCareerText = nil 
	
	----------------------------	
	self._pDataInfo = nil 
	-- 排行榜的类型
	self._nRankType = 0 
	self._fMoveDis = 0                        -- 每次点击emailItem项时的位移
	self._fNormalScale = 1.0                  -- 正常大小尺寸
    self._fBigScale = 1.04                    -- 按下时的放大尺寸
end

function RankItemRender:create()
	local imageView = RankItemRender.new()
	imageView:dispose()
	return imageView
end

function RankItemRender:dispose()
	local params = require("ListPanelParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pListBg
	self._pRankText = params._pText_1
	self._pNickText = params._pText_2
	self._pLevelText = params._pText_3
	self._pCareerText = params._pText_4
	
	self:addChild(self._pCCS)

	local function touchEvent(sender,eventType)	
	 	if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self:toBigScale()
            self._fMoveDis = 0
        elseif eventType == ccui.TouchEventType.moved then
            self._fMoveDis = self._fMoveDis + 1
            if self._fMoveDis >= 5 then
                self:toNormalScale()
            end
        elseif eventType == ccui.TouchEventType.ended then
            if self:getScale() > self._fNormalScale then
                --FriendCGMessage:sendMessageQueryRoleInfoFriend22018(self._pDataInfo.roleId)
                local roleInfo = {roleId = self._pDataInfo.roleId,roleName = self._pDataInfo.name}
                DialogManager:getInstance():showDialog("PlayRoleTipsDialog",{roleInfo})
            end
            self:toNormalScale()
            self._fMoveDis = 0
        end
	end
	self._pBg:setTouchEnabled(true)
    self._pBg:setSwallowTouches(false)
    self._pBg:addTouchEventListener(touchEvent)
	------------------ 节点事件 -----------------------------
	local function onNodeEvent(event)
		if event == "exit" then 
			self:onExitRankItemRender()
		end
	end
	self:registerScriptHandler(onNodeEvent)

end

-- 设置排行榜的数据
function RankItemRender:setData(pDataInfo)
	if not pDataInfo then 
		return
	end
	self._pDataInfo = pDataInfo

	self._pRankText:setString(pDataInfo.rank)
	self._pNickText:setString(pDataInfo.name)
	if self._nRankType == kRankType.kLevle or 
	   self._nRankType == kRankType.kFightPower or
	   self._nRankType == kRankType.kFortune or
	   self._nRankType == kRankType.kAchievement then
		self._pCareerText:setString(kRoleCareerTitle[pDataInfo.roleTp])
	end
	self._pLevelText:setString(pDataInfo.keyWord)
	-- 如果是宠物keyWord 为 宠物id
	if self._nRankType == kRankType.kPet then 
		self._pCareerText:setString(TablePets[pDataInfo.roleTp].Name)
	end
end

-- 设置点击事件
function RankItemRender:initTouches()
	
end

--  退出函数
function RankItemRender:onExitRankItemRender()
	-- cleanup
end

-- 整体到放大尺寸
function RankItemRender:toBigScale()
    self:setScale(self._fBigScale)
end

-- 整体到正常尺寸
function RankItemRender:toNormalScale()
    self:setScale(self._fNormalScale)
end

return RankItemRender