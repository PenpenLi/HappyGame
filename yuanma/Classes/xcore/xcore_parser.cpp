#include "xcore_parser.h"

namespace xcore {

static bool __is_whitespace(char ch);
static bool __is_digit(char ch);
static bool __is_alpha(char ch);
static bool __is_hex(char ch);
static const char* __findchar(const char* str, char ch);
static string __unicode_to_utf8(uint32 unicode);
static const char* __empty_str = "";


/////////////////////////////////////////////////////////////////////
// class XStrParser
/////////////////////////////////////////////////////////////////////
XBufferParser::XBufferParser()
	: m_buff(__empty_str)
	, m_pos(__empty_str)
	, m_end(__empty_str)
{
	// empty
}

XBufferParser::XBufferParser(const char* buff, uint32 length)
	: m_buff(buff)
	, m_pos(buff)
	, m_end(buff + length)
{
	if (m_buff == NULL)
	{
		__clear();
	}
}

XBufferParser::XBufferParser(const XBufferParser& other)
	: m_buff(other.m_buff)
	, m_pos(other.m_pos)
	, m_end(other.m_end)
{
	// empty
}

XBufferParser& XBufferParser::operator=(const XBufferParser& other)
{
	if (&other != this)
	{
		m_buff = other.m_buff;
		m_pos = other.m_pos;
		m_end = other.m_end;
	}
	return *this;
}

XBufferParser::~XBufferParser()
{
	__clear();
}

void XBufferParser::attach(const char* buff, uint32 length)
{
	if (buff)
	{
		m_buff = buff;
		m_pos = m_buff;
		m_end = m_buff + length;
	}
	else
	{
		__clear();
	}
	return;
}

bool XBufferParser::set_pos(const char* pos)
{
	if (pos < m_buff) return false;
	if (pos > m_end) return false;
	m_pos = pos;
	return true;
}

void XBufferParser::__clear()
{
	m_buff = __empty_str;
	m_pos = __empty_str;
	m_end = __empty_str;
	return;
}


/////////////////////////////////////////////////////////////////////
// class XStrParser
/////////////////////////////////////////////////////////////////////
XStrParser::XStrParser()
{
	// empty
}

XStrParser::XStrParser(const char* buff, uint32 length)
	: XBufferParser(buff, length)
{
	// empty
}

XStrParser::XStrParser(const XStrParser& other)
	: XBufferParser(other)
{
	// empty
}

XStrParser& XStrParser::operator=(const XStrParser& other)
{
	if (&other != this)
	{
		XBufferParser::operator=(other);
	}
	return *this;
}

XStrParser::~XStrParser()
{
	// empty
}

void XStrParser::chop_head_whitespace()
{
	while (m_buff < m_end && __is_whitespace(*m_buff))
	{
		m_buff++;
	}
	if (m_pos < m_buff)	m_pos = m_buff;
	return;
}

void XStrParser::chop_tail_whitespace()
{
	while (m_buff < m_end && __is_whitespace(*(m_end - 1)))
	{
		m_end--;
	}
	if (m_pos > m_end) m_pos = m_end;
	return;
}

void XStrParser::chop_whitespace()
{
	chop_head_whitespace();
	chop_tail_whitespace();
	return;
}

bool XStrParser::is_whitespace() const
{
	return !eof() && __is_whitespace(*m_pos);
}

bool XStrParser::is_digit() const
{
	return !eof() && __is_digit(*m_pos);
}

bool XStrParser::is_alpha() const
{
	return !eof() && __is_alpha(*m_pos);
}

bool XStrParser::is_hex() const
{
	return !eof() && __is_hex(*m_pos);
}

uint32 XStrParser::skip_n(uint32 n)
{
	if (m_pos + n > m_end)
	{
		n = (uint32)(m_end - m_pos);
	}
	m_pos += n;
	return n;
}

uint32 XStrParser::skip_char(uint8 ch)
{
	if (eof()) return 0;
	if (*m_pos != ch) return 0;
	m_pos++;
	return 1;
}

uint32 XStrParser::skip_within(const char* incharset)
{
	uint32 count = 0;
	if (incharset == NULL) return 0;
	while (!eof() && __findchar(incharset, *m_pos))
	{
		m_pos++;
		count++;
	}
	return count;
}

uint32 XStrParser::skip_without(const char* outcharset)
{
	uint32 count = 0;
	if (outcharset == NULL) return 0;
	while (!eof() && !__findchar(outcharset, *m_pos))
	{
		m_pos++;
		count++;
	}
	return count;
}

uint32 XStrParser::skip_whitespace()
{
	uint32 count = 0;
	while (!eof() && __is_whitespace(*m_pos))
	{
		m_pos++;
		count++;
	}
	return count;
}

uint32 XStrParser::skip_nonwhitespace()
{
	uint32 count = 0;
	while (!eof() && !__is_whitespace(*m_pos))
	{
		m_pos++;
		count++;
	}
	return count;
}

char XStrParser::getch()
{
	if (eof()) return 0;
	return *m_pos++;
}

bool XStrParser::getch_digit(uint8& digit)
{
	digit = 0;
	if (eof()) return false;
	if (!is_digit()) return false;
	digit = *m_pos++ - '0';
	return true;
}

bool XStrParser::getch_hex(uint8& hex)
{
	hex = 0;
	if (eof()) return false;
	char ch = *m_pos;
	if ('0' <= ch && ch <= '9')
		hex = ch - '0';
	else if ('a' <= ch && ch <= 'f')
		hex = ch - 'a' + 10;
	else if ('A' <= ch && ch <= 'F')
		hex = ch - 'A' + 10;
	else
		return false;

	m_pos++;
	return true;
}

bool XStrParser::getch_unicode(uint32& unicode)
{
	unicode = 0;
	if (remain() < 6) return false;
	if (*m_pos != '\\' || *(m_pos + 1) != 'u') return false;
	m_pos += 2;

	uint8 hex = 0;
	for (int i = 0; i < 4; i++)
	{
		if (!getch_hex(hex)) return false;
		unicode <<= 4;
		unicode += hex;
	}
	if (unicode >= 0xD800 && unicode <= 0xDBFF)
	{
		uint32 surrogatePair = 0;
		if (remain() < 6) return false;
		if (*m_pos != '\\' || *(m_pos + 1) != 'u') return false;
		m_pos += 2;
		for (int i = 0; i < 4; i++)
		{
			if (!getch_hex(hex)) return false;
			surrogatePair <<= 4;
			surrogatePair += hex;
		}
		unicode = 0x10000 + ((unicode & 0x3FF) << 10) + (surrogatePair & 0x3FF);
	}
	return true;
}

string XStrParser::getstr_n(uint32 n)
{
	if (n > (uint32)(m_end - m_pos))
	{
		n = (uint32)(m_end - m_pos);
	}
	const char* pos = m_pos;
	m_pos += n;
	return string(pos, n);
}

bool XStrParser::getstr_by_quotation(string& result)
{
	result.clear();
	if (eof()) return false;
	if (*m_pos != '"') return false;
	m_pos++;

	while (!eof())
	{
		char ch = *m_pos++;
		if (ch == '\\')
		{
			if (eof()) return false;
			ch = *m_pos++;
			switch ( ch )
			{
			case '"':  result += '"';  break;
			case '/':  result += '/';  break;
			case '\\': result += '\\'; break;
			case 'b':  result += '\b'; break;
			case 'f':  result += '\f'; break;
			case 'n':  result += '\n'; break;
			case 'r':  result += '\r'; break;
			case 't':  result += '\t'; break;
			case 'u':
				{
					m_pos -= 2;
					uint32 unicode = 0;
					if (!getch_unicode(unicode)) return false;
					result += __unicode_to_utf8(unicode);
				}
				break;
			default:
				return false;
			}
		}
		else if (ch == '"')
		{
			return true;
		}
		else
		{
			result += ch;
		}
	}

	return false;
}

bool XStrParser::getstr_by_sign(string& result, char lsign, char rsign, bool with_sign)
{
	result.clear();
	if (eof()) return false;
	if (lsign != *m_pos) return false;

	const char* pos = m_pos;
	m_pos++;
	while (!eof() && *m_pos != rsign)
	{
		m_pos++;
	}
	if (eof()) return false;
	m_pos++;

	if (with_sign)
		result.assign(pos, m_pos);
	else
		result.assign(pos + 1, m_pos - 1);
	return true;
}

string XStrParser::getstr_within(const char* incharset)
{
	const char* pos = m_pos;
	if (incharset == NULL) return __empty_str;
	while (!eof() && __findchar(incharset, *m_pos))
	{
		m_pos++;
	}
	return string(pos, m_pos);
}

string XStrParser::getstr_without(const char* outcharset)
{
	const char* pos = m_pos;
	if (outcharset == NULL) return __empty_str;
	while (!eof() && !__findchar(outcharset, *m_pos))
	{
		m_pos++;
	}
	return string(pos, m_pos);
}

int64 XStrParser::get_integer()
{
	const char* pos = m_pos;
	skip_whitespace();
	if (eof())
	{
		m_pos = pos;
		return 0;
	}

	int64 signum = 1;
	if (*m_pos == '+')
	{
		skip_n(1);
	}
	else if (*m_pos == '-')
	{
		signum = -1;
		skip_n(1);
	}
	skip_whitespace();
	if (!is_digit())
	{
		m_pos = pos;
		return 0;
	}

	int64 ret = 0;
	while (!eof() && __is_digit(*m_pos))
	{
		// 0xffffffffffffffff = 18446744073709551615
		uint8 num = (uint8)(*m_pos - '0');
		if (ret > 1844674407370955161LL) break;
		if (ret == 1844674407370955161LL && num > 5) break;
		ret *= 10;
		ret += num;
		m_pos++;
	}

	return ret * signum;
}

double XStrParser::get_fractional()
{
	double factor = 10.0;
	double result = 0.0;
	const char* pos = m_pos;
	skip_whitespace();
	while (!eof() && __is_digit(*m_pos))
	{
		result += (double)(*m_pos - '0') / factor;
		factor *= 10.0;
		m_pos++;
	}
	return result;
}

uint8 XStrParser::get_uint8()
{
	uint8 ret = 0;
	skip_whitespace();
	while (!eof() && __is_digit(*m_pos))
	{
		// 0xff = 255
		uint8 num = (uint8)(*m_pos - '0');
		if (ret > 25) break;
		if (ret == 25 && num > 5) break;
		ret *= 10;
		ret += num;
		m_pos++;
	}
	return ret;
}

uint32 XStrParser::get_uint32()
{
	uint32 ret = 0;
	skip_whitespace();
	while (!eof() && __is_digit(*m_pos))
	{
		// 0xffffffff = 4294967295
		uint8 num = (uint8)(*m_pos - '0');
		if (ret > 429496729) break;
		if (ret == 429496729 && num > 5) break;
		ret *= 10;
		ret += num;
		m_pos++;
	}
	return ret;
}

uint64 XStrParser::get_uint64()
{
	uint64 ret = 0;
	skip_whitespace();
	while (!eof() && __is_digit(*m_pos))
	{
		// 0xffffffffffffffff = 18446744073709551615
		uint8 num = (uint8)(*m_pos - '0');
		if (ret > 1844674407370955161ULL) break;
		if (ret == 1844674407370955161ULL && num > 5) break;
		ret *= 10;
		ret += num;
		m_pos++;
	}
	return ret;
}

uint64 XStrParser::get_hex()
{
	uint64 ret = 0;
	skip_whitespace();
	if ((remain() > 2) && 
		((*m_pos == '0' && *(m_pos + 1) == 'x') || 
		(*m_pos == '0' && *(m_pos + 1) == 'X')))
		m_pos += 2;

	while (!eof() && __is_hex(*m_pos))
	{
		// max = 0xffffffffffffffff
		uint8 num = 0;
		char ch = *m_pos;
		if ('0' <= ch && ch <= '9')
			num = (uint8)(ch - '0');
		else if ('a' <= ch && ch <= 'f')
			num = (uint8)(ch - 'a' + 10);
		else //if ('A' <= ch && ch <= 'F')
			num = (uint8)(ch - 'A' + 10);
		if (ret >= 0X1000000000000000ULL) break;
		ret <<= 1;
		ret |= num;
		m_pos++;
	}
	return ret;
}

const char* XStrParser::findchar(char ch) const
{
	const char* pos = m_pos;
	while (pos < m_end && *pos != ch)
	{
		pos++;
	}
	return pos;
}

const char* XStrParser::findchar(char ch, const char* before) const
{
	const char* before_ = before;
	if (before_ > m_end) before_ = m_end;
	if (before_ < m_buff) return before;
	if (m_pos >= before_) return before;
	const char* pos = m_pos;
	while (pos < before_ && *pos != ch)
	{
		pos++;
	}
	if (pos == before_) return before;
	return pos;
}

const char* XStrParser::findchar_within(const char* incharset) const
{
	if (incharset == NULL) return m_end;
	const char* pos = m_pos;
	while (pos < m_end && !__findchar(incharset, *pos))
	{
		pos++;
	}
	return pos;
}

const char* XStrParser::findchar_without(const char* outcharset) const
{
	if (outcharset == NULL) return m_end;
	const char* pos = m_pos;
	while (pos < m_end && __findchar(outcharset, *pos))
	{
		pos++;
	}
	return pos;
}

const char* XStrParser::findstr(const char* str) const
{
	if (str == NULL) return m_end;
	uint32 len = (uint32)strlen(str);
	if (len == 0) return m_pos;
	if ((uint32)(m_end - m_pos) < len) return m_end;

	const char* pos = m_pos;
	const char* end = m_end - len;
	for ( ; pos <= end; pos++)
	{
		if (0 == memcmp(str, pos, len))
		{
			return pos;
		}
	}
	return m_end;
}


/////////////////////////////////////////////////////////////////////
// class XByteParser
/////////////////////////////////////////////////////////////////////
XByteParser::XByteParser()
{
	// empty
}

XByteParser::XByteParser(const char* buff, uint32 length)
	: XBufferParser(buff, length)
{
	// empty
}

XByteParser::XByteParser(const XByteParser& other)
	: XBufferParser(other)
{
	// empty
}

XByteParser& XByteParser::operator=(const XByteParser& other)
{
	if (&other != this)
	{
		XBufferParser::operator=(other);
	}
	return *this;
}

XByteParser::~XByteParser()
{
	// empty
}


bool XByteParser::get_bool(bool& val)
{
	if (remain() < sizeof(uint8)) return false;
	val = (0 != *(uint8 *)m_pos);
	m_pos += sizeof(uint8);
	return true;
}

bool XByteParser::get_char(char& val)
{
	if (remain() < sizeof(char)) return false;
	val = *(char *)m_pos;
	m_pos += sizeof(char);
	return true;
}

bool XByteParser::get_int8(int8& val)
{
	if (remain() < sizeof(int8)) return false;
	val = *(int8 *)m_pos;
	m_pos += sizeof(int8);
	return true;
}

bool XByteParser::get_uint8(uint8& val)
{
	if (remain() < sizeof(uint8)) return false;
	val = *(uint8 *)m_pos;
	m_pos += sizeof(uint8);
	return true;
}

bool XByteParser::get_int16(int16& val)
{
	if (remain() < sizeof(int16)) return false;
	val = *(int16 *)m_pos;
	m_pos += sizeof(int16);
	return true;
}

bool XByteParser::get_uint16(uint16& val)
{
	if (remain() < sizeof(uint16)) return false;
	val = *(uint16 *)m_pos;
	m_pos += sizeof(uint16);
	return true;
}

bool XByteParser::get_int32(int32& val)
{
	if (remain() < sizeof(int32)) return false;
	val = *(int32 *)m_pos;
	m_pos += sizeof(int32);
	return true;
}

bool XByteParser::get_uint32(uint32& val)
{
	if (remain() < sizeof(uint32)) return false;
	val = *(uint32 *)m_pos;
	m_pos += sizeof(uint32);
	return true;
}

bool XByteParser::get_float(float& val)
{
	if (remain() < sizeof(float)) return false;
	val = *(float *)m_pos;
	m_pos += sizeof(float);
	return true;
}

bool XByteParser::get_double(double& val)
{
	if (remain() < sizeof(double)) return false;
	uint8* dst = (uint8*)&val;
	uint8* src = (uint8*)m_pos;
	for (int i = 0; i < sizeof(double); i++)
	{
		*dst++ = *src++;
	}
	//val = *(double *)m_pos;
	m_pos += sizeof(double);
	return true;
}

bool XByteParser::get_string(string& val)
{
	uint16 len = 0;
	if (!get_uint16(len)) return false;
	if (remain() < len) return false;
	val.assign(m_pos, len);
	m_pos += len;
	return true;
}

bool XByteParser::get_bool_array(bool* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(uint8)) return false;
	for (uint32 i = 0; i < len; i++)
	{
		buf[i] = (0 != *(m_pos + i));
	}
	m_pos += len * sizeof(uint8);
	return true;
}

