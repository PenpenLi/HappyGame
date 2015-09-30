--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  defs.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   全局变量定义
--===================================================
-- 通用颜色定义
cWhite = cc.c3b(255,255,255)
cRed = cc.c3b(234,45,45)
cGreen = cc.c3b(59,255,59)
cOrange = cc.c3b(255,198,0)
cBlue = cc.c3b(48,159,253)
cPurple = cc.c3b(144,66,251)
cGrey = cc.c3b(145,145,145)
cDeepGrey = cc.c3b(70,70,70)
cYellow = cc.c3b(255,253,103)
cBlack = cc.c3b(0,0,0)
cMapNight = cc.c3b(8,93,189)
cPeopleNight = cc.c3b(42,245,254)

-- 场景会话类型
kSession =
{
    kNone = 0,
    kLogin = 1,
    kWorld = 2,
    kBattle = 3,
    kGuide=4,
    kSelect=5
}

-- 是否直接登录主场景
isFirstLoginMain = true

-- 通用字体名称
strCommonFontName = "simhei.ttf"

-- UI按钮点击时的缩放比例
nButtonZoomScale = 0.2

-- 默认家园地图文件名称
tDefaultMapNames = {"world_map1","world_map2"}

-- 地图分块区域总行数
nMapAreaRowNum = 10  --3

-- 地图分块区域总列数
nMapAreaColNum = 10  --2

-- 地图跟随动作Tag
nMapFollowTag = 100

-- 地图震动动作Tag
nMapShakeActionTag = 105

-- 触发器Tag标记
nTriggerItemTag = 8000

-- 角色动作通用Tag
nRoleActAction = 200

-- 角色掉血动作tag
nRoleLoseHpActAction = 205

-- 角色延时等待动作Tag
nRoleActDelayTag = 2

-- 实体动作通用Tag
nEntityActAction = 300

-- 传送门实体动作通用Tag
nDoorActAction = 310

-- Buff的动态ID号
nBattleBuffID = 1

-- 技能飞出动画tag
nSkillFlyActTag = 1010

-- 角色冲刺位移动作tag
nRoleShootAheadTag = 1020

-- 角色由站立状态到跑步状态或者AI逻辑相关的转换时需要等待的最短时长
fRoleStandWaitDelay = 0.2

-- 角色击退动作tag
nRoleBackActionTag = 1030

-- zorder定义
kZorder =
    {
        -- go箭头提示标
        kGoDirection = 0,
        -- 实物所在zorder（避免与tmx的其他图块层的zorder重合，所以要预留出一部分zorder给图块层使用）
        kEntity = 50,
        -- NpcRole所在zorder的最小起始值（避免与tmx的其他图块层的zorder重合，所以要预留出一部分zorder给图块层使用）
        kNpcRole = 80,
        -- Role所在zorder的最小起始值（避免与tmx的其他图块层的zorder重合，所以要预留出一部分zorder给图块层使用）
        kMinRole = 100,
        -- Skill所在zorder（避免与tmx的其他图块层的zorder重合，所以要预留出一部分zorder给图块层使用）
        kMinSkill = 100,
        kMaxSkill = 10000,
        -- 场景动画所在zorder的最小起始值
        kMinMapAni = 100,
        -- sky所在的zorder
        kSky = 30000,
        -- Layer所在的zorder
        kLayer = 200,
        -- 主UI层所在的zorder
        kMainUiLayer = 210,
        -- MaskBgLayer所在的zorder
        kMaskBgLayer = 300,
        -- Dialog所在的zorder
        kDialog = 400,
        -- 添加系统提示文字所在的zorder
        kSystemMessageLayer = 600,

        -- 前置Mask所在的zorder
        kPreposMaskLayer = 800,
        -- Debug层所在的zorder
        kMapDebugLayer = 10000,
        kEntityDebugLayer = 10001,
        kRectDebugLayer = 10002,
        kRoleDebugLayer = 10003,
        kTriggerDebugLayer = 10004,
        kSkillDebugLayer = 10005,
       
        -- 新手引导层所在的zorder
        kNewbieLayer = 888888,
        
        -- TransitionLayer的zorder
        kTransitionLayer = 900000,
        
        -- 等待层所在的zorder
        kWaitingLayer = 990000,
        
        -- zorder最大值
        kMax = 999999,
        
    }

-- 方向定义
kDirection =
    {
        kNone           =       0x00,      -- 无方向
        kUp             =       0x01,      -- 上
        kDown           =       0x02,      -- 下
        kLeft           =       0x04,      -- 左
        kRight          =       0x08,      -- 右
        kLeftUp         =       0x10,      -- 左上
        kLeftDown       =       0x20,      -- 左下
        kRightUp        =       0x40,      -- 右上
        kRightDown      =       0x80,      -- 右下
    }

