--设置界面
local SetSystemDialog = class("SetSystemDialogParams")

function SetSystemDialog:ctor()
    self._pCCS = cc.CSLoader:createNode("SetSystemDialog.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --音乐按钮
    self._pMusicButton = self._pBackGround:getChildByName("MusicButton")
    --音效按钮
    self._pSoundEffectButton = self._pBackGround:getChildByName("SoundEffectButton")
    --昵称显示按钮
    self._pNameButton = self._pBackGround:getChildByName("NameButton")
    --摇杆锁定按钮
    self._pRockerButton = self._pBackGround:getChildByName("RockerButton")
    --手机震动按钮
    self._pShakeButton = self._pBackGround:getChildByName("ShakeButton")
    self._pShakeText = self._pBackGround:getChildByName("Text5")
    --同屏低
    self._pLowButton = self._pBackGround:getChildByName("LowButton")
    --同屏中
    self._pMidButton = self._pBackGround:getChildByName("MidButton")
    --同屏高
    self._pHeighButton = self._pBackGround:getChildByName("HeighButton")
    --更换角色按钮
    --self._pChangePlayerButton = self._pBackGround:getChildByName("ChangePlayerButton")
    --退出游戏按钮
    self._pExitGameButton = self._pBackGround:getChildByName("ExitGameButton")
    --返回游戏按钮
    self._pGoGameButton = self._pBackGround:getChildByName("GoGameButton")
    --联系gm按钮  
    self._pGmButton = self._pBackGround:getChildByName("GmButton")
    
end

function SetSystemDialog:create()
    local params = SetSystemDialog.new()
    return params  
end

return SetSystemDialog
