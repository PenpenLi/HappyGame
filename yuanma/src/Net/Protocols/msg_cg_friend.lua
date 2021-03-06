-- Date: 2015-10
-- File: msg_cg_friend.lua
-- Auth: generated by auto tool 'lazybone'
-- Desc: message define
--// 定义了客户端与游戏服务间的部分协议
--// 定义好友相关协议
--// 协议号分配：22000 ~ 22099


QueryFriendListReqBody = {
    ["name"] = "QueryFriendListReqBody",
    ["id"] = 22000,
}

QueryFriendListRespBody = {
    ["name"] = "QueryFriendListRespBody",
    ["id"] = 22001,
    ["attribs"] = {
        {"friendList", "FriendInfo", "repeat"},
    },
}

QueryApplyFriendListReqBody = {
    ["name"] = "QueryApplyFriendListReqBody",
    ["id"] = 22002,
}

QueryApplyFriendListRespBody = {
    ["name"] = "QueryApplyFriendListRespBody",
    ["id"] = 22003,
    ["attribs"] = {
        {"applyFriendList", "ApplyFriendInfo", "repeat"},
    },
}

QueryGiftListReqBody = {
    ["name"] = "QueryGiftListReqBody",
    ["id"] = 22004,
}

QueryGiftListRespBody = {
    ["name"] = "QueryGiftListRespBody",
    ["id"] = 22005,
    ["attribs"] = {
        {"giftList", "GiftInfo", "repeat"},
    },
}

SearchFriendReqBody = {
    ["name"] = "SearchFriendReqBody",
    ["id"] = 22006,
    ["attribs"] = {
        {"name", "string"},
    },
}

SearchFriendRespBody = {
    ["name"] = "SearchFriendRespBody",
    ["id"] = 22007,
    ["attribs"] = {
        {"roleInfo", "ApplyFriendInfo"},
    },
}

RecommendListReqBody = {
    ["name"] = "RecommendListReqBody",
    ["id"] = 22008,
}

RecommendListRespBody = {
    ["name"] = "RecommendListRespBody",
    ["id"] = 22009,
    ["attribs"] = {
        {"recommendList", "ApplyFriendInfo", "repeat"},
    },
}

ApplyFriendReqBody = {
    ["name"] = "ApplyFriendReqBody",
    ["id"] = 22010,
    ["attribs"] = {
        {"roleId", "uint32"},
    },
}

ApplyFriendRespBody = {
    ["name"] = "ApplyFriendRespBody",
    ["id"] = 22011,
}

ReplyApplicationReqBody = {
    ["name"] = "ReplyApplicationReqBody",
    ["id"] = 22012,
    ["attribs"] = {
        {"roleId", "uint32"},
        {"isAgree", "bool"},
    },
}

ReplyApplicationRespBody = {
    ["name"] = "ReplyApplicationRespBody",
    ["id"] = 22013,
    ["attribs"] = {
        {"friendList", "FriendInfo", "repeat"},
        {"applyFriendList", "ApplyFriendInfo", "repeat"},
    },
}

GiftFriendReqBody = {
    ["name"] = "GiftFriendReqBody",
    ["id"] = 22014,
    ["attribs"] = {
        {"roleId", "uint32"},
        {"itemId", "uint32"},
    },
}

GiftFriendRespBody = {
    ["name"] = "GiftFriendRespBody",
    ["id"] = 22015,
    ["attribs"] = {
        {"friendShip", "uint32"},
    },
}

RemoveFriendReqBody = {
    ["name"] = "RemoveFriendReqBody",
    ["id"] = 22016,
    ["attribs"] = {
        {"roleId", "uint32"},
    },
}

RemoveFriendRespBody = {
    ["name"] = "RemoveFriendRespBody",
    ["id"] = 22017,
}

QueryRoleInfoReqBody = {
    ["name"] = "QueryRoleInfoReqBody",
    ["id"] = 22018,
    ["attribs"] = {
        {"roleId", "uint32"},
    },
}

QueryRoleInfoRespBody = {
    ["name"] = "QueryRoleInfoRespBody",
    ["id"] = 22019,
    ["attribs"] = {
        {"roleInfo", "RoleFightInfo"},
    },
}

QueryFriendSkillReqBody = {
    ["name"] = "QueryFriendSkillReqBody",
    ["id"] = 22020,
}

QueryFriendSkillRespBody = {
    ["name"] = "QueryFriendSkillRespBody",
    ["id"] = 22021,
    ["attribs"] = {
        {"friendSkill", "RoleFightInfo", "repeat"},
    },
}

MountFriendSkillReqBody = {
    ["name"] = "MountFriendSkillReqBody",
    ["id"] = 22022,
    ["attribs"] = {
        {"roleId", "uint32"},
    },
}

MountFriendSkillRespBody = {
    ["name"] = "MountFriendSkillRespBody",
    ["id"] = 22023,
    ["attribs"] = {
        {"friendSkill", "RoleFightInfo", "repeat"},
    },
}

