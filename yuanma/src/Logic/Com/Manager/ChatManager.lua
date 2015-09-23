--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChatManager.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   聊天管理器
--===================================================
ChatManager = {}

local instance = nil

-- 单例
function ChatManager:getInstance()
    if not instance then
        instance = ChatManager
        instance:clearCache()
    end
    return instance
end

--[[ 对手信息机构
desRoleInfo = {
{"desRoleId", "uint32"},
{"vipLv", "uint32"},
{"level", "uint32"},
{"roleCareer", "uint16"},
{"name", "string"},
{"timestamp", "uint32"},
}
]]
-- 清空缓存
function ChatManager:clearCache()
    self._bChatOpenView = false
    self._pSelectChatType = kChatType.kAll --当前界面选择的类型
    self._pSelectPrivateRoldId = nil       --私聊频道打开私聊的对方id
    self._tChatNumUnreadInfo ={}                 --记录信息的未读信息条目跟时间戳
    self._tNewMessage = {false,false,false,false,false,false} --{全服,家族,私聊,队伍,组队信息,系统}是否有了新消息
    self._tNewMessageTime = {0,0,0,0,0,0}
    self._tIsSendMessage = {true,true,true,true,true,true} --{全服,家族,私聊,队伍,组队信息,系统}是否能发消息(每个界面走自己的cd)
    self._tTimeCd ={TableConstants.WorldChatCD.Value,TableConstants.FamilyChatCD.Value,TableConstants.PrivateChatCD.Value,TableConstants.TeamChatCD.Value,TableConstants.TeamInvitedCD.Value,0}   --聊天计时
    self._tChatMessage = {}
    self._tChatMessage[kChatType.kAll] = {} --全服
    self._tChatMessage[kChatType.kFamily] = {} --家族
    self._tChatMessage[kChatType.kPrivate] = {} --私聊
    self._tChatMessage[kChatType.kTeam] = {} --队伍
    self._tChatMessage[kChatType.kAddTeam] = {} --组队信息
    self._tChatMessage[kChatType.kSystem] = {} --系统
    self._nChatHistoryMax = TableConstants.ChatHistoryMax.Value
    self._tBlacklist = {}   --黑名单
    
    self._tdesRoleInfo = {}          --对手信息
    self._tAutoPlayVoice = {}        --自动播放语音的数据
    self._tAutoPlayId = {}           --播放的id
    self._tAutoPlayTeamId = {}       --组队的自动播放的语音Id
end 

