#ifndef _COMMON_MESSAGE_H_
#define _COMMON_MESSAGE_H_

#include "xcore_define.h"
#include "xnet_message.h"
#include "common_define.h"
#include "common_message_body.h"

namespace common {

///////////////////////////////////////////////////////////////////////////////
// class XCommonBaseMessage
///////////////////////////////////////////////////////////////////////////////
class XCommonBaseMessage : public XMessage
{
public:
	DEFINE_MESSAGE_VISITABLE();

public:
	virtual ~XCommonBaseMessage() {}

	virtual uint32 get_number() = 0;
	virtual uint32 get_cseq() = 0;
	virtual void   set_cseq(uint32 cseq) = 0;
	virtual XCommonBaseMessage* clone() = 0;

	virtual bool parse_bytes(const void* pBuff, uint32 len) { return false; }
	virtual bool to_bytes(void** ppBuff, uint32& len) { return false; }
};

///////////////////////////////////////////////////////////////////////////////
// class XCommonMessage
///////////////////////////////////////////////////////////////////////////////
template <typename HeaderT, typename BodyT, uint32 Number>
class XCommonMessage : public XCommonBaseMessage
{
public:
	DEFINE_MESSAGE_VISITABLE();

	enum { NUMBER = Number };

	static string to_str(uint32 num)
	{
		char buf[32];
		sprintf(buf, "%u", num);
		return buf;
	}

	static const string& KEY()
	{
		static string str = "common_" + to_str(NUMBER);
		return str;
	}

public:
	XCommonMessage()
	{
		m_header.m_cmdNum  = NUMBER;
		m_header.m_cmdSeq  = 0;
		m_header.m_reserve = 0;
	}

	XCommonMessage(const XCommonMessage& src)
	{
		assert(src.m_header.m_cmdNum == NUMBER);
		m_header = src.m_header;
		m_body = src.m_body;
	}

	virtual ~XCommonMessage()
	{
		// empty
	}

	XCommonMessage& operator = (const XCommonMessage& src)
	{
		if (this != &src)
		{
			assert(src.m_header.m_cmdNum == NUMBER);
			XCommonBaseMessage::operator=(src);
			m_header = src.m_header;
			m_body = src.m_body;
		}
		return *this;
	}

	virtual const string& unique_key() { return KEY(); }

	virtual uint32 get_number() { return m_header.m_cmdNum; }
	virtual uint32 get_cseq() { return m_header.m_cmdSeq; }
	virtual void   set_cseq(uint32 cseq) { m_header.m_cmdSeq = cseq; }
	virtual XCommonBaseMessage* clone()
	{
		XCommonMessage* msg = new(nothrow) XCommonMessage;
		*msg = *this;
		return msg;
	}

	HeaderT& header() { return m_header; }

	const HeaderT& header() const { return m_header; }

	BodyT& body() { return m_body; }

	const BodyT& body() const { return m_body; }

	virtual bool parse_bytes(const void* pBuff, uint32 len)
	{
		CommonCmdHeader_* cmd = (CommonCmdHeader_ *)pBuff;
		assert(cmd != NULL && len > 0);
		if (len < sizeof(HeaderT))
		{
			printf("Invalid Common message(cmdNum:%u), has %u bytes, need more bytes.\n", m_header.m_cmdNum, len);
			return false;
		}
		if (cmd->m_cmdNum != NUMBER && 
			NUMBER != COMMON_CMD_UNKNOWN_REQ && 
			NUMBER != COMMON_CMD_UNKNOWN_RESP) 
		{
			printf("Invalid Common message(NUMBER:%u), bad cmdNum(%u).\n", NUMBER, cmd->m_cmdNum);
			return false;
		}

		m_header = *(HeaderT *)cmd;
		uint32 bodyLen = len - sizeof(HeaderT);
		CommonRespHeader_* respHeader = (CommonRespHeader_ *)cmd;
		if (m_header.m_cmdNum % 2 == 0 || respHeader->m_result == 0) // 回复时返回码不为0时，不带消息体
		{
			if (m_body.parse_bytes((const char*)cmd + sizeof(HeaderT), bodyLen) != (int)bodyLen)
			{
				printf("Invalid Common message(cmdNum:%u), parse body failed.\n", m_header.m_cmdNum);
				return false;
			}
		}

		return true;
	}