-- 所有类型定义
kType =
    {
        kSky = 
        {
            kDaySunShine = 0,               -- 【白日】晴天
            kDayCloudy = 1,                 -- 【白日】多云
            kDayRainy = 2,                  -- 【白日】下雨
            kDayCloudyRainy = 3,            -- 【白日】多云下雨
            kNightSunShine = 4,             -- 【夜晚】晴天
            kNightCloudy = 5,               -- 【夜晚】多云
            kNightRainy = 6,                -- 【夜晚】下雨
            kNightCloudyRainy = 7,          -- 【夜晚】多云下雨
        },
        -------------多元文本元素类型------------
        kElementText = 
        {
            kElement = 
            {
                kNone = 0,          -- 无
                kWords = 1,         -- 文字
                kImage = 2,         -- 图片
            }
        },
        -------------品质类型-------------------
        kQuality = 
        {
            kNone = 0,          -- 品质：无
            kWhite = 1,         -- 品质：白
            kGreen = 2,         -- 品质：绿
            kBlue = 3,          -- 品质：蓝
            kPurple = 4,        -- 品质：紫
            kOrange = 5,        -- 品质：橙
        },
        -------------副本类型-------------------
        kCopy =
        {
            kNone = 0,          -- 无效
            kGold = 1,          -- 金钱副本
            kStuff = 2,         -- 材料副本
            kMaze = 3,          -- 迷宫副本
            kChallenge = 4,     -- 挑战副本
            kTower = 5,         -- 爬塔副本
            kMapBoss = 6,       -- 地图boss副本
            kMidNight = 7,      -- 午夜惊魂副本
            kPVP = 8,           -- 排行榜副本
            kHuaShan = 9,       -- 华山论剑副本
            kStory = 10,        -- 剧情副本

        },
        -------------副本类型(文字)-------------------
        kCopyDesc =
        {
            ["0"] = "",          -- 无效
            ["1"] = "金钱副本",          -- 金钱副本
            ["2"] = "材料副本",         -- 材料副本
            ["3"] = "迷宫副本",          -- 迷宫副本
            ["4"] = "挑战副本",     -- 挑战副本
            ["5"] = "爬塔副本",         -- 爬塔副本
            ["6"] = "地图BOSS副本",       -- 地图boss副本
            ["7"] = "午夜惊魂",      -- 午夜惊魂副本
            ["8"] = "竞技场",           -- 排行榜副本
            ["9"] = "斗神殿",       -- 华山论剑副本
            ["10"] = "剧情副本",        -- 剧情副本

        },
        -------------动画展现类型----------------
        kAni =
        {
            kNone = 0,
            k2D = 2,
            k3D = 3,
            kParticle = 4,
        },
        -------------地图中属性格子类型----------------
        kTiledAttri =
        {
            kNone = 0,           -- 无效
            kFree = 1,           -- 自由空地（可利用）
            kBarrier = 2,        -- 障碍物（不可利用）
        },
        --------------状态机类型------------------
        kStateMachine =
        {
            kNone = 0,                      -- 无效状态机
            kWorldEntity = 1,               -- 世界实体状态机
            kWorldNpcRole = 2,              -- 世界NPC角色状态机
            kWorldPlayerRole = 3,           -- 世界玩家角色状态机
            kWorldPetRole = 4,              -- 世界玩家宠物角色状态机
            kWorldOtherPlayerRole = 5,      -- 世界其他玩家状态机
            kWorldOtherPetRole = 6,         -- 世界其他宠物状态机
            kBattleEntity = 7,              -- 战斗实体状态机
            kBattlePlayerRole = 8,          -- 战斗玩家角色状态机
            kBattlePetRole = 9,             -- 战斗玩家宠物角色状态机
            kBattleMonster = 10,            -- 战斗怪物角色状态机
            kBattleFriendRole = 11,         -- 战斗好友角色状态机
            kBattleSkill = 12,              -- 战斗技能状态机
        },
        ---------------状态类型--------------------
        kState =
        {
            kNone = 0,  -- 无效状态
            kWorldEntity =   -- 世界实体状态
            {
                kNone = 0,      -- 无效状态
                kNormal = 1,    -- 正常状态
            },
            kWorldNpcRole =     -- 世界NPC角色状态
            {
                kNone = 0,      -- 无效状态
                kStand = 1,     -- 站立状态
            },
            kWorldPlayerRole =   -- 世界角色状态
            {
                kNone = 0,      -- 无效状态
                kStand = 1,     -- 站立状态
                kRun = 2,       -- 奔跑状态
            },
            kWorldPetRole =   -- 世界宠物角色状态
            {
                kNone = 0,      -- 无效状态
                kStand = 1,     -- 站立状态
                kRun = 2,       -- 奔跑状态
            },
            kWorldOtherPlayerRole =   -- 世界其他角色状态
            {
                kNone = 0,      -- 无效状态
                kStand = 1,     -- 站立状态
                kRun = 2,       -- 奔跑状态
            },
            kWorldOtherPetRole =   -- 世界其他宠物角色状态
            {
                kNone = 0,      -- 无效状态
                kStand = 1,     -- 站立状态
                kRun = 2,       -- 奔跑状态
            },
            kBattleEntity =   -- 战斗实体状态
            {
                kNone = 0,          -- 无效状态
                kNormal = 1,        -- 正常状态
                kSkillAttack = 2,   -- 技能攻击状态
                kDestroy = 3,       -- 摧毁状态
            },
            kBattlePlayerRole =   -- 战斗角色状态
            {
                kNone = 0,          -- 无效状态
                kAppear = 1,        -- 出场状态
                kStand = 2,         -- 站立状态
                kRun = 3,           -- 奔跑状态
                kGenAttack = 4,     -- 普通攻击状态
                kSkillAttack = 5,   -- 技能攻击状态
                kAngerAttack = 6,   -- 怒气攻击状态
                kBeaten = 7,        -- 受击打状态
                kDead = 8,          -- 死亡状态
                kFrozen = 9,        -- 冻结状态
                kDizzy = 10,        -- 眩晕状态
            },
            kBattlePetRole =        -- 战斗宠物角色状态
            {
                kNone = 0,          -- 无效状态
                kAppear = 1,        -- 出场状态
                kStand = 2,         -- 站立状态
                kRun = 3,           -- 奔跑状态
                kSkillAttack = 4,   -- 技能攻击状态
                kBeaten = 5,        -- 受击打状态
                kDead = 6,          -- 死亡状态
                kFrozen = 7,        -- 冻结状态
                kDizzy = 8,         -- 眩晕状态
            },
            kBattleFriendRole =     -- 战斗好友角色状态
            {
                kNone = 0,          -- 无效状态
                kSuspend = 1,       -- 挂起状态
                kAppear = 2,        -- 出场状态
                kDisAppear = 3,     -- 退场状态
                kStand = 4,         -- 站立状态
                kSkillAttack = 5,   -- 技能攻击状态
            },
            kBattleMonster =
            {
                kNone = 0,        -- 无效状态
                kSuspend = 1,     -- 挂起状态
                kAppear = 2,      -- 出场状态
                kStand = 3,       -- 站立状态
                kRun = 4,         -- 奔跑状态
                kSkillAttack = 5, -- 技能攻击状态
                kBeaten = 6,      -- 受击打状态
                kDead = 7,        -- 死亡状态
                kFrozen = 8,      -- 冻结状态
                kDizzy = 9,       -- 眩晕状态
            },
            kBattleSkill =
            {
                kNone = 0,       -- 无效状态
                kIdle = 1,       -- 空闲状态
                kChant = 2,      -- 吟唱状态
                kProcess = 3,    -- 执行状态
                kRelease = 4,    -- 释放状态
            },
        },
        --------------控制机类型----------------------
        kControllerMachine =
        {
            kNone = 0,              -- 无效控制机
            kBattleBuff = 1,        -- 战斗Buff控制机
            kBattlePassive = 2,     -- 战斗Passive控制机
        },
        --------------控制类型-----------------------
        kController =
        {
            kNone = 0,
            kBuff = 
            {
                kNone = 0,                          -- 无效控制
                kBattleFireBuff = 1,                -- 灼烧Buff
                kBattleColdBuff = 2,                -- 寒冷Buff
                kBattleThunderBuff = 3,             -- 雷击Buff
                kBattleDizzyBuff = 4,               -- 眩晕Buff
                kBattlePoisonBuff = 5,              -- 中毒Buff
                kBattleAddHpBuff = 6,               -- 持续加血Buff
                kBattleGodBuff = 7,                 -- 无敌Buff
                kBattleGhostBuff = 8,               -- 虚影Buff
                kBattleAttriUpBuff = 9,             -- 属性增益Buff
                kBattleAttriDownBuff = 10,          -- 属性弱化Buff
                kBattleSpeedDownBuff = 11,          -- 减速Buff
                kBattleHpLimitUpBuff = 12,          -- 增加血量上限Buff
                kBattleClearAndImmuneBuff = 13,     -- 异常抵抗（免疫）Buff
                kBattleRigidBodyBuff = 14,          -- 钢体Buff
                kBattleFightBackFireBuff = 15,      -- 属性反击-火Buff
                kBattleFightBackIceBuff = 16,       -- 属性反击-冰Buff
                kBattleFightBackThunderBuff = 17,   -- 属性反击-雷Buff
                kBattleSunderArmorBuff = 18,        -- 破甲Buff
                kBattleBuffTotalNum = 18,           -- 战斗Buff总类数
            },
            kPassive = 
            {
                kNone = 0,                              -- 无效控制
                kBattleDoWhenHpBelowPassive = 1,        -- 血量低于多少时passive
                kBattleDoWhenPetDeadPassive = 2,        -- 宠物死亡passive
                kBattleAddHpWhenDoPassive = 3,          -- 每次xx时恢复血量passive
                kBattleDoWhenAngerIsReadyPassive = 4,   -- 怒气技能准备就绪时passive
                kBattleDoWhenAnyEnemyDeadPassive = 5,   -- 每杀死一个敌方单位passive
                kBattleDoWhenGetDebuffPassive = 6,      -- 受到异常buff的passive
                kBattleDoWhenBeSafePassive = 7,         -- 未被攻击x秒钟时passive
                kBattlePassiveTotalNum = 7,             -- 战斗Passive总类数
            },
            
        },
        --------------触发器动作项类型-----------------------
        kTriggerItemType =
        {
            kNone = 0,          -- 无效
            kDelay = 1,         -- 延时
            kCamera = 2,        -- 镜头
            kDoor = 3,          -- 传送门
            kMonsterArea = 4,   -- 野怪区域
            kDialog = 5,        -- 对话框触发
            kTalks = 6,         -- 剧情对话
        },
        kBattleResult = 
        {
            kBattling = 0,
            kWin = 1,
            kLose = 2,
            kCancel = 3,
        },
        --------------游戏对象-----------------------
        kGameObj =
        {
            kNone = 0,      -- 无效对象
            kRole = 1,      -- 角色对象
            kEntity = 2,    -- 实体对象
        },
        -------------角色类型------------------------
        kRole =
        {
            kNone = 0,          -- 无效角色
            kPlayer = 1,        -- 玩家角色
            kNpc = 2,           -- NPC角色
            kMonster = 3,       -- 野怪角色
            kPet = 4,           -- 宠物角色
            kFriend = 5,        -- 好友角色
            kOtherPlayer = 6,   -- 其他玩家角色
            kOtherPet = 7,      -- 其他宠物角色
        },
        -------------宠物类型------------------------
        kPet =
        {
            kNone = 0,       -- 无效宠物角色
            kPet1 = 1,       -- 宠物角色1
            kPet2 = 2,       -- 宠物角色2
            kPet3 = 3,       -- 宠物角色3
            kPet4 = 4,       -- 宠物角色4
            kPet5 = 5,       -- 宠物角色5
            kPet6 = 6,       -- 宠物角色6
            kPet7 = 7,       -- 宠物角色7
            kPet8 = 8,       -- 宠物角色8
            kPet9 = 9,       -- 宠物角色9
            kPet10 = 10,     -- 宠物角色10
            
        },
        -------------野怪类型------------------------
        kMonster =
        {
            kNone = 0,       -- 无效
            kNormal = 1,     -- 普通怪
            kBOSS = 2,       -- BOSS
            kThiefBOSS = 3,  -- 盗宝贼(BOSS)
        },
        -------------实体类型------------------------
        kEntity =
        {
            kNone = 0,              -- 无效实体
            kCanbeDestroyed = 1,    -- 可被摧毁
            kDoor = 2,              -- 传送门 （不可被摧毁）
            kRoadBlock = 3,         -- 屏障（不可被摧毁）
            kPoisonPool = 4,        -- 毒池塘（不可被摧毁）
            kSwamp = 5,             -- 沼泽（不可被摧毁）
            kRollHammer = 6,        -- 旋转锤（可被摧毁）
            kBomb = 7,              -- 地雷（不可被摧毁）
            kSpikeRock = 8,         -- 地刺（可被摧毁）
            kFireMachine = 9,       -- 喷火机关（可被摧毁）
        },
        ------------技能类型-------------------------
        kSkill =
        {
            ------------技能方式类型-------------------------
            kWayIndex =
            {
                kNone = 0,
                --------玩家角色---------------
                kPlayerRole =
                {
                    kGenAttack = 1,
                    kSkill1 = 2,
                    kSkill2 = 3,
                    kSkill3 = 4,
                    kSkill4 = 5,
                    kAngerAttack = 6,
                },
                --------宠物角色---------------
                kPetRole =
                {
                    kSkill1 = 1,
                    kSkill2 = 2,
                    kSkill3 = 3,
                    kSkill4 = 4,
                },
                --------野怪-------------------
                kMonsterRole =
                {
                    kSkill1 = 1,
                    kSkill2 = 2,
                    kSkill3 = 3,
                    kSkill4 = 4,
                    kSkill5 = 5,
                    kSkill6 = 6,
                },
            },
            ------------技能类型ID-------------------------
            kID =
            {
                kNone = 0,

                --------战士相关-------------------
                kWarriorGenAttack = 1,
                kWarriorAngerSkill1 = 2,     -- 绝剑·空裂
                kWarriorAngerSkill2 = 3,     -- 绝剑·焚天
                kWarriorAngerSkill3 = 4,     -- 绝剑·黑白
                kWarriorSkill1 = 5,          -- 钢气斩
                kWarriorSkill2 = 6,          -- 一断剑
                kWarriorSkill3 = 7,          -- 万仞山
                kWarriorSkill4 = 8,          -- 裂风斩
                kWarriorSkill5 = 9,          -- 鬼神惊
                kWarriorSkill6 = 10,          -- 奔雷斩
                kWarriorSkill7 = 11,          -- 风暴剑
                kWarriorSkill8 = 12,         -- 炎螺旋
                kWarriorSkill9 = 13,         -- 炎魔碎
                kWarriorSkill10 = 14,        -- 金刚身
                kWarriorSkill11 = 15,        -- 大地铠
                kWarriorSkill12 = 16,        -- 大升天

                --------法师相关-------------------
                kMageGenAttack = 100,
                kMageAngerSkill1 = 101,     -- 青龙斩
                kMageAngerSkill2 = 102,     -- 大凤化阳
                kMageAngerSkill3 = 103,     -- 冰封极光
                kMageSkill1 = 104,          -- 道法·凝冰
                kMageSkill2 = 105,          -- 道法·天雷
                kMageSkill3 = 106,          -- 道法·烈焰
                kMageSkill4 = 107,          -- 守身冰、护身雷、焚身火 
                kMageSkill5 = 108,          -- 冰莲花
                kMageSkill6 = 109,          -- 风雪咒
                kMageSkill7 = 110,          -- 大雷锤
                kMageSkill8 = 111,          -- 鬼炎瞳
                kMageSkill9 = 112,          -- 炎咆哮
                kMageSkill10 = 113,         -- 雷音斩

                --------刺客相关-------------------
                kThugGenAttack = 200,
                kThugAngerSkill1 = 201,     -- 毒龙烟
                kThugAngerSkill2 = 202,     -- 杀戮之瞳
                kThugAngerSkill3 = 203,     -- 幻影阵
                kThugSkill1 = 204,          -- 回旋镖
                kThugSkill2 = 205,          -- 连影杀
                kThugSkill3 = 206,          -- 罗天坠
                kThugSkill4 = 207,          -- 风火雷
                kThugSkill5 = 208,          -- 毒牙弹
                kThugSkill6 = 209,          -- 七星斩
                kThugSkill7 = 210,          -- 无形影
                kThugSkill8 = 211,          -- 飞刀阵
                kThugSkill9 = 212,          -- 死寂杀
                kThugSkill10 = 213,         -- 八方刃
                kThugSkill11 = 214,         -- 腐骨尘
                kThugSkill12 = 215,         -- 嗜血刃

                --------怪物相关-------------------
                kMonsterSkill1 = 300,
                kMonsterSkill2 = 301,
                kMonsterSkill3 = 302,
                kMonsterSkill4 = 303,
                kMonsterSkill5 = 304,
                kMonsterSkill6 = 305,
                kMonsterSkill7 = 306,
                kMonsterSkill8 = 307,
                kMonsterSkill9 = 308,
                kMonsterSkill10 = 309,
                kMonsterSkill11 = 310,
                kMonsterSkill12 = 311,
                kMonsterSkill13 = 312,
                kMonsterSkill14 = 313,
                kMonsterSkill15 = 314,
                kMonsterSkill16 = 315,
                kMonsterSkill17 = 316,
                kMonsterSkill18 = 317,
                kMonsterSkill19 = 318,
                kMonsterSkill20 = 319,
                kMonsterSkill21 = 320,
                kMonsterSkill22 = 321,
                kMonsterSkill23 = 322,
                kMonsterSkill24 = 323,
                kMonsterSkill25 = 324,
                kMonsterSkill26 = 325,
                kMonsterSkill27 = 326,
                kMonsterSkill28 = 327,
                kMonsterSkill29 = 328,
                kMonsterSkill30 = 329,
                kMonsterSkill31 = 330,
                kMonsterSkill32 = 331,
                kMonsterSkill33 = 332,
                kMonsterSkill34 = 333,
                kMonsterSkill35 = 334,
                kMonsterSkill36 = 335,
                kMonsterSkill37 = 336,
                kMonsterSkill38 = 337,
                kMonsterSkill39 = 338,
                kMonsterSkill40 = 339,
                kMonsterSkill41 = 340,
                kMonsterSkill42 = 341,
                kMonsterSkill43 = 342,
                kMonsterSkill44 = 343,
                kMonsterSkill45 = 344,
                kMonsterSkill46 = 345,
                kMonsterSkill47 = 346,
                kMonsterSkill48 = 347,
                kMonsterSkill49 = 348,
                kMonsterSkill50 = 349,
                kMonsterSkill51 = 350,
                kMonsterSkill52 = 351,
                kMonsterSkill53 = 352,
                kMonsterSkill54 = 353,
                kMonsterSkill55 = 354,
                kMonsterSkill56 = 355,
                kMonsterSkill57 = 356,
                kMonsterSkill58 = 357,
                kMonsterSkill59 = 358,
                kMonsterSkill60 = 359,
                kMonsterSkill61 = 360,

                --------实体相关-------------------
                kPoisonPoolSkill = 400,
                kSwampSkill = 401,
                kBombSkill = 402,
                kSpikeRockSkill = 403,
                kRollHammerSkill = 404,
                kFireMachineSkill = 405,
                
                ------- 宠物相关-------------------
                kPetSkill1 = 500,
                kPetSkill2 = 501,
                kPetSkill3 = 502,
                
                ------- 好友技能 -------------------
                kWarriorFriendSkill1 = 600,
                kMageFriendSkill1 = 601,
                kThugFriendSkill1 = 602,

            },
            kElement =
            {
                kNone = 0,
                kPhysic = 1,
                kFire = 2,
                kIce = 3,
                kThunder = 4,
                kTotalNum = 4
            },
        },
        ----------------受击类型---------------------------
        kBeaten =
        {
            kNone = 0,          -- 无反应
            kNoOffset = 1,      -- 原地受击
            kBack = 2,          -- 被击退
            kFall = 3,          -- 被击倒
            kBackAndFall = 4,   -- 被击退同时被击倒
        },
        ----------------- 目标群体类型 -----------------------
        kTargetGroupType =
        {
            kNone = 0,
            kOpposite = 1,   -- 对方
            kSelfs = 2,      -- 己方
            kOneSelf = 3,    -- 自己
        },
        ----------------- 攻击性质类型 -----------------------
        kAttackMode =
        {
            kNone = 0,
            kRevert = 1,   -- 回复
            kDamage = 2,   -- 伤害
        },
        kBodyParts = 
        {
            kNone = 0,
            kBody = 1,
            kWeapon = 2,
            kBack = 3,
        },
        ----------------- 野怪技能的提前预警 ---------------------
        kSkillEarlyWarning = 
        {
            kNone = 0,
            kType1 = 1,
            kType2 = 2,
            kType3 = 3,
            kType4 = 4,
            kType5 = 5,
        },
        ------------------
        kObjCmd = 
        {
            kNone = 0,
            kStand = 1,
            kMove = 2,            
        },
    }

