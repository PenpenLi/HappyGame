--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BagCommonManager.lua
-- author:    liyuhang
-- created:   2014/12/7
-- descrip:   背包管理器
--===================================================
BagCommonManager = {}

local instance = nil

-- 单例
function BagCommonManager:getInstance()
    if not instance then
        instance = BagCommonManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function BagCommonManager:clearCache()
    --self._bagPanel = nil    -- 背包
    --self._bagPanel = require("BagCommonPanel"):create()
    self._pLastItemArry = {} --  上一次的物品集合
    
    self._pItemArry = {} -- 所有物品的集合
    self._tEquipArry = {} -- 所有装备的集合
    self._tGemArry = {} -- 所有宝石的集合
    self._tPropArry = {} -- 所有道具的集合
    self._nOpenCount = 0 -- 背包开启的格子数
    self._tDataTemple = {
        {itemType = kItemType.kEquip,dataTable = TableEquips,templeTable = TableTempleteEquips },
        {itemType = kItemType.kStone,dataTable = TableStones,templeTable = TableTempleteItems },
        {itemType = kItemType.kBox,dataTable = TableBoxAndCards,templeTable = TableTempleteItems },
        {itemType = kItemType.kFeed,dataTable = TableItems,templeTable = TableTempleteItems },
        {itemType = kItemType.kCounter,dataTable = TableItems,templeTable = TableTempleteItems },
    }
    self._tArrayAllResolveEqu = {}          --可分解装备表的集合
    
    self._beSellOutPosition = -1
    self._bGetInitData = false
    
    -- 新获得物品
    self._tNewGetEquip = {}
    
    -- 可强化装备索引数组
    self._tCanIntensifyEquips = {}
    -- 可镶嵌装备索引数组
    self._tCanInlayEquips = {}
    
    self._tPlayTowerAniId = {}
end

-- 获取背包是否已经获得第一次数据
function BagCommonManager:getInitDataOrNot()
    return self._bGetInitData
end

-- 设置背包某格子都被卖出
function BagCommonManager:setSellOutPosition(pos)
	self._beSellOutPosition = pos
end

-- 获取背包层
function BagCommonManager:getBagPanel()
    --[[
    if not self._bagPanel then
    self._bagPanel = require("BagCommonPanel"):create()
    end

    return self._bagPanel]]
    return require("BagCommonPanel"):create()
end

-- 刷新物品的信息
function BagCommonManager:updateItemArry(tItems)
    if type(tItems) == "table" then
        self._pLastItemArry = self._pItemArry
    
        self._pItemArry = tItems
        
        
        -- 获得物品的数据表数据 获得物品的模板表数据
        self:initData()
        -- 初始化所有标签数据
        self:initTagInfoArry()
        --初始化可分解的装备标签
        self:InitResolveAllEquip()
    end
end

-- 筛选是否有可合成或进化到宠物
function BagCommonManager:checkPets()
    local bigCount = table.getn(TablePets)
    for i = 1,bigCount do
        -- 按照宠物索引 取宠物数据
        local info = nil
        info = PetsManager:getInstance():getPetChipDataWithId(i)

        local chipCount = BagCommonManager:getInstance():getItemNumById(info.data.PieceID)
        local chipNeed = info.data.PieceNum
        if chipCount >= chipNeed and info.step == 0 then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "宠物按钮" , value = true})  
        elseif chipCount >= chipNeed and info.step >= 0 then
            local enough = true
            local MaterialRequiredinfo = info.data["MaterialRequired"..info.step]

            for i=1,3 do
                local info = BagCommonManager:getInstance():getItemRealInfo(200036 - 1 + i,kItemType.kFeed)

                if info.value < MaterialRequiredinfo[i+1][2] then
                    --材料不够
                    enough = false
                end  
            end
            
            if enough == true then
                NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "宠物按钮" , value = true})
            end
        end
    end
end

