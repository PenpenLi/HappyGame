--游戏的邮箱UI
local EmailParams = class("EmailParams")

function EmailParams:ctor()
    self._pCCS = cc.CSLoader:createNode("Email.csb")

	-- 背景板
    self._pBackground = self._pCCS:getChildByName("BackGround")
	-- 关闭按钮
    self._pCloseButton = self._pBackground:getChildByName("CloseButton")
    -- 滚动板
    self._pScrollView = self._pBackground:getChildByName("ScrollView")
    -- 邮件数
    self._pEmailNum = self._pBackground:getChildByName("EmailNum")
    -- 删除已读按钮
    self._pDeleteAllReadButton = self._pBackground:getChildByName("DeleteAllReadButton")
    -- 一键领取
    self._pGetAllGoodsButton = self._pBackground:getChildByName("GetAllGoodsButton")
    
    
end

function EmailParams:create()
    local params = EmailParams.new()
    return params  
end

return EmailParams