DetailInfosCallbackCMD = {
    -- 装备穿戴
    kDetailCallbackWear = {key = 1001 , name = "穿戴",normalImg = "tips05",selectedImg = "tips06", callback = function (pItemInfo)
        print("穿戴")
        if RolesManager:getInstance()._pMainRoleInfo.level < pItemInfo.dataInfo.RequiredLevel then --等级不足
            NoticeManager:getInstance():showSystemMessage("角色等级不足")
            return
        end
        EquipmentCGMessage:sendMessageWareEquipment20106(pItemInfo.position)
        DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
    end},
    -- 装备分解
    kDetailCallbackAnalysis = {key = 1002 , name = "分解",normalImg = "tips07",selectedImg = "tips08", callback = function (pItemInfo)
        print("分解")
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[8].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("分解功能"..TableNewFunction[8].Level.."级开放")
            return
        end
        -- 装备品质至少三星
        if pItemInfo.dataInfo.Quality < kType.kQuality.kBlue then
            NoticeManager:getInstance():showSystemMessage("装备最低蓝色才可进行分解")
            return
        end
        --cc.Director:getInstance():getRunningScene():showDialog(require("EquipmentDialog"):create(EquipmentTabType.EquipmentTabTypeResolve,pItemInfo))
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeResolve,pItemInfo})
        DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
    end},
    -- 装备强化
    kDetailCallbackIntensify = {key = 1003 , name = "强化", normalImg = "tips09",selectedImg = "tips10", callback = function (pItemInfo,kSrcCalloutType)
        
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[6].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("强化功能"..TableNewFunction[6].Level.."级开放")
            return
        end
        -- 强化等级达到最高级不可强化
        if pItemInfo.value < TableConstants.EquipMaxLevel.Value then
            --cc.Director:getInstance():getRunningScene():showDialog(require("EquipmentDialog"):create(EquipmentTabType.EquipmentTabTypeIntensify,pItemInfo,kSrcCalloutType))
            DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeIntensify,pItemInfo,kSrcCalloutType})
            DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
        else
            NoticeManager:getInstance():showSystemMessage("强化已经满级，不可强化")
        end
        
        NewbieManager:showOutAndRemoveWithRunTime()
    end},
    -- 装备镶嵌
    kDetailCallbackMosaic = {key = 1004 , name = "镶嵌",normalImg = "tips11",selectedImg = "tips12", callback = function (pItemInfo,kSrcCalloutType)
        print("镶嵌")
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[16].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("镶嵌功能"..TableNewFunction[16].Level.."级开放")
            return
        end
        if pItemInfo.baseType == kItemType.kEquip and pItemInfo.dataInfo.InlaidHole <= 0 then
            NoticeManager:getInstance():showSystemMessage("此装备没有宝石孔，无法进行镶嵌")
            return
        end
        local srcType = pItemInfo.baseType == kItemType.kStone and kCalloutSrcType.kCalloutSrcGem or kSrcCalloutType
        if srcType == kCalloutSrcType.kCalloutSrcGem then
            if pItemInfo.dataInfo.RequiredLevel > RolesManager:getInstance()._pMainRoleInfo.level then
                local msg = string.format("镶嵌%s宝石需要达到%d级",pItemInfo.templeteInfo.Name,pItemInfo.dataInfo.RequiredLevel)
                NoticeManager:getInstance():showSystemMessage(msg)
                return
            end
            pItemInfo = nil
        end
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabGemTypeGemInlay,pItemInfo,srcType})
        DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
        -- 如果当前选中的是宝石
        local dialog = DialogManager:getInstance():getDialogByName("EquipmentDialog")
        if srcType == kCalloutSrcType.kCalloutSrcGem then --如果选中的是宝石需要超链接到装备界面
            DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
            dialog._kItemSrcType = kCalloutSrcType.kCalloutSrcEquip
        else --如果选的是装备默认选择宝石界面
            dialog._kItemSrcType = kCalloutSrcType.kCalloutSrcGem
        end
        dialog:selectOneUiByType(EquipmentTabType.EquipmentTabGemTypeGemInlay)

    end},
    -- 装备炼化
    kDetailCallbackSuccinct = {key = 1005 , name = "炼化", normalImg = "tips19",selectedImg = "tips20", callback = function (pItemInfo) print("炼化")
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[15].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("剑灵功能"..TableNewFunction[15].Level.."级开放")
            return
        end
        if pItemInfo.baseType == kItemType.kEquip and pItemInfo.dataInfo.Quality > kType.kQuality.kGreen then
            NoticeManager:getInstance():showSystemMessage("装备品质太高，无法进行炼化")
            return
        end
        TasksManager:getInstance()._bOpenBladeSoul = true
        TasksManager:getInstance()._nOpenType = 1
        BladeSoulCGMessage:sendMessageSelectBladeSoulInfo20700()
        DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
    end},
    -- 装备传承
    kDetailCallbackPass = {key = 1006 , name = "传承", normalImg = "tips15",selectedImg = "tips16", callback = function () print("传承") end},
    -- 物品出售
    kDetailCallbackItemSell = {key = 1007 , name = "出售", normalImg = "tips17",selectedImg = "tips18", callback = function (pItemInfo)
        print("出售")
        if pItemInfo.baseType ==kItemType.kEquip then --假如是装备的只需要弹出提示框
            local nItemName = pItemInfo.templeteInfo.Name
            local nItemPrice =  pItemInfo.dataInfo.Price
            showConfirmDialog("是否确定出售 "..nItemName.." 出售后不可回收\n\n您将获得"..nItemPrice.."金币",function()
                EquipmentCGMessage:sendMessageSellItem20128(pItemInfo.position,1)
                BagCommonManager:getInstance():setSellOutPosition(pItemInfo.position)
                DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
            end)  --（背包中的下表，数量）
        else --弹出复选框标示可以批量出售
            pItemInfo = BagCommonManager:getInstance():getItemInfoByIndex(pItemInfo.position)
            DialogManager:getInstance():showDialog("MutlipeUseItemDialog",{pItemInfo,3,kFinance.kCoin})
        end

    end},
    -- 宝石合成
    kDetailCallbackGemSynthesis = {key = 1008, name = "合成", normalImg = "tips25",selectedImg = "tips26",  callback = function (pItemInfo,kSrcType,args)
        print("合成")
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[17].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("合成功能"..TableNewFunction[17].Level.."级开放")
            return
        end
        -- 判断玩家等级是否满足使用下级宝石需要的等级
        -- 获得下级宝石的信息
        local nextLevelGemInfo = GemManager:getInstance():getGemDataInfoByGemId(pItemInfo.dataInfo.MixResult)
        if nextLevelGemInfo ~= nil and nextLevelGemInfo.dataInfo.RequiredLevel > RolesManager:getInstance()._pMainRoleInfo.level then
            local msg = string.format("合成%s宝石需要达到%d级",nextLevelGemInfo.templeteInfo.Name,nextLevelGemInfo.dataInfo.RequiredLevel)
            NoticeManager:getInstance():showSystemMessage(msg)
            return
        end
        -- 判断是否达到最高级
        if not pItemInfo.dataInfo.MixResult then
            NoticeManager:getInstance():showSystemMessage("已达到最高级")
            return
        end
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return
        end
        if not kSrcType or kSrcType == kCalloutSrcType.kCalloutSrcBagCommon then
            DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeGemCompound,pItemInfo})
            DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
            DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
            return
        end
        local function okCallback ()
            -- 向服务器发送宝石合成的协议
            if kSrcType == kCalloutSrcType.kCalloutSrcBagEquipGem then
                GemSystemCGMessage:sendMessageGemSynThesis20116(args.index,pItemInfo.dataInfo.ID)
            else
                GemSystemCGMessage:sendMessageGemSynthesis20118(args.part,pItemInfo.dataInfo.ID)
            end
            DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
        end
        -- 获得背包中该物品的真实数量
        pItemInfo.value = BagCommonManager:getInstance():getItemRealInfo(pItemInfo.dataInfo.ID,pItemInfo.baseType).value
        -- 判断是否达到最高级
        if not pItemInfo.dataInfo.MixResult then
            NoticeManager:getInstance():showSystemMessage("已达到最高级")
            return
        end
        local strNextGemName = GemManager:getInstance():getGemDataInfoByGemId(pItemInfo.dataInfo.MixResult).templeteInfo.Name
        -- 判断背包中材料是否齐全
        if 5 > pItemInfo.value then
            --  缺少宝石的数量
            local lackGemNum =  4 - pItemInfo.value
            -- 需要花费的钻石数量
            local needPrice =  pItemInfo.dataInfo.ShopPrice * lackGemNum
            local msg = string.format("确定需要花费%d玉璧购买%d个%s合成一个%s?",needPrice,
                lackGemNum,pItemInfo.templeteInfo.Name,strNextGemName)

            showConfirmDialog(msg,okCallback)
        else
            local msg = string.format("确定消耗%d个%s合成一个%s?",5,
                pItemInfo.templeteInfo.Name,strNextGemName)
            showConfirmDialog(msg,okCallback)
        end
    end},
    -- 宝石卸下
    kDetailCallbackGemDisboard = {key = 1009, name = "卸下", normalImg = "tips27",selectedImg = "tips28", callback = function (pItemInfo,kSrcType,args)
        print("卸下")
        -- 如果当前装备为背包中
        if kSrcType == kCalloutSrcType.kCalloutSrcBagEquipGem then
            GemSystemCGMessage:sendMessageInlayBagEquipReq20120(true,args.index,pItemInfo.dataInfo.ID,0)
        else
            GemSystemCGMessage:sendMessageInlayRoleEquipReq20122(true,args.part,pItemInfo.dataInfo.ID,0)
        end
        DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
    end},
    -- 物品使用
    kDetailCallbackItemUse = {key = 1010, name = "使用", normalImg = "tips21",selectedImg = "tips22", callback = function (pItemInfo)
        print("使用")
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return
        end
        if pItemInfo.baseType == kItemType.kBox then --如果是宝箱
            OpenItemSystemCGMessage:sendMessageOpenBox20132(pItemInfo.position,1)
            -- 刷新一下数据 
            pItemInfo = BagCommonManager:getInstance():getItemInfoByPosition(pItemInfo.position)
            if pItemInfo.value - 1 < 1 then 
                DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
            end
        end
        if pItemInfo.dataInfo.UseType == kItemUseType.kPetFood then  -- 如果是宠物食材
            DialogManager:showDialog("PetDialog",{})
            DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
        elseif pItemInfo.dataInfo.UseType == kItemUseType.kFriendGift then  -- 如果是好友礼物
            DialogManager:showDialog("FriendsDialog",{})
        elseif pItemInfo.dataInfo.UseType == kItemUseType.kExpPill then  -- 如果是经验丹
        local buffId = pItemInfo.dataInfo.Property[1]
        local buffType = TableHomeBuff[buffId].ReplaceType
            if BuffManager:selectBuffIsExistByBuffType(buffType)then 
                showConfirmDialog("您已经拥有了此类BUFF，立即使用会覆盖之前的buff，是否继续使用？",function()
                OpenItemSystemCGMessage:sendMessageEatPills20134(pItemInfo.position,1)end) 
        	else
               OpenItemSystemCGMessage:sendMessageEatPills20134(pItemInfo.position,1)
           end
          
        end
     
    end},
    -- 物品批量使用
    kDetailCallbackItemBatchUse = {key = 1011, name = "批量使用",  normalImg = "tips23",selectedImg = "tips24",callback = function (pItemInfo)
        print("批量使用")
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return
        end
        pItemInfo = BagCommonManager:getInstance():getItemInfoByPosition(pItemInfo.position)
        DialogManager:getInstance():showDialog("MutlipeUseItemDialog",{pItemInfo,1})
    end},
    -- 物品锻造
    kDetailCallbackItemForge = {key = 1012, name = "锻造",  normalImg = "tips29",selectedImg = "tips30",callback = function (pItemInfo)
        print("锻造")
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[26].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("装备锻造"..TableNewFunction[26].Level.."级开放")
            return
        end
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeEquFoundry,pItemInfo})
        DialogManager:getInstance():closeDialogByName("BagCallOutDialog")

    end},
    -- 装备镶嵌宝石tips镶嵌按钮
    kDetailCallbackGemSysMosaic = {key = 1013, name = "镶嵌", normalImg = "tips11",selectedImg = "tips12",callback = function(pItemInfo)
        local pEquipDialog = DialogManager:getInstance():getDialogByName("EquipmentDialog")
        if pEquipDialog ~= nil then 
            pEquipDialog._pGemInlayInfoView:gemTipsCallback(pItemInfo)
        end
        DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
    end},
}