-- 筛选新增装备
function BagCommonManager:updateNewEquip()
    if  table.getn(self._pItemArry) == 0 then
        self._tNewGetEquip = {}
    	return
    end

	for i=1,table.getn(self._pItemArry) do
        local tempData = self._pItemArry[i]
        local beNew = true
        
        -- 排除原有装备
        if table.getn(tempData.equipment) ~= 0 then
            for j=1,table.getn(self._pLastItemArry) do
                if table.getn(self._pLastItemArry[j].equipment)  ~= 0 then
                    if self._pLastItemArry[j].id == tempData.id and
                        self._pLastItemArry[j].value == tempData.value and 
                        self._pLastItemArry[j].position == tempData.position and 
                        tempData.equipment[1].fightingPower == self._pLastItemArry[j].equipment[1].fightingPower then
                        beNew = false
                    end
                end
            end
        end
        -- 确定战斗力提升
        local nJoin = 0  -- 0:不添加  1:添加  2:替代到相关位置
        if beNew == true and table.getn(tempData.equipment) ~= 0 then
            tempData = GetCompleteItemInfo(tempData)
            
            for i=1,table.getn(self._tNewGetEquip) do
                local existData = self._tNewGetEquip[i]
                
                if tempData.dataInfo.Part == existData.dataInfo.Part and existData.equipment[1].fightingPower < tempData.equipment[1].fightingPower then
                    nJoin = i + 1
                elseif tempData.dataInfo.Part == existData.dataInfo.Part and existData.equipment[1].fightingPower >= tempData.equipment[1].fightingPower then
                    nJoin = -1
                end
            end
            
            if nJoin == 0 then
                local tempInfo = RolesManager:getInstance():selectHasEquipmentByType(tempData.dataInfo.Part)
                if tempInfo ~= nil and tempData.equipment ~= nil then
                    if tempInfo.equipment[1].fightingPower < tempData.equipment[1].fightingPower then
                        nJoin = 1
                    end
                end
                if tempInfo == nil and tempData.equipment ~= nil then
                    nJoin = 1
                end
            end
        end
        
        if nJoin >= 2 then
            if self._tNewGetEquip[nJoin-1] ~= nil then
                self._tNewGetEquip[nJoin-1] = tempData
        	end
        elseif nJoin == 1 then
            table.insert(self._tNewGetEquip , tempData)
        end
    end
    
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kNewEquip,{})
end

-- 设置背包开启的格子数
function BagCommonManager:setOpenCellCount(nOpenCount)
    if nOpenCount > 0 then
        self._nOpenCount = nOpenCount
    end
end

-- 初始化数据
function BagCommonManager:initData()
    for i = 1, #self._pItemArry do
        local item = GetCompleteItemInfo(self._pItemArry[i])
        self._pItemArry[i] = item
    end
end

-- 通过背包位置获取物品信息
function BagCommonManager:getItemInfoByPosition(position)
    if not self._pItemArry then
        return nil
    end

    for k,v in pairs(self._pItemArry) do
        if v.position == position then
            return v
        end
    end

    return nil
end

-- 通过背包的位置获得物品信息0
function BagCommonManager:getItemInfoByIndex(nIndex,bagTabType)
    if not self._pItemArry then
        return
    end
    -- 如果bagType为nil ,设置bagType 的默认值为所有装备
    if not bagTabType then
        bagTabType = BagTabType.BagTabTypeAll
    end
    local tempTable = {}

    if bagTabType == BagTabType.BagTabTypeEquip then
        tempTable = self._tEquipArry
    elseif bagTabType == BagTabType.BagTabTypeStone then
        tempTable = self._tGemArry
    elseif bagTabType == BagTabType.BagTabTypeAll then
        tempTable = self._pItemArry
    else
        tempTable = self._tPropArry
    end
    if bagTabType ~= BagTabType.BagTabTypeAll then
        for k,v in pairs(tempTable) do
            if k == nIndex then
                return v
            end
        end
    else
        for k,v in pairs(tempTable) do
            if v.position == nIndex then
                return v
            end
        end
    end
    return nil
