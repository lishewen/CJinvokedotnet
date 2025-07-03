package CJinvokedotnet

foreign func sayhello(namePtr: CString): CString

foreign func free_string(ptr: CString): Unit

main(): Int64 {
    println("调用.NET DLL演示")
    unsafe {
        var name = LibC.mallocCString("算神")
        var greeting = sayhello(name)
        println(greeting)
        free_string(greeting)
        LibC.free(name)
        LibC.free(greeting)
    }
    return 0
}
