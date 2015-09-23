--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ServerListPanel.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/23
-- descrip:   服务器选择列表
--===================================================
local ServerListPanel = class("ServerListPanel",function()
    return cc.Node:create()
end)

-- 构造函数
function ServerListPanel:ctor()
    self._strName = "ServerListPanel"        -- 层名称
    self._pServerScrollView = nil            -- 服务器列表信息scrollview
    self._tServerButtons = {}                -- 所有服务器按钮的集合
end

-- 创建函数
function ServerListPanel:create()
    local panel = ServerListPanel.new()
    panel:dispose()
    return panel
end

-- 处理函数
function ServerListPanel:dispose()

    -- 加载组件
    local params = require("SeverSlectPanelParams"):create()
    self._pServerScrollView = params._pServerScrollView
    self:addChild(params._pCCS)
    
    -- 服务器所有按钮的回调函数
    local clickServerButtonCallBack = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            for k,v in pairs(self._tServerButtons) do
                if v == sender then
                    -- 获取相关服务器info
                    local info = LoginManager:getInstance()._tServerList[k]
                    LoginManager:getInstance():setCurServerInfo(info)
                    -- 刷新界面info
                    self:getParent():refreshServerInfo()
                    -- 关闭服务器列表界面
                    self:getParent():closeServerList()
                end
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    -- 设置scrollview的滚动尺寸    
    self._pServerScrollView:setInnerContainerSize(cc.size(self._pServerScrollView:getInnerContainerSize().width,30+(table.getn(LoginManager:getInstance()._tServerList)+1)/3*98))
    local scrollViewDisplaySize = self._pServerScrollView:getContentSize()                -- 滚动容器显示尺寸
    local scrollViewInnerSize = self._pServerScrollView:getInnerContainerSize()           -- 滚动容器内部滚动尺寸  
    for k,v in pairs(LoginManager:getInstance()._tServerList) do
        local col = (k-1)%3
        local row = math.modf((k-1)/3)
        -- 创建button
        local pItemButton = ccui.Button:create("ServerItemsRes/dljm_normal_btn.png","ServerItemsRes/dljm_press_btn.png","ServerItemsRes/dljm_press_btn.png",ccui.TextureResType.plistType)
        local sizeItemButton = pItemButton:getContentSize()
        pItemButton:setTitleText(v.zoneName)
        pItemButton:setTitleFontSize(25)
        --pItemButton:getTitleRenderer():enableShadow()
        pItemButton:setPosition(sizeItemButton.width*0.8 + col*sizeItemButton.width*1.3, scrollViewInnerSize.height - 47 - row*(pItemButton:getContentSize().height + 20) )   
        self._pServerScrollView:addChild(pItemButton)
        table.insert(self._tServerButtons,pItemButton)
        -- 给服务器按钮添加回调函数
        pItemButton:addTouchEventListener(clickServerButtonCallBack)
        -- 创建状态描述文字
        local pItemStatusText = cc.Label:createWithTTF("", strCommonFontName, 25)
        pItemStatusText:setAnchorPoint(1.0,0.5)
        if v.zoneStatus == kZoneStateType.SST_UNKONWN then
            pItemStatusText:setString("")
        elseif v.zoneStatus == kZoneStateType.SST_NORMAL then
            pItemStatusText:setString("普通")
            pItemStatusText:setColor(cGreen)
        elseif v.zoneStatus == kZoneStateType.SST_HOT then
            pItemStatusText:setString("火爆")
            pItemStatusText:setColor(cRed)
        elseif v.zoneStatus == kZoneStateType.SST_STOP then
            pItemStatusText:setString("维护")
            pItemStatusText:setColor(cGrey)
        end
        pItemStatusText:setPosition(sizeItemButton.width*0.3 + col*sizeItemButton.width*1.3, scrollViewInnerSize.height - 47 - row*(pItemButton:getContentSize().height + 20) )
        self._pServerScrollView:addChild(pItemStatusText)
        
        -- 创建角色分析信息展示
        for kZoneFlags, vZoneFlags in pairs(LoginManager:getInstance()._tZoneFlags) do 
            if v.zoneId == vZoneFlags then
                local roleZoneSpr = cc.Sprite:createWithSpriteFrameName("ServerItemsRes/roleFlag.png")
                roleZoneSpr:setPosition(pItemButton:getContentSize().width - roleZoneSpr:getContentSize().width, pItemButton:getContentSize().height - roleZoneSpr:getContentSize().width/2 - 25)
                pItemButton:addChild(roleZoneSpr)
            end
        end
        -- 创建是否推荐、新区等标记
        -- ------------------------------------------------------------------------------------------------------
        local zoneTypeFrameName = ""
        if v.zoneType == kZoneType.ZT_UNKONWN then
            zoneTypeFrameName = "ServerItemsRes/UnknownServerIcon.png"
        elseif v.zoneType == kZoneType.ZT_NEW then
            zoneTypeFrameName = "ServerItemsRes/NewServerIcon.png"
        elseif v.zoneType == kZoneType.ZT_RECOMMEND then
            zoneTypeFrameName = "ServerItemsRes/groomicon.png"
        end
        local pZoneTypeIcon = ccui.ImageView:create(zoneTypeFrameName, ccui.TextureResType.plistType)
        local sizeZoneTypeIcon = pZoneTypeIcon:getContentSize()
        pZoneTypeIcon:setAnchorPoint(1.0,1.0)
        pZoneTypeIcon:setPosition(pItemButton:getContentSize().width - pZoneTypeIcon:getContentSize().width+53, pItemButton:getContentSize().height-9)
        pItemButton:addChild(pZoneTypeIcon)
        -- --------------------------------------------------------------------------------------------------------
        
    end
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitServerListPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function ServerListPanel:onExitServerListPanel()

end

-- 循环更新
function ServerListPanel:update(dt)
    return
end

return ServerListPanel
