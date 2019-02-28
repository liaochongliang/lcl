win10 编译 chrome
粗略编译流程
- win10 更新到 1803 17134.590 （否则磁盘不支持大小写敏感）

- 安装wsl
  - C:\Users\pc\AppData\Local\lxss\rootfs\etc
  - C:\Users\pc\AppData\Local\lxss\home\bytedance
  - 切记不要在windows上操作lxss文件，lunix文件有inode信息和ntfs不一致

- 磁盘需要check是否支持大小写敏感
  - 注意递归目录的大小写敏感属性
  - fsutil.exe file SetCaseSensitiveInfo D:\workplace
  - fsutil.exe file queryCaseSensitiveInfo <path>  
  - fsutil.exe file queryCaseSensitiveInfo  D:\workplace\temp\ttwebview\src\third_party\android_tools\ndk\platforms

- wsl要支持外部ssh登陆(可选)
  - sudo vim /etc/ssh/sshd_config
  - 修改端口 去掉密码
  - sudo service ssh --full-restart
  - win10 关闭防火墙，或者是添加对应端口的入站放行规则

- 拉取代码（拉去chrome代码62）
  - lxss拉取后 运行gclient runhooks
    - code：
    - git config --global http.postBuffer 52428800
    - git config --global --add core.compression -1
    - gclient runhooks   //wsl 部分下载不了可以拷贝 or 临时删除那个文件 把其他的下载完
    - git clone ssh://xxx@git.byted.org:29418/lynx/ttwebview && scp -p -P 29418 xxx@git.byted.org:hooks/commit-msg ttwebview/.git/hooks/
  - 上面一部可能遇到问题，去linux机器拷贝一份

- 编译1（纯命令行即可）
  - install linux  sdk
  - export CCACHE_SLOPPINESS=time_macros
  - export CCACHE_CPP2=yes
  - #export ANDROID_HOME=/mnt/d/workplace/ttwebview/src/third_party/android_tools/sdk
  - export ANDROID_HOME=/mnt/d/sdk/android-sdk-linux
  - export ANDROID_NDK_HOME=/mnt/d/workplace/ttwebview/src/third_party/android_tools/ndk
  - export ccx=/mnt/d/workplace/temp/ttwebview/src/third_party/llvm-build/Release+Asserts/bin
  - export PATH=$PATH:$ANDROID_HOME:$ANDROID_NDK_HOME:$ccx:

  - 遇到无license $ANDROID_HOME/tools/bin
    - ./sdkmanager --licenses

- 编译+lnk
  - cd /mnt/d/workplace/ttwebview
  - 编译会遇到一些问题，主要是因为wsl上一些linux的调用有问题
  - 以及部分代码不知道为撒编不过，需要修改下代码就行
  - 修改
    - https://github.com/bazelbuild/bazel/pull/2108