bool XByteParser::get_char_array(char* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(char)) return false;
	memcpy(buf, m_pos, len * sizeof(char));
	m_pos += len * sizeof(char);
	return true;
}

bool XByteParser::get_int8_array(int8* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(int8)) return false;
	memcpy(buf, m_pos, len * sizeof(int8));
	m_pos += len * sizeof(int8);
	return true;
}

bool XByteParser::get_uint8_array(uint8* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(uint8)) return false;
	memcpy(buf, m_pos, len * sizeof(uint8));
	m_pos += len * sizeof(uint8);
	return true;
}

bool XByteParser::get_int16_array(int16* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(int16)) return false;
	memcpy(buf, m_pos, len * sizeof(int16));
	m_pos += len * sizeof(int16);
	return true;
}
bool XByteParser::get_uint16_array(uint16* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(uint16)) return false;
	memcpy(buf, m_pos, len * sizeof(uint16));
	m_pos += len * sizeof(uint16);
	return true;
}

bool XByteParser::get_int32_array(int32* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(int32)) return false;
	memcpy(buf, m_pos, len * sizeof(int32));
	m_pos += len * sizeof(int32);
	return true;
}

bool XByteParser::get_uint32_array(uint32* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(uint32)) return false;
	memcpy(buf, m_pos, len * sizeof(uint32));
	m_pos += len * sizeof(uint32);
	return true;
}

