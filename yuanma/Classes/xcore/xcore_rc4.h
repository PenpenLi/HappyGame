#ifndef _XCORE_RC4_H_
#define _XCORE_RC4_H_

#include "xcore_define.h"

namespace xcore
{

////////////////////////////////////////////////////////////////////////////////
// class RC4
////////////////////////////////////////////////////////////////////////////////
class RC4
{
public:
	RC4();

	void init(byte* key, uint8 keylen);

	void init(const string& key);

	void update(const byte* input, byte* output, uint32 length);

private:
	byte    m_sbox[256];
	uint8   m_index_i;
	uint8   m_index_j;
};

}//namespace xcore

using namespace xcore;

#endif//_XCORE_RC4_H_
