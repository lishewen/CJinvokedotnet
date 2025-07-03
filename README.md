# 仓颉语言调用.net9 C#编写的dll

## 仓颉语言简介

仓颉编程语言是由华为打造一款面向全场景智能的新一代编程语言，主打原生智能化、天生全场景、高性能、强安全。主要应用于鸿蒙原生应用及服务应用等场景中，为开发者提供良好的编程体验。

## 小试牛刀

作为一名dotnet开发人员，最近又接触到了仓颉语言。突发奇想能不能将两者联动一下，于是有了本篇内容。

## 仓颉安装

到[仓颉官网](https://cangjie-lang.cn/download)下载SDK包，解压后添加一下`Path`环境变量即可，详细的可看[安装指南](https://cangjie-lang.cn/docs?url=%2F1.0.0%2Fuser_manual%2Fsource_zh_cn%2Ffirst_understanding%2Finstall_Community.html)，此处不多加赘述。

之后，再到VSCode的插件商店搜索`Cangjie`安装，再配置一下插件的SDK路径，环境就算是配置完成了。

## 准备C#的类库项目

1. 新建一个类库项目`CSLibrary`
2. 写点代码`Hello.cs`
```csharp
namespace CSLibrary;

public static class Hello
{
    public static string SayHello(string name)
    {
        return $"Hello, {name}! My name is CSLibrary.Hello";
    }
}
```

> 这里的思路是通过P/Invoke手法导出原生C接口，让仓颉调用，所以`Hello.cs`要这样修改下

```csharp
using System.Runtime.InteropServices;
namespace CSLibrary;

public static class Hello
{
    [UnmanagedCallersOnly(EntryPoint = "sayhello")]
    public static IntPtr SayHello(IntPtr namePtr)
    {
        // 将非托管字符串指针转换为C#字符串
        string? name = Marshal.PtrToStringUTF8(namePtr);
        string greeting = $"Hello, {name}! My name is CSLibrary.Hello";

        // 将C#字符串转换为非托管UTF-8字符串指针
        IntPtr resultPtr = Marshal.StringToCoTaskMemUTF8(greeting);
        return resultPtr;
    }
}
```

> 之所以如此修改是因为非托管函数只能使用非托管兼容的类型（如基本数值类型、指针或结构体），而C#中的`string`是托管类型。

3. 修改`CSLibrary.csproj`启用AOT编译
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <OutputType>Library</OutputType>
    <PublishAot>true</PublishAot>    <!-- 启用AOT编译 -->
  </PropertyGroup>

</Project>
```

4. 发布为原生DLL

```cmd
dotnet publish -c Release -r win-x64
```

这样我们就得到了一个`CSLibrary.dll`，放着备用。

## 编写仓颉代码

在之前配置好的VSCode环境中，按下`ctrl`+`shift`+`p`，输入`Create Cangjie Project`，按照提示一路下去就可以创建一个仓颉工程项目

修改`main.cj`里面的代码

```javascript
package CJinvokedotnet
// declare the function by `foreign` keyword
foreign func sayhello(namePtr: CString): CString

main(): Int64 {
    println("hello world")
    // call this function by `unsafe` block
    unsafe {
        var name = LibC.mallocCString("算神")
        var greeting = sayhello(name)
        println(greeting)
        LibC.free(name)
    }
    return 0
}

```

把刚才得到的`CSLibrary.dll`放到`main.cj`的同级目录下

使用以下命令进行编译

```cmd
cjc -L . -l CSLibrary ./main.cj
```

运行生成的`main.exe`可得到以下结果

```cmd
hello world
Hello, 算神! My name is CSLibrary.Hello
```

## C#调用仓颉的dll
1. 新建一个文件`mylib.cj`
```javascript
package CJinvokedotnet
// 定义C可见方法
@C
func myHello(): Unit {
    println("您好，欢迎使用仓颉！")
}
```
2. 使用下面的命令编译可以得到一个`libCJinvokedotnet.dll`
```cmd
cjc mylib.cj --output-type=dylib
```
3. C#中通过`DllImport`导入`libCJinvokedotnet.dll`的`myHello`方法，并调用它
```csharp
// 导入仓颉库的自定义方法
[DllImport("libCJinvokedotnet.dll", EntryPoint = "myHello")]
private static extern void myHello();

// 调用仓颉自定义库中的myHello方法
myHello();
```

## 一键体验

1. Clone本项目`https://github.com/lishewen/CJinvokedotnet`
2. 使用`build.bat`一键生成C#和仓颉的项目
3. 运行`main.exe`
