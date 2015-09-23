#include "xnet_sock_addr.h"

namespace xnet {

static string& chop_head(string &strSrc, const char *pcszCharSet)
{
	if (pcszCharSet == NULL) return strSrc;
	size_t pos = strSrc.find_first_not_of(pcszCharSet);
	return strSrc.erase(0, pos);
}

static string& chop_tail(string &strSrc, const char *pcszCharSet)
{
	if (pcszCharSet == NULL) return strSrc;
	size_t pos = strSrc.find_last_not_of(pcszCharSet);
	if (pos == string::npos)
	{
		strSrc.clear();
		return strSrc;
	}
	return strSrc.erase(++pos);
}

static string& chop(string &strSrc, const char *pcszCharSet)
{
	chop_head(strSrc, pcszCharSet);
	return chop_tail(strSrc, pcszCharSet);
}

static uint32 try_to_uint_def(const string &strSrc, uint32 def = 0, int radix = 10)
{
	char* endPtr = 0;
	uint32 uValue = 0;
	string str = strSrc;

	chop(str, "\r\n\t");
	if (str.empty()) return def;

	errno = 0;
	uValue = strtoul(str.c_str(), &endPtr, radix);
	if (endPtr == str.c_str())
	{
		return def;
	}
	if (errno == ERANGE) return false;
	return uValue;
}

static uint32 split(const string &strSrc, vector<string> &vItems, const char *pcszCharSet = " \r\n\t", int nMaxCount = -1)
{
	vItems.clear();

	size_t pos_begin = 0;
	size_t pos_end = 0;
	int count = 0;
	while (pos_end != string::npos)
	{
		pos_begin = strSrc.find_first_not_of(pcszCharSet, pos_end);
		if (pos_begin == string::npos) break;
		pos_end = strSrc.find_first_of(pcszCharSet, pos_begin);
		string strTmp(strSrc, pos_begin, pos_end - pos_begin);
		if (!strTmp.empty())
		{
			count++;
			vItems.push_back(strTmp);
		}
		if (nMaxCount > 0 && count >= nMaxCount)
		{
			break;
		}
	}
	return (uint32)vItems.size();
}

static bool to_uint(const string &strSrc, uint32 &uValue, int radix = 10)
{
	char* endPtr = 0;
	string str = strSrc;

	chop(str, "\r\n\t");
	if (str.empty()) return false;

	errno = 0;
	uValue = strtoul(str.c_str(), &endPtr, radix);
	if (endPtr - str.c_str() != (int)str.size())
	{
		return false;
	}
	if (errno == ERANGE) return false;
	return true;
}

////////////////////////////////////////////////////////////////////////////////
// class __XSockGuarder
////////////////////////////////////////////////////////////////////////////////
class __XSockGuarder
{
public:
	__XSockGuarder()
	{
		#ifdef __WINDOWS__
		WSADATA wsaData;
		WORD wVersionRequested = MAKEWORD(2, 2);
		int nRetCode = WSAStartup(wVersionRequested, &wsaData);
		assert((!nRetCode) && "WSAStartup failed!");
		#endif//__WINDOWS__

		#ifdef __LINUX__
		signal(SIGPIPE, SIG_IGN);
		#endif//__LINUX__
	}