bool XByteParser::get_float_array(float* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(float)) return false;
	memcpy(buf, m_pos, len * sizeof(float));
	m_pos += len * sizeof(float);
	return true;
}

bool XByteParser::get_double_array(double* buf, uint32 len)
{
	if (buf == NULL) return false;
	if (remain() < len * sizeof(double)) return false;
	memcpy(buf, m_pos, len * sizeof(double));
	m_pos += len * sizeof(double);
	return true;
}

bool XByteParser::get_string_array(string* buf, uint32 len)
{
	if (buf == NULL) return false;
	for (uint32 i = 0; i < len; i++)
	{
		if (!get_string(buf[i])) return false;
	}
	return true;
}

bool XByteParser::get_bool_vector(vector<bool>& val, uint32 len)
{
	if (remain() < len * sizeof(uint8)) return false;
	for (uint8 i = 0; i < len; i++)
	{
		val.push_back(0 != (const uint8 *)m_pos + i);
	}
	m_pos += len * sizeof(uint8);
	return true;
}

bool XByteParser::get_char_vector(vector<char>& val, uint32 len)
{
	if (remain() < len * sizeof(char)) return false;
	val.insert(val.end(), (const char *)m_pos, (const char *)m_pos + len);
	m_pos += len * sizeof(char);
	return true;
}

