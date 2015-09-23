#include "xnet_sock_connector.h"
#include "xnet_sock_transfer.h"
#include "cocos2d.h"

namespace xnet {

///////////////////////////////////////////////////////////////////////////////
// class XSockConnector
///////////////////////////////////////////////////////////////////////////////
XSockConnector::XSockConnector(const string& key)
	: m_key(key)
{
	// empty
}

XSockConnector::~XSockConnector()
{
	m_sock.close();
}

XSockTransfer* XSockConnector::connect(const XSockAddr& remoteAddr, int timeout_ms, bool is_nonblock, const XSockAddr& localAddr)
{
	if (timeout_ms < 0)
	{
		do 
		{
			if (!m_sock.open(SOCK_STREAM)) break;
			if ((localAddr != XSockAddr::AnyAddr) && !m_sock.bind(localAddr)) break;
			if (!m_sock.connect(remoteAddr)) break;
			if (is_nonblock && !m_sock.set_nonblock(true)) break;
			if (!m_sock.set_keep_alive(true)) break;
			if (!m_sock.set_tcp_nodelay(true)) break;
			cocos2d::log("----- Socket connect to %s OK -----", m_sock.remote_addr().to_str().c_str());
			//printf("XSockConnector connect to remote(%s) OK!\n", m_sock.remote_addr().to_str().c_str());
			return new XSockTransfer(m_sock.detach(), m_key);
		} while (false);
	}
	else
	{
		if (timeout_ms > 30000) timeout_ms = 30000; // 最多等30秒
		if (timeout_ms == 0) timeout_ms = 1;
		do 
		{
			if (!m_sock.open(SOCK_STREAM)) break;
			if ((localAddr != XSockAddr::AnyAddr) && !m_sock.bind(localAddr)) break;
			if (!m_sock.set_nonblock(true)) break;  // set nonblock flag
			if (!m_sock.connect(remoteAddr)) break;
			if (!m_sock.can_send(timeout_ms)) break;
			if (!is_nonblock && !m_sock.set_nonblock(false)) break;  // reset nonblock flag
			if (!m_sock.set_keep_alive(true)) break;
			if (!m_sock.set_tcp_nodelay(true)) break;
			cocos2d::log("----- Socket connect to %s OK -----", m_sock.remote_addr().to_str().c_str());
			//printf("XSockConnector connect to remote(%s) OK!\n", m_sock.remote_addr().to_str().c_str());
			return new XSockTransfer(m_sock.detach(), m_key);
		} while (false);
	}

	cocos2d::log("----- Socket connect to %s Failed -----", remoteAddr.to_str().c_str());
	//printf("XSockConnector connect to remote(%s) failed.\n", remoteAddr.to_str().c_str());
	m_sock.close();
	return NULL;
}

bool XSockConnector::async_connect_start(const XSockAddr& remoteAddr, const XSockAddr& localAddr)
{
	do 
	{
		if (!m_sock.open(SOCK_STREAM)) break;
		if ((localAddr != XSockAddr::AnyAddr) && !m_sock.bind(localAddr)) break;
		if (!m_sock.set_nonblock(true)) break;
		if (!m_sock.connect(remoteAddr)) break;
		return true;
	} while (false);

	printf("XSockConnector async connect to remote(%s) failed.\n", remoteAddr.to_str().c_str());
	m_sock.close();
	return false;
}

bool XSockConnector::async_connect_test(int timeout_ms)
{
	if (!m_sock.is_open()) return false;
	return m_sock.can_send(timeout_ms);
}

XSockTransfer* XSockConnector::async_connect_end(bool is_nonblock)
{
	if (!m_sock.is_open()) return NULL;
	do 
	{
		if (!m_sock.can_send(0)) break;
		if (!is_nonblock && !m_sock.set_nonblock(false)) break;
		if (!m_sock.set_keep_alive(true)) break;
		if (!m_sock.set_tcp_nodelay(true)) break;
		printf("XSockConnector async connect to remote(%s) OK!\n", m_sock.remote_addr().to_str().c_str());
		return new XSockTransfer(m_sock.detach(), m_key);
	} while (false);
	
	printf("XSockConnector async connect to remote(%s) failed.", m_sock.remote_addr().to_str().c_str());
	m_sock.close();
	return NULL;
}

}//namespace xnet