end

-- 初始化标签数据
function BagCommonManager:initTagInfoArry()
    --如果刷新背包表则需要从新复制，不然又2份数据
    self._tEquipArry = {}
    self._tGemArry = {}
    self._tPropArry = {}

    for k,v in pairs(self._pItemArry) do
        if v.baseType == kItemType.kEquip then
            table.insert(self._tEquipArry,v)
        elseif v.baseType == kItemType.kStone then
            local exist = false
            for i=1,table.getn(self._tGemArry) do
                if self._tGemArry[i].id == v.id then
                    self._tGemArry[i].value = v.value + self._tGemArry[i].value
                    exist = true
                end
            end

            if exist == false then
                local temp = {baseType = v.baseType,dataInfo = v.dataInfo , equipment = v.equipment , id = v.id , position = v.position,templeteInfo = v.templeteInfo,value = v.value}
                table.insert(self._tGemArry,temp)
            end
        else
            local exist = false
            for i=1,table.getn(self._tPropArry) do
                if self._tPropArry[i].id == v.id then
                    self._tPropArry[i].value = v.value + self._tPropArry[i].value
                    exist = true
                end
            end

            if exist == false then
                local temp = {baseType = v.baseType,dataInfo = v.dataInfo , equipment = v.equipment , id = v.id , position = v.position,templeteInfo = v.templeteInfo,value = v.value}
                table.insert(self._tPropArry,temp)
            end
        end

    end
    table.sort(self._tEquipArry,function(a,b)
        return a.position < b.position -- 从小到大排序
    end
    )
    table.sort(self._tGemArry,function(a,b)
        return a.position < b.position -- 从小到大排序
    end
    )
    table.sort(self._tPropArry,function(a,b)
        return a.position < b.position -- 从小到大排序
    end
    )
end

-- 获取包内元素个数
function BagCommonManager:getItemCountWithBagTabType(bagTabType)
    if bagTabType == BagTabType.BagTabTypeEquip then
        return table.getn(self._tEquipArry)
    elseif bagTabType == BagTabType.BagTabTypeStone then
        return table.getn(self._tGemArry)
    elseif bagTabType == BagTabType.BagTabTypeAll then
        return table.getn(self._pItemArry)
    else
        return table.getn(self._tPropArry)
    end
end

-- 判断背包是否已经满
function BagCommonManager:isBagItemsEnough()
    if self._bGetInitData == false then
        BagCommonCGMessage:sendMessageGetBagList20100()
        return false
    end

    if not self._pItemArry then
        return false
    end

    if #self._pItemArry > self._nOpenCount then
        return true
    elseif #self._pItemArry <= self._nOpenCount then
        return false
    end
end

--得到所有可以分解的装备列表
function BagCommonManager:InitResolveAllEquip()
    local tAllCanResolveEqu = {}  --所有可分解的装备
    local tWhiteResloveEqu = {}   --白色可以分级的装备
    local tGreenResloveEqu = {}   --绿色可以分解的装备
    local tBlueResolveEqu = {}    --蓝色可分解的装备
    local tPurpleResolveEqu = {}  --紫色分解的装备
    local tOrangeResolveEqu = {}  --橙色可分解的装备
    self._tArrayAllResolveEqu = {}

    tAllCanResolveEqu = self._tEquipArry 
    for k,v in pairs(self._tEquipArry) do
        local nQua = v.dataInfo.Quality
        if nQua == kType.kQuality.kWhite then --如果是大于蓝色的那么就添加到表里
            table.insert(tWhiteResloveEqu,v)
        elseif nQua == kType.kQuality.kGreen then --如果是大于蓝色的那么就添加到表里
            table.insert(tGreenResloveEqu,v)
        elseif nQua == kType.kQuality.kBlue then  --蓝色装备
           table.insert(tBlueResolveEqu,v)
        elseif nQua == kType.kQuality.kPurple then --紫色装备
           table.insert(tPurpleResolveEqu,v)
        elseif nQua == kType.kQuality.kOrange then --橙色装备
           table.insert(tOrangeResolveEqu,v)
        end

    end

    -- 得到的是一个表数组
    self._tArrayAllResolveEqu = {tBlueResolveEqu ,tPurpleResolveEqu ,tOrangeResolveEqu,tAllCanResolveEqu}
