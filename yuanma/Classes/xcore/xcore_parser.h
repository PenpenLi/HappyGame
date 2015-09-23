#ifndef _XCORE_PARSER_H_
#define _XCORE_PARSER_H_

#include "xcore_define.h"

namespace xcore {

/////////////////////////////////////////////////////////////////////
// class XStrParser
/////////////////////////////////////////////////////////////////////
class XBufferParser
{
public:
	XBufferParser();
	XBufferParser(const char* buff, uint32 length);
	XBufferParser(const XBufferParser& other);
	XBufferParser& operator=(const XBufferParser& other);
	virtual ~XBufferParser();

	void attach(const char* buff, uint32 length);

	const char*  position() const { return m_pos; }
	const char*  start() const { return m_buff; }
	const char*  end() const { return m_end; }
	
	uint32 remain() const { return (uint32)(m_end - m_pos); }
	bool   eof() const { return m_pos >= m_end; }
	void   reset() { m_pos = m_buff; }
	bool   set_pos(const char* pos);
	
protected:
	void __clear();

protected:
	const char*    m_buff;
	const char*    m_pos;
	const char*    m_end;
};


/////////////////////////////////////////////////////////////////////
// class XStrParser
/////////////////////////////////////////////////////////////////////
class XStrParser : public XBufferParser
{
public:
	XStrParser();
	XStrParser(const char* buff, uint32 length);
	XStrParser(const XStrParser& other);
	XStrParser& operator=(const XStrParser& other);
	virtual ~XStrParser();

	void   chop_head_whitespace();
	void   chop_tail_whitespace();
	void   chop_whitespace();

	bool   is_whitespace() const;
	bool   is_digit() const;
	bool   is_alpha() const;
	bool   is_hex() const;

	uint32 skip_n(uint32 n);
	uint32 skip_char(uint8 ch);
	uint32 skip_within(const char* incharset);
	uint32 skip_without(const char* outcharset);
	uint32 skip_whitespace();
	uint32 skip_nonwhitespace();

	char   getch();
	bool   getch_digit(uint8& digit);
	bool   getch_hex(uint8& hex);
	bool   getch_unicode(uint32& unicode);
	bool   getstr_by_quotation(string& result);
	bool   getstr_by_sign(string& result, char lsign, char rsign, bool with_sign = false);
	string getstr_n(uint32 n = (uint32)-1);
	string getstr_within(const char* incharset);
	string getstr_without(const char* outcharset);

	int64  get_integer();
	double get_fractional();
	uint8  get_uint8();
	uint32 get_uint32();
	uint64 get_uint64();
	uint64 get_hex();

	const char*  findchar(char ch) const;
	const char*  findchar(char ch, const char* before) const;
	const char*  findchar_within(const char* incharset) const;
	const char*  findchar_without(const char* outcharset) const;
	const char*  findstr(const char* str) const;
};


/////////////////////////////////////////////////////////////////////
// class XByteParser
/////////////////////////////////////////////////////////////////////
class XByteParser : public XBufferParser
{
public:
	XByteParser();
	XByteParser(const char* buff, uint32 length);
	XByteParser(const XByteParser& other);
	XByteParser& operator=(const XByteParser& other);
	virtual ~XByteParser();

public:
	bool get_bool(bool& val);
	bool get_char(char& val);
	bool get_int8(int8& val);
	bool get_uint8(uint8& val);
	bool get_int16(int16& val);
	bool get_uint16(uint16& val);
	bool get_int32(int32& val);
	bool get_uint32(uint32& val);
	bool get_float(float& val);
	bool get_double(double& val);
	bool get_string(string& val);

	bool get_bool_array(bool* buf, uint32 len);
	bool get_char_array(char* buf, uint32 len);
	bool get_int8_array(int8* buf, uint32 len);
	bool get_uint8_array(uint8* buf, uint32 len);
	bool get_int16_array(int16* buf, uint32 len);
	bool get_uint16_array(uint16* buf, uint32 len);
	bool get_int32_array(int32* buf, uint32 len);
	bool get_uint32_array(uint32* buf, uint32 len);
	bool get_float_array(float* buf, uint32 len);
	bool get_double_array(double* buf, uint32 len);
	bool get_string_array(string* buff, uint32 len);

	bool get_bool_vector(vector<bool>& val, uint32 len);
	bool get_char_vector(vector<char>& val, uint32 len);
	bool get_int8_vector(vector<int8>& val, uint32 len);
	bool get_uint8_vector(vector<uint8>& val, uint32 len);
	bool get_int16_vector(vector<int16>& val, uint32 len);
	bool get_uint16_vector(vector<uint16>& val, uint32 len);
	bool get_int32_vector(vector<int32>& val, uint32 len);
	bool get_uint32_vector(vector<uint32>& val, uint32 len);
	bool get_float_vector(vector<float>& val, uint32 len);
	bool get_double_vector(vector<double>& val, uint32 len);
	bool get_string_vector(vector<string>& val, uint32 len);
};

///////////////////////////////////////////////////////////////////////////////
// class XStrUtil
///////////////////////////////////////////////////////////////////////////////
class XStrUtil
{
public:
	// 去除字符串头(或尾)中在字符集中指定的字符
	static string& chop_head(string &strSrc, const char *pcszCharSet = " \t\r\n");
	static string& chop_tail(string &strSrc, const char *pcszCharSet = " \t\r\n");
	static string& chop(string &strSrc, const char *pcszCharSet = " \t\r\n");

	// 字符串转大写(或小写)
	static void to_upper(char *pszSrc);
	static void to_lower(char *pszSrc);
	static void to_upper(string &strSrc);
	static void to_lower(string &strSrc);

	// 字符串转整数
	static bool	  to_int(const string &strSrc, int &nValue, int radix = 10);
	static int	  to_int_def(const string &strSrc, int def = -1, int radix = 10);
	static int	  try_to_int_def(const string &strSrc, int def = -1, int radix = 10);
	static bool	  to_uint(const string &strSrc, uint32 &uValue, int radix = 10);
	static uint32 to_uint_def(const string &strSrc, uint32 def = 0, int radix = 10);
	static uint32 try_to_uint_def(const string &strSrc, uint32 def = 0, int radix = 10);

	// 字符串转浮点型数
	static bool   to_float(const string &strSrc, double &value);
	static double to_float_def(const string &strSrc, double def = 0.0);
	static double try_to_float_def(const string &strSrc, double def = 0.0);

	// 数值转字符串
	static string to_str(int nVal, const char* cpszFormat = NULL/*"%d"*/);
	static string to_str(uint32 uVal, const char* cpszFormat = NULL/*"%u"*/);
	static string to_str(int64 nlVal, const char* cpszFormat = NULL/*"%lld"*/);
	static string to_str(uint64 ulVal, const char* cpszFormat = NULL/*"%llu"*/);
	static string to_str(double fVal, const char* cpszFormat = NULL/*"%f"*/);
};

}//namespace xcore

using namespace xcore;

#endif//_XCORE_PARSER_H_