	virtual bool to_bytes(void** ppBuff, uint32& len)
	{
		assert(ppBuff);
		*ppBuff = NULL;
		len = 0;

		*ppBuff = new(nothrow) uint8[COMMON_MSG_MAX_LENGTH];
		assert(*ppBuff);
		
		char* buf = (char *)(*ppBuff);
		uint32 maxlen = COMMON_MSG_MAX_LENGTH;
		
		int ret = 0;
		int32 result = *(int32 *)((char *)&m_header + sizeof(CommonCmdHeader_));
		if (m_header.m_cmdNum % 2 == 0 || result == 0) // 回复时返回码不为0时，不带消息体
		{
			ret = m_body.to_bytes(buf + sizeof(HeaderT), maxlen - sizeof(HeaderT));
			if (ret < 0)
			{
				printf("Common message(cmdNum:%u) body to_bytes() failed.\n", m_header.m_cmdNum);
				return false;
			}
		}
		memcpy(buf, &m_header, sizeof(HeaderT));

		len = sizeof(HeaderT) + ret;
		return true;
	}

protected:
	HeaderT		m_header;
	BodyT		m_body;
};

///////////////////////////////////////////////////////////////////////////////
// class XCommonRequest
///////////////////////////////////////////////////////////////////////////////
template <typename BodyT, uint32 Number>
class XCommonRequest : public XCommonMessage<CommonReqHeader_, BodyT, Number>
{
public:
	DEFINE_MESSAGE_VISITABLE();

public:
	XCommonRequest()
	{
		CommonReqHeader_& header_ = XCommonMessage<CommonReqHeader_, BodyT, Number>::m_header;
		header_.m_srcId = 0;
		header_.m_session = 0;
	}

	virtual ~XCommonRequest() {}

	virtual XCommonBaseMessage* clone()
	{
		XCommonMessage<CommonReqHeader_, BodyT, Number>* msg = new(nothrow) XCommonRequest;
		*msg = *this;
		return msg;
	}

	uint32 get_srcId() const
	{
		CommonReqHeader_& header_ = XCommonMessage<CommonReqHeader_, BodyT, Number>::m_header;
		return header_.m_srcId;
	}

	void set_srcId(uint32 srcId)
	{
		CommonReqHeader_& header_ = XCommonMessage<CommonReqHeader_, BodyT, Number>::m_header;
		header_.m_srcId = srcId;
	}

	uint32 get_session() const
	{
		CommonReqHeader_& header_ = XCommonMessage<CommonReqHeader_, BodyT, Number>::m_header;
		return header_.m_session;
	}

	void set_session(uint32 session)
	{
		CommonReqHeader_& header_ = XCommonMessage<CommonReqHeader_, BodyT, Number>::m_header;
		header_.m_session = session;
	}
};

///////////////////////////////////////////////////////////////////////////////
// class XCommonResponse
///////////////////////////////////////////////////////////////////////////////
template <typename BodyT, uint32 Number>
class XCommonResponse : public XCommonMessage<CommonRespHeader_, BodyT, Number>
{
public:
	DEFINE_MESSAGE_VISITABLE();

public:
	XCommonResponse()
	{
		CommonRespHeader_& header_ = XCommonMessage<CommonRespHeader_, BodyT, Number>::m_header;
		header_.m_result = 0;
	}

	virtual ~XCommonResponse() {}

	virtual XCommonBaseMessage* clone()
	{
		XCommonMessage<CommonRespHeader_, BodyT, Number>* msg = new(nothrow) XCommonResponse;
		*msg = *this;
		return msg;
	}

	int get_result() const
	{
		const CommonRespHeader_& header_ = XCommonMessage<CommonRespHeader_, BodyT, Number>::m_header;
		return header_.m_result;
	}

	void set_result(int result)
	{
		CommonRespHeader_& header_ = XCommonMessage<CommonRespHeader_, BodyT, Number>::m_header;
		header_.m_result = result;
	}
};

typedef XCommonRequest  <CommonBytesMessageBody, COMMON_CMD_UNKNOWN_REQ>  CommonUnknownRequest;
typedef XCommonResponse <CommonBytesMessageBody, COMMON_CMD_UNKNOWN_RESP> CommonUnknownResponse;
typedef XCommonRequest  <CommonEmptyMessageBody, COMMON_CMD_UNKNOWN_REQ>  CommonEmptyRequest;
typedef XCommonResponse <CommonEmptyMessageBody, COMMON_CMD_UNKNOWN_RESP> CommonEmptyResponse;

}//namespace common

using namespace common;

#endif//_COMMON_MESSAGE_H_
