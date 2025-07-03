using System.Runtime.InteropServices;
namespace CSLibrary;

public static class Hello
{
    [UnmanagedCallersOnly(EntryPoint = "sayhello")]
    public static IntPtr SayHello(IntPtr namePtr)
    {
        // 将非托管字符串指针转换为C#字符串
        string? name = Marshal.PtrToStringUTF8(namePtr);
        string greeting = $"你好, {name}！来自.NET 9的问候";

        // 将C#字符串转换为非托管UTF-8字符串指针
        IntPtr resultPtr = Marshal.StringToCoTaskMemUTF8(greeting);
        return resultPtr;
    }

    // 添加内存释放函数供仓颉调用
    [UnmanagedCallersOnly(EntryPoint = "free_string")]
    public static void FreeString(IntPtr ptr)
    {
        if (ptr != IntPtr.Zero)
        {
            Marshal.FreeCoTaskMem(ptr);
        }
    }
}
