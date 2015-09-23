#ifndef _COMMON_DEFINE_H_
#define _COMMON_DEFINE_H_

#include "xcore_define.h"

namespace common{

///////////////////////////////////////////////////////////////////////////////
// 命令号定义
///////////////////////////////////////////////////////////////////////////////
#define COMMON_CMD_UNKNOWN_REQ                  0       // 用于匹配未知请求命令
#define COMMON_CMD_UNKNOWN_RESP                 1       // 用于匹配未知回复命令
#define COMMON_CMD_BASE                         1000    // 起始号


///////////////////////////////////////////////////////////////////////////////
// 相关宏和结构定义
///////////////////////////////////////////////////////////////////////////////

#define COMMON_MSG_MAX_LENGTH 20480  // 最大消息大小定义

struct CommonCmdHeader_
{
	uint32 m_cmdNum;  // 消息编号
	uint32 m_cmdSeq;  // 消息序列号(递增)
	uint32 m_reserve; // 保留字段
};

struct CommonReqHeader_ : public CommonCmdHeader_
{
	uint32 m_srcId;   // 操作源ID
	uint32 m_session; // 会话ID
};

struct CommonRespHeader_ : public CommonCmdHeader_
{
	int    m_result; // 回复结果码
};

}//namespace common

using namespace common;

#endif//_COMMON_DEFINE_H_
