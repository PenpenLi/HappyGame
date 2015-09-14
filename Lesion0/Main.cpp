//**********************************************************************************************
// 最简单的Win32程序
// Author: SimoWu
// Date: 2015-09-13
//**********************************************************************************************
#include <Windows.h>

//#pragma comment(lib,"winmm.lib")

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	// 播放音乐的方法（只支持 wav 格式的文件）
	PlaySound(L"110.wav", NULL, SND_FILENAME | SND_ASYNC);

	MessageBox(NULL, L"你好，DX9!", L"MessageBox", 0);
	return 0;
}