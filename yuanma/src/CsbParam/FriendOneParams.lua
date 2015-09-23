--游戏的战斗界面
local FriendOneParams = class("FriendOneParams")

function FriendOneParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FriendOne.csb")

	--背景板
    self._pFriendOneBg = self._pCCS:getChildByName("FriendOneBg")
    --好友头像icon
    self._pFriendIcon = self._pFriendOneBg:getChildByName("FriendIcon")
    --好友名称
    self._pFriendName = self._pFriendOneBg:getChildByName("FriendName")
    --正在售卖 4个字
    self._pFriendBuy01 = self._pFriendOneBg:getChildByName("FriendBuy01")
    --正在售卖酒品的名字
    self._pFriendBuy02 = self._pFriendOneBg:getChildByName("FriendBuy02")
    --友好度
    self._pHeart = self._pFriendOneBg:getChildByName("Heart")
    --友好度具体数值
    self._pHeartText = self._pHeart:getChildByName("HeartText")
    --已喝过角标
    self._pDrinkOk = self._pFriendOneBg:getChildByName("DrinkOk")



    
end

function FriendOneParams:create()
    local params = FriendOneParams.new()
    return params  
end

return FriendOneParams