--添加聊天
function ChatManager:insertChat(chat)
    local pChatlist = chat.chatlist   --聊天内容
    local pTeamlist = chat.teamlist  --组队信息
    local pMaxNum = self._nChatHistoryMax

    for k,v in pairs(pChatlist) do
        local pOneTypeChat = self._tChatMessage[v.chatType]
        self:setDesInfoByChatInfo(v)
        if v.chatType == kChatType.kPrivate then  --私聊需要特殊处理
            if  pOneTypeChat[v.roleId] == nil then
                pOneTypeChat[v.roleId] = {}
            end    
            local pSize = table.getn(pOneTypeChat[v.roleId])
            if pSize >= pMaxNum then
                table.remove(pOneTypeChat[v.roleId],1)
            end
            table.insert(pOneTypeChat[v.roleId],v)
            if self._tChatNumUnreadInfo[v.roleId] == nil then
                self._tChatNumUnreadInfo[v.roleId] = {notOpenNum = 0,finalTime = 0}
            end
            self._tChatNumUnreadInfo[v.roleId].notOpenNum = self._tChatNumUnreadInfo[v.roleId].notOpenNum +1 --基数+1
            if self._tChatNumUnreadInfo[v.roleId].notOpenNum > self._nChatHistoryMax then
                self._tChatNumUnreadInfo[v.roleId].notOpenNum = self._nChatHistoryMax --本地只缓存
            end
    
            self._tChatNumUnreadInfo[v.roleId].finalTime = v.timestamp                                 --时间戳
    
            for kn,vn in pairs(self._tChatNumUnreadInfo)do
            if kn >100 and vn.notOpenNum >0 and v.roleId ~= self._pSelectPrivateRoldId or self._bChatOpenView == false then  --如果当前私聊界面的引用基数有一个大于0或者聊天界面没打开，那么说明有未读消息
                    self._tNewMessage[v.chatType] = true
                    break
                end
            end

        else  --其他界面统一处理
            if self._pSelectChatType ~= v.chatType or self._bChatOpenView == false then --如果当前打开的界面是不是数据增加的界面或者没有打开聊天界面，增加红点
                self._tNewMessage[v.chatType] = true
            else
                self._tNewMessage[v.chatType] = false
            if v.roleId ~= RolesManager:getInstance()._pMainRoleInfo.roleId and v.contentType == kContentType.kVoice then --如果这个不是自己发送的聊天，切是语音类型的聊天需要缓存
                if v.chatType == kChatType.kAll and self._tAutoPlayVoice[1] then  --如果是全服的语音聊天切打开了自动可以插入
                    table.insert(self._tAutoPlayId,StrToLua(v.content)[1])
                elseif  v.chatType == kChatType.kFamily and self._tAutoPlayVoice[2] then  --如果是家族的语音聊天切打开了自动可以插入
                table.insert(self._tAutoPlayId,StrToLua(v.content)[1])
                elseif  v.chatType == kChatType.kTeam and self._tAutoPlayVoice[3] then  --如果是队伍的语音聊天切打开了自动可以插入
                table.insert(self._tAutoPlayId,StrToLua(v.content)[1])
                end
                	
             end
  
            end
            table.insert(pOneTypeChat,v)
            local pSize = table.getn(pOneTypeChat)
            if pSize > pMaxNum then
                table.remove(pOneTypeChat,1)
            end
            
            if self._tChatNumUnreadInfo[v.chatType] == nil then
                self._tChatNumUnreadInfo[v.chatType] = {notOpenNum = 0,finalTime = 0}
            end
            self._tChatNumUnreadInfo[v.chatType].notOpenNum = self._tChatNumUnreadInfo[v.chatType].notOpenNum +1 --基数+1
            if self._tChatNumUnreadInfo[v.chatType].notOpenNum > self._nChatHistoryMax then
                self._tChatNumUnreadInfo[v.chatType].notOpenNum = self._nChatHistoryMax --本地只缓存
            end
            self._tChatNumUnreadInfo[v.chatType].finalTime = v.timestamp

        end
    end
    --有新消息提示了
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kChatResp)
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kChatOutSide,pChatlist) 
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kChatTeamVoice,pChatlist) 
    
end


--主动发送聊天回调
function ChatManager:setSendChatResp(event)

    local pTempchat = {}
    pTempchat.roleId = RolesManager:getInstance()._pMainRoleInfo.roleId
    pTempchat.vipLv = RolesManager:getInstance()._pMainRoleInfo.vipInfo.vipLevel-- vip等级
    pTempchat.level = RolesManager:getInstance()._pMainRoleInfo.level           -- 等级
    pTempchat.roleCareer =RolesManager:getInstance()._pMainRoleInfo.roleCareer  -- 角色职业
    pTempchat.name = RolesManager:getInstance()._pMainRoleInfo.roleName         -- 昵称
    pTempchat.useHorn = event.argsBody.useHorn                                  -- 使用喇叭
    pTempchat.timestamp = event.timestamp                                       -- 发送时间戳
    pTempchat.chatType = event.argsBody.chatType                                -- 聊天频道
    pTempchat.contentType = event.argsBody.contentType                                -- 内容类型
    pTempchat.content = event.content                                           -- 聊天内容

    --设置发送cd --如果是使用了大喇叭，不走cd
    if pTempchat.useHorn == false then
       self:setChatTypeCd( pTempchat.chatType)
    end
   
    if pTempchat.chatType == kChatType.kPrivate then  --私聊需要特殊处理
        local pdesRoleId = event.argsBody.desRoleId
        local pOneTypeChat = self._tChatMessage[kChatType.kPrivate]
        if  pOneTypeChat[pdesRoleId] == nil then
            pOneTypeChat[pdesRoleId] = {}
        end
        local pSize = table.getn(pOneTypeChat[event.argsBody.desRoleId])
        if pSize > self._nChatHistoryMax then
            table.remove(pOneTypeChat[pdesRoleId ],1)
        end
        table.insert(pOneTypeChat[pdesRoleId],pTempchat)

        if self._tChatNumUnreadInfo[pdesRoleId] == nil then
            self._tChatNumUnreadInfo[pdesRoleId] = {notOpenNum = 0,finalTime = 0}
        end
        self._tChatNumUnreadInfo[pdesRoleId].notOpenNum = self._tChatNumUnreadInfo[pdesRoleId].notOpenNum +1 --基数+1
        if self._tChatNumUnreadInfo[pdesRoleId].notOpenNum > self._nChatHistoryMax then
            self._tChatNumUnreadInfo[pdesRoleId].notOpenNum = self._nChatHistoryMax --本地只缓存
        end
        self._tChatNumUnreadInfo[pdesRoleId].finalTime = event.timestamp
    --有新消息提示了
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kChatResp)
    else
        --手动组装一条聊天数据
        self:insertChat({chatlist = {pTempchat} })
    end

