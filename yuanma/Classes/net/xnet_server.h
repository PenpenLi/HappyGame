#ifndef _XNET_SERVER_H_
#define _XNET_SERVER_H_

#include "xcore_define.h"
#include "xnet_sock_connector.h"
#include "xnet_sock_transfer.h"


namespace xnet {

///////////////////////////////////////////////////////////////////////////////
// class XSockServer
///////////////////////////////////////////////////////////////////////////////
class XSockServer
{
public:
	enum EventType {
		UNKNOWN = 0,      // 未知事件
		DISCONNECTED = 1, // 网络断开(无消息)
		MESSAGE = 2,      // 收到消息(回复消息或通知消息)
		TIMEOUT = 3       // 接收回复超时(请求消息的副本)
	};

	class Event
	{
	public:
		EventType      m_type;
		byte*				m_msg;
		uint32				m_len;
		
		Event() : m_type(UNKNOWN), m_msg(NULL) {}
		Event(EventType type, byte*  msg, uint32 len) : m_type(type), m_msg(msg), m_len(len) {}
	};

	class MsgCache
	{
	public:
		byte*				m_msg;
		uint32				m_len;
		time_t            m_time;
	};

public:
	static XSockServer* sharedSockServer();

	bool open(XSockAddr serverAddr, const string& key);
	void close();
	bool isOpen();

	void   setResponseTimeout(uint32 timeout/*秒*/);
	uint32 getResponseTimeout();

	bool sendMessage(byte* data, uint32 len, bool hasResp = false);

	bool getEvent(Event& event);

	void update();

private:
	XSockServer();
	~XSockServer();

private:
	XSockTransfer*   m_transfer;
	string           m_key;
	uint32           m_responseTimeout;
	uint32           m_request_seq;
	XSockAddr        m_serverAddr;
	list<Event*>     m_events;
	map<byte*, MsgCache> m_requests;
};

}//namespace xnet

using namespace xnet;

#endif//_XNET_SERVER_H_
