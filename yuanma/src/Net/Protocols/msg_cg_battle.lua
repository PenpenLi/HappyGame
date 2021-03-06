-- Date: 2015-10
-- File: msg_cg_battle.lua
-- Auth: generated by auto tool 'lazybone'
-- Desc: message define
--// 定义了客户端与游戏服务间的部分协议
--// 定义用户副本系统协议
--// 协议号分配：21000 ~ 21299


QueryBattleListReqBody = {
    ["name"] = "QueryBattleListReqBody",
    ["id"] = 21000,
    ["attribs"] = {
        {"copyTypes", "uint16", "repeat"},
    },
}

QueryBattleListRespBody = {
    ["name"] = "QueryBattleListRespBody",
    ["id"] = 21001,
    ["attribs"] = {
        {"battleExts", "BattleExtData", "repeat"},
    },
}

EntryBattleReqBody = {
    ["name"] = "EntryBattleReqBody",
    ["id"] = 21002,
    ["attribs"] = {
        {"battleId", "uint32"},
        {"identity", "uint32"},
        {"friendId", "uint32"},
    },
}

EntryBattleRespBody = {
    ["name"] = "EntryBattleRespBody",
    ["id"] = 21003,
    ["attribs"] = {
        {"strength", "uint32"},
        {"cheerTime", "uint32"},
    },
}

UploadBattleResultReqBody = {
    ["name"] = "UploadBattleResultReqBody",
    ["id"] = 21004,
    ["attribs"] = {
        {"battleId", "uint32"},
        {"winData", "BattleWinData"},
    },
}

UploadBattleResultRespBody = {
    ["name"] = "UploadBattleResultRespBody",
    ["id"] = 21005,
    ["attribs"] = {
        {"curStar", "uint32"},
        {"addExp", "uint32"},
        {"extPickCount", "uint32"},
        {"items", "ItemInfo", "repeat"},
        {"finances", "FinanceUnit", "repeat"},
        {"currLevel", "uint32"},
        {"currExp", "uint32"},
        {"roleAttrInfo", "RoleAttrInfo", "repeat"},
        {"cardId", "uint32"},
        {"midNight", "bool"},
    },
}

PickCardReqBody = {
    ["name"] = "PickCardReqBody",
    ["id"] = 21006,
    ["attribs"] = {
        {"index", "uint32"},
    },
}

PickCardRespBody = {
    ["name"] = "PickCardRespBody",
    ["id"] = 21007,
    ["attribs"] = {
        {"cardInfo", "PickCardUnit"},
    },
}

QueryStoryBattleListReqBody = {
    ["name"] = "QueryStoryBattleListReqBody",
    ["id"] = 21008,
    ["attribs"] = {
        {"storyId", "uint32"},
    },
}

QueryStoryBattleListRespBody = {
    ["name"] = "QueryStoryBattleListRespBody",
    ["id"] = 21009,
    ["attribs"] = {
        {"lastStory", "uint32"},
        {"lastBattle", "uint32"},
        {"stories", "StoryBattle", "repeat"},
    },
}

DrawStoryBoxReqBody = {
    ["name"] = "DrawStoryBoxReqBody",
    ["id"] = 21010,
    ["attribs"] = {
        {"storyId", "uint32"},
        {"index", "uint32"},
    },
}

DrawStoryBoxRespBody = {
    ["name"] = "DrawStoryBoxRespBody",
    ["id"] = 21011,
}

QueryTowerBattleListReqBody = {
    ["name"] = "QueryTowerBattleListReqBody",
    ["id"] = 21012,
}

QueryTowerBattleListRespBody = {
    ["name"] = "QueryTowerBattleListRespBody",
    ["id"] = 21013,
    ["attribs"] = {
        {"identity", "uint32"},
        {"towerInfo", "TowerBattle", "repeat"},
    },
}

ReviveReqBody = {
    ["name"] = "ReviveReqBody",
    ["id"] = 21014,
}

ReviveRespBody = {
    ["name"] = "ReviveRespBody",
    ["id"] = 21015,
}

PickCardStateReqBody = {
    ["name"] = "PickCardStateReqBody",
    ["id"] = 21016,
}

PickCardStateRespBody = {
    ["name"] = "PickCardStateRespBody",
    ["id"] = 21017,
    ["attribs"] = {
        {"remainCount", "uint32"},
        {"cardInfo", "PickCardUnit"},
    },
}

QueryBattleInfoReqBody = {
    ["name"] = "QueryBattleInfoReqBody",
    ["id"] = 21018,
    ["attribs"] = {
        {"battleId", "uint32"},
    },
}

QueryBattleInfoRespBody = {
    ["name"] = "QueryBattleInfoRespBody",
    ["id"] = 21019,
    ["attribs"] = {
        {"battleInfo", "BattleExtData"},
    },
}

FormTeamReqBody = {
    ["name"] = "FormTeamReqBody",
    ["id"] = 21020,
    ["attribs"] = {
        {"battleId", "uint32"},
    },
}

FormTeamRespBody = {
    ["name"] = "FormTeamRespBody",
    ["id"] = 21021,
    ["attribs"] = {
        {"memberList", "FormMemberInfo", "repeat"},
    },
}

