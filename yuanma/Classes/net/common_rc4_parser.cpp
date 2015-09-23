#include "common_rc4_parser.h"
#include "common_define.h"
#ifdef __LINUX__
#include <typeInfo>
#endif

namespace common {

///////////////////////////////////////////////////////////////////////////////
// class XCommonRC4Parser
///////////////////////////////////////////////////////////////////////////////
XCommonRC4Parser::XCommonRC4Parser(const string& key)
	: m_buffer(NULL)
	, m_cmdLen(0)
	, m_head_len(0)
	, m_buffer_len(0)
	, m_request_seq((uint32)rand() % 1000 + 1)
	, m_hasError(false)
{
	m_input_rc4.init(key);
	m_output_rc4.init(key);
}

XCommonRC4Parser::~XCommonRC4Parser()
{
	if (m_buffer)
	{
		delete[] m_buffer;
		m_buffer = NULL;
	}
}

bool XCommonRC4Parser::put_bytes(const void* src, uint32 len)
{
	if (m_hasError) return false;
	if (src == NULL || len == 0) return true;

	if (m_head_len < sizeof(uint32))
	{
		assert(len + m_head_len <= sizeof(uint32) && "call exception!");
		memcpy((char *)&m_cmdLen + m_head_len, src, len);
		m_input_rc4.update((const byte*)((char *)&m_cmdLen + m_head_len), (byte*)((char *)&m_cmdLen + m_head_len), len); // 对数据解密
		m_head_len += len;
		if (m_head_len == sizeof(uint32) && 
			(m_cmdLen < sizeof(CommonCmdHeader_) || m_cmdLen + sizeof(uint32) > COMMON_MSG_MAX_LENGTH))
		{
			printf("Invalid Common message, cmdLen is %d.\n", m_cmdLen);
			m_hasError = true;
			return false;
		}
		return true;
	}

	assert(m_buffer);
	assert(m_buffer_len + len <= m_cmdLen && "data size exception!");

	uint8* pos = m_buffer + m_buffer_len;
	if (pos != src) memcpy(pos, src, len);
	m_buffer_len += len;
	m_input_rc4.update((const byte*)pos, (byte*)pos, len); // 对数据解密
	return true;
}
	
bool XCommonRC4Parser::need_bytes(void** ppbuf, uint32& len)
{
	len = 0;
	assert(ppbuf);
	*ppbuf = NULL;
	if (m_hasError) return false;

	assert(m_head_len <= sizeof(uint32));
	if (m_head_len < sizeof(uint32))
	{
		*ppbuf = (char *)&m_cmdLen + m_head_len;
		len = (uint32)sizeof(uint32) - m_head_len;
		return true;
	}
	if (m_cmdLen < sizeof(CommonCmdHeader_) || m_cmdLen + sizeof(uint32) > COMMON_MSG_MAX_LENGTH)
	{
		printf("Invalid Common message, cmdLen is %d.\n", m_cmdLen);
		m_hasError = true;
		return false;
	}

	if (m_buffer == NULL)
	{
		m_buffer = new(nothrow) uint8[m_cmdLen];
		assert(m_buffer && "malloc exception!");
	}

	*ppbuf = m_buffer + m_buffer_len;
	len = m_cmdLen - m_buffer_len;

	return true;
}

byte* XCommonRC4Parser::get_byte_message(uint32& len)
{
	if (m_hasError) return NULL;
	if (m_head_len < sizeof(uint32)) return NULL;
	if (m_buffer == NULL) return NULL;
	if (m_buffer_len < m_cmdLen) return NULL;

	byte* tmp = m_buffer;
	len = m_cmdLen;
	m_buffer = NULL;
	m_cmdLen = 0;
	m_buffer_len = 0;
	m_head_len = 0;
	return tmp;
}

byte* XCommonRC4Parser::to_byte_message(byte* data, uint32 len, uint32& sendLen)
{
	if (data == NULL) return NULL;

	// copy length of message to head
	byte* pBuff = new uint8[len + sizeof(uint32)];
	*(uint32*)(pBuff) = len;
	memcpy(((uint8*)pBuff) + 4, data, len);
	m_output_rc4.update((const byte*)pBuff, (byte*)pBuff, len + sizeof(uint32)); // 对数据加密
	sendLen = len + 4;
	return pBuff;
}

bool XCommonRC4Parser::has_error()
{
	return m_hasError;
}
}//namespace common
