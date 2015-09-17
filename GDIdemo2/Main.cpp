//-----------------------------------�� ����˵�� ��-----------------------------------------------------------------------
// �������ƣ�GDIdemoCore
// 2015��9��15�� simon
// ������ ʵ��GDI ��Ϸ��������ĺ��ĳ���
//---------------------------------------------------------------------------------------------------------------------

//-----------------------------------�� ͷ�ļ����岿�� ��------------------------------------------------------------------
// ����������������������ͷ�ļ�
//---------------------------------------------------------------------------------------------------------------------
#include <windows.h>

//------------------------------------�� �궨�岿�� ��---------------------------------------------------------------------
// ����������һЩ������
//---------------------------------------------------------------------------------------------------------------------
#define WINDOW_WIDTH 800	//Ϊ���ڶ����ȵĺ꣨�����ڴ˴��޸Ĵ��ڵĿ�ȣ�
#define WINDOW_HEIGHT 450	//Ϊ���ڶ���߶ȵĺ� (�����ڴ˴��޸Ĵ��ڵĸ߶�)
#define WINDOW_TITLE L"GDIλͼ����"	  //Ϊ������ⶨ��ĺ�

//------------------------------------�� ȫ�ֱ����������� ��----------------------------------------------------------------
// ������ȫ�ֱ���������
//----------------------------------------------------------------------------------------------------------------------
HDC g_hdc = NULL, g_hmdc = NULL;	//ȫ���豸�������
HBITMAP g_hBitMap = NULL;	//����һ��λͼ�ľ��

//------------------------------------�� ȫ�ֺ������������� ��--------------------------------------------------------------
// ������ȫ�ֺ�����������ֹ��δ�����ı�ʾ��ϵ�д���
//----------------------------------------------------------------------------------------------------------------------
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);	//���ڹ��̺���
BOOL Game_Init(HWND hwnd);	//�ڴ˺����н�����Դ��ʼ��
VOID Game_Paint(HWND hwnd);	//�ڴ˺����н��л�ͼ�������д
BOOL Game_CleanUp(HWND hwnd);	//�ڴ˺����н�����Դ������

//-------------------------------------�� WinMain() ���� ��---------------------------------------------------------------
// ��������������
//------------------------------------------------------------------------------------------------------------------------
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	//��1����ʼ���һ�������Ĵ�����
	WNDCLASSEX wndClass = { 0 };	//�� WNDCLASSEX ����һ��������
	wndClass.cbSize = sizeof(WNDCLASSEX);	//���ýṹ����ֽ�����С
	wndClass.style = CS_HREDRAW | CS_VREDRAW;	//���ô��ڵ���ʽ
	wndClass.lpfnWndProc = WndProc;		//����ָ�򴰿ڵĹ��̺���ָ��
	wndClass.cbClsExtra = 0;	//������ĸ����ڴ棬ȡ 0�Ϳ�����
	wndClass.hInstance = hInstance;		//ָ������������̵ĳ����ʵ�����
	wndClass.hIcon = NULL;	// Ĭ�ϵ�icon ͼ��
	wndClass.hCursor = LoadCursor(NULL, IDC_ARROW);		//ָ������Ĺ����
	wndClass.hbrBackground = (HBRUSH)GetStockObject(GRAY_BRUSH); //ָ��һ����ɫ�Ļ�ˢ���
	wndClass.lpszMenuName = NULL;	//ָ���˵�����Դ����
	wndClass.lpszClassName = L"GDIdemoCore";	//ָ�������������

	//��2�� ע�ᴰ����
	if (!RegisterClassEx(&wndClass))	//����괰����Ҫ�������ע�ᣬ�������ܴ�������Ĵ���
	{
		return -1;
	}

	//��3�� ��ʽ��������
	HWND hwnd = CreateWindow(L"GDIdemoCore", WINDOW_TITLE, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT,
		WINDOW_WIDTH, WINDOW_HEIGHT, NULL, NULL, hInstance, NULL);

	//��4�� ���ڵ��ƶ�����ʾ������
	MoveWindow(hwnd, 250, 80, WINDOW_WIDTH, WINDOW_HEIGHT, true);	//����������ʾʱ��λ�ã��Ǵ��ڵ����Ͻ�λ�ڣ�250��80����
	ShowWindow(hwnd, nShowCmd);		//����ShowWindow ������ʾ����
	UpdateWindow(hwnd);		//�Դ��ڽ��и���

	//��Ϸ��Դ�ĳ�ʼ��������ʼ��ʧ�ܵ���һ����Ϣ�򣬲�����FALSE
	if (!Game_Init(hwnd))
	{
		MessageBox(hwnd, L"��Դ��ʼ��ʧ��", L"��Ϣ����", 0);
		return FALSE;
	}

	//��5�� ��Ϣѭ������
	MSG msg = { 0 };	//���岢��ʼ��msg
	while (msg.message != WM_QUIT)
	{
		if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE))	//�鿴��Ϣ���У�����Ϣʱ����Ϣ�����е���Ϣ�ɷ���ȥ��
		{
			TranslateMessage(&msg);		//���������Ϣת�����ַ���Ϣ��
			DispatchMessage(&msg);		//�ַ�һ����Ϣ�����ڳ���
		}
	}

	//��6�� �������ע��
	UnregisterClass(L"GDIdemoCore", wndClass.hInstance);
	return 0;
}

