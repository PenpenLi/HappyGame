// TestOne.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "amp_math.h"

int _tmain(int argc, _TCHAR* argv[])
{
	float roate = 1136 / 480;
	float dw = ceilf(640/roate);
	printf("%f",dw);
	return 0;
}

