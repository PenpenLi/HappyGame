--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SturaLibraryHandler.lua
-- author:    wuqd
-- created:   2015/09/15
-- descrip:   藏经阁handler
--===================================================
local SturaLibraryHandler = class("SturaLibraryHandler")

-- 构造函数
function SturaLibraryHandler:ctor()
	-- 获取藏经阁信息回复
	NetHandlersManager:registHandler(22401,self.handleMsgQuerySturaLibraryInfoResp)
	-- 注入残页的回复
	NetHandlersManager:registHandler(22403,self.handleMsgInsertPageResp)
end

-- 创建函数
function SturaLibraryHandler:create()
	print("SturaLibraryHandler create")
	local handler = SturaLibraryHandler.new()
	return handler
end

-- 获取藏经阁信息
function SturaLibraryHandler:handleMsgQuerySturaLibraryInfoResp(msg)
	print("SturaLibraryHandler 22401")
	if msg.header.result == 0 then 
		-- 获取佛经卷轴信息
		local sturaBookList = msg.body.bibleList
		-- 更新本地的佛经信息
		SturaLibraryManager:getInstance():getLocalSturaPages()
		SturaLibraryManager:getInstance():updateSturaBookInfo(sturaBookList)
		-- 显示藏经阁的界面
		DialogManager:getInstance():showDialog("SutraLibraryDialog")
	else
		print("返回错误码：" ..msg.header.result)
	end
end

-- 注入经书残页的回复
function SturaLibraryHandler:handleMsgInsertPageResp(msg)
	print("SturaLibraryHandler 22403")
	if msg.header.result == 0 then
		SturaLibraryManager:getInstance():getLocalSturaPages()
		local id = msg.body.argsBody.bookId
		local index = msg.body.argsBody.pageIndex + 1
		local pBookInfo = SturaLibraryManager:getInstance():getLocalSturaBookInfoById(id)
		if pBookInfo ~= nil then 
			pBookInfo.pages[index] = pBookInfo.pages[index] + 1
		end
		local event = 
		{
			bookId = id,
			pageIndex = index
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kSturaInsertPageResp,event)
	else
		print("返回错误码：" ..msg.header.result)
	end
end

return SturaLibraryHandler