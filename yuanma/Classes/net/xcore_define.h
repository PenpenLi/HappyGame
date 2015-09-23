#ifndef _XCORE_DEFINE_H_
#define _XCORE_DEFINE_H_

#if !defined(__WINDOWS__) && !defined(__LINUX__)
#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
#define __WINDOWS__   1
#elif defined(__linux__) || defined(__APPLE__) || defined(__MACOSX__)
#define __LINUX__  1
#else
#error "Unrecognized OS platform"
#endif
#endif//!defined(__WINDOWS__) && !defined(__LINUX__)

#if (defined(_DEBUG) || defined(DEBUG)) && !defined(__DEBUG__)
#define __DEBUG__        1    // debug version
#endif

#if defined(_MSC_VER)
# pragma warning(disable:4996) // VC++ 2008 deprecated function warnings
# pragma warning(disable:4200) // warning C4200: nonstandard extension used : zero-sized array in struct/union
# pragma warning(disable:4355) // warning C4355: 'this': used in base member initializer list
# pragma warning(disable:4819) // warning C4819: The file contains a character that cannot be represented in the current code page (936)
#endif

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <errno.h>
#include <string.h>
//#include <malloc.h>
#include <fcntl.h>
#include <signal.h>
#include <limits.h>
#include <assert.h>

#include <vector>
#include <string>
#include <list>
#include <set>
#include <map>
#include <algorithm>
using namespace std;

#ifdef __WINDOWS__

#ifndef _INC_WINDOWS
#include <WinSock2.h>
#endif /* _INC_WINDOWS */

#endif


#ifdef __LINUX__
#include <unistd.h>
#include <stdint.h>       // int64_t, uint64_t
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <sys/times.h>
#include <sys/time.h>
#include <sys/stat.h>
//#include <sys/statvfs.h>
#include <sys/wait.h>
#include <sys/file.h>
#include <sys/ioctl.h>
#include <sys/poll.h>
//#include <sys/epoll.h>
#include <pthread.h>
#include <semaphore.h>
//#include <linux/types.h>
#endif//__LINUX__

#ifdef __WINDOWS__
typedef signed char          int8;
typedef unsigned char        uint8;
typedef signed short         int16;
typedef unsigned short       uint16;
typedef signed int           int32;
typedef unsigned int         uint32;
typedef __int64              int64;
typedef unsigned __int64     uint64;
typedef int                  socklen_t;
#ifdef XAPI_EXPORTS
#define XAPI __declspec(dllexport)
#else//defined(XAPI_EXPORTS)
#define XAPI __declspec(dllimport)
#endif//defined(XAPI_EXPORTS)
#endif//__WINDOWS__

#ifdef __LINUX__
typedef int8_t               int8;
typedef uint8_t              uint8;
typedef int16_t              int16;
typedef uint16_t             uint16;
typedef int32_t              int32;
typedef uint32_t             uint32;
typedef int64_t              int64;
typedef uint64_t             uint64;
typedef unsigned char        BYTE;
typedef unsigned char        byte;
typedef unsigned short       WORD;
typedef unsigned long        DWORD;
typedef int                  SOCKET;
typedef int                  BOOL;
typedef int                  HANDLE;
#define TRUE                 (1)
#define FALSE                (0)
#define INVALID_SOCKET       (SOCKET)(~0)
#define INVALID_HANDLE_VALUE (HANDLE)(-1)
#define SOCKET_ERROR         (-1)
#define __stdcall 
#define XAPI
#endif//__LINUX__

#endif //_XCORE_DEFINE_H_
