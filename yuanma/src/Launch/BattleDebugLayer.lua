--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/20
-- descrip:   战斗调试入口层
--===================================================
local BattleDebugLayer = class("BattleDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function BattleDebugLayer:ctor()
    self._strName = "BattleDebugLayer"       -- 层名称
end

-- 创建函数
function BattleDebugLayer:create()
    local layer = BattleDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleDebugLayer:dispose()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)        
        if event == "enter" then
        
            -- 初始化游戏文件（代码和资源）
            self:initialGameFiles()
            -- 初始化游戏主场景（进入战斗开发模式）
            self:debugIntoBattle()
            
        elseif event == "exit" then
            self:onExitBattleDebugLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function BattleDebugLayer:onExitBattleDebugLayer()

end

-- 初始化游戏文件（代码和资源）
function BattleDebugLayer:initialGameFiles()

    require("src/paths")
    require("defs")
    require("requirs")
    require("cleans")
    require("funcs")

    -- 加载公共UI库合图资源(一次加载，永驻内存，不需释放)
    ResPlistManager:getInstance():addNecessarySpriteFrames()

    -- 清空所有逻辑管理器的缓存数据
    cleansAllLogicManagersCache()

    -- 初始化设备信息
    LoginManager:getInstance():initDeviceInfo()

    -- 初始化APP信息
    LoginManager:getInstance():initAppInfo()

    -- 注册网络消息handler
    NetHandlersManager:getInstance():registNetHandlers()

    -- 加载网络协议文件
    loadMessageProcotolFiles()

    return
end

