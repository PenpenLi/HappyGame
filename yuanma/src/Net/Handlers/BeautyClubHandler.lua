--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BeautyClubHandler.lua
-- author:    wuquandong
-- created:   2015/02/06
-- descrip:   群芳阁相关网络handler
--===================================================
local BeautyClubHandler = class("BeautyClubHandler")

-- 构造函数
function BeautyClubHandler:ctor()
	-- 打开群芳阁返回的handler
	NetHandlersManager:registHandler(20801, self.handleMsgQueryBeautyInfo20801)
	-- 和美人互动返回的handler
    NetHandlersManager:registHandler(20803,self.handleMsgKissBeauty20803)
	-- 镶嵌美人返回的handler
    NetHandlersManager:registHandler(20805,self.handleMsgBeautyAwake20805)
end

-- 创建函数
function BeautyClubHandler:create()
	local handler = BeautyClubHandler.new()
	return handler
end

-- 获取请求群芳阁
function BeautyClubHandler:handleMsgQueryBeautyInfo20801(msg)
	print("BeautyClubHandler 20801")
	if msg.header.result == 0 then
		local beautyModels = BeautyManager:getInstance()._tBeautyModelList
		local beautyGroupModels = BeautyManager:getInstance()._tBeautyGroupModelList
		for k,v in pairs(msg.body.beautyInfos) do
			local beauytModel = beautyModels[v.id]
			beauytModel.num = v.num
			beauytModel.level = v.level
			beauytModel.expValue = v.expValue
			beauytModel.haveSeen = true
		end
		for k1,v1 in pairs(msg.body.beautyGroups) do
			local beautyGroupModel = beautyGroupModels[v1.id]
			beautyGroupModel.beautyStates = v1.beautyStates
		end
		--local event = {timeDiff = msg.body.timeLeft}		
		-- 互动剩余的时间    
		DialogManager:getInstance():showDialog("BeautyClubDialog",{msg.body.timeLeft,msg.body.countLeft})
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 美人互动
function BeautyClubHandler:handleMsgKissBeauty20803(msg)
	print("BeautyClubHandler 20803")
	if msg.header.result == 0 then
        local beautyModels = BeautyManager:getInstance()._tBeautyModelList
       	local isLevelUpgrade = false
       	-- 更新对应美人的信息 
       	local beauytModel = beautyModels[msg.body.argsBody.id]
       	local previousLevel = beauytModel.level
		beauytModel.num = msg.body.beautyInfo.num
		if beauytModel.level ~= msg.body.beautyInfo.level then
			beauytModel.level = msg.body.beautyInfo.level
			isLevelUpgrade = true
		end
		beauytModel.expValue = msg.body.beautyInfo.expValue
       	-- 更新主角属性信息
        -- 玩家战斗力变化的值 
        if  #msg.body.roleAttr > 0 then
	       local fightResiveValue = msg.body.roleAttr[1].fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
	       if fightResiveValue > 0 then
	           NoticeManager:getInstance():showFightStrengthChange(fightResiveValue)
           end
	       RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg.body.roleAttr[1]
	       RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        end
        -- 参数 
        local event = {timeDiff = msg.body.timeLeft,remainNum = msg.body.countLeft,beautyModel = beauytModel,levelUpgrade = isLevelUpgrade,previousLevel = previousLevel}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kKissBeauty,event)
    else
    	print("返回错误码："..msg.header.result)
	end  		
end

-- 美人唤醒
function BeautyClubHandler:handleMsgBeautyAwake20805(msg)
	print("BeautyClubHandler 20805")
	if msg.header.result == 0 then
      if #msg.body.roleAttr > 0 then
        local fightResiveValue = msg.body.roleAttr[1].fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
            if fightResiveValue > 0 then
                NoticeManager:getInstance():showFightStrengthChange(fightResiveValue)
            end
        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg.body.roleAttr[1]
        RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
      end
      local beautyId = BeautyManager:getInstance()._tBeautyGroupModelList[msg.body.argsBody.groupId].dataInfo.BeautiesID[msg.body.argsBody.index] 
      local beautyNum = BeautyManager:getInstance()._tBeautyModelList[beautyId].num
      BeautyManager:getInstance()._tBeautyModelList[beautyId].num = beautyNum - 1 
      BeautyManager:getInstance()._tBeautyGroupModelList[msg.body.argsBody.groupId].beautyStates[msg.body.argsBody.index] = true
      local event = {groupId = msg.body.argsBody.groupId,index = msg.body.argsBody.index}
      NetRespManager:getInstance():dispatchEvent(kNetCmd.kBeautyAwake,event)
	else
		print("返回错误码："..msg.header.result)
	end	
end

return BeautyClubHandler
