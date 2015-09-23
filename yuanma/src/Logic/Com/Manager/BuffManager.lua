--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BuffManager.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   Buff管理器
--===================================================
BuffManager = {}

local instance = nil

-- 单例
function BuffManager:getInstance()
    if not instance then
        instance = BuffManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function BuffManager:clearCache()
self._tBuffInfos = {}
end

--添加
function BuffManager:insertBuff(tBuff)

--添加buff的时候先删除cd里面的所有buff，再从新添加
	self._tBuffInfos = tBuff
	local timeCallBack = function(time,id)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kHomeBuffTime,{time,id})
		if time == 0 then
			self:deleteOneBuffById(id)
		end
	end
	
    for k,v in pairs(self._tBuffInfos) do
        CDManager:getInstance():insertCD({v.id,v.remainTime,timeCallBack})
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kHomeAddBuff,v)
	end
  
end

--删除
function BuffManager:deleteOneBuffById(nId)
    for k,v in pairs(self._tBuffInfos) do
    	if v.id == nId then
            table.remove(self._tBuffInfos,k)
            NetRespManager:getInstance():dispatchEvent(kNetCmd.kHomeRemoveBuff,{nId})
            break
    	end
    end
end

--删除全部buff
function BuffManager:clearAllBuff()
    self._tBuffInfos = {}
end

--判断当前buff是否拥有
function BuffManager:selectBuffIsExistByBuffType(type)
    for k,v in pairs( self._tBuffInfos) do
        if  TableHomeBuff[v.id].ReplaceType == type then 
            return true
        end	
	end
	return false
end

-- 