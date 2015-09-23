#ifndef _XNET_SOCK_TRANSFER_H_
#define _XNET_SOCK_TRANSFER_H_

#include "xcore_define.h"
#include "xnet_socket.h"
#include "common_parser.h"
#include "common_rc4_parser.h"

namespace xnet {
	
///////////////////////////////////////////////////////////////////////////////
// class XSockTransfer
///////////////////////////////////////////////////////////////////////////////
class XSockTransfer
{
public:
	XSockTransfer(SOCKET sock, const string& key);

	~XSockTransfer();

	int get_handle() const;

	bool is_open() const;

	bool close();

	bool can_recv(int timeout_ms);

	bool can_send(int timeout_ms);

	string description();

	bool write(byte* data, uint32 len);
	bool read(byte** data, uint32& len);

private:
	XSocket              m_sock;
	XCommonRC4Parser       m_parser;
	string               m_description;
};

}//namespace xnet

using namespace xnet;

#endif//_XNET_SOCK_TRANSFER_H_
