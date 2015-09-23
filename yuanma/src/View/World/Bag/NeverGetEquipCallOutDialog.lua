--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NeverGetEquipCallOut.lua
-- author:    liyuhang
-- created:   2015/7/27
-- descrip:   未获得装备tips 对话框
--===================================================--===================================================
local NeverGetEquipCallOutDialog = class("NeverGetEquipCallOutDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function NeverGetEquipCallOutDialog:ctor()
    self._strName = "NeverGetEquipCallOutDialog"      -- 层名称
    
    self._pItemInfo = nil                     -- 显示物品的信息
    
end

-- 创建函数
function NeverGetEquipCallOutDialog:create(args)
    local dialog = NeverGetEquipCallOutDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function NeverGetEquipCallOutDialog:dispose(args)   
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
            return false
        end
        return true    --可以向下传递事件
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

    -- 加载装备tips合图资源
    ResPlistManager:getInstance():addSpriteFrames("NotAcquiredEquip.plist")
    -- 加载dialog组件
    self._pMainParams = require("NotAcquiredEquipParams"):create()
    self._pCCS = self._pMainParams._pCCS
    self._pBg = self._pMainParams._pEquipTipsBg
    self._pCloseButton = self._pMainParams._pCloseButton
    
    -- 初始化dialog的基础组件
    self:disposeCSB()

    -- 根据物品信息初始化界面  
    self:setDataSource(args)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitNeverGetEquipCallOutDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function NeverGetEquipCallOutDialog:onExitNeverGetEquipCallOutDialog()
    self:onExitDialog()   
    -- 释放掉login合图资源  
    ResPlistManager:getInstance():removeSpriteFrames("NotAcquiredEquip.plist")
    print(self._strName.." onExit!")
end

-- 循环更新
function NeverGetEquipCallOutDialog:update(dt)
    return
end

-- 显示结束时的回调
function NeverGetEquipCallOutDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function NeverGetEquipCallOutDialog:doWhenCloseOver()
    return
end  


-- 初始化界面的数据展示 
function NeverGetEquipCallOutDialog:initUI()
    self._pMainParams._pEquipIcon:loadTexture(self._pItemInfo.templeteInfo.Icon .. ".png",ccui.TextureResType.plistType)
    self._pMainParams._pEqiupNameText:setString(self._pItemInfo.templeteInfo.Name)
    self._pMainParams._pEquipType:setString("类型: "..kEquipPositionTypeTitle[self._pItemInfo.dataInfo.Part])
    self._pMainParams._pEquipLv:setString("等级："..self._pItemInfo.dataInfo.RequiredLevel)
    self._pMainParams._pEquipIconFrame:loadTexture("ccsComRes/qual_"..self._pItemInfo.dataInfo.Quality.."_normal.png",ccui.TextureResType.plistType)
    self._pMainParams._pEffectiveBitmapFont:setString("("..self._pItemInfo.dataInfo.FightingMin .. "-" ..self._pItemInfo.dataInfo.FightingMax..")")
    
    self._pMainParams._pInlayAttributeText:setString("(" .. self._pItemInfo.dataInfo.InlaidHole  .. "个宝石镶嵌孔)") 
    if self._pItemInfo.dataInfo.InlaidHole == 0 then
        self._pMainParams._pInlayAttributeText:setVisible(false)
    end
    self._pMainParams._pAddAttributeText:setString("(额外" .. self._pItemInfo.dataInfo.AddProperty .. "条随机附加属性)") 
    if self._pItemInfo.dataInfo.AddProperty == 0 then
        self._pMainParams._pAddAttributeText:setVisible(false)
    end
    
    self._pMainParams._pAttributeText:setString(kAttributeNameTypeTitle[self._pItemInfo.dataInfo.Main]..": (" .. 
        self._pItemInfo.dataInfo.MainPoint[1] * self._pItemInfo.dataInfo.MainPoint[3] .. "-" ..
        self._pItemInfo.dataInfo.MainPoint[2] * self._pItemInfo.dataInfo.MainPoint[3]..")" )
        
    if self._pMainParams._pAdvanceLvText ~= nil then
    	self._pMainParams._pAdvanceLvText:setVisible(false)
    end
    
end

-- 设置界面显示需要的数据
function NeverGetEquipCallOutDialog:setDataSource(args)
    self._pItemInfo = args[1]
    
    -- 更新界面显示
    self:initUI()
end

return NeverGetEquipCallOutDialog