end

-- 根据id 获得某个基数类物品的数量 比如宝石，材料
function BagCommonManager:getItemNumById(nItemId)
    local nItemNum = 0
    for index,pItemInfo in pairs(self._pItemArry) do
        if nItemId == pItemInfo.dataInfo.ID then
            nItemNum = pItemInfo.baseType == kItemType.kEquip and pItemInfo.value or nItemNum + pItemInfo.value
        end
    end
    return nItemNum
end

-- 根据物品的id、baseType 获得物品的临时数据 数量叠加
function BagCommonManager:getItemRealInfo(nId,kBaseType)
    local nItemNum = self:getItemNumById(nId)
    -- 如果背包中没有此物品的信息
    local pItemInfo = {id = nId, baseType = kBaseType, value = nItemNum}
    pItemInfo = GetCompleteItemInfo(pItemInfo)
    return pItemInfo
end

--得到身上装备的info
function BagCommonManager:getWearEquInfo()
    local tRoleInfo = RolesManager:getInstance()._pMainRoleInfo.equipemts
    for i=1,table.getn(tRoleInfo) do
        tRoleInfo[i] = GetCompleteItemInfo(tRoleInfo[i])
    end
    return tRoleInfo
end

--根据part获取身上装备是否有更新
function BagCommonManager:getIsWarningEquipByPart(part)
    for i=1,table.getn(self._tCanIntensifyEquips) do
        if self._tCanIntensifyEquips[i] == part then
			return true
		end
	end
	
    for i=1,table.getn(self._tCanInlayEquips) do
        if self._tCanInlayEquips[i] == part then
            return true
        end
    end
    return false
end

-- 得到有宝石孔的装备数据
function BagCommonManager:getHasGemInlaidHoleEquipArry(tEquips)
    local equipArry = {}
    for k,equipInfo in pairs(tEquips) do
        if equipInfo.dataInfo.InlaidHole > 0 then
            table.insert(equipArry,equipInfo)
        end
    end
    return equipArry
end

-- 判断是否有装备可强化
function BagCommonManager:getCanIntensifyWearEquipIndexArry()
local pEquipIndex = {}
 local pCurEquipment = RolesManager:getInstance()._pMainRoleInfo.equipemts
    for k,v in pairs(pCurEquipment) do
    	GetCompleteItemInfo(v)
    end

    for k,v in pairs(pCurEquipment) do
        local pCurValue = v.value --装备强化等级
        if pCurValue < TableConstants.EquipMaxLevel.Value then
           local pNeedMateria =v.dataInfo["MaterialRequire"..pCurValue+1]
           local pCanIntens = true
             for i=1,table.getn(pNeedMateria)do
                local nNeedMateriaId = pNeedMateria[i][1]
                local nNeedMateriaNum = pNeedMateria[i][2]
                local pCurHasNum = self:getItemNumById(nNeedMateriaId)
                if pCurHasNum < nNeedMateriaNum then
                    pCanIntens = false
                	break
                end
              end
            if pCanIntens then
                table.insert(pEquipIndex,k)
            end  
        end 
    end


    return pEquipIndex
end

