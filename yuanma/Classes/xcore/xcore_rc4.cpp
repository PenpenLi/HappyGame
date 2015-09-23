#include "xcore_rc4.h"
#include "xcore_md5.h"

namespace xcore
{

////////////////////////////////////////////////////////////////////////////////
// class RC4
////////////////////////////////////////////////////////////////////////////////
RC4::RC4()
	: m_index_i(0)
	, m_index_j(0)
{
	// empty
}

void RC4::init(byte* key, uint8 keylen)
{
	assert(key && keylen > 0);

	byte tmp;

	//Fill in linearly s0=0, s1=1, ...
	for (int i = 0; i < 256; i++)
	{
		m_sbox[i] = i;
	}

	int j = 0;
	for (int i = 0; i < 256; i++)
	{
		// j = (j + Si + Ki) mod 256
		j = (j + m_sbox[i] + key[i % keylen]) & 255;

		tmp = m_sbox[i];
		m_sbox[i] = m_sbox[j];
		m_sbox[j] = tmp;
	}
}

void RC4::init(const string& key)
{
	byte digest1[16], digest2[16];
	xcore::md5(key.c_str(), key.size(), digest1);
	byte tmp = digest1[7];
	digest1[7] = digest1[13];
	digest1[13] = tmp;
	xcore::md5(digest1, 16, digest2);
	init(digest2, 16);
}

void RC4::update(const byte* input, byte* output, uint32 length)
{
	byte tmp;

	while (length-- > 0)
	{
		// Get the next S box indices...
		m_index_i = (m_index_i + 1) & 255;
		m_index_j = (m_index_j + m_sbox[m_index_i]) & 255;

		// Swap Si and Sj...
		tmp = m_sbox[m_index_i];
		m_sbox[m_index_i] = m_sbox[m_index_j];
		m_sbox[m_index_j] = tmp;

		// Get the S box index for this byte...
		int t = (m_sbox[m_index_i] + m_sbox[m_index_j]) & 255;

		// Encrypt using the S box...
		*output++ = *input++ ^ m_sbox[t];
	}
}

}//namespace xcore