end

--根据聊天类型来刷新发送聊天的cd
function ChatManager:setChatTypeCd(pChatType)
    local cdFunctionCallBack = function(time,id)
        self._tNewMessageTime[id-100] = time
        if time == 0 then --如果cd时间为0说明该类型的消息可以发送了
            self._tIsSendMessage[id-100] = true
        end
    end
    self._tIsSendMessage[pChatType] = false
    CDManager:getInstance():insertCD({pChatType+100,self._tTimeCd[pChatType],cdFunctionCallBack})
end

--删除某个聊天频道的信息
function ChatManager:deleteOneChatInfoByType(nType)

    if nType ~= kChatType.kPrivate then 
     self._tChatMessage[nType] = {}
     self._tChatNumUnreadInfo[nType] = nil
     self._tNewMessage[nType] = false
    end
   
    
end

--是否可以发送聊天
function ChatManager:isCanSendMessage(pType)
    local pSelectType = self._pSelectChatType
    if pType then
       pSelectType = self._pSelectChatType
    end
    return self._tIsSendMessage[pSelectType],self._tNewMessageTime[pSelectType]
end


--根据类型返回某个类型的聊天信息
function ChatManager:selectChatMessageByType(nChatType)
    local tempInfo = {}
    local pTypeChatDate = self._tChatMessage[nChatType]
    if nChatType ==  kChatType.kPrivate then --私聊特殊处理
        for k,v in pairs(pTypeChatDate)do
            tempInfo[k] = {}
            local nNotRead = self._tChatNumUnreadInfo[k].notOpenNum
            for i=1,table.getn(v)-nNotRead do
            table.insert(tempInfo[k],v[i])
            end
    	
        end
       
    else
         if self._tChatNumUnreadInfo[nChatType] then
            local nNotRead = self._tChatNumUnreadInfo[nChatType].notOpenNum
            for i=1,table.getn(pTypeChatDate)-nNotRead do
                tempInfo[i] = pTypeChatDate[i]
            end
         end
    end
      
    return tempInfo
end

--设置私聊对手id，帮助界面做消息刷新
function ChatManager:setPrivateChatRoleId(nRoleId)
    self._pSelectPrivateRoldId  = nRoleId
end

--得到你是否有了新消息
function ChatManager:getIsHasNewMessage()
    return  self._tNewMessage
end

--根据类型得到未读数据，私聊就直接传对方id(返回未读条目，时间戳)
function ChatManager:getUnReadNumByType(nType)
    if  self._tChatNumUnreadInfo[nType] then
        return  self._tChatNumUnreadInfo[nType].notOpenNum ,self._tChatNumUnreadInfo[nType].finalTime
    end
    return 0
end

--设置未读数据的数目
function ChatManager:setUnReadNumByType(nType,nNum)
   if nNum < 0 then
      nNum = 0
   end
    self._tChatNumUnreadInfo[nType].notOpenNum = nNum
end


--判断是否有未读消息
function ChatManager:isHasNewMessage()
    for k,v in pairs(self._tNewMessage) do
       if v == true then 
        return true
       end
    end
    return false
end


--根据聊天类型得到未读数据内容
function ChatManager:getUnReadInfoByType(nType,nRoleId)
    if nType == nil then
        return
    end
    local pAddInfo = {}
    local nUnReadNum = 0
    local pRoleAllInfo  = nil
    if nType ==  kChatType.kPrivate then  --私聊需要特殊处理
        if nRoleId == nil then --在聊天的第一目录
           return self._tChatMessage[nType]
         else
            nUnReadNum = self:getUnReadNumByType(nRoleId)
            pRoleAllInfo = self._tChatMessage[nType][nRoleId] 
        end
    else
        nUnReadNum =  self:getUnReadNumByType(nType)
        pRoleAllInfo = self._tChatMessage[nType]

    end
    if pRoleAllInfo and table.getn(pRoleAllInfo) >= nUnReadNum then
        local pSize = table.getn(pRoleAllInfo)
        for i=pSize-nUnReadNum+1,pSize do
            table.insert(pAddInfo,pRoleAllInfo[i])
        end
    end
    return pAddInfo