-- 得到身上可镶嵌的装备
function BagCommonManager:getCanInlayWearEquipIndexArry()
    if #self._tGemArry < 1 then 
        return {}
    end

    local tInlayState = {}
    local tEquips = self:getWearEquInfo()
    for i,equipInfo in ipairs(tEquips) do
        local tInlayGem = equipInfo.equipment[1].stones
        local bCanInlay = false
        if equipInfo.dataInfo.InlaidHole > 0 and equipInfo.dataInfo.InlaidHole > #tInlayGem then
            -- 判断是否还有没镶嵌的类型宝石
            local tHasGemArry = shallowcopy(self._tGemArry)
            local tRemoveTag = {}
            for i1, gemInfo in ipairs(tHasGemArry) do
                for i2,gemId in ipairs(tInlayGem) do
                    if gemInfo.dataInfo.Type == self:getItemRealInfo(gemId,kItemType.kStone).dataInfo.Type then 
                        tHasGemArry[i1] = nil 
                    end
                end
            end
           
            if #tHasGemArry > 0 then 
                for i3,pGemInfo in ipairs(tHasGemArry) do
                    if pGemInfo ~= nil  then
                        -- 判断等级是否满足
                        if pGemInfo.dataInfo.RequiredLevel <= RolesManager:getInstance()._pMainRoleInfo.level then 
                            bCanInlay = true  
                        end
                    end
                end
            else
                bCanInlay = false           
            end
        else
            bCanInlay = false
        end
        if bCanInlay == true then 
            table.insert(tInlayState,i)
        end
    end
    return tInlayState
end

-- 判断是否有宝石可合成
function BagCommonManager:isCanGemSynthesis()
    for k,pGemInfo in pairs(self._tGemArry) do
       -- 获得下级宝石的信息
        local nextLevelGemInfo = GemManager:getInstance():getGemDataInfoByGemId(pGemInfo.dataInfo.MixResult)
        -- 判断是否达到最大级 
        if nextLevelGemInfo ~= nil and nextLevelGemInfo.dataInfo.RequiredLevel <= RolesManager:getInstance()._pMainRoleInfo.level and  pGemInfo.value >= TableConstants.GemMixRequire.Value  then 
           return true
        end
    end
    return false    
end


--得到可炼化的的数据
function BagCommonManager:getBladeSoulItemInfo()
    local tBladeSoulItem = {}
    local tEquipItem = {}
    local tSoulItem = {}
    for k,v in pairs(self._tEquipArry) do
        local nQua = v.dataInfo.Quality
        if nQua < kType.kQuality.kBlue then --如果是小于藍色的那么就添加到表
            table.insert(tBladeSoulItem,v)
            table.insert(tEquipItem,v)
        end
    end

    for k,v in pairs(self._tPropArry) do
        if self._tPropArry[k].dataInfo.UseType == kItemUseType.kBladeSoul  then
            table.insert(tBladeSoulItem,v)
            table.insert(tSoulItem,v)
        end
    end

    return tBladeSoulItem,tEquipItem,tSoulItem
end

--得到装备碎片和图谱
function BagCommonManager:getFoundryItemInfo()
    local tEqiupPiecesItem = {}
    local tEquipTreeItem = {}
    for k,v in pairs(self._tPropArry) do
        if self._tPropArry[k].dataInfo.UseType == kItemUseType.kEquipPieces then
            table.insert(tEqiupPiecesItem,self._tPropArry[k])
        elseif self._tPropArry[k].dataInfo.UseType == kItemUseType.kEquipTree then
             table.insert(tEquipTreeItem,self._tPropArry[k])
         end
   end
    return joinWithTables(tEqiupPiecesItem,tEquipTreeItem)
end

function BagCommonManager:insertPlayBossId(nChaper)
    for k,v in pairs(self._tPlayTowerAniId) do
        if nChaper == v  then --这个特效已经播放一次了
            return 
        end
    end
 table.insert(self._tPlayTowerAniId,nChaper)
end

--重置这个play章节id
function BagCommonManager:resetPlayBossId(nChaper)
    for k,v in pairs(self._tPlayTowerAniId) do
        if nChaper == v  then --这个特效已经播放一次了
            table.remove(self._tPlayTowerAniId,nChaper)
            return 
        end
    end
end