#include "main.h"
#include "AppDelegate.h"

USING_NS_CC;

int APIENTRY _tWinMain(HINSTANCE hInstance,
                       HINSTANCE hPrevInstance,
                       LPTSTR    lpCmdLine,
                       int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // Set console output to UTF-8 for CJK character support
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);

    // create the application instance
    AppDelegate app;
    return Application::getInstance()->run();
}