-- 背包显示类别

BagTabType = {
    BagTabTypeAll = 1,
    BagTabTypeEquip = 2,
    BagTabTypeStone = 3,
    BagTabTypeItem = 4
}


-- callout（tips）来源
kCalloutSrcType = {
    KCalloutSrcTypeUnKnow = 0, -- 位置未知(不需要显示按钮标签列表)
    kCalloutSrcEquip = 1,     -- 装备栏面板
    kCalloutSrcBagCommon = 2, -- 背包面板
    kCalloutSrcGem = 3,       -- 是宝石
    kCalloutSrcBagEquipGem = 4,  -- 背包里的装备上的宝石
    kCalloutSrcRoleEquipGem = 5, -- 身上的装备上的宝石
    kCalloutSrcGemSysMosaic = 6, -- 装备系统宝石镶嵌的宝石
}

-- 角色职业名称
kRoleCareerTitle = {"修罗","鱼姬","夜叉"}

-- 角色头像
kRoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}

-- 角色职业的字体颜色
kRoleCareerFontColor = { 
        cRed, -- 战士（红色）
        cBlue,-- 法师 （蓝色）
        cPurple,-- 刺客 (紫色)
}    

-- 装备的位类型定义
kEquipPositionTypeTitle = {"头部","身体","手","腿","武器","项链","戒指","时装背","时装身","时装光环"}