-- 快速进入战斗（战斗系统开发调试阶段）
function BattleDebugLayer:debugIntoBattle()

    -- 创建主游戏场景
    local pScene = require("GameScene"):create()
    pScene._bSkipHeartBeat = true -- 暂时屏蔽心跳

    --设置 layer，dialog manager的root
    LayerManager:getInstance():setRootSence(pScene)
    DialogManager:getInstance():setRootSence(pScene)

    --战斗开发快速通道 组装---------------------------------------------------------------------------
    -- 【战斗数据对接】
    -- 测试：
    local copyDataInfo = TableGoldCopys[4]
    local copyFirstMapInfo = TableGoldCopysMaps[copyDataInfo.MapID]
    local args = {}
    args._strNextMapName = copyFirstMapInfo.MapsName
    args._strNextMapPvrName = copyFirstMapInfo.MapsPvrName
    args._nNextMapDoorIDofEntity = copyFirstMapInfo.Doors[1][1]
    args._nMainPlayerRoleCurHp = nil      -- 从副本进入时，这里为无效值
    args._nMainPlayerRoleCurAnger = nil   -- 从副本进入时，这里为无效值
    args._nMainPetRoleCurHp = nil         -- 从副本进入时，这里为无效值
    args._tOtherPlayerRolesCurHp = {}      -- 从副本进入时，这里为无效值
    args._tOtherPlayerRolesCurAnger = {}   -- 从副本进入时，这里为无效值
    args._tOtherPetRolesCurHp = {}         -- 从副本进入时，这里为无效值 
    args._nCurCopyType = kType.kCopy.kGold
    args._nCurStageID = copyDataInfo.ID
    args._nCurStageMapID = copyDataInfo.MapID
    args._nBattleId = copyDataInfo.ID
    args._fTimeMax = copyDataInfo.Timeing
    args._bIsAutoBattle = false
    args._tMonsterDeadNum = {}
    args._nIdentity = 0
    args._tTowerCopyStepResultInfos = {}
    args._pPvpRoleInfo = nil
    args._tPvpRoleMountAngerSkills = {}
    args._tPvpRoleMountActvSkills = {}
    args._tPvpPasvSkills = {}
    args._tPvpPetRoleInfosInQueue = {}
    args._tPvpPetCooperates = {}
    args._tOtherPlayerRolesInfosOnBattleMap = {}
    args._tOtherPlayerRolesMountAngerSkillsInfos = {}
    args._tOtherPlayerRolesMountActvSkillsInfos = {}
    args._tOtherPlayerRolesPasvSkillsInfos = {}
    args._tOtherPetCooperates = {}
    args._bIsFirstBattleOfNewbie = false
    
    -- 主角玩家信息
    require("TestMainRoleInfo")
    args._pMainRoleInfo = mainRoleInfo
    SkillsManager:getInstance()._tMainRoleMountActvSkills = 
        {
        ------------------------------- 战士相关技能 ---------------------------------------
        -- 钢气斩
        --{
          --id=2,
          --level=1
        --},
        --一断剑
        --{
          --id=3,
          --level=1
        --},
        -- 万仞山
        --{
          --id=4,
          --level=1
        --},
        -- 大地铠
        --{
          --id=5,
          --level=1
        --},
        -- 裂风斩
        --{
          --id=12,
          --level=1
        --},
        -- 大升天
        --{
          --  id=13,
          --  level=1
        --},
        -- 金刚身
        --{
          --  id=6,
          --  level=1
        --},
        -- 鬼神惊
        --{
          --  id=7,
          --  level=1
        --},
        -- 奔雷斩
        --{
          --id=8,
          --level=1
        --},
        -- 风暴剑
        --{
          --id=9,
          --level=1
        --},
        -- 炎魔碎
        --{
          --  id=10,
          --  level=1
        --},
        -- 炎螺旋
        --{
          --  id=11,
          --  level=1
        --},
        ------------------------------- 法师相关技能 ---------------------------------------
        -- 道法烈焰
        --{
          --  id=18,
          --  level=1
        --},
        -- 道法凝冰
        --{
          --  id=19,
          --  level=1
        --},
        -- 道法天雷
        --{
          --  id=20,
          --  level=1
        --},
        -- 炎咆哮
          --{
            -- id=21,
            -- level=1
          --},
        -- 冰莲花
        --{
          --  id=22,
          --  level=1
        --},
        -- 雷音斩
        --{
          --  id=23,
          --  level=1
        --},
        -- 守身冰
        --{
        --  id=24,
         -- level=1
        --},
        -- 护身雷
        --{
          --  id=25,
          --  level=1
        --},
        -- 焚身火
        --{
          --  id=26,
          --  level=1
        --},
        -- 风雪咒
         --{
          -- id=27,
          -- level=1
        --},
        -- 鬼炎瞳
        --{
          --  id=28,
          --  level=1
        --},
        -- 大雷锤
        --{
          --  id=29,
          --  level=1
        --},
        ------------------------------- 刺客相关技能 ---------------------------------------
         --飞镖
         --{
           -- id=45,
           -- level=1
         --},
        -- 连影杀
         --{
           --  id=34,
           --  level=1
         --},
        -- 罗天坠
         --{
           -- id=35,
           -- level=1
         --},
        -- 七星斩
        --{
         -- id=36,
         -- level=1
        --},
        -- 风火雷
        --{
          --  id=37,
          --  level=1
        --},
        -- 毒牙弹
        --{
          --  id=38,
          --  level=1
        --},
        -- 腐骨尘
        --{
          --id=39,
          --level=1
        --},
        -- 无形影
        --{
          --  id=40,
          --  level=1
        --},
        -- 嗜血刃
        --{
          --id=41,
          --level=1
        --},
        -- 死寂杀
        --{
          --id=42,
          --level=1
        --},
        -- 八方刃
        --{
          --id=43,
          --level=1
        --},
        -- 飞刀阵
        --{
          --id=44,
          --level=1
        --},
        }
    SkillsManager:getInstance()._tMainRoleMountAngerSkills = 
        {
            -- 杀戮之瞳
            --{
              --  id=46,
              --  level=1
            --},
            -- 毒龙烟
            --{
              --  id = 48,
              --  level = 1
           --}
            -- 青龙斩
            --{
              --  id=30,
              --  level=1
            --},
            -- 绝剑·空裂
            {
              id=14,
              level=1
            },
            -- 绝剑·焚天
            --{
              -- id=15,
              -- level=1
            --},
            -- 绝剑·黑白
            --{
              --id=16,
              --level=1
            --},
            -- 大凤化阳
            --{
              --  id=31,
              --  level=1
            --},
            -- 幻影阵
            --{
              --id=47,
              --level=1
            --},
            -- 冰封极光
            --{
              --  id=32,
              --  level=1
            --},
        
        }

    SkillsManager:getInstance()._tMainRoleSkillsLevels.pasvSkills = 
        {
        --{
          --  id=1001,
          --  level=1
        --},
        --{
          -- id=1002,
          -- level=1
        -- },
        --{
          --id=1003,
          --level=1
        --},
        --{
          --id=1004,
          --level=1
        --},
        }

    -- 好友技能 
    --[[
    require("TestFriendRoleInfo")
    FriendManager:getInstance()._nMountFriendSkill = friendRoleInfo     -- 好友角色信息
    FriendManager:getInstance()._nMountFriendSkillId = 21                -- 好友技能ID
    ]]

    -- 宠物信息
    --[[
    require("TestMainPetRoleInfo1")
    require("TestMainPetRoleInfo2")
    require("TestMainPetRoleInfo3")
    PetsManager:getInstance()._tMainPetRoleInfosInQueue[1] = mainPetRoleInfo1
    PetsManager:getInstance()._tMainPetRoleInfosInQueue[2] = mainPetRoleInfo2
    PetsManager:getInstance()._tMainPetRoleInfosInQueue[3] = mainPetRoleInfo3
    -- 宠物共鸣信息
    RolesManager:getInstance()._tMainPetCooperates[1] = TablePetsResonance[1]
    ]]
    
    -- PVP对手信息
    --[[
    require("TestPvpRoleInfo")
    args._pPvpRoleInfo = pvpRoleInfo
    args._tPvpRoleMountAngerSkills = 
    {
        -- 毒龙烟
        --{
          --  id = 48,
          --  level = 1
        --}
    }
    args._tPvpRoleMountActvSkills = 
    {
        -- 飞镖
        -- {
         --  id=45,
         --  level=1
        -- },
        -- 连影杀
         --{
             --id=34,
             --level=1
         --},
        -- 罗天坠
         --{
           --  id=35,
           --  level=1
         --},
        -- 风火雷
          --{
            --id=37,
            --level=1
          --},
        -- 毒牙弹
         --{
           --id=38,
           --level=1
         --},
        -- 七星斩
        -- {
          --    id=36,
          --    level=1
         -- },
        -- 无形影
          --{
             -- id=40,
             -- level=1
          --},

        -- 飞刀阵
        -- {
        --   id=44,
        --   level=1
        -- },
    }
    args._tPvpPasvSkills = 
    {
        --{
          --  id=1001,
          --  level=1
        --},
        --{
          -- id=1002,
          -- level=1
        -- },
        --{
          --id=1003,
          --level=1
        --},
        --{
          --id=1004,
          --level=1
        --},
    }
    ]]

    -- 宠物信息
    --[[
    require("TestPvpPetRoleInfo1")
    require("TestPvpPetRoleInfo2")
    require("TestPvpPetRoleInfo3")
    args._tPvpPetRoleInfosInQueue[1] = pvpPetRoleInfo1
    args._tPvpPetRoleInfosInQueue[2] = pvpPetRoleInfo2
    args._tPvpPetRoleInfosInQueue[3] = pvpPetRoleInfo3
    -- 宠物共鸣信息
    args._tPvpPetCooperates[1] = TablePetsResonance[1]
    ]]
    -- 战场中的其他玩家信息
    require("TestOtherPlayerRoleInfo1")
    require("TestOtherPlayerRoleInfo2")
    args._tOtherPlayerRolesInfosOnBattleMap = {}
    args._tOtherPlayerRolesMountAngerSkillsInfos = {}
    args._tOtherPlayerRolesMountActvSkillsInfos = {}
    args._tOtherPlayerRolesPasvSkillsInfos = {}

    for i=1, 0 do
      args._tOtherPlayerRolesInfosOnBattleMap[i] = otherPlayerRoleInfo1
      -- 其他玩家的宠物共鸣信息
      args._tOtherPetCooperates[i] = {}
      args._tOtherPetCooperates[i][1] = TablePetsResonance[1]

      args._tOtherPlayerRolesMountAngerSkillsInfos[i] = 
      {
          -- 毒龙烟
          --{
             -- id = 48,
             -- level = 1
          --}
      }
      args._tOtherPlayerRolesMountActvSkillsInfos[i] = 
      {
          -- 飞镖
           --{
             --id=45,
             --level=1
           --},
          -- 连影杀
           --{
               --id=34,
               --level=1
           --},
          -- 罗天坠
           --{
               --id=35,
               --level=1
           --},
          -- 风火雷
           --{
              --id=37,
              --level=1
           --},
          -- 毒牙弹
           --{
             --id=38,
             --level=1
           --},
          -- 七星斩
          -- {
            --    id=36,
            --    level=1
           -- },
          -- 无形影
            --{
               -- id=40,
               -- level=1
            --},

          -- 飞刀阵
          -- {
          --   id=44,
          --   level=1
          -- },
      }
      args._tOtherPlayerRolesPasvSkillsInfos[i] = 
      {
        --{
           --id=1007,
           --level=1
        --},
      }

    end

    LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER, args)

    -- 切换场景
    cc.Director:getInstance():replaceScene(pScene)

    --ResPlistManager:getInstance():addSpriteFrames("pet_icon.plist")

    --local layer = cc.LayerColor:create(cc.c4b(65,65,70,255))
    --pScene:addChild(layer)
    
    --[[
    local node = require("FightRoleUINode"):create(2,"PetIcon/PetIcon4.png",8,"小侏儒",150)
    node:setPosition(cc.p(100,200))
    layer:addChild(node)
    ]]
    --[[
    ResPlistManager:getInstance():addSpriteFrames("battle_common_anis.plist")
    local node = require("StarUINode"):create()
    node:setPosition(cc.p(100,200))
    layer:addChild(node)
    ]]

    return
end

return BattleDebugLayer
