--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NetCmds.lua
-- author:    liyuhang
-- created:   2014/12/7
-- descrip:   返回网络协议号对照表
--===================================================

-- 客户端内部观察者通信key（网络返回）
kNetCmd = 
{
    kLoginAccount = "k10001",                   -- 登录账户[回复]
    kServerList = "k10003",                     -- 服务器列表[回复]
    kLoginAccountMother = "k10005",             -- 母包登录账户[回复]
    kLoginGame = "k20001",                      -- 登录游戏[回复]
    kRandomName = "k20003",                     -- 随机名字[回复]
    kCreateRole = "k20005",                     -- 创建角色[回复]
    kRoleList = "k20007",                       -- 已创建用户列表[回复]
    kChangeRole = "k20009",                     -- 切换角色[回复]
    kChangeName = "k20011",                     -- 修改昵称 [回复]
    kOtherPlayerInfos = "k20015",               -- 其他玩家角色信息 [回复]
    kUpdateBagItemList = "UpdateBagItemList",   -- 背包数据列表[更新]
    kUpdateRoleInfo = "kUpdateRoleInfo",        -- 人物信息RoleInfo[更新]
    kUpdateFisance = "kUpdateFisance",          -- 金融数据[更新]
    kBagSelectedCell = "kBagSelectedCell",      -- 背包选中某个cell[更新]
    kNetReconnected = "kNetReconnected",        -- 断线重连后通知客户端[更新]
    kNetGetPets = "kNetGetPets",                -- 获取宠物列表[更新]
    kNetFieldPet = "kNetFieldPet",              -- 上阵宠物[更新]
    kNetUnFieldPet = "kNetUnFieldPet",          -- 下阵宠物[更新]
    kNetCompoundPet = "kNetCompoundPet",        -- 合成宠物[更新]
    kNetAdvancePet = "kNetAdvancePet",          -- 进阶宠物[更新]
    kNetFeedPet = "kNetFeedPet",                -- 喂食宠物[更新]
    kNetErrorInfo = "kNetErrorInfo",            -- 错误码通知[更新]
    kWareEquipment = "k20107",                  -- 装备穿戴[回复]
    kFashionHasWare = "k20111",                 -- 时装是否穿戴[回复]
    kResolveEquipment = "k20113",               -- 分解装备[回复]
    kGemSynthesis = "k20115",                   -- 宝石合成[回复]
    kBagEqpStoneSynthesis = "k20117",           -- 背包装备上宝石合成[回复]
    kRoleEqpStoneSynthesis = "k20119",          -- 身上装备上宝石合成[回复]
    kInlayBagEquip = "k20121",                  -- 镶嵌背包装备[回复]
    kInlayRoleEquip = "k20123",                 -- 镶嵌身上装备[回复]
    kIntensifyyBagEquipment = "k20125",         -- 背包装备强化[回复]
    kIntensifyyRoleEquipment = "k20127",        -- 身上装备强化[回复]
    kSellItem = "k20129",                       -- 出售物品[回复]
    kForgingEquip = "k20131",                   -- 锻造装备[回复]
    kSelectFairyInfo = "k20601",                -- 查询境界盘信息[回复]
    kInlayFairyPill = "k20603",                 -- 境界丹镶嵌[回复]
    kDropFairyPill = "k20605",                  -- 卸下境界丹[回复]
    kDevourFairyPill = "k20607",                -- 吞噬境界丹[回复]
    kRefreshFairyPill = "20609",                -- 刷新境界丹列表[回复]
    kAutoDevour = "k20611",                     -- 一键吞噬[回复]
    kUpgradeFairyDish = "k20613",               -- 境界丹镶嵌[回复]
    kQueryShopInfo = "k20501",                  -- 查询商城信息[回复]
    kQueryShopInfoByTag = "k20503",             -- 查询对应标签的商品信息[回复]
    kBuyGoods = "k20505",                       -- 购买物品[回复]
    kGenerateOrderSussess = "kGenerateOrderSussess", -- 生成订单成功
    kRechargeNotice = "kRechargeNotice",        -- 支付成功
    kQueryChargeList = "k20507",                -- 查询充值列表
    kGainVipBox = "k20509",                     -- 领取Vip 对应的礼包
    kQueryBladeSoul= "k20701",                  -- 查询剑灵信息[回复]
    kRefineItem = "k20703",                     -- 剑灵丹炼化[回复]
    kCollectBladeSoul = "k20705",               -- 收取剑灵丹[回复]
    kCancelRefine = "k20707",                   -- 取消剑灵丹[回复]
    kBoostRefine = "k20709",                    -- 加速剑灵丹[回复]
    kDevourBladeSoul = "k20711",                -- 吞噬剑魂[回复]
    kSellBladeSoul = "k20713",                  -- 出售剑魂[回复]
    kAutoRefineItem = "k20715",                 -- 一键炼化[回复]
    kAutoDevourBladeSoul = "k20717",            -- 一键吞噬剑魂[回复]
    kUpgradeSkill = "k21403",                   -- 升级技能[回复]
    kMountSkill = "k21405",                     -- 出战技能[回复]
    kUpdateSkill = "k21401",                    -- 更新技能列表[回复]
    kQueryBattleList = "k21001",                -- 请求游戏副本列表[回复]
    kEntryBattle = "k21003",                    -- 请求进入副本战斗[回复]
    kUploadBattleResult = "k21005",             -- 上传战斗结果数据[回复]
    kPickCard = "k21007",                       -- 上传请求选卡[回复]
    kQueryBeautyClub = "k20801",                -- 查询群芳阁[回复]
    kKissBeauty = "k20803",                     -- 美人亲密[回复]
    kBeautyAwake = "k20805",                    -- 美人镶嵌[回复]
    kQueryStory = "k21009",                     -- 获取剧情副本[回复]
    kDrawStoryBox = "k21011",                   -- 领取宝箱[回复]
    kQueryArenaInfo = "k21601",                 -- 获取竞技场回复信息
    kFightResp = "21603",                       -- 挑战回复
    kFightResultResp = "21605",                 -- 挑战结果回复
    kQueryArenaRankResp = "21607",              -- 获取竞技场排行榜回复
    kRefreshEnemyResp = "21609",                -- 刷新挑战列表回复
    kDrawArenaBoxResp = "21611",                -- 获取竞技场礼包[回复]
    kDisPlayNotice = "k29503",                  -- 跑马灯通知[回复]

    kGameCopysScroll = "kGameCopysScroll",      -- 副本定向滑动到某关
    kQueryTasksResp = "k21701",                 -- 获取任务列表回复
    kGainTaskAwardResp = "k21703",              -- 领取任务奖励[回复]
    kGainVitalityAward = "k21705",              -- 获取活跃度礼包[回复]
    kQueryFriendRoleInfo = "kQueryFriendRoleInfo", -- 请求好友人物信息
    kUpdateFriendDatas = "kUpdateFriendDatas",  -- 更新好友列表 参数 1:好友列表 2:申请列表 3:礼物列表
    kUpdateRecommendFriendDatas = "kUpdateRecommendFriendDatas",  -- 更新推荐好友列表
    kUpdateFriendSkillDatas = "kUpdateFriendSkillDatas",        -- 更新好友配置技能 
    kUseUnDeadResp = "k21801",                  -- 使用免死符[回复]
    kAnswerRightResp = "k21803",                -- 答题正确[回复]
    --kEmailNotice = "xxxxx",                   -- 邮件通知[回复]
    kQueryHSInfoResp = "k21901",                -- 查看华山论剑[回复]
    kQueryHSEnemyDetialResp = "k21903",         -- 查看华山论剑挑战对手详情[回复]
    kFightHSFightResp = "k21905",               -- 挑战华山论剑[回复]
    kFightResultResp = "k21907",                -- 华山论剑挑战结果[回复]
    kAddHSBuffResp = "k21909",                  -- 华山论剑增加Buf[回复]

    kFuncWarning = "kFuncWarning" ,              -- 按钮红点提示
    kFriendWarning = "kFriendWarning" ,         -- 好友新提示提醒
    kHomeAddBuff = "kAddBuff",                  -- 增加buff的通知
    kHomeRemoveBuff = "kRemoveBuff",            -- 增加buff的通知
    kHomeBuffTime = "kHomeBuffTimeCall",        -- 增加的buff时间通知

    kGetWineryInfoResp = "k22101",              -- 获得酒坊信息[回复]
    kGetWineryRewardResp = "k22103",            -- 获得酒坊奖励[回复]
    kWineryOnceCompleteResp = "k22105",         -- 酒坊立即完成[回复]
    kGetFriendWineryInfoResp = "k22109",        -- 获取好友酒坊信息[回复]
    kSellWineResp = "k22107",                   -- 售卖酒品[回复]   
    kDrinkResp = "k22111",                      -- 喝个痛快[回复]
    kAllDrinkResp = "k22113",                   -- 一键喝光[回复]

    kMailList = "k22201",                       -- 获取邮件列表的回复[回复]
    kMailInfo = "k22203",                       -- 获取邮件详情回复[回复]
    kMailDeleteSuccess = "k22205",              -- 邮件删除成功[回复]
    kMailGetGoodsSuccess = "k22207",            -- 领取邮件的附件[回复]
    kMailNotice = "k29513",                     -- 邮件通知[通知]
    kRoleLevelUp = "k29515",                    -- 角色升级[通知]
    
    kReviveResp = "k21015",                     -- 复活反馈[回复]
    kPickCardState = "k21017",                  -- 查询翻卡数据[回复]
    kChatOutSide= "kOutSide",                   -- 公共聊天的一条数据通知     
    kChatTeamVoice = "kChatTeamVoice",          -- 队伍频道的语音聊天
    kChatResp = "k21303",                       -- 聊天推送[回复]
    kQueryBlackList = "k21305",                 -- 查询黑名单[回复]
    kSetBlackList = "k21307",                   -- 设置黑名单[回复]
    kStopVoice = "stopVoicePlay",                --停止播放语音
    kSetStickLocked = "kSetStickLocked",        -- 设置 摇杆锁定
    kMainTaskChange = "kMainTaskChange",        -- 主线任务更改
    kWorldLayerTouch = "kWorldLayerTouch",      -- 通知world触摸
    kNewEquip = "kNewEquip",                    -- 新装备获得
    kNewEquipShow = "kNewEquipShow",            -- 新装备显示控制获得 
    kItemSourceGo = "kItemSourceGo",            -- 物品来源关卡验证结束通知
    
    kNewbieOver = "kNewbieOver",                -- 新手结束
    kEquipWarning = "kEquipWarning",            -- 有装备可以强化或镶嵌
    
    kQueryFamilyListResp = "k22301",            -- 请求家族排行榜[回复]
    kEnteryFamilyResp = "k22303",               -- 进入家族[回复]
    kFindFamilyResp = "k22305",                 -- 查找家族[回复]
    kCreateFamilyResp = "k22307",               -- 创建家族[回复]
    kApplyFamilyResp = "k22309",                -- 申请家族[回复]
    kChangeFamilyNameResp = "k22311",           -- 修改家族名字[回复]
    kChangeFamilyPurposeResp = "k22313",        -- 修改家族宗旨[回复]
    kDonateFamilyResp = "k22315",               -- 家族捐献[回复]
    kUpgradeFamilyResp = "k22317",              -- 家族升级[回复]
    kQueryFamilyApplysResp = "k22319",          -- 家族申请者列表[回复]
    kReplyFamilyApplyResp = "k22321",           -- 批复申请[回复]
    kQueryFamilyMemberResp = "k22323",          -- 获取成员列表[回复]
    kFamilyAppointResp = "k22325",              -- 家族任命[回复]
    kDismissFamilyMemberResp = "k22327",        -- 开除成员[回复]
    kQuitFamilyResp = "k22329",                 -- 退出家族[回复]
    kQueryFamilyNewsResp = "k22331",            -- 获取家族动态[回复]
    kQueryFamilyAcademyResp = "k22333",         -- 获取研究院信息[回复]
    kUpgradeFamilyAcademyResp = "k22335",       -- 升级研究院[回复]
    kActivateFamilyTechResp = "k22337",         -- 激活研究院科技[回复]
    kUpgradeFamilyTechResp = "k22339",          -- 升级研究院信息[回复]
    kFindFamilyByIdResp = "k22341",             -- 查找家族回复[回复]
    kNoticeTagListResp = "k10007",              -- 获取公告标签列表回复
    kNoticeDescResp = "k10009",                 -- 获取公告内容回复
    kSelectZoneResp = "k10011",                 -- 获取选择分区回复
    kQueryRankResp = "k10013",                  -- 获取选择分区数据更新回复
    kCancelRankResp = "k10015",                 -- 取消排队分区回复
    kResultByGradeResp = "kResultByGradeResp",  -- 积分评星的推送
    kSameLoginNotice = "k29527",                -- 相同账号登陆通知
    kStopServiceNotice = "k29529",              -- 强制退服通知（停服）
    kQuerySturaLibraryResp = "k22401",          -- 查询藏经阁信息回复
    kSturaInsertPageResp = "k22403",            -- 藏经阁注入残页
}