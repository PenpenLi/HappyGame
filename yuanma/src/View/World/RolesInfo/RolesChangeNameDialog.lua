--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RolesChangeNameDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/2/12
-- descrip:   改名
--===================================================
local RolesChangeNameDialog = class("RolesChangeNameDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function RolesChangeNameDialog:ctor()
    self._strName = "RolesChangeNameDialog"        -- 层名称
    self._pBg = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pOkButton = nil                          --确定按钮
    self._pCancelButton = nil                      --取消按钮
    self._pNameText = nil                          --输入提示框
    self._pChangeType = nil

end

-- 创建函数
function RolesChangeNameDialog:create(args)
    local dialog = RolesChangeNameDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function RolesChangeNameDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("ChangeNameDialog.plist")
     --修改名字
    NetRespManager:getInstance():addEventListener(kNetCmd.kChangeFamilyNameResp ,handler(self, self.changeNameResp))
    NetRespManager:getInstance():addEventListener(kNetCmd.kChangeName ,handler(self, self.changeNameResp))
    if args then 
       self._pChangeType = args[1]
    end

    local params = require("ChangeNameDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pOkButton = params._pOkButton          --确定按钮
    self._pOkButton:setZoomScale(nButtonZoomScale)
    self._pOkButton:setPressedActionEnabled(true)
    --self._pOkButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pCancelButton = params._pCancelButton  --取消按钮
    self._pCancelButton:setZoomScale(nButtonZoomScale)
    self._pCancelButton:setPressedActionEnabled(true)
    --self._pCancelButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pEditBoxNode = params._pEditBoxNode    --输入框的挂节点
    self._pNameText = createEditBoxBySize(cc.size(320,43),TableConstants.NameMaxLenWord.Value)          --输入提示框
    self._pEditBoxNode:addChild(self._pNameText)
    -- 初始化dialog的基础组件
    self:disposeCSB()

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

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRolesChangeNameDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
   self:loadChangeNameUi()    --初始化界面

    return

end


function RolesChangeNameDialog:loadChangeNameUi()

   local nConst = 0
   
    local nMainLen = TableConstants.NameMinLen.Value
   local nMaxLen = TableConstants.NameMaxLen.Value
   if self._pChangeType == kChangeNameType.kChangeRoleName then --如果是修改人名
        nConst = TableConstants.ChangeName.Value
   elseif self._pChangeType == kChangeNameType.kChangeFamilyName then --如果是修改家族名
        nConst = TableConstants.FamilyChangeName.Value
        nMaxLen =  TableConstants.FamilyNameMax.Value
   end
   --设置改名数值
   self._pOkButton:setTitleText(nConst)

    -- 确定按钮回调函数
    local function onTouchOkButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pString = self._pNameText:getText()
            local nameLenth = string.len(pString)
            for i=1, string.len(pString) do 
                if string.byte(pString, i) == 32 then
                    NoticeManager:getInstance():showSystemMessage("昵称中不能存在空格！")
                    return
                end
            end
            
            if strIsHaveMoji(pString) then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
             end   
            if string.find(pString,"□") then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
             end
           
             if self._pChangeType == kChangeNameType.kChangeRoleName then --如果是修改人名    
                if pString == RolesManager:getInstance()._pMainRoleInfo.roleName then
                    NoticeManager:getInstance():showSystemMessage("昵称已存在！")
                 	return 
                 end        
             elseif self._pChangeType == kChangeNameType.kChangeFamilyName then --如果是修改家族名  
                if pString == FamilyManager:getInstance()._pFamilyInfo.familyName then
                    NoticeManager:getInstance():showSystemMessage("家族名称已经存在！")
                    return
                 end       
             end
            
            if nameLenth == 0 then
                NoticeManager:getInstance():showSystemMessage("昵称不能为空！")
            elseif nameLenth < nMainLen then
                NoticeManager:getInstance():showSystemMessage("昵称过短！")
            elseif nameLenth > nMaxLen then
                NoticeManager:getInstance():showSystemMessage("昵称过长！")
            else
            
                local tMsg = {
                    {type = 2,title = "确定花费"..nConst.."玉璧将昵称改为",fontColor = cWhite},           
                    {type = 1},
                    {type = 2,title = ""..pString,fontColor = cRed},
                }
                
                
                local fCallBack = function()
                	 if self._pChangeType == kChangeNameType.kChangeRoleName then --如果是修改人名    
                        EquipmentCGMessage:sendMessageRoleChangeName20010(pString)
                     elseif self._pChangeType == kChangeNameType.kChangeFamilyName then --如果是修改家族名  
                        FamilyCGMessage:changeFamilyNameReq22310(pString)
                     end
                    -- self:close()
                	
                end
                showConfirmDialog(tMsg,fCallBack)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pOkButton:addTouchEventListener(onTouchOkButton)
    
    
    -- 取消按钮回调函数
    local function onTouchCancelButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pCancelButton:addTouchEventListener(onTouchCancelButton)
end


--改名回复
function RolesChangeNameDialog:changeNameResp(event)
    NoticeManager:getInstance():showSystemMessage("昵称修改成功")
    self:close()
end


-- 退出函数
function RolesChangeNameDialog:onExitRolesChangeNameDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("ChangeNameDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function RolesChangeNameDialog:update(dt)
    return
end

-- 显示结束时的回调
function RolesChangeNameDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function RolesChangeNameDialog:doWhenCloseOver()
    return
end

return RolesChangeNameDialog