-- 属性名称类型定义
kAttributeNameTypeTitle = {"生命","攻击", "防御","暴率","暴伤","韧性","抗性", "格挡", "穿透","闪避", "属强","火攻", "冰攻", "雷攻", "再生", "吸血" }

-- 货币的名称
kFinanceNameTypeTitle = {"玉璧","铜钱","元神","斗魂","荣誉","家族活跃","家族贡献"}

-- 根据品质设置字体的颜色
kQualityFontColor3b = {
    cWhite, -- 白
    cGreen,   -- 绿
    cBlue,  -- 蓝
    cPurple,  -- 紫
    cOrange,   -- 橙
}

-- 装备系统标签的类型
EquipmentTabType = {
    EquipmentTabTypeResolve = 1,         --分解
    EquipmentTabTypeIntensify = 2,       --强化
    EquipmentTabGemTypeGemInlay = 3,     --宝石镶嵌
    EquipmentTabTypeGemCompound = 4,     --宝石合成
    EquipmentTabTypeEquFoundry  = 5,     --锻造
    EquipmentTabTypeRefine = 6,          --洗练
    EquipmentTabTypeInherit = 7,         --传承
    EquipmentTabTypeAll = 8
}

RoleDialogTabType = {
    RoleDialogTypeBag = 1,         --背包
    RoleDialogTypeDetail = 2,       --详细信息
}

