//**********************************************************************************************
// ��򵥵�Win32����
// Author: SimoWu
// Date: 2015-09-13
//**********************************************************************************************
#include <Windows.h>

//#pragma comment(lib,"winmm.lib")

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	// �������ֵķ�����ֻ֧�� wav ��ʽ���ļ���
	PlaySound(L"110.wav", NULL, SND_FILENAME | SND_ASYNC);

	MessageBox(NULL, L"��ã�DX9!", L"MessageBox", 0);
	return 0;
}