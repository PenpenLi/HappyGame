--好友列表中好友信息
local FriendListDialogParams = class("FriendListInfoParams")

function FriendListDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FriendListInfo.csb")
	--大底板
    self._pListInfoBg = self._pCCS:getChildByName("ListInfoBg")
    --头像底板
    self._pHeadIconBg = self._pListInfoBg:getChildByName("HeadIconBg")
    --头像图标
    self._pHeadIcon = self._pHeadIconBg:getChildByName("HeadIcon")
    --vip背景图
    self._pVipBg = self._pHeadIconBg:getChildByName("VipBg")
    --vip等级数字
    self._pVipFnt = self._pHeadIconBg:getChildByName("VipFnt")
    --等级
    self._pPlayerLvText = self._pListInfoBg:getChildByName("PlayerLvText")
    --职业
    self._pPlayerJobText = self._pListInfoBg:getChildByName("PlayerJobText")
    --昵称
    self._pPlayerNameText = self._pListInfoBg:getChildByName("PlayerNameText")
    --战斗力
    self._pPowerFont = self._pListInfoBg:getChildByName("PowerFont")
    --亲密度值
    self._pIntimacyNum = self._pListInfoBg:getChildByName("IntimacyNum")
    --是否在线
    self._pText = self._pListInfoBg:getChildByName("Text")
    --助战冷却时间文字
    self._pZzTextTimeDesc = self._pListInfoBg:getChildByName("ZzTextTime")
    --助战冷却时间
    self._pZzTextTime = self._pListInfoBg:getChildByName("ZzTextTime")
    --已上阵图标
    self._pAlreadyIcon = self._pListInfoBg:getChildByName("AlreadyIcon")
end

function FriendListDialogParams:create()
    local params = FriendListDialogParams.new()
    return params  
end

return FriendListDialogParams