bool XByteParser::get_int8_vector(vector<int8>& val, uint32 len)
{
	if (remain() < len * sizeof(int8)) return false;
	val.insert(val.end(), (const int8 *)m_pos, (const int8 *)m_pos + len);
	m_pos += len * sizeof(int8);
	return true;
}

bool XByteParser::get_uint8_vector(vector<uint8>& val, uint32 len)
{
	if (remain() < len * sizeof(uint8)) return false;
	val.insert(val.end(), (const uint8 *)m_pos, (const uint8 *)m_pos + len);
	m_pos += len * sizeof(uint8);
	return true;
}

bool XByteParser::get_int16_vector(vector<int16>& val, uint32 len)
{
	if (remain() < len * sizeof(int16)) return false;
	val.insert(val.end(), (const int16 *)m_pos, (const int16 *)m_pos + len);
	m_pos += len * sizeof(int16);
	return true;
}

bool XByteParser::get_uint16_vector(vector<uint16>& val, uint32 len)
{
	if (remain() < len * sizeof(uint16)) return false;
	val.insert(val.end(), (const uint16 *)m_pos, (const uint16 *)m_pos + len);
	m_pos += len * sizeof(uint16);
	return true;
}

bool XByteParser::get_int32_vector(vector<int32>& val, uint32 len)
{
	if (remain() < len * sizeof(int32)) return false;
	val.insert(val.end(), (const int32 *)m_pos, (const int32 *)m_pos + len);
	m_pos += len * sizeof(int32);
	return true;
}

