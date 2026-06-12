#include <windows.h>

#include <string>
#include <vector>

namespace {

std::wstring moduleFileName()
{
    std::vector<wchar_t> buffer(MAX_PATH);
    for (;;) {
        const DWORD length = GetModuleFileNameW(nullptr, buffer.data(), static_cast<DWORD>(buffer.size()));
        if (length == 0)
            return std::wstring();
        if (length < buffer.size() - 1)
            return std::wstring(buffer.data(), length);
        buffer.resize(buffer.size() * 2);
    }
}

std::wstring parentDirectory(const std::wstring &path)
{
    const std::wstring::size_type slash = path.find_last_of(L"\\/");
    if (slash == std::wstring::npos)
        return std::wstring();
    return path.substr(0, slash);
}

std::wstring joinPath(const std::wstring &base, const std::wstring &relative)
{
    if (base.empty())
        return relative;
    const wchar_t last = base.back();
    if (last == L'\\' || last == L'/')
        return base + relative;
    return base + L"\\" + relative;
}

bool fileExists(const std::wstring &path)
{
    const DWORD attributes = GetFileAttributesW(path.c_str());
    return attributes != INVALID_FILE_ATTRIBUTES && (attributes & FILE_ATTRIBUTE_DIRECTORY) == 0;
}

std::wstring quoteArgument(const std::wstring &argument)
{
    std::wstring quoted = L"\"";
    for (const wchar_t ch : argument) {
        if (ch == L'"')
            quoted += L"\\\"";
        else
            quoted += ch;
    }
    quoted += L"\"";
    return quoted;
}

std::wstring windowsErrorMessage(DWORD errorCode)
{
    wchar_t *message = nullptr;
    const DWORD length = FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER
                                            | FORMAT_MESSAGE_FROM_SYSTEM
                                            | FORMAT_MESSAGE_IGNORE_INSERTS,
                                        nullptr,
                                        errorCode,
                                        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                                        reinterpret_cast<LPWSTR>(&message),
                                        0,
                                        nullptr);
    std::wstring result = length > 0 && message ? std::wstring(message, length)
                                                : L"Unknown error";
    if (message)
        LocalFree(message);
    while (!result.empty() && (result.back() == L'\r' || result.back() == L'\n'))
        result.pop_back();
    return result;
}

void showError(const std::wstring &message)
{
    MessageBoxW(nullptr, message.c_str(), L"QLizzie", MB_ICONERROR | MB_OK);
}

} // namespace

int WINAPI wWinMain(HINSTANCE, HINSTANCE, PWSTR, int)
{
    const std::wstring launcherPath = moduleFileName();
    const std::wstring portableRoot = parentDirectory(launcherPath);
    if (portableRoot.empty()) {
        showError(L"Cannot determine the QLizzie package directory.");
        return 1;
    }

    const std::wstring appPath = joinPath(portableRoot, L"app\\qlizzie.exe");
    if (!fileExists(appPath)) {
        showError(L"Cannot find app\\qlizzie.exe.\n\nPlease keep QLizzie.exe next to the app folder.");
        return 1;
    }

    SetEnvironmentVariableW(L"QLIZZIE_LAUNCHED_BY_LAUNCHER", L"1");
    SetEnvironmentVariableW(L"QLIZZIE_PORTABLE_ROOT", portableRoot.c_str());

    STARTUPINFOW startupInfo = {};
    startupInfo.cb = sizeof(startupInfo);
    PROCESS_INFORMATION processInfo = {};
    std::wstring commandLine = quoteArgument(appPath);

    const BOOL started = CreateProcessW(appPath.c_str(),
                                        commandLine.data(),
                                        nullptr,
                                        nullptr,
                                        FALSE,
                                        0,
                                        nullptr,
                                        portableRoot.c_str(),
                                        &startupInfo,
                                        &processInfo);
    if (!started) {
        showError(L"Failed to start app\\qlizzie.exe.\n\n" + windowsErrorMessage(GetLastError()));
        return 1;
    }

    CloseHandle(processInfo.hThread);
    CloseHandle(processInfo.hProcess);
    return 0;
}
