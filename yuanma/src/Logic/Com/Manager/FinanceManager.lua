--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FinanceManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   金融管理器
--===================================================
FinanceManager = {}

local instance = nil

-- 单例
function FinanceManager:getInstance()
    if not instance then
        instance = FinanceManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function FinanceManager:clearCache()
    self._tCurrency = {}                -- 所有货币的集合
end

-- 监控网络自动刷新Finance数据
function FinanceManager:refreshDataNetBack(event)
    for k,v in pairs(event) do
    	self._tCurrency[v.finance] = v.amount
    end
end

-- 根据类型获取数值
function FinanceManager:getValueByFinanceType(type)
    return self._tCurrency[type]
end

-- 根据货币类型获取货币的图标
function FinanceManager:getIconByFinanceType(kFinanceType)
	local tIcos = {}
	-- 设置钻石的图标
	tIcos[kFinance.kDiamond] = {filename = "icon_0002.png",fileBigName = "icon_0002.png",textureType = ccui.TextureResType.plistType}
	-- 设置金币的图标
    tIcos[kFinance.kCoin] = {filename = "icon_0001.png",fileBigName = "icon_0001.png",textureType = ccui.TextureResType.plistType}
    -- 境界点
    tIcos[kFinance.kBP] = {filename = "icon_0003.png",fileBigName = "icon_0003.png",textureType = ccui.TextureResType.plistType}
    -- 斗魂点
    tIcos[kFinance.kSP] = {filename = "icon_0004.png",fileBigName = "icon_0004.png",textureType = ccui.TextureResType.plistType}
    -- 荣誉值
    tIcos[kFinance.kHR] = {filename = "icon_0005.png",fileBigName = "icon_0005.png",textureType = ccui.TextureResType.plistType}
    -- 家族活跃度
    --tIcos[kFinance.kFA] = {filename = "icon_0006.png",fileBigName = "icon_0006.png",textureType = ccui.TextureResType.plistType}
    -- 家族贡献度
    tIcos[kFinance.kFC] = {filename = "icon_0007.png",fileBigName = "icon_0007.png",textureType = ccui.TextureResType.plistType} 
    -- 家族建设值
    tIcos[20] = {filename = "icon_0020.png",fileBigName = "icon_0020.png",textureType = ccui.TextureResType.plistType}
    -- 家族建设值
    tIcos[21] = {filename = "icon_0021.png",fileBigName = "icon_0025.png",textureType = ccui.TextureResType.plistType}
	return tIcos[kFinanceType]
end

-- 根据货币的类型获得货币的名称
function FinanceManager:getFinanceTitleByType(kFinanceType)
	local tTitles = {"玉璧","金币","境界点","斗魂点","荣誉值","家族活跃度","家族贡献度"}
	return tTitles[kFinanceType]
end