bool XByteParser::get_uint32_vector(vector<uint32>& val, uint32 len)
{
	if (remain() < len * sizeof(uint32)) return false;
	val.insert(val.end(), (const uint32 *)m_pos, (const uint32 *)m_pos + len);
	m_pos += len * sizeof(uint32);
	return true;
}

bool XByteParser::get_float_vector(vector<float>& val, uint32 len)
{
	if (remain() < len * sizeof(float)) return false;
	val.insert(val.end(), (const float *)m_pos, (const float *)m_pos + len);
	m_pos += len * sizeof(float);
	return true;
}

bool XByteParser::get_double_vector(vector<double>& val, uint32 len)
{
	if (remain() < len * sizeof(double)) return false;
	val.insert(val.end(), (const double *)m_pos, (const double *)m_pos + len);
	m_pos += len * sizeof(double);
	return true;
}

bool XByteParser::get_string_vector(vector<string>& val, uint32 len)
{
	for (uint32 i = 0; i < len; i++)
	{
		string str;
		if (!get_string(str)) return false;
		val.push_back(str);
	}
	return true;
}


///////////////////////////////////////////////////////////////////////////////
// class XStrUtil
///////////////////////////////////////////////////////////////////////////////
string& XStrUtil::chop_head(string &strSrc, const char *pcszCharSet)
{
	if (pcszCharSet == NULL) return strSrc;
	size_t pos = strSrc.find_first_not_of(pcszCharSet);
	return strSrc.erase(0, pos);
}

