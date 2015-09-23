--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyCreateDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/08
-- descrip:   家族创建界面
--===================================================

local FamilyCreateDialog = class("FamilyCreateDialog",function()
	return require("Dialog"):create()
end)

function FamilyCreateDialog:ctor()
	self._strName = "FamilyCreateDialog"
	self._pCloseButton = nil 
	self._pCCS = nil
	self._pBg = nil 
	-- 家族的名字
	self._pFamilyNameText = nil 
	-- 家族宗旨
	self._pFamilyPurposeText = nil 
	-- 创建家族
	self._pCreateFamilyBtn = nil 
	-- 消耗的货币图标
	self._pCostFinanceIcon = nil 
	-- 消耗的货币数量
	self._pCostFinanceNumText = nil
	------------------------------
	self._isMoneyEnough = true
	--家族宗旨显示text
	self._pHomeZZTextShow = nil
end

function FamilyCreateDialog:create(args)
	local dialog = FamilyCreateDialog.new()
	dialog:dispose()
	return dialog
end

function FamilyCreateDialog:dispose()
	-- 家族创建查找纹理           
	ResPlistManager:getInstance():addSpriteFrames("CreatHomeDialog.plist")
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyCreateDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

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
    -- 初始化界面
    self:initUI()
end

function FamilyCreateDialog:initUI()
    local params = require("CreatHomeDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pHomeNameTextNode = params._pHomeNameTextNode 
	self._pHomeNameZZTextNode = params._pHomeNameZZTextNode	
	self._pCreateFamilyBtn = params._pCreatButton
	self._pCostFinanceNumText = params._pMoneyNumText
	self._pCostFinanceIcon = params._pMoneyIcon
	self._pHomeZZTextShow = params._pHomeZZTextShow

    self._pFamilyNameText = createEditBoxBySize(cc.size(300,35),TableConstants.NameMaxLenWord.Value,255,"输入家族名称")
	self._pHomeNameTextNode:addChild(self._pFamilyNameText)
    self._pFamilyPurposeText = createEditBoxBySize(cc.size(300,160),TableConstants.FamilyPurposeMaxWord.Value,0)
	self._pHomeNameZZTextNode:addChild(self._pFamilyPurposeText)
	self._pHomeZZTextShow:setString("输入家族宗旨")

	self:disposeCSB()


	self:showCoinsInfo()
	
	self:initBtnEvent()
end

--注册界面按钮的点击事件
function FamilyCreateDialog:initBtnEvent()

   local nMainLen = TableConstants.NameMinLen.Value
   local nMaxLen = TableConstants.NameMaxLen.Value
   
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if self._isMoneyEnough == false then 
				NoticeManager:getInstance():showSystemMessage("玉璧不足")
				return
			end
            local strName = self._pFamilyNameText:getText()
            local strPurpose = self._pFamilyPurposeText:getText()
            for i=1, string.len(strName) do 
                if string.byte(strName, i) == 32 then
                    NoticeManager:getInstance():showSystemMessage("昵称中不能存在空格！")
                    return
                end
            end
            
            if strIsHaveMoji(strName) or strIsHaveMoji(strPurpose) then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
            end   
            if string.find(strName,"□") or string.find(strPurpose,"□") then
                NoticeManager:getInstance():showSystemMessage("昵称含有非法字符，请重新输入！")
                return 
            end
            
            local nameLenth = string.len(strName)
            if nameLenth == 0 then
                NoticeManager:getInstance():showSystemMessage("昵称不能为空！")
            elseif nameLenth < nMainLen then
                NoticeManager:getInstance():showSystemMessage("昵称过短！")
            elseif nameLenth > nMaxLen then
                NoticeManager:getInstance():showSystemMessage("昵称过长！")
            else
                local function okCallback() 
                    FamilyCGMessage:createFamilyReq22306(strName,strPurpose)
                    --self:close()
                end

                local msg = string.format("确定需要花费%d玉璧创建家族?",TableConstants.FamilyCreateCost.Value)

                showConfirmDialog(msg,okCallback)
            end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pCreateFamilyBtn:addTouchEventListener(touchEvent)



    local editBoxTextEventHandle = function(strEventName,pSender)
        local edit = pSender
        local strFmt 
        if strEventName == "began" then
          local pString = self._pHomeZZTextShow:getString()
          if pString == "输入家族宗旨" then
          	 pString = ""
          end
          self._pFamilyPurposeText:setText(pString)
        elseif strEventName == "ended" then
            --release_print("2")
        elseif strEventName == "return" then
           -- release_print("3")
        elseif strEventName == "changed" then
            --release_print("editBox changed")
            local pText = self._pFamilyPurposeText:getText()
            local pString = unicodeToUtf8(pText)
            self._pFamilyPurposeText:setText("")
            if pString == "" then 
            	pString = "输入家族宗旨"
            end
              self._pHomeZZTextShow:setString(pString)

        end
    end

    self._pFamilyPurposeText:registerScriptEditBoxHandler(editBoxTextEventHandle)

end

-- 设置玩家的货币信息
function FamilyCreateDialog:showCoinsInfo()
	local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(TableConstants.FamilyCreateCostType.Value)
	self._pCostFinanceIcon:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
	-- 设置金币
    self._pCostFinanceNumText:setString(TableConstants.FamilyCreateCost.Value)
	if TableConstants.FamilyCreateCost.Value > FinanceManager:getInstance()._tCurrency[TableConstants.FamilyCreateCostType.Value] then 
        self._pCostFinanceNumText:setColor(cRed)
		self._isMoneyEnough = false
	else
		self._pCostFinanceNumText:setColor(cWhite)
	end
end

function FamilyCreateDialog:onExitFamilyCreateDialog()
	self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("CreatHomeDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FamilyCreateDialog