//-------------------------------------�� WndProc() ���� ��---------------------------------------------------------------
// ���������ڵĹ��̺������Դ�����Ϣ���д���
//------------------------------------------------------------------------------------------------------------------------
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT paintStruct;	//��¼һЩ������Ϣ

	switch (message)
	{
	case WM_PAINT:	//���ǿͻ������ػ���Ϣ
		g_hdc = BeginPaint(hwnd, &paintStruct);		//ָ�����ڽ��л�ͼ������׼���������ͻ�ͼ�йص���Ϣ��䵽 paintStruct �ṹ����ȥ��
		Game_Paint(hwnd);
		EndPaint(hwnd, &paintStruct);	//���ָ�����ڻ�ͼ�����Ľ���
		ValidateRect(hwnd, NULL);	//���¿ͻ�������ʾ
		break;
	case WM_KEYDOWN:	//���Ǽ��̰�����Ϣ
		if (wParam == VK_ESCAPE)	//���ǰ��µļ��� ESC
		{
			DestroyWindow(hwnd);	//���ٴ��ڣ�������һ�� WM_DESTORY ��Ϣ
		}
		break;
	case WM_DESTROY:	//���Ǵ��ڵ�������Ϣ
		Game_CleanUp(hwnd);
		PostQuitMessage(0);		//��ϵͳ�����и��߳�����ֹ����������Ӧ WM_DESTORY ����
		break;
	default:
		return DefWindowProc(hwnd, message, wParam, lParam);
	}

	return 0;	//�����˳�
}

//-------------------------------------�� Game_Init() ���� ��-------------------------------------------------------------
// ��������ʼ������������һЩ�򵥵ĳ�ʼ��
//------------------------------------------------------------------------------------------------------------------------
BOOL Game_Init(HWND hwnd)
{
	g_hdc = GetDC(hwnd);	//��ȡ�豸�ľ��

	//-----------������λͼ4������----------------------------
	// 1 ����λͼ
	g_hBitMap = (HBITMAP)LoadImage(NULL, L"dota2.bmp", IMAGE_BITMAP, 800, 450, LR_LOADFROMFILE);
	if (g_hBitMap == NULL)
	{
		MessageBox(hwnd, L"��Դ��ʼ��ʧ��", L"��Ϣ����", 0);
		
	}
	// 2 ��������DC
	g_hmdc = CreateCompatibleDC(g_hdc); //���������豸�������ڴ�DC

	Game_Paint(hwnd);
	ReleaseDC(hwnd, g_hdc);
	return true;
}

//-------------------------------------�� Game_Paint() ���� ��------------------------------------------------------------
// ���������ƺ����� �ڴ˺����н��л��Ʋ���
//------------------------------------------------------------------------------------------------------------------------
VOID Game_Paint(HWND hwnd)
{
	// ����λͼ��4���� 3 ѡ��λͼ
	SelectObject(g_hmdc, g_hBitMap);	// ��Ϊͼ����ѡ�뵽 h_mdc �ڴ�DC ��ȥ
	// ����λͼ��4���� 4 ��ͼ
	BitBlt(g_hdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, g_hmdc, 0, 0, SRCCOPY);

}

//-------------------------------------�� Game_CleanUp() ���� ��----------------------------------------------------------
// ��������Դ������
//------------------------------------------------------------------------------------------------------------------------
BOOL Game_CleanUp(HWND hwnd)
{
	// �ͷŶ���
	DeleteObject(g_hBitMap);
	DeleteObject(g_hmdc);
	return TRUE;
}