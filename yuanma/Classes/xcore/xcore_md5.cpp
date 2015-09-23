﻿#include "xcore_md5.h"

namespace xcore
{

// Constants for MD5 Transform.
#define S11 7
#define S12 12
#define S13 17
#define S14 22
#define S21 5
#define S22 9
#define S23 14
#define S24 20
#define S31 4
#define S32 11
#define S33 16
#define S34 23
#define S41 6
#define S42 10
#define S43 15
#define S44 21

// F, G, H and I are basic MD5 transformations functions.
#define F(x, y, z) (((x) & (y)) | ((~x) & (z)))
#define G(x, y, z) (((x) & (z)) | ((y) & (~z)))
#define H(x, y, z) ((x) ^ (y) ^ (z))
#define I(x, y, z) ((y) ^ ((x) | (~z)))

// ROTATE_LEFT rotates x left n bits.
#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))

// Rounds 1, 2, 3, and 4 MD5 transformations.
// Rotation is seperate from addition to prevent recomputation.
#define FF(a, b, c, d, x, s, ac) { \
 (a) += F ((b), (c), (d)) + (x) + (uint32)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }

#define GG(a, b, c, d, x, s, ac) { \
 (a) += G ((b), (c), (d)) + (x) + (uint32)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }

#define HH(a, b, c, d, x, s, ac) { \
 (a) += H ((b), (c), (d)) + (x) + (uint32)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }

#define II(a, b, c, d, x, s, ac) { \
 (a) += I ((b), (c), (d)) + (x) + (uint32)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }

static unsigned char md5_padding[64] =
{
	0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

////////////////////////////////////////////////////////////////////////////////
// class XMD5
////////////////////////////////////////////////////////////////////////////////
XMD5::XMD5()
{
	initialize();
}

/// md5::Init
/// Initializes a new context.
void XMD5::initialize(void)
{
	m_count[0] = 0;
	m_count[1] = 0;

	m_state[0] = 0x67452301;
	m_state[1] = 0xEFCDAB89;
	m_state[2] = 0x98BADCFE;
	m_state[3] = 0x10325476;
}

/// XMD5::Update
/// MD5 block update operation. Continues an MD5 message-digest
/// operation, processing another message block, and updating the
/// context.
void XMD5::update(const uint8* input, uint32 inputLen)
{
	uint32 i, index, partLen;

	if (input == NULL) return;

	// Compute number of bytes mod 64.
	index = (uint32)((m_count[0] >> 3) & 0x3F);

	// Update number of bits.
	if ((m_count[0] += (inputLen << 3)) < (inputLen << 3))
	{
		m_count[1]++;
	}
	m_count[1] += (inputLen >> 29);

	partLen = 64 - index;

	// Transform as many times as possible.
	if (inputLen >= partLen)
	{
		memcpy(&m_buffer[index], input, partLen);
		_transform(m_buffer);

		for (i = partLen; i + 63 < inputLen; i += 64)
		{
			_transform(&input[i]);
		}

		index = 0;
	}
	else
	{
		i = 0;
	}

	// Buffer remaining input.
	memcpy(&m_buffer[index], &input[i], inputLen - i);
}

/// XMD5::Finalize
/// MD5 finalization. Ends an MD5 message-digest operation, writing
/// the message digest and zeroizing the context.
void XMD5::final(uint8(&digest)[16])
{
	uint8 bits[8];
	uint32 index, padLen;

	// Save number of bits.
	_encode(bits, m_count, 2);

	// Pad out to 56 mod 64.
	index = (uint32)((m_count[0] >> 3) & 0x3f);
	padLen = (index < 56) ? (56 - index) : (120 - index);
	update(md5_padding, padLen);

	// Append length (before padding).
	update(bits, 8);

	// Store state in digest
	_encode(digest, m_state, 4);

	// Zeroize sensitive information.  ???
	memset(m_count, 0, 2 * sizeof(uint32));
	memset(m_state, 0, 4 * sizeof(uint32));
	memset(m_buffer, 0, 64 * sizeof(uint8));
}

/// XMD5::Finalize
string XMD5::final()
{
	char buf[33];
	uint8 digest[16] = {};

	final(digest);

	for (int i = 0; i < 16; i++)
	{
		sprintf(buf + i * 2, "%02X", digest[i]);
	}
	buf[32] = '\0';
	return buf;
}

/// XMD5::Transform
/// MD5 basic transformation. Transforms state based on block.
void XMD5::_transform(const uint8* block)
{
	uint32 a = m_state[0], b = m_state[1], c = m_state[2], d = m_state[3], x[16];

	_decode(x, block, 64);

	// Round 1
	FF(a, b, c, d, x[ 0], S11, 0xd76aa478);  /* 1 */
	FF(d, a, b, c, x[ 1], S12, 0xe8c7b756);  /* 2 */
	FF(c, d, a, b, x[ 2], S13, 0x242070db);  /* 3 */
	FF(b, c, d, a, x[ 3], S14, 0xc1bdceee);  /* 4 */
	FF(a, b, c, d, x[ 4], S11, 0xf57c0faf);  /* 5 */
	FF(d, a, b, c, x[ 5], S12, 0x4787c62a);  /* 6 */
	FF(c, d, a, b, x[ 6], S13, 0xa8304613);  /* 7 */
	FF(b, c, d, a, x[ 7], S14, 0xfd469501);  /* 8 */
	FF(a, b, c, d, x[ 8], S11, 0x698098d8);  /* 9 */
	FF(d, a, b, c, x[ 9], S12, 0x8b44f7af);  /* 10 */
	FF(c, d, a, b, x[10], S13, 0xffff5bb1);  /* 11 */
	FF(b, c, d, a, x[11], S14, 0x895cd7be);  /* 12 */
	FF(a, b, c, d, x[12], S11, 0x6b901122);  /* 13 */
	FF(d, a, b, c, x[13], S12, 0xfd987193);  /* 14 */
	FF(c, d, a, b, x[14], S13, 0xa679438e);  /* 15 */
	FF(b, c, d, a, x[15], S14, 0x49b40821);  /* 16 */

	// Round 2
	GG(a, b, c, d, x[ 1], S21, 0xf61e2562);  /* 17 */
	GG(d, a, b, c, x[ 6], S22, 0xc040b340);  /* 18 */
	GG(c, d, a, b, x[11], S23, 0x265e5a51);  /* 19 */
	GG(b, c, d, a, x[ 0], S24, 0xe9b6c7aa);  /* 20 */
	GG(a, b, c, d, x[ 5], S21, 0xd62f105d);  /* 21 */
	GG(d, a, b, c, x[10], S22,  0x2441453);  /* 22 */
	GG(c, d, a, b, x[15], S23, 0xd8a1e681);  /* 23 */
	GG(b, c, d, a, x[ 4], S24, 0xe7d3fbc8);  /* 24 */
	GG(a, b, c, d, x[ 9], S21, 0x21e1cde6);  /* 25 */
	GG(d, a, b, c, x[14], S22, 0xc33707d6);  /* 26 */
	GG(c, d, a, b, x[ 3], S23, 0xf4d50d87);  /* 27 */
	GG(b, c, d, a, x[ 8], S24, 0x455a14ed);  /* 28 */
	GG(a, b, c, d, x[13], S21, 0xa9e3e905);  /* 29 */
	GG(d, a, b, c, x[ 2], S22, 0xfcefa3f8);  /* 30 */
	GG(c, d, a, b, x[ 7], S23, 0x676f02d9);  /* 31 */
	GG(b, c, d, a, x[12], S24, 0x8d2a4c8a);  /* 32 */

	// Round 3
	HH(a, b, c, d, x[ 5], S31, 0xfffa3942);  /* 33 */
	HH(d, a, b, c, x[ 8], S32, 0x8771f681);  /* 34 */
	HH(c, d, a, b, x[11], S33, 0x6d9d6122);  /* 35 */
	HH(b, c, d, a, x[14], S34, 0xfde5380c);  /* 36 */
	HH(a, b, c, d, x[ 1], S31, 0xa4beea44);  /* 37 */
	HH(d, a, b, c, x[ 4], S32, 0x4bdecfa9);  /* 38 */
	HH(c, d, a, b, x[ 7], S33, 0xf6bb4b60);  /* 39 */
	HH(b, c, d, a, x[10], S34, 0xbebfbc70);  /* 40 */
	HH(a, b, c, d, x[13], S31, 0x289b7ec6);  /* 41 */
	HH(d, a, b, c, x[ 0], S32, 0xeaa127fa);  /* 42 */
	HH(c, d, a, b, x[ 3], S33, 0xd4ef3085);  /* 43 */
	HH(b, c, d, a, x[ 6], S34,  0x4881d05);  /* 44 */
	HH(a, b, c, d, x[ 9], S31, 0xd9d4d039);  /* 45 */
	HH(d, a, b, c, x[12], S32, 0xe6db99e5);  /* 46 */
	HH(c, d, a, b, x[15], S33, 0x1fa27cf8);  /* 47 */
	HH(b, c, d, a, x[ 2], S34, 0xc4ac5665);  /* 48 */

	// Round 4
	II(a, b, c, d, x[ 0], S41, 0xf4292244);  /* 49 */
	II(d, a, b, c, x[ 7], S42, 0x432aff97);  /* 50 */
	II(c, d, a, b, x[14], S43, 0xab9423a7);  /* 51 */
	II(b, c, d, a, x[ 5], S44, 0xfc93a039);  /* 52 */
	II(a, b, c, d, x[12], S41, 0x655b59c3);  /* 53 */
	II(d, a, b, c, x[ 3], S42, 0x8f0ccc92);  /* 54 */
	II(c, d, a, b, x[10], S43, 0xffeff47d);  /* 55 */
	II(b, c, d, a, x[ 1], S44, 0x85845dd1);  /* 56 */
	II(a, b, c, d, x[ 8], S41, 0x6fa87e4f);  /* 57 */
	II(d, a, b, c, x[15], S42, 0xfe2ce6e0);  /* 58 */
	II(c, d, a, b, x[ 6], S43, 0xa3014314);  /* 59 */
	II(b, c, d, a, x[13], S44, 0x4e0811a1);  /* 60 */
	II(a, b, c, d, x[ 4], S41, 0xf7537e82);  /* 61 */
	II(d, a, b, c, x[11], S42, 0xbd3af235);  /* 62 */
	II(c, d, a, b, x[ 2], S43, 0x2ad7d2bb);  /* 63 */
	II(b, c, d, a, x[ 9], S44, 0xeb86d391);  /* 64 */

	m_state[0] += a;
	m_state[1] += b;
	m_state[2] += c;
	m_state[3] += d;

	// Zeroize sensitive information.
	memset(x, 0, sizeof(x));
}

/// XMD5::Encode
/// Encodes input (uint4) into output (uint8). Assumes nLength is
/// a multiple of 4.
void XMD5::_encode(uint8* output, const uint32* input, uint32 inputLen)
{
	memcpy(output, input, inputLen * 4);
}

/// XMD5::Decode
/// Decodes input (uint8) into output (uint4). Assumes nLength is
/// a multiple of 4.
void XMD5::_decode(uint32* output, const uint8* input, uint32 inputLen)
{
	memcpy(output, input, inputLen);
}


///////////////////////////////////////////////////////////////////////////////

void md5(const void* src, uint32 size, uint8(&digest)[16])
{
	static const char* s_empty = "";
	memset(digest, 0, 16);
	if (src == NULL)
	{
		src = s_empty;
		size = 0;
	}

	XMD5 md5_;
	md5_.update((const uint8*)src, size);
	md5_.final(digest);
	return;
}

string md5(const void* src, uint32 size)
{
	static const char* s_empty = "";
	if (src == NULL)
	{
		src = s_empty;
		size = 0;
	}

	XMD5 md5_;
	md5_.update((const uint8*)src, size);
	return md5_.final();
}

void hmac_md5(const void* src, uint32 size_, const void* key, uint32 key_size_, uint8(&digest)[16])
{
	byte ipad[64];
	byte opad[64];
	uint32 i = 0;
	const byte* key_ = (const byte*)key;

	// step 1
	if (key_size_ > 64)
	{
		uint8 digest_[16];
		xcore::md5(key, key_size_, digest_);

		for (i = 0; i < 16; ++i) ipad[i] = digest_[i] ^ 0x36;
		for (; i < 64; ++i) ipad[i] = 0x36;

		for (i = 0; i < 16; ++i) opad[i] = digest_[i] ^ 0x5c;
		for (; i < 64; ++i) opad[i] = 0x5c;
	}
	else
	{
		for (i = 0; i < key_size_; ++i) ipad[i] = key_[i] ^ 0x36;
		for (; i < 64; ++i) ipad[i] = 0x36;

		for (i = 0; i < key_size_; ++i) opad[i] = key_[i] ^ 0x5c;
		for (; i < 64; ++i) opad[i] = 0x5c;
	}

	// step2
	XMD5 md5Digest;
	md5Digest.update(ipad, 64);
	md5Digest.update((const byte*)src, size_);
	md5Digest.final(digest);

	// step3
	md5Digest.initialize();
	md5Digest.update(opad, 64);
	md5Digest.update(digest, 16);
	md5Digest.final(digest);
	return;
}

string hmac_md5(const void* src, uint32 size_, const void* key, uint32 key_size_)
{
	byte ipad[64];
	byte opad[64];
	uint8 digest[16];
	uint32 i = 0;
	const byte* key_ = (const byte*)key;

	// step 1
	if (key_size_ > 64)
	{
		uint8 digest_[16];
		xcore::md5(key, key_size_, digest_);

		for (i = 0; i < 16; ++i) ipad[i] = digest_[i] ^ 0x36;
		for (; i < 64; ++i) ipad[i] = 0x36;

		for (i = 0; i < 16; ++i) opad[i] = digest_[i] ^ 0x5c;
		for (; i < 64; ++i) opad[i] = 0x5c;
	}
	else
	{
		for (i = 0; i < key_size_; ++i) ipad[i] = key_[i] ^ 0x36;
		for (; i < 64; ++i) ipad[i] = 0x36;

		for (i = 0; i < key_size_; ++i) opad[i] = key_[i] ^ 0x5c;
		for (; i < 64; ++i) opad[i] = 0x5c;
	}

	// step2
	XMD5 md5Digest;
	md5Digest.update(ipad, 64);
	md5Digest.update((const byte*)src, size_);
	md5Digest.final(digest);

	// step3
	md5Digest.initialize();
	md5Digest.update(opad, 64);
	md5Digest.update(digest, 16);
	return md5Digest.final();
}

string md5_file(const string& filepath)
{
	FILE* fd = fopen(filepath.c_str(), "rb");
	if (fd == NULL) return "";

	byte buf[2048];
	XMD5 md5_;
	while (true)
	{
		size_t ret = fread(buf, 1, 2048, fd);
		if (ret == 0) break;
		md5_.update(buf, (uint32)ret);
	}
	fclose(fd);
	return md5_.final();
}

} // namespace xcore