```
Index: src/third_party/WebKit/Source/modules/webgl/WebGLContextEvent.h
IDEA additional info:
Subsystem: com.intellij.openapi.diff.impl.patch.CharsetEP
<+>UTF-8
===================================================================
--- src/third_party/WebKit/Source/modules/webgl/WebGLContextEvent.h	(revision edc2bfb6d7afaa6378f7c842a59f2aaf78c3ff77)
+++ src/third_party/WebKit/Source/modules/webgl/WebGLContextEvent.h	(revision dcbee21e11a7521d78c6aca0737ad737cf7289e2)
@@ -35,7 +35,7 @@
   DEFINE_WRAPPERTYPEINFO();
 
  public:
-  static WebGLContextEvent* Create() { return new WebGLContextEvent; }
+  static WebGLContextEvent* Create() { return new WebGLContextEvent(); }
   static WebGLContextEvent* Create(const AtomicString& type,
                                    bool can_bubble,
                                    bool cancelable,
Index: src/third_party/ijar/mapped_file_unix.cc
IDEA additional info:
Subsystem: com.intellij.openapi.diff.impl.patch.CharsetEP
<+>UTF-8
===================================================================
--- src/third_party/ijar/mapped_file_unix.cc	(revision edc2bfb6d7afaa6378f7c842a59f2aaf78c3ff77)
+++ src/third_party/ijar/mapped_file_unix.cc	(revision dcbee21e11a7521d78c6aca0737ad737cf7289e2)
@@ -87,7 +87,9 @@
 
 struct MappedOutputFileImpl {
   int fd_;
+  int mmap_length_;
 };
+
 
 MappedOutputFile::MappedOutputFile(const char* name, u8 estimated_size) {
   impl_ = NULL;
@@ -99,9 +101,11 @@
     return;
   }
 
+	printf("what a fucking day!");
+
   // Create mmap-able sparse file
   if (ftruncate(fd, estimated_size) < 0) {
-    snprintf(errmsg, MAX_ERROR, "ftruncate(): %s", strerror(errno));
+    snprintf(errmsg, MAX_ERROR, "ftruncate(): %s %s", strerror(errno),name);
     errmsg_ = errmsg;
     return;
   }
@@ -119,6 +123,7 @@
 
   impl_ = new MappedOutputFileImpl();
   impl_->fd_ = fd;
+  impl_->mmap_length_ = mmap_length;
   buffer_ = reinterpret_cast<u1*>(mapped);
   opened_ = true;
 }
@@ -129,8 +134,9 @@
 }
 
 int MappedOutputFile::Close(int size) {
+  munmap(buffer_, impl_->mmap_length_);	
   if (ftruncate(impl_->fd_, size) < 0) {
-    snprintf(errmsg, MAX_ERROR, "ftruncate(): %s", strerror(errno));
+    snprintf(errmsg, MAX_ERROR, "ftruncate(): %s  Close ", strerror(errno));
     errmsg_ = errmsg;
     return -1;
   }
Index: src/third_party/skia/src/gpu/GrProcessor.h
IDEA additional info:
Subsystem: com.intellij.openapi.diff.impl.patch.CharsetEP
<+>UTF-8
===================================================================
--- src/third_party/skia/src/gpu/GrProcessor.h	(revision edc2bfb6d7afaa6378f7c842a59f2aaf78c3ff77)
+++ src/third_party/skia/src/gpu/GrProcessor.h	(revision dcbee21e11a7521d78c6aca0737ad737cf7289e2)
@@ -133,8 +133,8 @@
         // 1 to the returned value.
         uint32_t id = static_cast<uint32_t>(sk_atomic_inc(&gCurrProcessorClassID)) + 1;
         if (!id) {
-            SK_ABORT("This should never wrap as it should only be called once for each GrProcessor "
-                   "subclass.");
+            //SK_ABORT("This should never wrap as it should only be called once for each GrProcessor "
+            //       "subclass.");
         }
         return id;
     }
```

- 编译出来文件区别
  - 资源类的会有空格换行不一致
  - zip jar的压缩后文件会有不一致
    - 解压后可以对比MD5一致
  - 基本运行测试demo都正常


其他
- android studio 下载sdk ndk
- windows 下启动后 无法debug调试
  - 解决方案是android studio ： file/setting/build execution deployment/instant run的选项下，第一个选项不勾选即可
  - 关闭混淆

- MINGW64
  - mount
- sudo lsb_release -a
- sudo apt update && sudo apt install android-sdk

- wsl忘记密码 1234qwer
  - C:\%userprofile%\AppData\Local\lxss\rootfs\etc这个目录下面找到'shadow'文件 还有'shadow-‘，用记事本打开’shadow'可以看到所有用户和加密显示的密码
  - 把个人登陆用户名的密码部分删除，然后保存退出
  - win ＋Ｒ　输入　bash~  进入username@localmachine：~$输入username@localmachine：~$passwd
  - 输入新密码
