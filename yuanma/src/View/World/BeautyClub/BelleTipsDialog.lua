--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BelleTipsDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2014/12/22
-- descrip:   美人组的提示信息
--===================================================
local BelleTipsDialog = class("BelleTipsDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BelleTipsDialog:ctor()
    self._strName = "BelleTipsDialog"        -- 层名称
    self._pTitleName = nil   -- 标题名字
    self._tPropNodeArry = {} -- 属性集合
    self._tAddPercentNodeArry = {} -- 加成百分比集合
end

-- 创建函数
function BelleTipsDialog:create(args)
    local dialog = BelleTipsDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function BelleTipsDialog:dispose(args)  

    -- 加载装备tips合图资源
    ResPlistManager:getInstance():addSpriteFrames("BelleTips.plist")
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return false   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end ".."x="..location.x.."  y="..location.y)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    -- 加载dialog组件
    local params = require("BelleTipsParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pTipsBg
    self._pCloseButton = params._pCloseButton
    self._pTitleName = params._pName    
    self._tPropNodeArry = {
        params._pPropNode1,
        params._pPropNode2,
        params._pPropNode3,
    }
    self._tAddPercentNodeArry = {
        params._pAddPercentNode1,
        params._pAddPercentNode2,
        params._pAddPercentNode3,
        params._pAddPercentNode4,
        params._pAddPercentNode5,
        params._pAddPercentNode6,
    }
   
    -- 初始化dialog的基础组件
    self:disposeCSB()

    -- 根据物品信息初始化界面  
    self:setDataSource(args)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBelleTipsDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end


function BelleTipsDialog:setDataSource(args)
    local beautyGroupInfo = args
     -- 计算亲密度加成属性
    local upRateNum = 0;
    for k1,v1 in pairs(beautyGroupInfo.beautys) do
        -- 获得美人相应的属性
        upRateNum = upRateNum + v1.dataInfo.Promote[v1.level + 1]
    end
    -- 设置美人组的名字
    self._pTitleName:setString(beautyGroupInfo.dataInfo.Name)
    -- 设置属性信息
    for i,propNode in ipairs(self._tPropNodeArry) do
       local propInfo = beautyGroupInfo.dataInfo.Property[i]
       if propInfo ~= nil then
           local propName = kAttributeNameTypeTitle[propInfo[1]]
           local originalValue = getStrNoTitleAttributeValue(propInfo[1],propInfo[2])
           local upAttrValue = getStrNoTitleAttributeValue(propInfo[1],propInfo[2] * upRateNum)
           propNode:getChildByName("propName"):setString(propName)
           propNode:getChildByName("originalValue"):setString(originalValue)
           propNode:getChildByName("addationValue"):setString("(".. upAttrValue..")")
       else
           propNode:setVisible(false)
       end
    end
    -- 设置各位美人的加成百分比
    for i,addPercentNode in ipairs(self._tAddPercentNodeArry) do
        local beautyInfo = beautyGroupInfo.beautys[i]
        if beautyInfo ~= nil then
            addPercentNode:getChildByName("titleText"):setString(beautyInfo.templeteInfo.Name)
            addPercentNode:getChildByName("valueText"):setString(beautyInfo.dataInfo.Promote[beautyInfo.level + 1] * 100 .."%")
        else
            addPercentNode:setVisible(false) 
        end
        if i == 6 then 
            addPercentNode:getChildByName("titleText"):setString("总加成")
            addPercentNode:getChildByName("valueText"):setString(upRateNum * 100 .."%")
            addPercentNode:setVisible(true)
        end
    end
end

-- 退出函数
function BelleTipsDialog:onExitBelleTipsDialog()
    self:onExitDialog()
    print(self._strName.." onExit!")
    ResPlistManager:getInstance():removeSpriteFrames("BelleTips.plist")
end

return BelleTipsDialog