	~__XSockGuarder()
	{
		#ifdef __WINDOWS__
		WSACleanup();
		#endif//__WINDOWS__
	}
};
static __XSockGuarder  __g_sock_guarder;


////////////////////////////////////////////////////////////////////////////////
// class XSockAddr
////////////////////////////////////////////////////////////////////////////////

const XSockAddr XSockAddr::AnyAddr;

const XSockAddr XSockAddr::NoneAddr(INADDR_NONE, 0);

XSockAddr::XSockAddr(void)
{
	reset();
}

XSockAddr::XSockAddr(const XSockAddr& addr)
{
	memcpy(this, &addr, sizeof(addr));
}

XSockAddr::XSockAddr(const sockaddr_in& addr)
{
	reset();
	m_inaddr.sin_addr.s_addr = addr.sin_addr.s_addr;
	m_inaddr.sin_port = addr.sin_port;
}

XSockAddr::XSockAddr(const sockaddr& addr)
{
	reset();
	const sockaddr_in& inaddr = (const sockaddr_in&)addr;
	m_inaddr.sin_addr.s_addr = inaddr.sin_addr.s_addr;
	m_inaddr.sin_port = inaddr.sin_port;
}

XSockAddr::XSockAddr(const string& addr)
{
	reset();

	string host = addr;
	string port;
	size_t pos = addr.find(':');
	if (pos != string::npos)
	{
		host = addr.substr(0, addr.find(':'));
		port = addr.substr(addr.find(':') + 1);
	}
	
	set_host(host);
	set_port(try_to_uint_def(port, 0));
}

XSockAddr::XSockAddr(const string& host, uint16 port)
{
	reset();
	set_host(host);
	set_port(port);
}

XSockAddr::XSockAddr(uint32 ip, uint16 port)
{
	reset();
	set_ipaddr(ip);
	set_port(port);
}

XSockAddr::~XSockAddr(void)
{
	reset();
}

XSockAddr& XSockAddr::operator = (const XSockAddr& addr)
{
	if (this != &addr)
	{
		memcpy(&m_inaddr, &addr.m_inaddr, sizeof(m_inaddr));
	}
	return *this;
}

XSockAddr& XSockAddr::operator = (const sockaddr_in& addr)
{
	m_inaddr.sin_addr.s_addr = addr.sin_addr.s_addr;
	m_inaddr.sin_port = addr.sin_port;
	return *this;
}

XSockAddr& XSockAddr::operator = (const sockaddr& addr)
{
	const sockaddr_in& inaddr = (const sockaddr_in&)addr;
	m_inaddr.sin_addr.s_addr = inaddr.sin_addr.s_addr;
	m_inaddr.sin_port = inaddr.sin_port;
	return *this;
}

XSockAddr::operator const sockaddr_in *() const
{
	return &m_inaddr;
}

XSockAddr::operator const sockaddr *() const
{
	return (const sockaddr *)&m_inaddr;
}

XSockAddr::operator sockaddr_in() const
{
	return m_inaddr;
}

XSockAddr::operator sockaddr() const
{
	return *(sockaddr *)&m_inaddr;
}

void XSockAddr::set_port(uint16 port)
{
	m_inaddr.sin_port = htons(port);
}

void XSockAddr::set_ipaddr(uint32 ip)
{
	m_inaddr.sin_addr.s_addr = htonl(ip);
}

bool XSockAddr::set_ipaddr(const string& ip)
{
	vector<string> vItems;
	if (4 != split(ip, vItems, "\r\n\t .", -1))
	{
		return false;
	}

	uint32 tmp = 0;
	uint32 num = 0;
	for (int i = 0; i < 4; i++)
	{
		if (!to_uint(vItems[i], tmp) || tmp >= 256)
		{
			return false;
		}
		num <<= 8;
		num |= tmp;
	}
	set_ipaddr(num);
	return true;
}

bool XSockAddr::set_host(const string& host)
{
	if (host.empty())
	{
		// ip set "0.0.0.0"
		m_inaddr.sin_addr.s_addr = INADDR_ANY;
		return true;
	}
	if (set_ipaddr(host)) return true;

	struct hostent *pHost = gethostbyname(host.c_str());
	if (pHost && pHost->h_addr)
	{
		m_inaddr.sin_addr = *(in_addr *)pHost->h_addr;
		return true;
	}
	else
	{
		m_inaddr.sin_addr.s_addr = INADDR_NONE;
		return false;
	}
}

uint16 XSockAddr::get_port() const
{
	return ntohs(m_inaddr.sin_port);
}

uint32 XSockAddr::get_ipaddr() const
{
	return ntohl(m_inaddr.sin_addr.s_addr);
}

string XSockAddr::get_hostname() const
{
	if (this->m_inaddr.sin_addr.s_addr == INADDR_ANY)
	{
		return local_net_name();
	}

	struct hostent *pHost = gethostbyaddr((char *)&m_inaddr.sin_addr, 4, PF_INET);
	if (pHost && pHost->h_name)
	{
		return pHost->h_name;
	}
	else
	{
		return get_hostaddr();
	}
}

string XSockAddr::get_hostaddr() const
{
	char buf[32];
	uint32 ip_ = get_ipaddr();
	sprintf(buf, "%u.%u.%u.%u", (ip_ >> 24) & 0XFF, (ip_ >> 16) & 0XFF, (ip_ >> 8) & 0XFF, ip_ & 0XFF);
	return buf;
}

string XSockAddr::to_str() const
{
	char buf[32];
	uint32 ip_ = get_ipaddr();
	uint16 port_ = get_port();
	sprintf(buf, "%u.%u.%u.%u:%u", (ip_ >> 24) & 0XFF, (ip_ >> 16) & 0XFF, (ip_ >> 8) & 0XFF, ip_ & 0XFF, port_);
	return buf;
}

void XSockAddr::reset()
{
	memset(&m_inaddr, 0, sizeof(m_inaddr));
	m_inaddr.sin_family = PF_INET;
	return;
}

bool XSockAddr::is_any() const
{
	return (m_inaddr.sin_addr.s_addr == INADDR_ANY);
}

bool XSockAddr::is_none() const
{
	return (m_inaddr.sin_addr.s_addr == INADDR_NONE);
}

bool XSockAddr::is_loopback() const
{
	 return ((get_ipaddr() & 0XFF000001) == 0X7F000001);
}

bool XSockAddr::is_multicast() const
{
	uint32 ip = get_ipaddr();
	return (ip >= 0xE0000000) &&  // 224.0.0.0
		   (ip <= 0xEFFFFFFF); // 239.255.255.255
}

string XSockAddr::local_net_name()
{
	static string name_;

	if (name_.empty())
	{
		char buf[1024] = {};
		struct hostent *pHost = NULL;
		if (SOCKET_ERROR != gethostname(buf, 1023))
			pHost = gethostbyname(buf);
		else
			pHost = gethostbyname("");
		
		if (pHost && pHost->h_name)
		{
			name_ = pHost->h_name;
		}
	}
	return name_;
}

XSockAddr XSockAddr::local_mainaddr()
{
	static XSockAddr addr_;
	if (!addr_.is_any()) return addr_;

	#ifdef __WINDOWS__
	char buf[1024] = {};
	struct hostent *pHost = NULL;
	if (SOCKET_ERROR != gethostname(buf, 1023))
		pHost = gethostbyname(buf);
	else
		pHost = gethostbyname("");
	if (pHost && pHost->h_addr)
	{
		addr_.m_inaddr.sin_addr = *(in_addr *)pHost->h_addr;
	}
	return addr_;
	#endif//__WINDOWS__

	#ifdef __LINUX__
	int             fd;
	struct ifreq    buf[16];
	struct ifconf   ifc;

	if ((fd = socket(PF_INET, SOCK_DGRAM, 0)) <= 0) return addr_;

	ifc.ifc_len = sizeof(buf);
	ifc.ifc_buf = (caddr_t)buf;
	if (ioctl(fd, SIOCGIFCONF, (char *)&ifc) == -1)
	{
		close(fd);
		return addr_;
	}

	int interface = ifc.ifc_len / sizeof(struct ifreq);
	for (int i = 0; i < interface; i++)
	{
		if (ioctl(fd, SIOCGIFFLAGS, (char *)&buf[i]) == -1) continue;
		if (buf[i].ifr_flags & IFF_LOOPBACK) continue;
		if (!(buf[i].ifr_flags & IFF_UP)) continue;
		if (ioctl(fd, SIOCGIFADDR, (char *)&buf[i]) == 0)
		{
			addr_.m_inaddr.sin_addr = ((struct sockaddr_in *)(&buf[i].ifr_addr))->sin_addr;
			break;
		}
	}
	close(fd);
	return addr_;
	#endif//__LINUX__
}

bool XSockAddr::local_addrs(vector<XSockAddr>& addrs)
{
	static vector<XSockAddr> addrs_;
	addrs.clear();
	if (addrs_.size() > 0)
	{
		addrs.insert(addrs.begin(), addrs_.begin(), addrs_.end());
		return true;
	}

	#ifdef __WINDOWS__
	struct hostent *pHost = gethostbyname("");
	if (pHost == NULL) return false;
	for (int i = 0; i < 16; i++)
	{
		char* inaddr = pHost->h_addr_list[i];
		if (inaddr == NULL) break;

		XSockAddr addr;
		addr.m_inaddr.sin_addr = *(in_addr *)inaddr;
		if (addr.is_any()) continue;
		addrs_.push_back(addr);
	}

	addrs.insert(addrs.begin(), addrs_.begin(), addrs_.end());
	return true;
	#endif//__WINDOWS__

	#ifdef __LINUX__
	int             fd;
	struct ifreq    buf[16];
	struct ifconf   ifc;

	if ((fd = socket(PF_INET, SOCK_DGRAM, 0)) <= 0) return false;

	ifc.ifc_len = sizeof(buf);
	ifc.ifc_buf = (caddr_t)buf;
	if (ioctl(fd, SIOCGIFCONF, (char *)&ifc) == -1)
	{
		close(fd);
		return false;
	}

	int interface = ifc.ifc_len / sizeof(struct ifreq);
	for (int i = 0; i < interface; i++)
	{
		if (ioctl(fd, SIOCGIFFLAGS, (char *)&buf[i]) == -1) continue;
		//if (buf[i].ifr_flags & IFF_LOOPBACK) continue;
		if (!(buf[i].ifr_flags & IFF_UP)) continue;
		if (ioctl(fd, SIOCGIFADDR, (char *)&buf[i]) == 0)
		{
			XSockAddr addr;
			addr.m_inaddr.sin_addr = ((struct sockaddr_in *)(&buf[i].ifr_addr))->sin_addr;
			if (addr.is_any()) continue;
			addrs_.push_back(addr);
		}
	}
	
	addrs.insert(addrs.begin(), addrs_.begin(), addrs_.end());
	close(fd);
	return true;
	#endif//__LINUX__
}

bool operator < (const XSockAddr& addr1, const XSockAddr& addr2)
{
	if ((addr1.get_ipaddr() < addr2.get_ipaddr()) ||
		((addr1.get_ipaddr() == addr2.get_ipaddr()) &&
		(addr1.get_port() < addr2.get_port())))
		return true;
	else
		return false;
}

bool operator <= (const XSockAddr& addr1, const XSockAddr& addr2)
{
	if ((addr1.get_ipaddr() < addr2.get_ipaddr()) ||
		((addr1.get_ipaddr() == addr2.get_ipaddr()) &&
		(addr1.get_port() <= addr2.get_port())))
		return true;
	else
		return false;
}

bool operator >  (const XSockAddr& addr1, const XSockAddr& addr2)
{
	if ((addr1.get_ipaddr() > addr2.get_ipaddr()) ||
		((addr1.get_ipaddr() == addr2.get_ipaddr()) &&
		(addr1.get_port() > addr2.get_port())))
		return true;
	else
		return false;
}

bool operator >= (const XSockAddr& addr1, const XSockAddr& addr2)
{
	if ((addr1.get_ipaddr() > addr2.get_ipaddr()) ||
		((addr1.get_ipaddr() == addr2.get_ipaddr()) &&
		(addr1.get_port() >= addr2.get_port())))
		return true;
	else
		return false;
}

bool operator == (const XSockAddr& addr1, const XSockAddr& addr2)
{
	if ((addr1.get_ipaddr() == addr2.get_ipaddr()) && 
		(addr1.get_port() == addr2.get_port()))
		return true;
	else
		return false;
}

bool operator != (const XSockAddr& addr1, const XSockAddr& addr2)
{
	if ((addr1.get_ipaddr() != addr2.get_ipaddr()) ||
		(addr1.get_port() != addr2.get_port()))
		return true;
	else
		return false;
}

}//namespace xnet
