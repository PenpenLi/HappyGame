//**********************************************************************************************
// Win32������򴴽���4����
// 1.����������
// 2.�������ע��
// 3.���ڵ���ʽ����
// 4.���ڵ���ʾ�����
// Author: SimonWu
// Date: 2015-09-13
//**********************************************************************************************
#include <Windows.h>
#include <tchar.h>

//#pragma comment(lib,"winmm.lib")

// ������ǰ������
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{

	return 0;
}

// 1.��ƴ���
bool InitializeWin(HINSTANCE hInstance, int nCmdShow)
{
	/**
	* ����һ�������࣬wndObj ����֮�󴰿ڵĸ����ʼ����
	*/
	WNDCLASSEX wndObj = { 0 };
	wndObj.cbSize = sizeof(WNDCLASSEX); // ���ýṹ����ֽ�����С
	wndObj.style = CS_HREDRAW | CS_VREDRAW; // ���ô��ڵ���ʽ��
	wndObj.lpfnWndProc = WndProc;	// ����ָ�򴰿ڹ��̺�����ָ�롣
	wndObj.cbClsExtra = 0;
	wndObj.cbWndExtra = 0;
	wndObj.hInstance = hInstance; //ָ��������ڹ��̵ĳ����ʵ�������
	wndObj.hIcon = NULL;	// ָ�� icon ͼ�ꡣ
	wndObj.hCursor = LoadCursor(NULL, IDC_ARROW);	//ָ��������Ĺ�����͡�
	wndObj.hbrBackground = (HBRUSH)GetStockObject(GRAY_BRUSH);	//ָ��һ����ɫ�Ļ�ˢ���
	wndObj.lpszMenuName = NULL;
	wndObj.lpszClassName = _T("ForTheDreamOfGameDevelop");

	// ���ڵ�ע��
	RegisterClassEx(&wndObj);
}

// ���ڵĹ��̺���
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	return 0; //�����˳�
}