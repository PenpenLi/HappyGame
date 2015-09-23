#ifndef _COMMON_RC4_PARSER_H_
#define _COMMON_RC4_PARSER_H_

#include "xcore_define.h"
#include "xcore_rc4.h"

namespace common {

////////////////////////////////////////////////////////////////////////////////
// class XCommonRC4Parser
////////////////////////////////////////////////////////////////////////////////
class XCommonRC4Parser
{
public:
	XCommonRC4Parser(const string& key);

	virtual ~XCommonRC4Parser();

	virtual bool put_bytes(const void* src, uint32 len);

	virtual bool need_bytes(void** ppbuf, uint32& len);

	virtual byte* get_byte_message(uint32& len);

	virtual byte* to_byte_message(byte* data, uint32 len, uint32& sendLen);

	virtual bool has_error();

private:
	uint8*               m_buffer;
	uint32               m_cmdLen;
	uint32               m_head_len;
	uint32				 m_buffer_len;
	uint32               m_request_seq;
	bool                 m_hasError;
	RC4                  m_input_rc4;  // 协议输入解密
	RC4                  m_output_rc4; // 协议输出加密
};

}//namespace common

using namespace common;

#endif//_COMMON_RC4_PARSER_H_
