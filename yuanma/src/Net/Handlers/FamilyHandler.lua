--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyHandler.lua
-- author:    wuqd
-- created:   2015/07/09
-- descrip:   家族handler
--===================================================
local FamilyHandler = class("FamilyHandler")

-- 构造函数
function FamilyHandler:ctor()
	-- 进入家族回复
    NetHandlersManager:registHandler(22303, self.handleMsgEnteryFamily)
    -- 获取家族排行榜回复
    NetHandlersManager:registHandler(22301,self.handleMsgQueryFamilyList)
    -- 查找家族回复
    NetHandlersManager:registHandler(22305,self.handleMsgQueryFamily)
    -- 创建家族回复
    NetHandlersManager:registHandler(22307,self.handleMsgCreateFamily)
    -- 申请家族回复
    NetHandlersManager:registHandler(22309,self.handleMsgApplyFamily)
    -- 修改家族名字回复
    NetHandlersManager:registHandler(22311,self.handleMsgChangeFamilyName)
    -- 修改家族宗旨
    NetHandlersManager:registHandler(22313,self.handleMsgChangeFamilyPurpose)
    -- 家族捐献
    NetHandlersManager:registHandler(22315,self.handleMsgDonateFamily)
    -- 家族升级
    NetHandlersManager:registHandler(22317,self.handleMsgUpgradeFamily)
    -- 获取申请者
    NetHandlersManager:registHandler(22319,self.handleMsgQueryFamilyApplys)
    --批复申请回复
    NetHandlersManager:registHandler(22321,self.handleMsgReplyFamilyApply)
    --获取成员列表回复
    NetHandlersManager:registHandler(22323,self.handleMsgQueryFamilyMembers)
    --任命回复
    NetHandlersManager:registHandler(22325,self.handleMsgFamilyAppoint)
    --开除成员回复
    NetHandlersManager:registHandler(22327,self.handleMsgDismissFamilyMember)
    --退出家族回复
    NetHandlersManager:registHandler(22329,self.handleMsgQuitFamily)
    --获取公会动态回复
    NetHandlersManager:registHandler(22331,self.handleMsgQueryFamilyNews)
    --获取研究院信息回复
    NetHandlersManager:registHandler(22333,self.handleMsgQueryFamilyAcademy)
    --升级研究院回复
    NetHandlersManager:registHandler(22335,self.handleMsgUpgradeFamilyAcademy)
    --激活研究院科技回复
    NetHandlersManager:registHandler(22337,self.handleMsgActivateFamilyTech)
    --升级研究院科技回复
    NetHandlersManager:registHandler(22339,self.handleMsgUpgradeFamilyTech)
    --服务器主动推送（是否有家族）
    NetHandlersManager:registHandler(29521,self.handleMsgFamilyOwnNotice)
    --查找家族回复
    NetHandlersManager:registHandler(22341,self.handleMsgFindFamilyById)
end

-- 创建函数
function FamilyHandler:create()
	local handler = FamilyHandler.new()
	return handler
end

-- 获取家族排行榜回复
function FamilyHandler:handleMsgQueryFamilyList(msg)
	print("FamilyHandler 22301")
    	if msg.header.result == 0 then 
		local event = 
		{
			familyCount = msg.body.familyCount,
			familyList = msg.body.familyList,
			applyInfo = msg.body.applyInfo,
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryFamilyListResp,event)	
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 进入家族回复
function FamilyHandler:handleMsgEnteryFamily(msg)
	print("FamilyHandler 22303")
	if msg.header.result == 0 then 
		FamilyManager:getInstance()._position = msg.body.position
		if #msg.body.familyInfo > 0 then --标示有家族
            FamilyManager:getInstance()._bOwnFamily = true
            FamilyManager:getInstance()._pFamilyInfo = msg.body.familyInfo[1]
            FamilyManager:getInstance()._nDonateCount = msg.body.donateCount
		else
			-- 表示尚未加入家族
            FamilyManager:getInstance()._bOwnFamily = false
            ChatManager:getInstance():deleteOneChatInfoByType(kChatType.kFamily)
		end
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kEnteryFamilyResp)	
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 查找家族回复
function FamilyHandler:handleMsgQueryFamily(msg)
	print("FamilyHandler 22305")
	if msg.header.result == 0 then 
		if #msg.body.familyInfo > 0 then 
			local event = msg.body
            NetRespManager:getInstance():dispatchEvent(kNetCmd.kFindFamilyResp,event)
		else
			NoticeManager:getInstance():showSystemMessage("不存在此家族")
            NetRespManager:getInstance():dispatchEvent(kNetCmd.kFindFamilyResp,"failed")
		end
	else
		print("返回错误码:"..msg.header.result)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kFindFamilyResp,"failed")
	end
end