string& XStrUtil::chop_tail(string &strSrc, const char *pcszCharSet)
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

string& XStrUtil::chop(string &strSrc, const char *pcszCharSet)
{
	chop_head(strSrc, pcszCharSet);
	return chop_tail(strSrc, pcszCharSet);
}

void XStrUtil::to_upper(char *pszSrc)
{
	if (pszSrc == NULL) return;
	char *pos = (char *)pszSrc;
	char diff = 'A' - 'a';
	while (*pos != '\0')
	{
		if ('a' <= *pos && *pos <= 'z')
		{
			*pos += diff;
		}
		pos++;
	}
	return;
}

void XStrUtil::to_lower(char *pszSrc)
{
	if (pszSrc == NULL) return;
	char *pos = (char *)pszSrc;
	char diff = 'A' - 'a';
	while (*pos != '\0')
	{
		if ('A' <= *pos && *pos <= 'Z')
		{
			*pos -= diff;
		}
		pos++;
	}
	return;
}

void XStrUtil::to_lower(string &strSrc)
{
	return to_lower((char *)strSrc.c_str());
}

void XStrUtil::to_upper(string &strSrc)
{
	return to_upper((char *)strSrc.c_str());
}

bool XStrUtil::to_int(const string &strSrc, int &nValue, int radix/* = 10*/)
{
	char* endPtr = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return false;

	errno = 0;
	nValue = (int)strtol(str.c_str(), &endPtr, radix);
	if (endPtr - str.c_str() != (int)str.size())
	{
		return false;
	}
	if (errno == ERANGE) return false;
	return true;
}

