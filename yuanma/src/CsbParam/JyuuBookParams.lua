--藏经阁界面
local JyuuBookParams = class("JyuuBookParams")

function JyuuBookParams:ctor()
    self._pCCS = cc.CSLoader:createNode("JyuuBook.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --小底板
    self._pPicBg = self._pBackGround:getChildByName("PicBg")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    -- 全部激活的背景图片
    self._pActiveBg =  self._pBackGround:getChildByName("Image2")
    --全本经书激活效果1文字
    self._pText_1 = self._pActiveBg:getChildByName("Text_1")
    --全本经书激活效果2文字
    self._pText_2 = self._pActiveBg:getChildByName("Text_2")
    --全本经书激活效果3文字
    self._pText_3 = self._pActiveBg:getChildByName("Text_3")
    --第1页经书效果
    self._pText_4 = self._pBackGround:getChildByName("Text_4")
    --第2页经书效果
    self._pText_5 = self._pBackGround:getChildByName("Text_5")
    --第3页经书效果
    self._pText_6 = self._pBackGround:getChildByName("Text_6")
    --第4页经书效果
    self._pText_7 = self._pBackGround:getChildByName("Text_7")
    --第5页经书效果
    self._pText_8 = self._pBackGround:getChildByName("Text_8")
    --经书残页1node
    self._pNode_1 = self._pBackGround:getChildByName("Node_1")
    --经书残页2node
    self._pNode_2 = self._pBackGround:getChildByName("Node_2")    
    --经书残页3node
    self._pNode_3 = self._pBackGround:getChildByName("Node_3")
    --经书残页4node
    self._pNode_4 = self._pBackGround:getChildByName("Node_4")
    --经书残页5node
    self._pNode_5 = self._pBackGround:getChildByName("Node_5")
    --经书名称
    self._pBookNameText = self._pBackGround:getChildByName("BookNameText")
    --解锁等级文字
    self._pUnLockText = self._pBackGround:getChildByName("UnLockText")
    -- 经书残页的容器
    self._pPageListView = self._pBackGround:getChildByName("ListView_1")
    -- 上一页的翻页按钮
    self._pPrevPageBtn = self._pBackGround:getChildByName("LeftButton1")
    -- 下一页的翻页按钮
    self._pNextPageBtn = self._pBackGround:getChildByName("NextButton1")
end

function JyuuBookParams:create()
    local params = JyuuBookParams.new()
    return params  
end

return JyuuBookParams