-- 创建家族回复
function FamilyHandler:handleMsgCreateFamily(msg)
	print("FamilyHandler 22307")
	if msg.header.result == 0 then 
        DialogManager:getInstance():closeDialogByName("FamilyCreateDialog")
        DialogManager:getInstance():closeDialogByName("FamilyRegisterDialog")
        FamilyManager:getInstance()._pFamilyInfo = msg.body.familyInfo
        FamilyManager:getInstance()._bOwnFamily = true
        FamilyManager:getInstance()._position = kFamilyPosition.kLeader
        DialogManager:getInstance():showDialog("FamilyDialog")
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kCreateFamilyResp)
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 申请家族回复
function FamilyHandler:handleMsgApplyFamily(msg)
	print("FamilyHandler 22309")
	if msg.header.result == 0 then 
		local event = {
			familyId = msg.body.argsBody.familyId
		}
        NoticeManager:getInstance():showSystemMessage("家族申请成功。")
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kApplyFamilyResp,event)
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 修改家族名字回复
function FamilyHandler:handleMsgChangeFamilyName(msg)
	print("FamilyHandler 22311")
	if msg.header.result == 0 then 
		local event = {
			strName = msg.body.argsBody.newName 
		}
        FamilyManager:getInstance()._pFamilyInfo.familyName = event.strName
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kChangeFamilyNameResp,event)
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 修改家族宗旨回复
function FamilyHandler:handleMsgChangeFamilyPurpose(msg)
	print("FamilyHandler 22313")
	if msg.header.result == 0 then 
		local event = {
			strPurpose = msg.body.argsBody.newPurpose 
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kChangeFamilyPurposeResp,event)
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 家族捐献
function FamilyHandler:handleMsgDonateFamily(msg)
	print("FamilyHandler 22315")
	if msg.header.result == 0 then 
		local event = msg["body"]
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kDonateFamilyResp,event)
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 家族升级回复
function FamilyHandler:handleMsgUpgradeFamily(msg)
	print("FamilyHandler 22317")
	if msg.header.result == 0 then 
	local event = msg["body"]
        FamilyManager:getInstance()._pFamilyInfo = event.familyInfo 
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpgradeFamilyResp,event.familyInfo)
	else
		print("返回错误码:"..msg.header.result)
	end
end

-- 获取家族申请者回复
function FamilyHandler:handleMsgQueryFamilyApplys(msg)
	print("FamilyHandler 22319")
	if msg.header.result == 0 then 
		local event = {
			applyList = msg.body.applyList 
		}
        table.sort(event.applyList, function(a,b) 
            return a.applyTime > b.applyTime
        end)
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryFamilyApplysResp,event)
		-- 创建成功跑马灯
	else
		print("返回错误码:"..msg.header.result)
	end
end

--批复申请回复
function FamilyHandler:handleMsgReplyFamilyApply(msg)
    print("FamilyHandler 22321")
    if msg.header.result == 0 then 
        
    else
        print("返回错误码:"..msg.header.result)
    end
    local event = {
        roleId = msg.body.argsBody.roleId,
        isAuto = msg.body.argsBody.isAuto,
    }
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kReplyFamilyApplyResp,event)
end

--获取成员列表回复
function FamilyHandler:handleMsgQueryFamilyMembers(msg)
    print("FamilyHandler 22323")
    if msg.header.result == 0 then 
        local members = msg.body.members
        table.sort( members, function (a,b)  
            -- 在线时间 > 战斗力 > 等级 > 贡献度
            local r = a.offlineTime < b.offlineTime
            if a.offlineTime == b.offlineTime then
                r = a.fightingPower > b.fightingPower 
                if a.fightingPower == b.fightingPower then 
                    r = a.level > b.level 
                    if a.level == b.level then 
                        r = a.weekScore > b.weekScore 
                    end
                end
            end
            return r
        end)
        local event = {
            members = members
        }
        FamilyManager:getInstance()._tMembers = members
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryFamilyMemberResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end


--任命回复
function FamilyHandler:handleMsgFamilyAppoint(msg)
    print("FamilyHandler 22325")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kFamilyAppointResp,event)
        NoticeManager:getInstance():showSystemMessage("职位任命成功")
    else
        print("返回错误码:"..msg.header.result)
    end
end


--开除成员回复
function FamilyHandler:handleMsgDismissFamilyMember(msg)
    print("FamilyHandler 22327")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kDismissFamilyMemberResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end

--退出家族回复
function FamilyHandler:handleMsgQuitFamily(msg)
    print("FamilyHandler 22329")
    if msg.header.result == 0 then 
        -- 重置一下本地家族缓存数据
        FamilyManager:getInstance():clearCache()
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQuitFamilyResp,event)
        ChatManager:getInstance():deleteOneChatInfoByType(kChatType.kFamily)
    else
        print("返回错误码:"..msg.header.result)
    end
end

--获取公会动态回复
function FamilyHandler:handleMsgQueryFamilyNews(msg)
    print("FamilyHandler 22331")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryFamilyNewsResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end


--获取研究院信息回复
function FamilyHandler:handleMsgQueryFamilyAcademy(msg)
    print("FamilyHandler 22333")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryFamilyAcademyResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end

--升级研究院回复
function FamilyHandler:handleMsgUpgradeFamilyAcademy(msg)
    print("FamilyHandler 22335")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpgradeFamilyAcademyResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end
--激活研究院科技回复
function FamilyHandler:handleMsgActivateFamilyTech(msg)
    print("FamilyHandler 22337")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kActivateFamilyTechResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end
--升级研究院科技回复
function FamilyHandler:handleMsgUpgradeFamilyTech(msg)
    print("FamilyHandler 22337")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpgradeFamilyTechResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end

--服务器主动推送（是否有家族）
function FamilyHandler:handleMsgFamilyOwnNotice(msg)
  print("FamilyHandler 29521")
    if msg.header.result == 0 then 
        local event = msg["body"]
        FamilyCGMessage:entryFamilyReq22302()
    else
        print("返回错误码:"..msg.header.result)
    end
end

--查找家族回复
function FamilyHandler:handleMsgFindFamilyById(msg)
    print("FamilyHandler 22341")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kFindFamilyByIdResp,event)
    else
        print("返回错误码:"..msg.header.result)
    end
end

return FamilyHandler