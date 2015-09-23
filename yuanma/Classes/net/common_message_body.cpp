#include "common_message_body.h"


namespace common {

///////////////////////////////////////////////////////////////////////////////
// class CommonBytesMessageBody
///////////////////////////////////////////////////////////////////////////////
CommonBytesMessageBody::CommonBytesMessageBody()
	: m_data(NULL)
	, m_len(0)
{
	// empty
}

CommonBytesMessageBody::CommonBytesMessageBody(const CommonBytesMessageBody& body)
	: m_data(NULL)
	, m_len(0)
{
	_copy(body.m_data, body.m_len);
}

CommonBytesMessageBody::~CommonBytesMessageBody()
{
	clear();
}

CommonBytesMessageBody& CommonBytesMessageBody::operator = (const CommonBytesMessageBody& body)
{
	if (this != &body)
	{
		_copy(body.m_data, body.m_len);
	}
	return *this;
}

int CommonBytesMessageBody::parse_bytes(const void* src, uint32 len)
{
	_copy(src, len);
	return m_len;
}

int CommonBytesMessageBody::to_bytes(void* dst, uint32 maxlen)
{
	if (dst == NULL) return -1;
	if (maxlen < m_len) return -1;
	if (m_data == NULL || m_len == 0) return 0;

	memcpy(dst, m_data, m_len);
	return m_len;
}

int CommonBytesMessageBody::calc_length()
{
	return m_len;
}

const uint8* CommonBytesMessageBody::get_bytes() const
{
	return m_data;
}

void CommonBytesMessageBody::set_bytes(const void* src, uint32 len)
{
	_copy(src, len);
}

void CommonBytesMessageBody::clear()
{
	if (m_data)
	{
		delete[] m_data;
		m_data = NULL;
	}
	m_len = 0;
}

void CommonBytesMessageBody::_copy(const void* src, uint32 len)
{
	clear();

	if ((src != NULL) && (len != 0))
	{
		m_data = new uint8[len + 1];
		memcpy(m_data, src, len);
		m_data[len] = '\0';
		m_len = len;
	}
}

}//namespace common
