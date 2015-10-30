--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetCooperatePanel.lua
-- author:    liyuhang
-- created:   2015/09/25
-- descrip:   战灵go共鸣面板 
--===================================================
local PetCooperatePanel = class("PetCooperatePanel",function()
    return cc.Layer:create()
end)

--构造函数
function PetCooperatePanel:ctor()
    self._strName = "PetCooperatePanel"
    self._pDataInfo = nil
    self._pParams = nil
    
    self._tLocalPetsResonanceWithId = {}
    
    self._pListController = nil
end

--创建函数
function PetCooperatePanel:create(info)
    local layer = PetCooperatePanel.new()
    layer:dispose(info)
    return layer
end

-- 处理函数
function PetCooperatePanel:dispose(info)
    -- 右侧列表的回调函数
    self._pDataInfo = info
    -- 加载图片资源
    ResPlistManager:getInstance():addSpriteFrames("PetGming.plist")
    -- 加载UI组件
    local params = require("PetGmingParams"):create()
    self._pCCS = params._pCCS

    self._pBg = params._pGmingBg
    self:addChild(self._pCCS)
    
    self._pListController = require("ListController"):create(self,params._pScrollView_1,listLayoutType.LayoutType_vertiacl,0,200)
    self._pListController:setVertiaclDis(2)
    self._pListController:setHorizontalDis(3)

    self:updateData()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetCooperatePanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

function PetCooperatePanel:updateData()
    self._tLocalPetsResonanceWithId = {}
    for i=1,table.getn(TablePetsResonance) do
        local localRequirePets = TablePetsResonance[i].RequiredPet
        for j=1,table.getn(localRequirePets) do
            if localRequirePets[j] == self._pDataInfo.id then
                table.insert(self._tLocalPetsResonanceWithId,i)
        	end
        end
    end

    local rowCount = table.getn(self._tLocalPetsResonanceWithId)
    

    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local info = TablePetsResonance[self._tLocalPetsResonanceWithId[index]]

        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("PetCooperateCell"):create(info)
        else
            cell:setInfo(info)
        end
        --cell:setDelegate(delegate)

        return cell
    end

    self._pListController._pNumOfCellDelegateFunc = function ()
        return table.getn(self._tLocalPetsResonanceWithId)
    end

    self._pListController:setDataSource(TablePetsResonance)
end

function PetCooperatePanel:onExitPetCooperatePanel()
    -- 释放宝石合成资源
    ResPlistManager:getInstance():removeSpriteFrames("PetGming.plist")
end

return PetCooperatePanel