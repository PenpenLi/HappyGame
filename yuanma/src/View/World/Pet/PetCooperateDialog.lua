--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetCooperateDialog.lua
-- author:    liyuhang
-- created:   2015/10/9
-- descrip:   宠物共鸣面板
--===================================================

local PetCooperateDialog = class("PetCooperateDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function PetCooperateDialog:ctor()
    -- 层名字
    self._strName = "PetCooperateDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self._pItems = {}
    

    self._pListController = nil
end

-- 创建函数
function PetCooperateDialog:create(args)
    local layer = PetCooperateDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function PetCooperateDialog:dispose(args)
    
    ResPlistManager:getInstance():addSpriteFrames("GmDialog.plist")
    self._tPets = args[1]

    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetCooperateDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function PetCooperateDialog:initUI()
    -- 加载组件
    local params = require("GmDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    --self._pBg:setVisible(false)
    
    self._pListController = require("ListController"):create(self,self.params._pScrollView,listLayoutType.LayoutType_vertiacl,0,200)
    self._pListController:setVertiaclDis(2)
    self._pListController:setHorizontalDis(3)

    self:disposeCSB()

    self:updateCooperateDatas()
end

function PetCooperateDialog:updateCooperateDatas()
    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local info = TablePetsResonance[index]

        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("PetCooperateCell"):create(info)
        else
            cell:setInfo(info)
        end
        
        return cell
    end

    self._pListController._pNumOfCellDelegateFunc = function ()
        return table.getn(TablePetsResonance)
    end

    self._pListController:setDataSource(TablePetsResonance)
end


-- 初始化触摸相关
function PetCooperateDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

-- 退出函数
function PetCooperateDialog:onExitPetCooperateDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("GmDialog.plist")
end

return PetCooperateDialog