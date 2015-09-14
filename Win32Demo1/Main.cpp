//**********************************************************************************************
// Win32桌面程序创建的4部曲
// 1.窗口类的设计
// 2.窗口类的注册
// 3.窗口的正式创建
// 4.窗口的显示与更新
// Author: SimonWu
// Date: 2015-09-13
//**********************************************************************************************
#include <Windows.h>
#include <tchar.h>

//#pragma comment(lib,"winmm.lib")

// 函数的前向声明
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{

	return 0;
}

// 1.设计窗口
bool InitializeWin(HINSTANCE hInstance, int nCmdShow)
{
	/**
	* 定义一个窗口类，wndObj 用于之后窗口的各项初始化。
	*/
	WNDCLASSEX wndObj = { 0 };
	wndObj.cbSize = sizeof(WNDCLASSEX); // 设置结构体的字节数大小
	wndObj.style = CS_HREDRAW | CS_VREDRAW; // 设置窗口的样式。
	wndObj.lpfnWndProc = WndProc;	// 设置指向窗口过程函数的指针。
	wndObj.cbClsExtra = 0;
	wndObj.cbWndExtra = 0;
	wndObj.hInstance = hInstance; //指向包含窗口过程的程序的实例句柄。
	wndObj.hIcon = NULL;	// 指定 icon 图标。
	wndObj.hCursor = LoadCursor(NULL, IDC_ARROW);	//指定窗口类的光标类型。
	wndObj.hbrBackground = (HBRUSH)GetStockObject(GRAY_BRUSH);	//指定一个灰色的画刷句柄
	wndObj.lpszMenuName = NULL;
	wndObj.lpszClassName = _T("ForTheDreamOfGameDevelop");

	// 窗口的注册
	RegisterClassEx(&wndObj);
}



// 窗口的过程函数
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{

}