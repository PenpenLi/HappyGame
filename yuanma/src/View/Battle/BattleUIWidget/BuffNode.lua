--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BladeSoulCellDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/18
-- descrip:   buff的Node
--===================================================
local BuffNode = class("BuffNode",function()
    return cc.Node:create()
end)

-- 构造函数
function BuffNode:ctor()
    self._strName = "BuffNode"               -- 层名称
    self._pTouchListener = nil               -- 触摸监听器
    self._tBuffDateArray = {}                --buff数组
    self._tBuffUiArray = {}                  --buff Icon Sprite
    self._bHasBuffChange = false             --是否有buff添加或者删除
    self._tTempChangeDate = {}               --临时的数据
    self._bTempHasBeing = true               --缓存机制是否要执行
end

-- 创建函数
function BuffNode:create()
    local BuffNode = BuffNode.new()
    BuffNode:dispose()
    return BuffNode
end

-- 处理函数
function BuffNode:dispose()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBuffNode()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

--对外接口：添加一个bufffIcon
function BuffNode:addBuffByType(nType)
    local tempAddbuff = {type = 1,date = nType}
    local nSize = #self._tTempChangeDate
    table.insert(self._tTempChangeDate,tempAddbuff)
    if not self._bHasBuffChange and nSize == 0 then --如果是当前缓存里面没有buff且没有在执行 说明的第一次
        self._bHasBuffChange = true
    end
end

--对外接口：删除一个bufffIcon
function BuffNode:removeBuffByType(nType)
    local tempAddbuff = {type = 2,date = nType}
    local nSize = #self._tTempChangeDate
    table.insert( self._tTempChangeDate,tempAddbuff)
    if not self._bHasBuffChange and nSize == 0 then --如果是当前缓存里面没有buff且没有在执行 说明的第一次
        self._bHasBuffChange = true
    end
end

--移除buff
function BuffNode:removeBuff(nType)
    local bBuffHasBeing,nIndex = self:isBuffByType(nType)           --判断这个buff是否存在
    if bBuffHasBeing then                                           --如果要删除的buff在表里面
        local pRemoveIcon = table.remove(self._tBuffUiArray,nIndex)
        local removeActionCallBack = function ()
            pRemoveIcon:removeFromParent(true)
            pRemoveIcon = nil
        end
        pRemoveIcon:runAction(cc.Sequence:create( cc.Spawn:create(cc.EaseIn:create(cc.MoveBy:create(0.15,cc.p(0,10)),6),cc.FadeOut:create(0.15)),cc.CallFunc:create(removeActionCallBack)))
        --pRemoveIcon:runAction(cc.Sequence:create(cc.EaseIn:create(cc.FadeIn:create(0.3),6),cc.CallFunc:create(removeActionCallBack)))
        table.remove(self._tBuffDateArray,nIndex)
        local nSize = 30
        local nLeftAndReightDis = 1
        for i=nIndex,#self._tBuffUiArray do
            local nX = (nSize+nLeftAndReightDis)*(i-1)+nSize/2      --从新算坐标
            if i ~= #self._tBuffUiArray then
                self._tBuffUiArray[i]:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveTo:create(0.2,cc.p(nX,nSize/2)),6)))
            else
                local moveActionCallBack = function()
                    self:deleteTheFirstTempDate()
                end
                self._tBuffUiArray[i]:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveTo:create(0.2,cc.p(nX,nSize/2)),6),cc.CallFunc:create(moveActionCallBack)))
            end
        end
        if nIndex > #self._tBuffUiArray then --说明是删除的最后一个
            local deleteActionCallBack = function()
                self:deleteTheFirstTempDate()
            end
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(deleteActionCallBack)))
        end


    else --如果缓存里面要移除的buff当前队列里面没有
        --print("type Id is "..self._tTempChangeDate[1].date.." ,buff is not found")
        self:deleteTheFirstTempDate()
    end
end

--添加buff
function BuffNode:addBuff(nType)
    local bBuffHasBeing,nIndex = self:isBuffByType(nType) --判断这个buff是否存在
    local nNum = #self._tBuffUiArray
    local nSize = 30                                      --一个Sprite的大小
    local nLeftAndReightDis = 1                           --左右间隔
    if bBuffHasBeing then --如果该buff已经存在了
        local pIcon = self._tBuffUiArray[nIndex]
        pIcon:setLocalZOrder(100)
        local addActiconCallBack = function()
            pIcon:setLocalZOrder(1)
            self:deleteTheFirstTempDate()
        end
        pIcon:runAction(cc.Sequence:create(cc.EaseIn:create(cc.ScaleTo:create(0.1,1.2),6),cc.EaseIn:create(cc.ScaleTo:create(0.05,1),6),cc.CallFunc:create(addActiconCallBack)))
    else --buff不在队列里面需要添加到最后一个
        table.insert(self._tBuffDateArray,nType)
        local pIcon = cc.Sprite:createWithSpriteFrameName("BuffIcons/buffIcon"..nType..".png")
        local nX = (nSize+nLeftAndReightDis)*nNum+nSize/2
        pIcon:setPosition(cc.p(nX-5,nSize/2))
        self:addChild(pIcon)
        table.insert(self._tBuffUiArray,pIcon)
        pIcon:setOpacity(0)
        local addFinActionCallBack = function()
            self:deleteTheFirstTempDate()
        end
        pIcon:runAction(cc.Sequence:create(cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(0.15,cc.p(nX,nSize/2)),6), cc.FadeIn:create(0.15) ),cc.CallFunc:create(addFinActionCallBack)))
    end
end

--判断添加的buff在不在队列里面
function BuffNode:isBuffByType(nType)
    for k, v in pairs(self._tBuffDateArray) do
        if v == nType then
            return true,k
        end
    end
    return false
end

--删除缓存里面的第一项
function BuffNode:deleteTheFirstTempDate()
    table.remove(self._tTempChangeDate,1)
    if #self._tTempChangeDate ~=0 then --如果缓存里面没有数据了
        self._bHasBuffChange = true
    end
end

--终止和清理缓存里面的所有buff
function BuffNode:clearAllTempDate()
    self._bTempHasBeing = false
    self._tTempChangeDate = {}
   
end

--清理所以的buff跟缓存信息
function BuffNode:clearAllBuffAndTempDate()
    self._tTempChangeDate = {}
    for k,v in pairs(self._tBuffUiArray) do
        v:removeFromParent(true)
    end
    self._tBuffUiArray = {}
    self._tBuffDateArray = {}

end


-- 退出函数
function BuffNode:onExitBuffNode()
    print(self._strName.." onExit!")
end

-- 循环更新
function BuffNode:update(dt)
    if self._bTempHasBeing then
        if self._bHasBuffChange then
            self._bHasBuffChange = false
            local pBuff = self._tTempChangeDate[1]
            if pBuff and pBuff.type == 1 then --add
                self:addBuff(pBuff.date)
            else                   --remove
                self:removeBuff(pBuff.date)
            end
        end
    end
end

return BuffNode