int XStrUtil::to_int_def(const string &strSrc, int def/* = -1*/, int radix/* = 10*/)
{
	char* endPtr = 0;
	int nValue = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return def;

	errno = 0;
	nValue = (int)strtol(str.c_str(), &endPtr, radix);
	if (endPtr - str.c_str() != (int)str.size())
	{
		return def;
	}
	if (errno == ERANGE) return false;
	return nValue;
}

int XStrUtil::try_to_int_def(const string &strSrc, int def/* = -1*/, int radix/* = 10*/)
{
	char* endPtr = 0;
	int nValue = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return def;

	errno = 0;
	nValue = (int)strtol(str.c_str(), &endPtr, radix);
	if (endPtr == str.c_str())
	{
		return def;
	}
	if (errno == ERANGE) return false;
	return nValue;
}

bool XStrUtil::to_uint(const string &strSrc, uint32 &uValue, int radix/* = 10*/)
{
	char* endPtr = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return false;

	errno = 0;
	uValue = (int)strtoul(str.c_str(), &endPtr, radix);
	if (endPtr - str.c_str() != (int)str.size())
	{
		return false;
	}
	if (errno == ERANGE) return false;
	return true;
}

uint32 XStrUtil::to_uint_def(const string &strSrc, uint32 def/* = 0*/, int radix/* = 10*/)
{
	char* endPtr = 0;
	uint32 uValue = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return def;

	errno = 0;
	uValue = (int)strtol(str.c_str(), &endPtr, radix);
	if (endPtr - str.c_str() != (int)str.size())
	{
		return def;
	}
	if (errno == ERANGE) return false;
	return uValue;
}

uint32 XStrUtil::try_to_uint_def(const string &strSrc, uint32 def/* = 0*/, int radix/* = 10*/)
{
	char* endPtr = 0;
	uint32 uValue = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return def;

	errno = 0;
	uValue = (int)strtol(str.c_str(), &endPtr, radix);
	if (endPtr == str.c_str())
	{
		return def;
	}
	if (errno == ERANGE) return false;
	return uValue;
}

bool XStrUtil::to_float(const string &strSrc, double &value)
{
	char* endPtr = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return false;

	errno = 0;
	value = (int)strtod(str.c_str(), &endPtr);
	if (endPtr - str.c_str() != (int)str.size())
	{
		return false;
	}
	if (errno == ERANGE) return false;
	return true;
}

double XStrUtil::to_float_def(const string &strSrc, double def/* = 0.0*/)
{
	char* endPtr = 0;
	double fValue = 0.0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return def;

	errno = 0;
	fValue = (int)strtod(str.c_str(), &endPtr);
	if (endPtr - str.c_str() != (int)str.size())
	{
		return def;
	}
	if (errno == ERANGE) return def;
	return fValue;
}

double	XStrUtil::try_to_float_def(const string &strSrc, double def/* = 0.0*/)
{
	char* endPtr = 0;
	double fValue = 0;
	string str = strSrc;

	chop(str);
	if (str.empty()) return def;

	errno = 0;
	fValue = (int)strtod(str.c_str(), &endPtr);
	if (endPtr == str.c_str())
	{
		return def;
	}
	if (errno == ERANGE) return def;
	return fValue;
}

