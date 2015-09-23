--游戏的邮件具体内容展示UI
local EmailItemContentDialogParams = class("EmailItemContentDialogParams")

function EmailItemContentDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("EmailItemContentDialog.csb")

	-- 背景板
    self._pBackground = self._pCCS:getChildByName("BackGround")
	-- 关闭按钮
    self._pCloseButton = self._pBackground:getChildByName("CloseButton")
    -- 发件人标签
    self._pSenderLabel = self._pBackground:getChildByName("SenderLabel")
    -- 标题标签
    self._pTitleLabel = self._pBackground:getChildByName("TitleLabel")
    -- 内容标签
    self._pContentLabel = self._pBackground:getChildByName("ContentLabel")
    -- 发件人姓名
    self._pSenderNameLabel = self._pBackground:getChildByName("SenderNameLabel")
    -- 标题名称
    self._pTitleNameLabel = self._pBackground:getChildByName("TitleNameLabel")
    -- 主要滚动板
    self._pMainScrollView = self._pBackground:getChildByName("MainScrollView")
    -- 文本显示区域
    self._pContentsPanel = self._pMainScrollView:getChildByName("ContentsPanel")
    -- 物品栏基础容器
    self._pGoodsPanel = self._pBackground:getChildByName("GoodsPanel")
    -- 获取按钮
    self._pGetButton = self._pGoodsPanel:getChildByName("GetButton")
    -- 物品滚动板
    self._pGoodsScrollView = self._pGoodsPanel:getChildByName("GoodsScrollView")

    
end

function EmailItemContentDialogParams:create()
    local params = EmailItemContentDialogParams.new()
    return params  
end

return EmailItemContentDialogParams
