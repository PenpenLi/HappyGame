#ifndef _COMMON_PARSER_H_
#define _COMMON_PARSER_H_

#include "xcore_define.h"
#include "common_message.h"

namespace common {

////////////////////////////////////////////////////////////////////////////////
// class XCommonParser
////////////////////////////////////////////////////////////////////////////////
class XCommonParser
{
public:
	XCommonParser();

	virtual ~XCommonParser();

	virtual bool put_bytes(const void* src, uint32 len);

	virtual bool need_bytes(void** ppbuf, uint32& len);

	virtual XMessage* get_message();

	virtual bool to_buffer(XMessage* msg, void** ppBuff, uint32& len);

	virtual bool has_error();

private:
	XCommonBaseMessage* create_message(CommonCmdHeader_& header);

private:
	uint8*                m_buffer;
	uint32               m_cmdLen;
	uint32               m_head_len;
	uint32				 m_buffer_len;
	uint32               m_request_seq;
	bool                 m_hasError;
};

}//namespace common

using namespace common;

#endif//_COMMON_PARSER_H_
