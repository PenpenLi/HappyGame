--游戏的邮箱UI中的item项
local EmailItemParams = class("EmailItemParams")

function EmailItemParams:ctor()
    self._pCCS = cc.CSLoader:createNode("EmailItem.csb")

	-- 邮件背景板
    self._pItemBg = self._pCCS:getChildByName("ItemBg")
    -- 邮件删除按钮
    self._pDeleteButton = self._pCCS:getChildByName("DeleteButton")
    -- 邮件未读图标
    self._pUnReadImage = self._pCCS:getChildByName("UnReadImage")
    -- 邮件日期label
    self._pDateLabel = self._pCCS:getChildByName("DateLabel")
    -- 邮件标题label
    self._pTitleLabel = self._pCCS:getChildByName("TitleLabel")
	-- 邮件类型label
    self._pTypeLabel = self._pCCS:getChildByName("TypeLabel")
    -- 邮件已读图标
    self._pReadedImage = self._pCCS:getChildByName("ReadedImage")
    -- 邮件带有附件的标记图标
    self._pGoodsFlag = self._pCCS:getChildByName("GoodsFlag")
    
end

function EmailItemParams:create()
    local params = EmailItemParams.new()
    return params  
end

return EmailItemParams
