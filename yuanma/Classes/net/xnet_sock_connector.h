#ifndef _XNET_SOCK_CONNECTOR_H_
#define _XNET_SOCK_CONNECTOR_H_

#include "xcore_define.h"
#include "xnet_socket.h"
#include "xnet_sock_transfer.h"

namespace xnet {

///////////////////////////////////////////////////////////////////////////////
// class XSockConnector
///////////////////////////////////////////////////////////////////////////////
class XSockConnector
{
public:
	XSockConnector(const string& key);

	~XSockConnector();

	XSockTransfer* connect(const XSockAddr& remoteAddr, 
						   int timeout_ms = -1, 
						   bool is_nonblock = false,
						   const XSockAddr& localAddr = XSockAddr::AnyAddr);
	
	bool async_connect_start(const XSockAddr& remoteAddr, 
							 const XSockAddr& localAddr = XSockAddr::AnyAddr);

	bool async_connect_test(int timeout_ms = 0);

	XSockTransfer* async_connect_end(bool is_nonblock = false);

private:
	XSocket		      m_sock;
	string            m_key;
};

}//namespace xnet

using namespace xnet;

#endif//_XNET_SOCK_CONNECTOR_H_
