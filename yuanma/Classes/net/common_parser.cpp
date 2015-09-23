#include "common_parser.h"
#include "common_message.h"
#include <typeinfo>

namespace common {

///////////////////////////////////////////////////////////////////////////////
// class XCommonParser
///////////////////////////////////////////////////////////////////////////////
XCommonParser::XCommonParser()
	: m_buffer(NULL)
	, m_cmdLen(0)
	, m_head_len(0)
	, m_buffer_len(0)
	, m_request_seq((uint32)rand() % 1000 + 1)
	, m_hasError(false)
{
	// empty
}

XCommonParser::~XCommonParser()
{
	if (m_buffer)
	{
		delete[] m_buffer;
		m_buffer = NULL;
	}
}

bool XCommonParser::put_bytes(const void* src, uint32 len)
{
	if (m_hasError) return false;
	if (src == NULL || len == 0) return true;

	if (m_head_len < sizeof(uint32))
	{
		assert(len + m_head_len <= sizeof(uint32) && "call exception!");
		memcpy((char *)&m_cmdLen + m_head_len, src, len);
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
	return true;
}
	
bool XCommonParser::need_bytes(void** ppbuf, uint32& len)
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

XMessage* XCommonParser::get_message()
{
	if (m_hasError) return NULL;
	if (m_head_len < sizeof(uint32)) return NULL;
	if (m_buffer == NULL) return NULL;
	if (m_buffer_len < m_cmdLen) return NULL;

	CommonCmdHeader_* cmd = (CommonCmdHeader_*)m_buffer;
	XCommonBaseMessage* message = create_message(*cmd);
	assert(message);

	if (!message->parse_bytes(m_buffer, m_cmdLen))
	{
		printf("Common message(Number:%d) parse failed.\n", cmd->m_cmdNum);
		m_hasError = true;
		return NULL;
	}
	delete m_buffer;
	m_buffer = NULL;
	m_cmdLen = 0;
	m_buffer_len = 0;
	m_head_len = 0;
	return message;
}

bool XCommonParser::to_buffer(XMessage* msg, void** ppBuff, uint32& len)
{
	assert(ppBuff);
	*ppBuff = NULL;
	len = 0;

	XCommonBaseMessage* msg_ = dynamic_cast<XCommonBaseMessage *>(msg);
	if (msg_ == NULL) return false;
	bool is_request = ((msg_->get_number() % 2) == 0);
	if (typeid(*msg) == typeid(CommonEmptyRequest) || typeid(*msg) == typeid(CommonEmptyResponse))
	{
		return true; // 不需要发送的消息
	}

	void* pBuff = NULL;
	bool bl = msg_->to_bytes(&pBuff, len);
	if (!bl || pBuff == NULL) return false;

	CommonCmdHeader_* header = (CommonCmdHeader_*)pBuff;
	if (is_request && (header->m_cmdSeq == 0)) header->m_cmdSeq = ++m_request_seq;  // auto set the sequence of header

	if (is_request)
		printf("<== Common Request: %u.\n", msg_->get_number());
	else
		printf("<== Common Response: %u.\n", msg_->get_number());

	// copy length of message to head
	*ppBuff = new uint8[len + sizeof(uint32)];
	assert(*ppBuff);
	*(uint32*)(*ppBuff) = len;
	memcpy(((uint8*)*ppBuff) + 4, pBuff, len);
	len += 4;
	delete[] pBuff;
	return true;
}

bool XCommonParser::has_error()
{
	return m_hasError;
}

XCommonBaseMessage* XCommonParser::create_message(CommonCmdHeader_& header)
{
	XCommonBaseMessage* msg = XMessageFactory<XCommonBaseMessage, uint32>::instance()->create(header.m_cmdNum);
	if (msg)
	{
		if (header.m_cmdNum % 2 == 0)
			printf("==> Common Request: %u.\n", header.m_cmdNum);
		else
			printf("==> Common Response: %u.\n", header.m_cmdNum);
	}
	else
	{
		if (header.m_cmdNum % 2 == 0)
		{
			printf("Unknown Common Request: %u.\n", header.m_cmdNum);
			CommonUnknownRequest* unknownMsg = new CommonUnknownRequest;
			unknownMsg->header().m_cmdNum = header.m_cmdNum; //
			return unknownMsg;
		}
		else
		{
			printf("Unknown Common Response: %u.\n", header.m_cmdNum);
			CommonUnknownResponse* unknownMsg = new CommonUnknownResponse;
			unknownMsg->header().m_cmdNum = header.m_cmdNum; //
			return unknownMsg;
		}
	}
	return msg;
}

}//namespace common
