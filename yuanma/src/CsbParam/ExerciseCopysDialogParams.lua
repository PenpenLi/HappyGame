--游戏的战斗界面
local ExerciseCopysDialogParams = class("ExerciseCopysDialogParams")

function ExerciseCopysDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ExerciseCopysDialog.csb")

	--技能tips背景板
    self._pbackground = self._pCCS:getChildByName("background")
    --关闭按钮
    self._pclosebutton = self._pbackground:getChildByName("closebutton")
    --大标题
    self._pframetitle = self._pbackground:getChildByName("frametitle")
    --滚动容器
    self._pscrollview = self._pbackground:getChildByName("scrollview")
	--副本节点01
    self._pnodecopys01 = self._pscrollview:getChildByName("nodecopys01")
    --副本图片01
    self._pcopyspicture01 = self._pnodecopys01:getChildByName("copyspicture01")
    --副本外框01
    self._pcopysbefore01 = self._pnodecopys01:getChildByName("copysbefore01")
    --副本标题01
    self._pcopystitle01 = self._pnodecopys01:getChildByName("copystitle01")
    --说明遮盖板1
    self._pCopysDiscBg1 = self._pnodecopys01:getChildByName("CopysDiscBg1")
    --副本奖励0101
    self._pcopysreward0101 = self._pCopysDiscBg1:getChildByName("copysreward0101")
    --副本奖励0102
    self._pcopysreward0102 = self._pCopysDiscBg1:getChildByName("copysreward0102")
    --副本描述0101
    self._pcopysdepict0101 = self._pCopysDiscBg1:getChildByName("copysdepict0101")
    --副本描述0102
    self._pcopysdepict0102 = self._pCopysDiscBg1:getChildByName("copysdepict0102")
    --副本按钮01
    self._pcopysbutton01 = self._pCopysDiscBg1:getChildByName("copysbutton01")
    --锁定图标01
    self._plock01 = self._pnodecopys01:getChildByName("lock01")
    --锁定图标文字01
    self._plocktext01 = self._plock01:getChildByName("locktext01")
    --副本锁定特效挂载节点01
    self._pnodelock01 = self._pnodecopys01:getChildByName("nodelock01")
    --副本节点02
    self._pnodecopys02 = self._pscrollview:getChildByName("nodecopys02")
    --副本图片02
    self._pcopyspicture02 = self._pnodecopys02:getChildByName("copyspicture02")
    --副本外框02
    self._pcopysbefore02 = self._pnodecopys02:getChildByName("copysbefore02")
    --副本标题02
    self._pcopystitle02 = self._pnodecopys02:getChildByName("copystitle02")
    --说明遮盖板2
    self._pCopysDiscBg2 = self._pnodecopys02:getChildByName("CopysDiscBg2")
    --副本奖励0201
    self._pcopysreward0201 = self._pCopysDiscBg2:getChildByName("copysreward0201")
    --副本奖励0202
    self._pcopysreward0202 = self._pCopysDiscBg2:getChildByName("copysreward0202")
    --副本描述0201
    self._pcopysdepict0201 = self._pCopysDiscBg2:getChildByName("copysdepict0201")
    --副本描述0202
    self._pcopysdepict0202 = self._pCopysDiscBg2:getChildByName("copysdepict0202")
    --副本按钮02
    self._pcopysbutton02 = self._pCopysDiscBg2:getChildByName("copysbutton02")
    --锁定图标02
    self._plock02 = self._pnodecopys02:getChildByName("lock02")
    --锁定图标文字02
    self._plocktext02 = self._plock02:getChildByName("locktext02")
    --副本锁定特效挂载节点02
    self._pnodelock02 = self._pnodecopys02:getChildByName("nodelock02")
    --副本节点03
    self._pnodecopys03 = self._pscrollview:getChildByName("nodecopys03")
    --副本图片03
    self._pcopyspicture03 = self._pnodecopys03:getChildByName("copyspicture03")
    --副本外框03
    self._pcopysbefore03 = self._pnodecopys03:getChildByName("copysbefore03")
    --副本标题03
    self._pcopystitle03 = self._pnodecopys03:getChildByName("copystitle03")
    --说明遮盖板3
    self._pCopysDiscBg3 = self._pnodecopys03:getChildByName("CopysDiscBg3")
    --副本奖励0301
    self._pcopysreward0301 = self._pCopysDiscBg3:getChildByName("copysreward0301")
    --副本奖励0302
    self._pcopysreward0302 = self._pCopysDiscBg3:getChildByName("copysreward0302")
    --副本描述0301
    self._pcopysdepict0301 = self._pCopysDiscBg3:getChildByName("copysdepict0301")
    --副本描述0302
    self._pcopysdepict0302 = self._pCopysDiscBg3:getChildByName("copysdepict0302")
    --副本按钮03
    self._pcopysbutton03 = self._pCopysDiscBg3:getChildByName("copysbutton03")
    --锁定图标03
    self._plock03 = self._pnodecopys03:getChildByName("lock03")
    --锁定图标文字03
    self._plocktext03 = self._plock03:getChildByName("locktext03")
    --副本锁定特效挂载节点03
    self._pnodelock03 = self._pnodecopys03:getChildByName("nodelock03") 
    --副本节点04
    --self._pnodecopys04 = self._pscrollview:getChildByName("nodecopys04")
    --副本图片04
    --self._pcopyspicture04 = self._pnodecopys04:getChildByName("copyspicture04")
    --副本外框04
    --self._pcopysbefore04 = self._pnodecopys04:getChildByName("copysbefore04")
    --副本标题04
    --self._pcopystitle04 = self._pnodecopys04:getChildByName("copystitle04")
    --说明遮盖板4
    --self._pCopysDiscBg4 = self._pnodecopys04:getChildByName("CopysDiscBg4")
    --副本奖励0401
    --self._pcopysreward0401 = self._pCopysDiscBg4:getChildByName("copysreward0401")
    --副本奖励0402
    --self._pcopysreward0402 = self._pCopysDiscBg4:getChildByName("copysreward0402")
    --副本描述0401
    --self._pcopysdepict0401 = self._pCopysDiscBg4:getChildByName("copysdepict0401")
    --副本描述0402
    --self._pcopysdepict0402 = self._pCopysDiscBg4:getChildByName("copysdepict0402")
    --副本按钮04
    --self._pcopysbutton04 = self._pCopysDiscBg4:getChildByName("copysbutton04")
    --锁定图标04
    --self._plock04 = self._pnodecopys04:getChildByName("lock04")
    --锁定图标文字04
    --self._plocktext04 = self._plock04:getChildByName("locktext04")
    --副本锁定特效挂载节点04
    --self._pnodelock04 = self._pnodecopys04:getChildByName("nodelock04")
    
end

function ExerciseCopysDialogParams:create()
    local params = ExerciseCopysDialogParams.new()
    return params  
end

return ExerciseCopysDialogParams
