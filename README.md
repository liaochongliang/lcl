
记录性质的东西都是放在everynote上的，通过导出html，然后上传到github上。这样就可以不用去管那些样式了。。。everynote的样式就是最终网页的呈现形势。

# V8学习记录

# 先讲下大概的学习思路

## 1.阅读v8 chrome nodejs相关文章，对v8js引擎有个基本认知

>参考文章代表性的有
[V8概念以及编程入门](https://zhuanlan.zhihu.com/p/35371048)  
[Javascript是如何工作的：V8引擎的内核Ignition和TurboFan](https://v8project.blogspot.com/2017/05/launching-ignition-and-turbofan.html)  
[中文版](https://juejin.im/post/5aaa89c36fb9a028e25d4a85)  


## 2.v8的wiki Blog相关
>[v8官方Wiki blog](https://github.com/v8/v8/wiki)  
[v8blog-realse68](https://v8project.blogspot.com/2018/06/v8-release-68.html)  
[v8blog-realse69](https://v8project.blogspot.com/2018/08/v8-release-69.html)


### V8绑定的设计
>https://chromium.googlesource.com/chromium/src/+/lkcr/third_party/WebKit/Source/bindings/core/v8/V8BindingDesign.md  
`Todo::中文翻译`  


### v8设计元素  
>https://github.com/v8/v8/wiki/Design-Elements   
https://github.com/Chunlin-Li/Chunlin-Li.github.io/blob/master/blogs/javascript/V8_Design_Elements_CHS.md

### v8嵌入相关  
>[v8Blog-Embedder's-Guide](https://github.com/v8/v8/wiki/Embedder's-Guide)  
[v8Blog-Embedder's-Guide-中文版](https://github.com/Chunlin-Li/Chunlin-Li.github.io/blob/master/blogs/javascript/V8_Embedder's_Guide_CHS.md)  
https://www.jianshu.com/p/8cd3cc2a1630  
[V8 Binding Explained - googleppt](https://docs.google.com/presentation/d/1OFG81taxgjOGU43sv9WHvPZkt5--KnM6gSijWN8NMcU/edit#slide=id.g16bb3cdb_0_70)

https://github.com/Chunlin-Li/Chunlin-Li.github.io/blob/master/blogs/javascript/V8_Internal_Profiler_CHS.md


### v8缓存相关，近期相关文章 
>[有个网站也翻译了对应的文章的翻译](https://xenojoshua.com/2018/04/improved-code-caching/)   
[2018/08/embedded-builtins](https://v8project.blogspot.com/2018/08/embedded-builtins.html)  
[2018/04/improved-code-caching](https://v8project.blogspot.com/2018/04/improved-code-caching.html)  
[2018/04/improved-code-caching_My中文翻译](https://liaochongliang.github.io/lcl/Docs/(T)v8_Blog_201804_improved-code-caching.html)   
[2018/02/lazy-deserialization](https://v8project.blogspot.com/2018/02/lazy-deserialization.html)     
[2015/09/custom-startup-snapshots](https://v8project.blogspot.com/2015/09/custom-startup-snapshots.html)  


### 编译解释器优化相关
>https://v8project.blogspot.com/2017/11/csa.html  
https://v8project.blogspot.com/2016/08/firing-up-ignition-interpreter.html
https://v8project.blogspot.com/2015/07/digging-into-turbofan-jit.html   
[V8 Full Codegen-2014-06](http://leeight.github.io/blog/2014/06/v8-full-codegen/)  
[Crankshafting from the ground up](https://docs.google.com/document/u/1/d/1hOaE7vbwdLLXWj3C8hTnnkpE0qSa2P--dtDvwXXEeD0/pub)  
[V8: Hooking up the Ignition to the Turbofan](https://docs.google.com/presentation/d/1chhN90uB8yPaIhx_h2M3lPyxPgdPmkADqSNAoXYQiVE/edit#slide=id.g1357e6d1a4_0_58)


## 3.v8  sample详细更进代码
>`Todo-1` 主要是了解大致v8调用流程，c++和js如何互相调用  
`Todo-2` 其次就是需要跟进编译+执行的较为详细的流程  
`Todo-3` 以缓存位重点关注点，熟悉周边调用环节

### 4.后续可以继续关注，v8的性能打点和基准测试，进行一些试验对比
>最好是能进行一些裁剪，这样就碉堡了。足够了解后。


---
# v8 安装和编译  windows+mac
因为习惯了在windows调试，所以2个平台都搞了一遍。最强的IDE还是VS2017 mac上用vscode也很不错。`Todo` 后面补一下详细的环境搭建步骤

---
# v8基本概念介绍 
- v8::Isolate   
  Isolate 本意是隔离的意识。在操作系统中，有类似概念，进程之前是相互隔离的（除去系统级相关资源），多个进程之间不会共享独有的资源。Isolate也一样，不同的Isolate对应不同v8引擎的实例，各自拥完整的堆栈虚拟机实例，且相互完全隔离。当Isolate在某个线程上执行的时候，会先把当前线程的环境进行保存（如果有其他Isolate执行过）。因为有很多运行时信息，会保存在线程全局可见变量中。当一个线程在多个Isolate中交替执行时，需要把Isolate依赖的资源进行相应的保持，因为tls很多变量只有一份，而且一般也不会单线程运行多个Isolate。当Isolte需要被多个线程同时执行时，例如某些线程只做编译，某些线程负责gc。Isaolte在多个线程中被互斥执行时，需要遵守v8的u规划，进行互斥加锁保护。v8::lock和v8::unlock，其内部实现本质上是进程级别的非递归同步机制。 以windwos为例，使用的是独占模式的读写锁。（这个api xp不支持）。不支持循环意味着，如果已经locker的线程，再次lock会直接卡住，因为这是逻辑错误了。v8内部代码，通过线程局部变量，进行线程级别保持，当前线程是否被Isolte lock。在每次lock前会进行相应的判断，如果已经被lock就直接return。这里更为细致的分析可以见   
  [2.2 一个线程如何可以支持多个Isolate交替运行](https://liaochongliang.github.io/lcl/)  
  [2.3 如何保证多线程安全Isolate的运行](https://liaochongliang.github.io/lcl/)  
  更多Isolate内部的逻辑可以见[2.1 Isolate 的初始化创建详细过程](https://liaochongliang.github.io/lcl/) 

- v8::Context  
   一个Context就是一个执行环境，这使得可以在一个V8实例中运行相互隔离而且无关的JavaScript代码。使得两个完全无关的js代码，可以运行并以同样的方式修改一个global对象。
- V8::Handle（v8::local v8::Persistent）  
    Local类型就是栈有效的，一般是配合v8.HandleScope使用。  
    Persistent::New, Persistent::Dispose 对全局的对象进行管理。
- Scope
    - v8.Isolate.Scope  
        前面有降到过，这个主要是准备执行Isolte实例时，在线程上进行Isolate级别的环境保持和恢复。

    - v8.HandleScope  
        用于管理其作用域名内的local类型的handle

        
    - v8.Context.scope  
        与上面类似，只不过起管理的是context对象
    ```
    void F(){
    //一开头放一个
    v8::HandleScope handle_scope(isolate);
    v8::Local<v8::String> source1 =.......
    v8::Local<v8::String> source2 =......

    //开头放一个
    v8::Local<v8::Context> context = Context::New(isolate);
    v8::Context::Scope context_scope(context)
    }
---
# v8 helloword 详细剖析
- v8环境初始化
  ```
  // Initialize V8.
  v8::V8::InitializeICUDefaultLocation(argv[0]);
  v8::V8::InitializeExternalStartupData(argv[0]);
  std::unique_ptr<v8::Platform> platform = v8::platform::NewDefaultPlatform();
  v8::V8::InitializePlatform(platform.get());
  v8::V8::Initialize();
  ```

- v8 isolate的创建
    ```
    // Create a new Isolate and make it the current one.
    v8::Isolate::CreateParams create_params;
    create_params.array_buffer_allocator =
        v8::ArrayBuffer::Allocator::NewDefaultAllocator();
    v8::Isolate* isolate = v8::Isolate::New(create_params);
    ```

- v8 执行环境准备准备
    - v8::Isolate::Scope  用于Isolate在栈上的相关信息保存。Isolate可以被多线程执行，以及单个线程可以在多个Isolate中切换交替运行。
        ```
        {
            v8::Isolate::Scope isolate_scope(isolate);
            ...
        }
        ```
    - Context创建用于js执行的上下文，拥有其内置函数和对象，可以类似压栈和出栈在不痛的context中切换；v8::HandleScope用于统一存储存储栈上申请的handle，在其释放后，gc会统一释放其持有的对象。如果要申请非栈生命周期使用的，需要使用与local对应的Persistent。
        ```    
        // Create a stack-allocated handle scope.
        v8::HandleScope handle_scope(isolate);// Create a new context.
        v8::Local<v8::Context> context = v8::Context::New(isolate);

        // Enter the context for compiling and running the hello world script.
        v8::Context::Scope context_scope(context);
        ```

- v8 进行编译脚本和运行
- v8 和c++相互调用





