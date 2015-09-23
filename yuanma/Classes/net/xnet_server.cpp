#include "xnet_server.h"

namespace xnet {

///////////////////////////////////////////////////////////////////////////////
// class XSockServer
///////////////////////////////////////////////////////////////////////////////
XSockServer::XSockServer()
	: m_transfer(NULL)
	, m_responseTimeout(5)
	, m_request_seq((uint32)rand() % 1000 + 1)
{
	//
}

XSockServer::~XSockServer()
{
	close();
}

XSockServer* XSockServer::sharedSockServer()
{
	static XSockServer instance_;
	return &instance_;
}

bool XSockServer::open(XSockAddr serverAddr, const string& key)
{
	m_key = key;
	if(m_transfer!=NULL)
	{
		if(m_transfer->is_open())
		{
			XSocket socket_ ;
			socket_.attach(m_transfer->get_handle());
			uint16 port_ = socket_.remote_addr().get_port();
			socket_.detach();
			if(serverAddr.get_port()!=port_)
			{
				close();
				m_serverAddr = serverAddr;
				m_transfer = XSockConnector(m_key).connect(serverAddr, 3500, true);
				if (m_transfer == NULL)
				{
					return false;
				}
				setResponseTimeout(30);
			}
		}else
		{
			close();
			m_serverAddr = serverAddr;
			m_transfer = XSockConnector(m_key).connect(serverAddr, 3500, true);
			if (m_transfer == NULL)
			{
				return false;
			}
			setResponseTimeout(30);
		}
	}else
	{
		close();
		m_serverAddr = serverAddr;
		m_transfer = XSockConnector(m_key).connect(serverAddr, 3500, true);
		if (m_transfer == NULL)
		{
			return false;
		}
		setResponseTimeout(30);
	}
	return true;
}

bool XSockServer::isOpen()
{
    if (m_transfer) {
        return m_transfer->is_open();
    }
	else
    {
        return false;
    }
}

void XSockServer::close()
{
	if (m_transfer)
	{
		m_transfer->close();
		delete m_transfer;
		m_transfer = NULL;
	}
}

void XSockServer::setResponseTimeout(uint32 timeout)
{
	if (timeout <= 1) timeout = 1;
	m_responseTimeout = timeout;
}

uint32 XSockServer::getResponseTimeout()
{
	return m_responseTimeout;
}

bool XSockServer::sendMessage(byte* data, uint32 len, bool hasResp)
{
	if (data == NULL) return false;
	if (m_transfer == NULL || !m_transfer->is_open())
	{
		return false;
	}
	if (!m_transfer->write(data, len))
	{
		m_transfer->close();
		m_events.push_back(new Event(DISCONNECTED, NULL, 0));
		return false;
	}

	if (hasResp)
	{
		MsgCache msg_cache;
		msg_cache.m_len = len;
		msg_cache.m_msg = data;
		msg_cache.m_time = time(NULL) + m_responseTimeout;
		m_requests[data] = msg_cache;
	}
	return true;
}

bool XSockServer::getEvent(Event& event)
{
	if (m_events.empty()) return false;
	event = *m_events.front();
	delete m_events.front();
	m_events.pop_front();
	return true;
}

void XSockServer::update()
{
	if (m_transfer == NULL) return;
	if (!m_transfer->is_open()) return;

	// 检测回复超时
	time_t now = time(NULL);
	map<byte*, MsgCache>::iterator it = m_requests.begin();
	while (it != m_requests.end())
	{
		if (now >= it->second.m_time)
		{
			// 回复超时，产生事件
			m_events.push_back(new Event(TIMEOUT, it->first, it->second.m_len));
			m_requests.erase(it++);
		}
		else
		{
			++it;
		}
	}

	if (!m_transfer->can_recv(0)) return;

	byte* byte = NULL;
	uint32 msglen = 0;
	if (!m_transfer->read(&byte, msglen))
	{
		m_transfer->close();
		m_events.push_back(new Event(DISCONNECTED, NULL, 0));
		return;
	}
	if (byte == NULL) return;
	
	// 产生事件
	m_events.push_back(new Event(MESSAGE, byte, msglen));

	// 从请求队列中取出
	it = m_requests.begin();
	while (it != m_requests.end())
	{
		CommonCmdHeader_* cmdReq = (CommonCmdHeader_*)it->first;
		CommonCmdHeader_* cmdResp = (CommonCmdHeader_*)byte;

		if (cmdReq->m_cmdSeq == cmdResp->m_cmdSeq)
		{
			delete[] it->first;
			m_requests.erase(it++);
			break;
		}
		else
		{
			++it;
		}
	}
	return;
}


}//namespace xnet
