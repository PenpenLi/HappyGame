#include "xnet_sock_transfer.h"
#include "cocos2d.h"

namespace xnet {

///////////////////////////////////////////////////////////////////////////////
// class XSockTransfer
///////////////////////////////////////////////////////////////////////////////
XSockTransfer::XSockTransfer(SOCKET sock, const string& key)
	: m_sock(sock)
	, m_parser(key)
{
	assert(sock != INVALID_SOCKET);

	char buf[80];
	//sprintf(buf, "local:%s, remote:%s, ptr:0X%X",m_sock.local_addr().to_str().c_str(), m_sock.remote_addr().to_str().c_str(), (uint32)this);
	m_description = buf;

	//printf("XSockTransfer(%s) constructed.\n", description().c_str());
}

XSockTransfer::~XSockTransfer()
{
	this->close();
	//printf("XSockTransfer(%s) destructed.\n", description().c_str());
}


int XSockTransfer::get_handle() const
{
	return m_sock.get_handle();
}

bool XSockTransfer::is_open() const
{
	return m_sock.is_open();
}

bool XSockTransfer::close()
{
	if (is_open())
	{
		m_sock.shutdown();
		m_sock.close();
		cocos2d::log("----- Socket close OK -----");
		//printf("XSockTransfer(%s) closed by local.\n", m_description.c_str());
	}

	return true;
}

bool XSockTransfer::can_recv(int timeout_ms)
{
	return m_sock.can_recv(timeout_ms);
}

bool XSockTransfer::can_send(int timeout_ms)
{
	return m_sock.can_send(timeout_ms);
}

string XSockTransfer::description()
{
	return m_description;
}

bool XSockTransfer::write(byte* data, uint32 len)
{
	uint32 sendlen = 0;
	if (!m_sock.is_open()) return false;
	byte* buff = m_parser.to_byte_message(data, len, sendlen);
	if (buff == NULL) return false;
	int ret = m_sock.send_n(buff, (int)sendlen, 100);
	delete[] buff;
	if (ret != (int)sendlen) return false;
	return true;
}

bool XSockTransfer::read(byte** msg, uint32& len)
{
	if (msg == NULL) return true;
	*msg = NULL;

	if (m_parser.has_error()) return false;
	*msg = m_parser.get_byte_message(len);
	if (*msg)
	{
		return true;
	}
	if (m_parser.has_error()) return false;
	if (!m_sock.is_open()) return false;

	while (m_sock.can_recv(0))
	{
		char* need_bytes_buf = NULL;
		uint32 need_bytes_sz = 0;
		if (!m_parser.need_bytes((void **)&need_bytes_buf, need_bytes_sz)) return false;
		assert(need_bytes_buf != NULL && need_bytes_sz > 0);

		int recv_sz = m_sock.recv(need_bytes_buf, need_bytes_sz);
		//printf("XSockTransfer(%s) need recv %d bytes, recv return %d.\n", m_description.c_str(), need_bytes_sz, recv_sz);
		printf("XSockTransfer need recv %d bytes, recv return %d.\n", need_bytes_sz, recv_sz);
		if (0 == recv_sz) continue;
		if (-1 == recv_sz)
		{
			//printf("XSockTransfer(%s) socket recv error or closed.\n", m_description.c_str());
			printf("XSockTransfer socket recv error or closed.\n");
			m_sock.close();
			return false;
		}

		if (!m_parser.put_bytes(need_bytes_buf, recv_sz))
		{
			//printf("XSockTransfer(%s) parser message error.\n", m_description.c_str());
			printf("XSockTransfer parser message error.\n");
			return false;
		}

		*msg = m_parser.get_byte_message(len);
		if (*msg)
		{
			return true;
		}
		if (m_parser.has_error()) return false;
	}

	return true;
}

}//namespace xnet