end

--设置你进入了某个界面
function ChatManager:setSelectChatType(nType,nRoleId)
    self._pSelectChatType = nType
    self._pSelectPrivateRoldId = nRoleId
    if nType ==  kChatType.kPrivate then  --私聊需要特殊处理

        if nRoleId and self._tChatNumUnreadInfo[nRoleId]then  --消息引用基数清空
            self._tChatNumUnreadInfo[nRoleId].notOpenNum = 0
        end

        local pIsNotOpen = false
        for k,v in pairs(self._tChatNumUnreadInfo)do
            if k >100 and v.notOpenNum >0 then  --如果当前私聊界面的引用基数有一个大于0，那么说明有未读消息
                pIsNotOpen = true
                break
            end
        end
        self._tNewMessage[nType] = pIsNotOpen
    else --如果是某个类型界面一旦打开，消息默认已读
        self._tNewMessage[nType] = false
        if self._tChatNumUnreadInfo[nType] then  --消息引用基数清空
            self._tChatNumUnreadInfo[nType].notOpenNum = 0
        end


    end


end

--根据对手的roleInfo设置人物信息
function ChatManager:setDesInfoByRoleInfo(tRoleInfo) 
local pTempInfo = {}
    pTempInfo.desRoleId = tRoleInfo.roleId
    pTempInfo.level = tRoleInfo.level
    pTempInfo.name = tRoleInfo.roleName
    pTempInfo.roleCareer = tRoleInfo.roleCareer
    pTempInfo.roleIcon = kRoleIcons[tRoleInfo.roleCareer]
    pTempInfo.vipLv = 1
    
    self._tdesRoleInfo[tRoleInfo.roleId] = pTempInfo
end

--根据对手的聊天结构设置人物的信息
function ChatManager:setDesInfoByChatInfo(tChatInfo) 
    local pTempInfo = {}
    pTempInfo.desRoleId = tChatInfo.roleId
    pTempInfo.level = tChatInfo.level
    pTempInfo.name = tChatInfo.name
    pTempInfo.roleCareer = tChatInfo.roleCareer
    pTempInfo.roleIcon = kRoleIcons[tChatInfo.roleCareer]
    pTempInfo.vipLv = tChatInfo.vipLv

    self._tdesRoleInfo[tChatInfo.roleId] = pTempInfo
end

--删除个人聊天信息
function ChatManager:deletePrivateInfoById(nRoleId)
   local pChatInfo = self._tChatMessage[kChatType.kPrivate] --私聊
    for k,v in pairs(pChatInfo) do 
        if k == nRoleId then 
            pChatInfo[k] = nil
            self._tChatNumUnreadInfo[k]=nil
           break
        end
    end
    --删除一条私聊信息。刷新提示消息
    self:setSelectChatType(kChatType.kPrivate)
	
end


--把缓存的记录引用基数全部清空
function ChatManager:clearUnreadInfo()
	  for k,v in pairs(self._tChatNumUnreadInfo)do
	     v.notOpenNum = 0
	  end
end

--得到自动播放语音的数据
function ChatManager:initChatAutoPlayVoice()
    self._tAutoPlayVoice = {}
    local pKey = {"autoPlayWoldVoice","autoPlayFamilyVoice","autoPlayTeamVoice"}
    for i=1,table.getn(pKey) do
        local pVoice =  cc.UserDefault:getInstance():getIntegerForKey(pKey[i],1)
      if pVoice == 0 then --标示没有自动播放
         table.insert(self._tAutoPlayVoice,false)
       else
         table.insert(self._tAutoPlayVoice,true)
      end

    end
end

--设置自动播放语音的勾选情况
function ChatManager:setChatAutoPlayVoice(nTag)
    local pKey = {"autoPlayWoldVoice","autoPlayFamilyVoice","autoPlayTeamVoice"}
    self._tAutoPlayVoice[nTag] = not self._tAutoPlayVoice[nTag]
    if self._tAutoPlayVoice[nTag] == true then --自动播放
        cc.UserDefault:getInstance():setIntegerForKey(pKey[nTag],1)
    else
        cc.UserDefault:getInstance():setIntegerForKey(pKey[nTag],0)
    end
    cc.UserDefault:getInstance():flush()
end

function ChatManager:getStringByChatType(nType)
    local tString = {"世界","家族","私聊","队伍","组队信息","系统"}
    return tString[nType]
end