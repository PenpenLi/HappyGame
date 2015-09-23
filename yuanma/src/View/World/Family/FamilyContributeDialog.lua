--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyContributeDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/7/14
-- descrip:   家族贡献界面
--===================================================
local FamilyContributeDialog = class("FamilyContributeDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FamilyContributeDialog:ctor()
    self._strName = "FamilyContributeDialog"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._tContributeBtn = {}                     --普通捐献,豪华捐献,至尊捐献 按钮
    self._tContributeLable = {}                   --普通捐献,豪华捐献,至尊捐献 lable
    self._tCanRoleGetLable = {}                   --普通捐献,豪华捐献,至尊捐献 个人获得 lable
    self._tCanFamilyGetLable = {}                 --普通捐献,豪华捐献,至尊捐献 家族获得 lable
    self._tCanFamilyGetImage = {}                 --普通捐献,豪华捐献,至尊捐献 家族获得 图片
    self._pClickType = 1

  

end

-- 创建函数
function FamilyContributeDialog:create(args)
    local dialog = FamilyContributeDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function FamilyContributeDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("DonateDialog.plist")
    if args then 
       self._pClickType = args[1]
    end

    local params = require("DonateDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    --普通捐献,豪华捐献,至尊捐献
    self._tContributeBtn = { params._pButton_1,params._pButton_2,params._pButton_3}
    --普通捐献数值,豪华捐献数值,至尊捐献数值
    self._tContributeLable = {params._pText_1_1, params._pText_3_1, params._pText_5_1}
    --普通捐献,豪华捐献,至尊捐献 个人获得 lable
    self._tCanRoleGetLable = {params._pText_2_1,params._pText_4_1,params._pText_6_1}
     --普通捐献,豪华捐献,至尊捐献 家族贡献，家族资金（Text）
    self._tCanGetText = {params._pText_7_1,params._pText_8_1,params._pText_9_1}
    --普通捐献,豪华捐献,至尊捐献 家族获得 lable
    self._tCanFamilyGetLable = {params._pText_7,params._pText_8,params._pText_9}                
    --普通捐献数值,豪华捐献数值,至尊捐献 捐献货币图片
    self._tCanFamilyGetImage =  {params._pJzGxIcon,params._pJzGxIcon_1,params._pJzGxIcon_2}         

   --初始化数据
   self:initContributeDate()
   
    -- 初始化dialog的基础组件
    self:disposeCSB()
    --初始化触摸机制
    self:initTouches()

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFamilyContributeDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end

-- 初始化触摸机制
function FamilyContributeDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
        end
        return true   --可以向下传递事件
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

end

--初始化数据
function FamilyContributeDialog:initContributeDate()


  local onTouchButton = function (sender, eventType)
     if eventType == ccui.TouchEventType.ended then
         local nTag = sender:getTag()-1000
         FamilyCGMessage:donateFamilyReq22314( self._pClickType,nTag)
     elseif eventType == ccui.TouchEventType.began then
         AudioManager:getInstance():playEffect("ButtonClick")
     end
   end

   -- local pFinceIcon = {"DonateDialogRes\JzGx.png","DonateDialogRes\JzGx.png.png","DonateDialogRes\JzGx.png.png"}
     for k,v in pairs(self._tContributeBtn) do
         v:setTag(k+1000)
         v:addTouchEventListener(onTouchButton)
         v:setZoomScale(nButtonZoomScale)
         v:setPressedActionEnabled(true)
         local pTableInfo = TableFamilyDonate[k]

         self._tContributeLable[k]:setString(pTableInfo.Cost[2])  
         self._tCanRoleGetLable[k]:setString(pTableInfo.Contribution)               

         if self._pClickType == kContributionType.kScore then --如果是家族建设度
            self._tCanFamilyGetLable[k]:setString("家族贡献")
            self._tCanGetText[k]:setString(pTableInfo.Construction)
         elseif self._pClickType == kContributionType.KCash then --如果是家族资金
            self._tCanFamilyGetLable[k]:setString("家族资金")
            self._tCanGetText[k]:setString(pTableInfo.Capital)

         end
      
         --self._tCanFamilyGetImage[k]:loadTexture(pFinceIcon[k],ccui.TextureResType.plistType) 
     end
     
end

-- 退出函数
function FamilyContributeDialog:onExitFamilyContributeDialog()
    self:onExitDialog()
    
    ResPlistManager:getInstance():removeSpriteFrames("DonateDialog.plist")
end

-- 循环更新
function FamilyContributeDialog:update(dt)
    return
end

-- 显示结束时的回调
function FamilyContributeDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function FamilyContributeDialog:doWhenCloseOver()
    return
end

return FamilyContributeDialog
