#ifndef _COMMON_MESSAGE_BODY_H_
#define _COMMON_MESSAGE_BODY_H_

#include "xcore_define.h"


namespace common {

///////////////////////////////////////////////////////////////////////////////
// class XCommonMessageBody
///////////////////////////////////////////////////////////////////////////////
class XCommonMessageBody
{
public:
	virtual ~XCommonMessageBody() {}

	// return -1: error   >=0: bytes of used
	virtual int parse_bytes(const void* src, uint32 len) = 0;

	// return -1: error   >=0: bytes of used
	virtual int to_bytes(void* dst, uint32 maxlen) = 0;

	// return -1: error   >=0: min bytes of need
	virtual int calc_length() = 0;
};

///////////////////////////////////////////////////////////////////////////////
// class CommonEmptyMessageBody
///////////////////////////////////////////////////////////////////////////////
class CommonEmptyMessageBody : public XCommonMessageBody
{
public:
	CommonEmptyMessageBody() {}

	virtual ~CommonEmptyMessageBody() {}

	virtual int parse_bytes(const void* src, uint32 len) { return 0; }

	virtual int to_bytes(void* dst, uint32 maxlen) { return 0; }

	virtual int calc_length() { return 0; }
};


///////////////////////////////////////////////////////////////////////////////
// class CommonBytesMessageBody
///////////////////////////////////////////////////////////////////////////////
class CommonBytesMessageBody : public XCommonMessageBody
{
public:
	CommonBytesMessageBody();

	CommonBytesMessageBody(const CommonBytesMessageBody& body);

	virtual ~CommonBytesMessageBody();

	CommonBytesMessageBody& operator = (const CommonBytesMessageBody& body);

	virtual int parse_bytes(const void* src, uint32 len);

	virtual int to_bytes(void* dst, uint32 maxlen);

	virtual int calc_length();

	const uint8* get_bytes() const;

	void set_bytes(const void* src, uint32 len);

	void clear();

private:
	void _copy(const void* src, uint32 len);

protected:
	uint8*		m_data;
	uint32		m_len;
};

}//namespace common

using namespace common;

#endif//_COMMON_MESSAGE_BODY_H_
