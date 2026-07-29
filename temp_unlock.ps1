$signature = @'
using System;
using System.Runtime.InteropServices;

public static class FileUnlocker
{
    [DllImport("rstrtmgr.dll", CharSet = CharSet.Unicode)]
    private static extern int RmStartSession(out uint pSessionHandle, int dwSessionFlags, string strSessionKey);

    [DllImport("rstrtmgr.dll")]
    private static extern int RmEndSession(uint pSessionHandle);

    [DllImport("rstrtmgr.dll", CharSet = CharSet.Unicode)]
    private static extern int RmRegisterResources(uint pSessionHandle, uint nFiles, string[] rgsFilenames, uint nApplications, IntPtr rgApplications, uint nServices, string[] rgsServiceNames);

    [DllImport("rstrtmgr.dll")]
    private static extern int RmGetList(uint dwSessionHandle, out uint pnProcInfoNeeded, ref uint pnProcInfo, [In, Out] IntPtr rgAffectedApps, ref uint lpdwRebootReasons);

    public static bool IsFileLocked(string path)
    {
        try {
            using (var fs = System.IO.File.Open(path, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite | System.IO.FileShare.Delete)) {
                return false;
            }
        } catch {
            return true;
        }
    }
}
'@
Add-Type -TypeDefinition $signature

$ttf = "g:\cocos2d-x-3.0-oh\build\win32-msvc-vs2013-x86\bin\cpp-tests\Debug\Resources\fonts\arial.ttf"
Write-Host "File locked: $([FileUnlocker]::IsFileLocked($ttf))"

# Try to find the process using handle.exe
$handlePath = "g:\cocos2d-x-3.0-oh\tools\handle.exe"
if (Test-Path $handlePath) {
    Write-Host "Running handle.exe..."
    & $handlePath -accepteula $ttf 2>&1
} else {
    Write-Host "handle.exe not found, trying alternative..."
    # Try to find via wmic
    $parent = Split-Path $ttf -Parent
    Get-Process | ForEach-Object {
        try {
            $proc = $_
            $proc.Modules | Where-Object { $_.FileName -like "*arial*" } | ForEach-Object {
                Write-Host "Process: $($proc.Name) (PID: $($proc.Id))"
            }
        } catch { }
    }
}