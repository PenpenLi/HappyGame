//-----------------------------------[程序说明]-----------------------------------------------------------------------
// 程序名称：GDIdemoCore
// 2015年9月15日 simon
// 描述： 实现GDI 游戏开发所需的核心程序
//---------------------------------------------------------------------------------------------------------------------

//-----------------------------------[头文件定义部分]------------------------------------------------------------------
// 描述：包含程序所依赖的头文件
//---------------------------------------------------------------------------------------------------------------------
#include <windows.h>

//------------------------------------[宏定义部分]---------------------------------------------------------------------
// 描述：定义一些辅助宏
//---------------------------------------------------------------------------------------------------------------------
#define WINDOW_WIDTH 800	//为窗口定义宽度的宏（方便在此处修改窗口的宽度）
#define WINDOW_HEIGHT 600	//为窗口定义高度的宏 (方便在此处修改窗口的高度)
#define WINDOW_TITLE L"GDI通用框架"	  //为窗体标题定义的宏

//------------------------------------[全局变量声明部分]----------------------------------------------------------------
// 描述：全局变量的声明
//----------------------------------------------------------------------------------------------------------------------
HDC g_hdc = NULL;	//全局设备环境句柄

//------------------------------------[全局函数的声明部分]--------------------------------------------------------------
// 描述：全局函数声明，防止“未声明的标示”系列错误
//----------------------------------------------------------------------------------------------------------------------
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);	//窗口过程函数
BOOL Game_Init(HWND hwnd);	//在此函数中进行资源初始化
VOID Game_Paint(HWND hwnd);	//在此函数中进行绘图代码的书写
BOOL Game_CleanUp(HWND hwnd);	//在此函数中进行资源的清理

//-------------------------------------【 WinMain() 函数 】---------------------------------------------------------------
// 描述：程序的入口
//------------------------------------------------------------------------------------------------------------------------
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	//【1】开始设计一个完整的窗口类
	WNDCLASSEX wndClass = { 0 };	//用 WNDCLASSEX 定义一个窗口类
	wndClass.cbSize = sizeof(WNDCLASSEX);	//设置结构体的字节数大小
	wndClass.style = CS_HREDRAW | CS_VREDRAW;	//设置窗口的样式
	wndClass.lpfnWndProc = WndProc;		//设置指向窗口的过程函数指针
	wndClass.cbClsExtra = 0;	//窗口类的附加内存，取 0就可以了
	wndClass.hInstance = hInstance;		//指定包含窗体过程的程序的实例句柄
	wndClass.hIcon = NULL;	// 默认的icon 图标
	wndClass.hCursor = LoadCursor(NULL, IDC_ARROW);		//指定窗体的光标句柄
	wndClass.hbrBackground = (HBRUSH)GetStockObject(GRAY_BRUSH); //指定一个灰色的画刷句柄
	wndClass.lpszMenuName = NULL;	//指定菜单的资源名字
	wndClass.lpszClassName = L"GDIdemoCore";	//指定窗口类的名字

	//【2】 注册窗口类
	if (! RegisterClassEx(&wndClass))	//设计完窗口需要对其进行注册，这样才能创建该类的窗口
	{
		return -1;
	}

	//【3】 正式创建窗体
	HWND hwnd = CreateWindow(L"GDIdemoCore", WINDOW_TITLE, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT,
		WINDOW_WIDTH, WINDOW_HEIGHT, NULL, NULL, hInstance, NULL);
	
	//【4】 窗口的移动、显示、更新
	MoveWindow(hwnd, 250, 80, WINDOW_WIDTH, WINDOW_HEIGHT, true);	//调整窗口显示时的位置，是窗口的左上角位于（250，80）处
	ShowWindow(hwnd, nShowCmd);		//调用ShowWindow 函数显示窗口
	UpdateWindow(hwnd);		//对窗口进行更新

	//游戏资源的初始化，若初始化失败弹出一个消息框，并返回FALSE
	if ( ! Game_Init(hwnd))
	{
		MessageBox(hwnd, L"资源初始化失败", L"消息窗口", 0);
		return FALSE;
	}

	//【5】 消息循环过程
	MSG msg = { 0 };	//定义并初始化msg
	while (msg.message != WM_QUIT)
	{
		if ( PeekMessage(&msg, 0, 0, 0,PM_REMOVE))	//查看消息队列，有消息时将消息队列中的消息派发出去。
		{
			TranslateMessage(&msg);		//将虚拟键消息转换成字符消息。
			DispatchMessage(&msg);		//分发一个消息给窗口程序
		}
	}

	//【6】 窗口类的注销
	UnregisterClass(L"GDIdemoCore", wndClass.hInstance);
	return 0;
}

//-------------------------------------【 WndProc() 函数 】---------------------------------------------------------------
// 描述：窗口的过程函数，对窗口消息进行处理
//------------------------------------------------------------------------------------------------------------------------
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT paintStruct;	//记录一些绘制信息

	switch (message)
	{
	case WM_PAINT:	//若是客户区域重绘信息
		g_hdc = BeginPaint(hwnd, &paintStruct);		//指定窗口进行绘图工作的准备，并将和绘图有关的信息填充到 paintStruct 结构体中去。
		Game_Paint(hwnd);
		EndPaint(hwnd, &paintStruct);	//标记指定窗口绘图工作的结束
		ValidateRect(hwnd, NULL);	//更新客户区的显示
		break;
	case WM_KEYDOWN:	//若是键盘按下消息
		if (wParam == VK_ESCAPE)	//若是按下的键是 ESC
		{
			DestroyWindow(hwnd);	//销毁窗口，并发送一条 WM_DESTORY 消息
		}
		break;
	case WM_DESTROY:	//若是窗口的销毁消息
		Game_CleanUp(hwnd);
		PostQuitMessage(0);		//向系统表明有个线程有终止请求，用来响应 WM_DESTORY 请求
		break;
	default:
		return DefWindowProc(hwnd, message, wParam, lParam);
	}

	return 0;	//正常退出
}

//-------------------------------------【 Game_Init() 函数 】-------------------------------------------------------------
// 描述：初始化函数，进行一些简单的初始化
//------------------------------------------------------------------------------------------------------------------------
BOOL Game_Init(HWND hwnd)
{
	g_hdc = GetDC(hwnd);
	Game_Paint(hwnd);
	ReleaseDC(hwnd, g_hdc);
	return true;
}

//-------------------------------------【 Game_Paint() 函数 】------------------------------------------------------------
// 描述：绘制函数， 在此函数中进行绘制操作
//------------------------------------------------------------------------------------------------------------------------
VOID Game_Paint(HWND hwnd)
{


}

//-------------------------------------【 Game_CleanUp() 函数 】----------------------------------------------------------
// 描述：资源清理函数
//------------------------------------------------------------------------------------------------------------------------
BOOL Game_CleanUp(HWND hwnd)
{
	return TRUE;
}