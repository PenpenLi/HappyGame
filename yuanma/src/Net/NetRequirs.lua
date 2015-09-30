--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NetDefs.lua
-- author:    liyuhang
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   网络通用定义
--===================================================

-- 服务器 server
SERVER_IP = "115.159.54.142"  -- 外网
--SERVER_IP = "192.168.0.181"    -- 占河
--SERVER_IP = "192.168.0.139"   -- 有信
 SERVER_PORT = 9000      -- 对内（开发）
--SERVER_PORT = 9010      -- 对外（巨人）
--SERVER_PORT = 9030      -- 对外（版署）

-- net requirs
require("NetProcess")
require("NetCmds")
require("NetHandlersManager")
require("NetRespManager")
require("NetProcotolPath")


require("msg_ce")
require("msg_cg_activity")
require("msg_cg_arena")
require("msg_cg_battle")
require("msg_cg_beauty")
require("msg_cg_blade")
require("msg_cg_buff")
require("msg_cg_common")
require("msg_cg_fairy")
require("msg_cg_friend")
require("msg_cg_huashan")
require("msg_cg_item")
require("msg_cg_night")
require("msg_cg_pet")
require("msg_cg_role")
require("msg_cg_shop")
require("msg_cg_skill")
require("msg_cg_task")
require("msg_cg_utils")
require("msg_cg_mail")
require("msg_gc_notice")
require("msg_xx_common")
require("msg_xx_error")
require("msg_xx_global")
require("msg_cg_winery")
require("msg_cg_family")
require("msg_cg_cjg")
-- cgmessage require
require("MessageActivity")
require("MessageArena")
require("MessageBagCommon")
require("MessageBeautyClub")
require("MessageBladeSoul")
require("MessageBuff")
require("MessageChat")
require("MessageEquipment")
require("MessageFairyLand")
require("MessageGameInstance")
require("MessageGemSystem")
require("MessageHeartBeat")
require("MessageHuaShan")
require("MessageLogin")
require("MessageOtherPlayers")
require("MessageNight")
require("MessageOpenItem")
require("MessagePet")
require("MessageShop")
require("MessageTask")
require("MessageFriend")
require("MessagePet")
require("MessageEmail")
require("MessageSkill")
require("MessageRevive")
require("MessageCommonUtil")
require("MessageDrunkery")
require("MessageFamily")
require("MessageSturaLibrary")