string XStrUtil::to_str(int nVal, const char* cpszFormat)
{
	char buf[128];
	if (cpszFormat && strlen(cpszFormat) > 100) return "";
	if (cpszFormat)
		sprintf(buf, cpszFormat, nVal);
	else
		sprintf(buf, "%d", nVal);
	return buf;
}

string XStrUtil::to_str(uint32 uVal, const char* cpszFormat)
{
	char buf[128];
	if (cpszFormat && strlen(cpszFormat) > 100) return "";
	if (cpszFormat)
		sprintf(buf, cpszFormat, uVal);
	else
		sprintf(buf, "%u", uVal);
	return buf;
}

string XStrUtil::to_str(int64 nlVal, const char* cpszFormat)
{
	char buf[256];
	if (cpszFormat && strlen(cpszFormat) > 240) return "";
	if (cpszFormat)
		sprintf(buf, cpszFormat, nlVal);
	else
		sprintf(buf, "%lld", (long long int)nlVal);
	return buf;
}

string XStrUtil::to_str(uint64 ulVal, const char* cpszFormat)
{
	char buf[256];
	if (cpszFormat && strlen(cpszFormat) > 240) return "";
	if (cpszFormat)
		sprintf(buf, cpszFormat, ulVal);
	else
		sprintf(buf, "%llu", (long long int)ulVal);
	return buf;
}

string XStrUtil::to_str(double fVal, const char* cpszFormat)
{
	char buf[256];
	if (cpszFormat && strlen(cpszFormat) > 240) return "";
	if (cpszFormat)
		sprintf(buf, cpszFormat, fVal);
	else
		sprintf(buf, "%f", fVal);
	return buf;
}

///////////////////////////////////////////////////////////////////////////////

bool __is_whitespace(char ch)
{
	return (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n');
}

bool __is_digit(char ch)
{
	return ('0' <= ch && ch <= '9');
}

bool __is_alpha(char ch)
{
	if ('a' <= ch && ch <= 'z') return true;
	if ('A' <= ch && ch <= 'Z') return true;
	return false;
}

bool __is_hex(char ch)
{
	if ('0' <= ch && ch <= '9') return true;
	if ('a' <= ch && ch <= 'f') return true;
	if ('A' <= ch && ch <= 'F') return true;
	return false;
}

const char* __findchar(const char* str, char ch)
{
	while (*str != '\0')
	{
		if (*str == ch)
			return str;
		else
			str++;
	}
	return NULL;
}

// Converts a unicode code-point to UTF-8.
string __unicode_to_utf8(uint32 unicode)
{
	string result;

	// based on description from http://en.wikipedia.org/wiki/UTF-8

	if (unicode <= 0x7f) 
	{
		result.resize(1);
		result[0] = static_cast<char>(unicode);
	} 
	else if (unicode <= 0x7FF) 
	{
		result.resize(2);
		result[1] = static_cast<char>(0x80 | (0x3f & unicode));
		result[0] = static_cast<char>(0xC0 | (0x1f & (unicode >> 6)));
	} 
	else if (unicode <= 0xFFFF) 
	{
		result.resize(3);
		result[2] = static_cast<char>(0x80 | (0x3f & unicode));
		result[1] = 0x80 | static_cast<char>((0x3f & (unicode >> 6)));
		result[0] = 0xE0 | static_cast<char>((0xf & (unicode >> 12)));
	}
	else if (unicode <= 0x10FFFF) 
	{
		result.resize(4);
		result[3] = static_cast<char>(0x80 | (0x3f & unicode));
		result[2] = static_cast<char>(0x80 | (0x3f & (unicode >> 6)));
		result[1] = static_cast<char>(0x80 | (0x3f & (unicode >> 12)));
		result[0] = static_cast<char>(0xF0 | (0x7 & (unicode >> 18)));
	}

	return result;
}

}//namespace xcore
