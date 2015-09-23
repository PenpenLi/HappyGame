--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BeautyGroupItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/11
-- descrip:   美人组模板
--===================================================
local BeautyGroupItemRender = class("BeautyGroupItemRender",function () 
	return ccui.ImageView:create()
end)

function BeautyGroupItemRender:ctor()
	self._strName = "BeautyGroupItemRender"
	self._pCCS = nil 
	self._pBg = nil
	-- 美人组合
	self._tBeautyItems = {}
	-- 属性组合
	self._tPropertyTextArry = {}
	-- 查看详情	
	self._pDetailBtn = nil
	-- 标题
	self._pTitleText = nil 
	-- 未解锁图标
	self._pUnLockImg = nil 
	--------------------------------------
	self._pBeautyGroupModel = nil
	self._index = 0 
	self._bEffective = true
end

function BeautyGroupItemRender:create()
	local imageView = BeautyGroupItemRender.new()
	imageView:dispose()
	return imageView
end

function BeautyGroupItemRender:dispose()
	local params = require("BeautyArmyListParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pArmyBg
	self._pTitleText = params._pDisecText
	self._pUnLockImg = params._pActivatedImage
	self._pDetailBtn = params._pHelpButton
	self._tBeautyItems = {
		params._pBelleNode01,
		params._pBelleNode02,
		params._pBelleNode03,
		params._pBelleNode04,
		params._pBelleNode05,
	}
	self._tPropertyTextArry = {
        params._pUpText01,
        params._pUpText02,
        params._pUpText03,
	}
	
	self:addChild(self._pCCS)

	-- 显示美人组详细属性tip
	local function showBelleTips(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			DialogManager:getInstance():showDialog("BelleTipsDialog",self._pBeautyGroupModel)

		elseif eventType == ccui.TouchEventType.began then
      	    AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pDetailBtn:addTouchEventListener(showBelleTips)
	self._pDetailBtn:setZoomScale(nButtonZoomScale)
    self._pDetailBtn:setPressedActionEnabled(true)

	------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBeautyGroupItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)	
end

function BeautyGroupItemRender:updateUI()
	local beautyGroupModel = self._pBeautyGroupModel
	-- 角色等级
	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level
	local isReachLevel = roleLevel >= beautyGroupModel.dataInfo.RequiredLevel
	
	-- 激活按钮函数
	local function onClickAwakeBtnEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			-- 向服务器发送信息
			local index = sender:getTag() - 3000
			local groupId = beautyGroupModel.id
			local nRequireCoinNum = beautyGroupModel.dataInfo.RequiredMoney[index]
			local nHasCoinNum = FinanceManager:getInstance()._tCurrency[kFinance.kCoin]
			if beautyGroupModel.beautys[index].haveSeen == false then 
				NoticeManager:getInstance():showSystemMessage("你还没有美人"..beautyGroupModel.beautys[index].templeteInfo.Name.."。")
				return
			end
			if beautyGroupModel.beautys[index].num < 1 then
				NoticeManager:getInstance():showSystemMessage("美人"..beautyGroupModel.beautys[index].templeteInfo.Name.."的数量不足。")
				return
			end
			if nHasCoinNum < nRequireCoinNum then 
				NoticeManager:getInstance():showSystemMessage("金币数量不足。")
				return
			end
			BeautyClubSystemCGMessage:beautyAwakeReq20804(groupId,index)
		elseif eventType == ccui.TouchEventType.began then
       		AudioManager:getInstance():playEffect("ButtonClick")
		end
	end

	local beautyNum = #beautyGroupModel.beautys
	for k1,v1 in pairs(self._tBeautyItems) do
		if k1 <= beautyNum then
	    	local isAwake = false
	    	if beautyGroupModel.beautyStates[k1] ~= nil then
	    		isAwake = beautyGroupModel.beautyStates[k1]
	    	end
	    	-- 美人信息 
	    	local benautyInfo = beautyGroupModel.beautys[k1]
	    	-- 其它控件的挂载节点
	    	local iconBg = v1:getChildByName("BelleIconBg")
	    	-- 美人头像
            iconBg:loadTexture(benautyInfo.templeteInfo.Icon..".png",ccui.TextureResType.plistType)
	    	-- 美人的名字
            iconBg:getChildByName("NameText"):setString(benautyInfo.templeteInfo.Name)
			-- 激活消耗的金币数量
			local nRequireCoinNum = beautyGroupModel.dataInfo.RequiredMoney[k1]
			iconBg:getChildByName("ActivateNum"):setString(nRequireCoinNum)
			local nHasCoinNum = FinanceManager:getInstance()._tCurrency[kFinance.kCoin]
			if nHasCoinNum < nRequireCoinNum then 
				iconBg:getChildByName("ActivateNum"):setColor(cRed)
			end
			-- 激活按钮
			local pAwakeBtn = iconBg:getChildByName("ActivateButton")
			pAwakeBtn:setZoomScale(nButtonZoomScale)
    		pAwakeBtn:setPressedActionEnabled(true)
    		pAwakeBtn:setTag(3000 + k1)

    		local warningSprite = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    		warningSprite:setPosition(85,50)
		    warningSprite:setScale(0.5)
		    warningSprite:setVisible(false)
		    warningSprite:setName("warningSprite") 
		    warningSprite:setAnchorPoint(cc.p(0.5, 0.5))
		    pAwakeBtn:addChild(warningSprite)
    		-- 属性加成标签
    		local pAdationText = iconBg:getChildByName("adationProp")
    		pAdationText:setString("+" ..benautyInfo.dataInfo.Promote[benautyInfo.level + 1] * 100 .."%")
    		if isAwake == true then
    			-- 如果已经激活 
    			pAwakeBtn:setVisible(false)
    			iconBg:getChildByName("ActivateNum"):setVisible(false)
    			iconBg:getChildByName("ActivateMoneyIcon"):setVisible(false)
    			unDarkNode(iconBg:getVirtualRenderer():getSprite())
    			unDarkNode(iconBg:getChildByName("BelleIcon"):getVirtualRenderer():getSprite())
    			pAdationText:setVisible(true)
    		else
    			pAwakeBtn:setVisible(true)
    			pAdationText:setVisible(false)
				pAwakeBtn:addTouchEventListener(onClickAwakeBtnEvent)
    			darkNode(iconBg:getVirtualRenderer():getSprite())
    			darkNode(iconBg:getChildByName("BelleIcon"):getVirtualRenderer():getSprite())
    		end
    		if isReachLevel == false then 
    			pAwakeBtn:setVisible(false)
    			iconBg:getChildByName("ActivateNum"):setVisible(false)
    			iconBg:getChildByName("ActivateMoneyIcon"):setVisible(false)
    		end
    		local bNeedShowWarningSpri = false
    		if beautyGroupModel.beautys[k1].haveSeen == true 
    			and beautyGroupModel.beautys[k1].num >= 1 
    			and nHasCoinNum >= nRequireCoinNum  then 
				bNeedShowWarningSpri = true
			end
			pAwakeBtn:getChildByName("warningSprite"):setVisible(bNeedShowWarningSpri)
    	else
        	v1:setVisible(false)
    	end
    end

    -- 计算亲密度加成属性
 	local upRateNum = 0;
 	for k1,v1 in pairs(beautyGroupModel.beautys) do
  		-- 获得美人相应的属性
  		upRateNum = upRateNum + v1.dataInfo.Promote[v1.level + 1]
  	end
    -- 此处为美人的加成总属性 
    for k,v in pairs(beautyGroupModel.dataInfo.Property) do
  		self._tPropertyTextArry[k]:setString(getStrAttributeRealValue(v[1],v[2] * (1 + upRateNum)))
 	end
 	-- 清除以前的数据
 	local addationPropNum = #beautyGroupModel.dataInfo.Property
 	for i = addationPropNum + 1, #self._tPropertyTextArry do
 		self._tPropertyTextArry[i]:setString("")
 	end
 	-- 标题(解锁等级)
	if isReachLevel == false then
        self._pTitleText:setString("等级"..beautyGroupModel.dataInfo.RequiredLevel.."解锁")
        self._pUnLockImg:setVisible(true)
        -- 加成属性不可见
        for i,v in ipairs(self._tPropertyTextArry) do
        	v:setVisible(false)
        end
    else 
       self._pTitleText:setString(beautyGroupModel.dataInfo.Name)
       self._pUnLockImg:setVisible(false)
    end
    -- 初始化 
     self._bEffective = true 
    -- 判断美人组是否已经全部激活
     for k,v in pairs(beautyGroupModel.beautys) do
        if not beautyGroupModel.beautyStates[k] or beautyGroupModel.beautyStates[k] == false then
          self._bEffective = false
        end
    end 
    self:setEffective(self._bEffective)         
end

function BeautyGroupItemRender:setEffective(bEffective)
    local strBgImg = bEffective == true and "BeautyArmyListRes/tytck2.png" or "BeautyArmyListRes/qfgjm21.png"
	self._pBg:loadTexture(strBgImg,ccui.TextureResType.plistType)
end

function BeautyGroupItemRender:setDataSource(beautyGroupModel)
	self._pBeautyGroupModel = beautyGroupModel
	self:updateUI()
end

function BeautyGroupItemRender:setIndex(index)
	self._index = index
end

function BeautyGroupItemRender:onExitBeautyGroupItemRender()
	-- cleanup 
end

return BeautyGroupItemRender