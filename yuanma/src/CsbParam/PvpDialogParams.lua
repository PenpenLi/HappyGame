--竞技界面
local PvpDialogParams = class("PvpDialogParams")

function PvpDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PvpDialog.csb")
    --界面大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --玩家昵称底板
    self._pPlayerNameBg = self._pBackGround:getChildByName("PlayerNameBg")
    --玩家昵称
    self._pPlayerNameText = self._pPlayerNameBg:getChildByName("PlayerNameText")
    --当前排名艺术字
    self._pRankingFont = self._pBackGround:getChildByName("RankingFont")
    --当前荣誉数值
    self._pHonorTextNum = self._pBackGround:getChildByName("HonorTextNum")  
    --连胜数值
    self._pWinTextNum = self._pBackGround:getChildByName("WinTextNum") 
    --剩余挑战次数艺术字
    self._pLeaveFnt = self._pBackGround:getChildByName("LeaveFnt") 
    --挑战礼包
    self._pGiftsPic = self._pBackGround:getChildByName("GiftsPic") 
    --挑战礼包次数底板
    self._pImage_17 = self._pGiftsPic:getChildByName("Image_17") 
    --挑战礼包次数
    self._pText1 = self._pGiftsPic:getChildByName("Text1")
    --领取挑战礼包间隔文字说明
    self._pNextTimeGifts = self._pBackGround:getChildByName("NextTimeGifts") 
    --领取挑战礼包间隔时间
    self._pTimeNum = self._pBackGround:getChildByName("TimeNum") 
    --排行榜按钮
    self._pRankingButton = self._pBackGround:getChildByName("RankingButton") 
    --荣誉值商店按钮
    self._pHonorShopButton = self._pBackGround:getChildByName("HonorShopButton") 
    --右侧板子挂点
    self._pRightNode = self._pBackGround:getChildByName("RightNode")
    --右侧板子底板
    self._pRightFrameImage = self._pRightNode:getChildByName("RightFrameImage")
    -- 对手列表容器
    self._pScrollView = self._pRightFrameImage:getChildByName("ScrollView")
    --刷新按钮
    self._pRefurbishButton= self._pRightFrameImage:getChildByName("RefurbishButton")
    -- 剩余免费刷新次数文字提示 
    self._pRefurbishText = self._pRightFrameImage:getChildByName("TextTime")
    -- 剩余免费刷新次数
    self._pTextTimeNum = self._pRightFrameImage:getChildByName("TextTimeNum")
    --RMB图标
    self._pRmbIcon= self._pRightFrameImage:getChildByName("RmbIcon")
    --Rmb数量
    self._pRMBNum = self._pRightFrameImage:getChildByName("RMBNum")
end

function PvpDialogParams:create()
    local params = PvpDialogParams.new()
    return params
end

return PvpDialogParams
