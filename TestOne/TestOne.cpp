// TestOne.cpp : �������̨Ӧ�ó������ڵ㡣
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

