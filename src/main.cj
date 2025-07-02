package CJinvokedotnet

foreign func sayhello(namePtr: CString): CString

main(): Int64 {
    println("hello world")
    unsafe {
        var name = LibC.mallocCString("算神")
        var greeting = sayhello(name)
        println(greeting)
        LibC.free(name)
    }
    return 0
}
