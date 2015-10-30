local CumulativeRechargeCell = class("CumulativeRechargeCell", function () 
    return cc.Node:create()
end)

-- 创建函数
function CumulativeRechargeCell:create()
    local instance = CumulativeRechargeCell.new()
    instance:initialize()
    return instance
end

function CumulativeRechargeCell:initialize()
	local params = require("RechargeRewardParams"):create()
	-- ccs Node
    self._pCCS = params._pCCS
    -- 背景
    self._pRechargerRewardBg = params._pRechargerRewardBg
    --充值数额说明
    self._pMoneyText = params._pMoneyText
    -- 奖励图标1
    self._pReward1 = params._pReward1
    -- 奖励1数额
    self._pRewardNum1 = params._pRewardNum1
    -- 奖励图标2
    self._pReward2 = params._pReward2
    -- 奖励2数额
    self._pRewardNum2 = params._pRewardNum2
    -- 奖励图标3
    self._pReward3 = params._pReward3
    -- 奖励3数额
    self._pRewardNum3 = params._pRewardNum3
    -- 进度条
    self._pMoneyLoadingBar = params._pMoneyLoadingBar
    -- 进度数值：当前值/上限
    self._pMoneyNow = params._pMoneyNow 
    -- 领取按钮
    self._pYesButton = params._pYesButton
    -- 已领取美术字
    self._pReceived = params._pReceived

    self:addChild(self._pCCS)

    -- 数据
    self.tData = nil

	self._pYesButton:addTouchEventListener(function(sender, eventType)
	        if eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
	        elseif eventType == ccui.TouchEventType.ended then
                ActivityManager:getInstance().nCurrentAward = self.tData.Id
                print("发送领奖请求，ID=" .. self.tData.Id)

                --本地测试 require("ActivityHandler"):create():handleMsgAmassAwardResp22503({header={result=0}})

                -- 向服务器发送领奖请求
                ActivityMessage:GainAmassAwardReq22502(self.tData.Id)
	        end
		end)
end

function CumulativeRechargeCell:setReceived(bool)
    if bool then
        self._pYesButton:setVisible(false)
        self._pReceived:setVisible(true)
    else
        self._pYesButton:setVisible(true)
        self._pReceived:setVisible(false)
    end
end

function CumulativeRechargeCell:setData(data, isReceived)
    self.tData = data
    self._pMoneyText:setString(data.Text)
    -- 指定时间的充值总额
    local totalCharge = ActivityManager:getInstance().tAmassAward.amassPay
    print("指定时间的充值总额" .. totalCharge)
    --本地测试 totalCharge = 90
    if totalCharge >= data.RechargeNum then
        totalCharge = data.RechargeNum
        self._pYesButton:setEnabled(true)
        unDarkNode(self._pYesButton:getVirtualRenderer():getSprite())
    else
        self._pYesButton:setEnabled(false)
        darkNode(self._pYesButton:getVirtualRenderer():getSprite())
    end
    self._pMoneyNow:setString(totalCharge .. "/" .. data.RechargeNum)
    --loadingBar 进度0-100
    self._pMoneyLoadingBar:setPercent(totalCharge/data.RechargeNum*100)
    -- 设置是否领取状态
    self:setReceived(isReceived)

    local imgList = {self._pReward1, self._pReward2, self._pReward3}
    local countList = {self._pRewardNum1, self._pRewardNum2, self._pRewardNum3}
    -- 奖品处理
    local reward = data.Reward
    local viewReward = {}
    for i=1,#reward,1 do
        if i <= 3 then
            local value = reward[i]
            countList[i]:setString(tostring(value[2]))
            local view = imgList[i]
            if value[1] > kFinance.kNone and value[1] < kFinance.kFC then 
                -- 表示金融货币
                view.dataInfo = FinanceManager:getInstance():getIconByFinanceType(value[1])
                view.isBaseItem = false
                view:loadTexture(view.dataInfo.filename,ccui.TextureResType.plistType)
            else -- 物品
                local temp = {id = value[1], baseType = value[3], value = value[2]}
                view.dataInfo = GetCompleteItemInfo(temp)
                view.isBaseItem = true
                view:loadTexture(view.dataInfo.templeteInfo.Icon .. ".png",ccui.TextureResType.plistType)
                view:setTouchEnabled(true)
                view:addTouchEventListener(function(sender, eventType)
                        if eventType == ccui.TouchEventType.ended then
                            if sender.dataInfo.baseType ~= kItemType.kEquip then            
                                DialogManager:getInstance():showDialog("BagCallOutDialog",{sender.dataInfo ,nil,nil,false,false})
                            else
                                DialogManager:getInstance():showDialog("NeverGetEquipCallOutDialog",{sender.dataInfo})
                            end
                        elseif eventType == ccui.TouchEventType.began then
                            AudioManager:getInstance():playEffect("ButtonClick")
                        end
                    end)
            end
            view.count = value[2]
        end
    end    
end

return CumulativeRechargeCell