fairyLandTabType = {
    fairyLandTabInlay = 1,         --镶嵌
    fairyLandTabDrop = 2,     --卸下
    fairyLandTabAllAttUp = 3,   --整体提升效果

}

boxInfoShowType = {
    kBoxstoryCopy = 1,             --剧情副本界面
    kTaskAward = 2,                --任务领取活跃度礼包界面
    kVipDialog = 3,                -- vip领取宝箱
}
--cdManager里面的cdKey
cdType = {
    kNeightBuffOne = 1,        --午夜惊魂buff1  
    kNeightBuffTwo = 2,        --午夜惊魂buff2
    kNeightBuffThree = 3,      --午夜惊魂buff3
    kSmallExpDan = 4,          --小经验丹
    kMiddleExpDan = 5,         --中经验丹
    kBigExpDan = 6,            --大经验丹
    kUpGold = 7,               --提升金钱
    kUpBP = 8,                 --提升境界点
    kUpSP = 9,                 --提升斗魂
    kUpHp = 10,                --提升血
    kUpAttack = 11,            --提升攻击
    kUpDef = 12,               --提升防御
    kChatNew = 100,            --提示有新的聊天消息
    kChatWord = 101,           --世界聊天消息
    kChatFamily = 102,         --家族聊天消息
    kChatPrivate = 103,        --私聊消息
    kChatTeam = 104,           --队伍聊天
    kChatMakeTeam = 105,       --组队消息
    kChatSystem = 106,         --系统消息
    kChatVoiceTime = 107,      --语音消息
    kServerRank =108,          --服务器排队界面
    kNPcTalk = 200,            --npcTag(200-299)npc占用
    kNpcWaiting = 298,         --npc等待的cd
    kNpcTalkMax = 299,         --npcTag
    
}

