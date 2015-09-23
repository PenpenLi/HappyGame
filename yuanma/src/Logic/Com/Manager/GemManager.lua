--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GemManager.lua
-- author:    wuquandong
-- created:   2015/01/07
-- descrip:   宝石管理器
--===================================================
GemManager = {}
local instance = nil 

-- 单例
function GemManager:getInstance()
	if not instance then 
		instance = GemManager
		instance:clearCache()
	end
	return instance
end

-- 清空缓存
function GemManager:clearCache()

end

-- 获得下级宝石的信息({dataInfo,templeteInfo})
function GemManager:getGemDataInfoByGemId(nGemId)
	local gemInfo = {}
	gemInfo.baseType = kItemType.kStone
	for k,v in pairs(TableStones) do
		if v.ID == nGemId then 
			gemInfo.dataInfo = v
			break
		end
	end
	if not gemInfo.dataInfo then 
        return nil 
    end 
	for index,val in pairs(TableTempleteItems) do
		if gemInfo.dataInfo.TempleteID == val.TempleteID then
            gemInfo.templeteInfo = val
			break
		end
	end
	return gemInfo
end