kOptionType = {
    NoneOption = 0,
    LoginOption = 1,
    MainOption = 2
}

-- 帮助面板系统类型
kHelpSysType = {
    kHuaShanPvp = 1, -- 华山论剑系统
}

-- 家族的权限类型
kFamilyChiefType = {
   kChief = "SetChief",  -- 任命族长
   kViceCheif = "SetViceChief", -- 任命副族长
   kElders = "SetElders", -- 任命长老
   kMember = "SetMember", -- 任命成员
   kJoinFamily = "JoinFamily", -- 同意/拒绝加入家族
   kExpelMember = "ExpelMember", -- 开除成员
   kUpgradeFamily = "UpgradeFamily", -- 升级家族
   kUpgradeLab = "UpgradeLab", -- 研究院升级
   kUpgradeBuff = "UpgradeBuff", -- 升级家族科技
   kActiveBuff = "FamilyBuff", -- 激活家族科技
   kChangeName = "ChangeName", -- 修改家族名称
   kChangePurpsoe = "ChangePurpose", -- 修改家族宗旨
}

kCopyDesc = {
    ["0"] = "",  --// 无效
    ["1"] = "",  --// 打副本
    ["2"] = "竞技场挑战",  --// 竞技场挑战
    ["3"] = "分解",  --// 分解
    ["4"] = "合成",  --// 合成
    ["5"] = "镶嵌",  --// 镶嵌
    ["6"] = "锻造",  --// 锻造
    ["7"] = "升级境界丹",  --// 升级境界丹
    ["8"] = "升级境界盘",  --// 升级境界盘
    ["9"] = "炼化剑魂",  --// 炼化剑魂
    ["10"] = "吞噬剑魂",  --// 吞噬剑魂
    ["11"] = "唤醒美人",  --// 唤醒美人
    ["12"] = "亲密美人",  --// 亲密美人
    ["13"] = "美人升级",  --// 美人升级
    ["14"] = "技能升级",  --// 技能升级
    ["15"] = "给宠物喂食",  --// 给宠物喂食
    ["16"] = "宠物升级",  --// 宠物升级
    ["17"] = "合成宠物",  --// 合成宠物
    ["18"] = "给宠物升阶",  --// 给宠物升阶
    ["19"] = "充值",  --// 充值
    ["20"] = "消耗钻石",  --// 消耗钻石
    ["21"] = "升级",  --// 升级
    ["22"] = "使用道具",  --// 使用道具
    ["23"] = "消耗体力",  --// 消耗体力
    ["24"] = "申请好友",  --// 申请好友
    ["25"] = "强化",  --// 强化
    ["26"] = "战斗力",  --// 战斗力
    ["27"] = "好友数量",  --// 好友数量
    ["28"] = "好友亲密度",  --// 好友亲密度
    ["29"] = "好友礼包",  --// 好友礼包
    ["30"] = "加入家族",  --// 加入家族
    ["31"] = "家族贡献",  --// 家族贡献
    ["32"] = "完成某类型任务N次",  --// 完成某类型
    ["33"] = "出售酒品",  --// 出售酒品
    ["34"] = "购买酒品",  --// 购买酒品
}

kFamilyType = {
    kFamilyInfo = 1,           --家族信息
    kFamilyManage = 2,         --家族管理
    kFamilyScience = 3,        --家族科技
    kFamilyApplyFor = 4,       --家族申请
    kFamilyDynamic = 5,        --家族动态
}

kChangeNameType = {
    kChangeRoleName = 1,       --修改人名
    kChangeFamilyName = 2,     --修改家族名字
}
kFamilyUpLevelType = {
    kUpFamilyLevel = 1,       --升级家族
    kUpTechLevel = 2,         --升级研究所
    kUpBuff = 3,              --升级buff
    kActiveBuff = 4,          --激活buff
}

-- 家族职位名称
kFamilyPositionTitle = {"族长","副族长","长老","成员"}

--按照什么结算的副本（积分，时间）
kResultType = {
    kGreadResult = 1,
    kTimeResult = 1,
}