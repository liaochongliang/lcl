# Commit 标准流程
```
首次
1.先把自己支线提交，merge成一次
2.基于需要提交对应的线，进行rebase操作
3.rebase --continue?

打patch
git diff commitid1 commitid2 >patch_1
git diff：是查看working tree与index file的差别的。
git diff --cached：是查看index file与commit的差别的。
git diff HEAD：是查看working tree和commit的差别的。（你一定没有忘记，HEAD代表的是最近的一次commit的信息）
git apply --check patch_1
git apply patch_1

持续Patch提交时
git add .
git rm -r  --cached android_webview/out/out1/
git cl format
git commit --amend
git push origin HEAD:refs/for/v62_develop

确认当前是哪个cherry pick 第几个 patch
1. 查看 .git/FETCH_HEAD
2. git diff FETCH_HEAD  本质上就是diff 2个commitid
3. 查看远端的commitid git ls-remote|grep 739248'
```

# 编译62_Develop 版本
```
(down target=android 的代码，运行相关脚本，准备好初始环境 src/build/install-build-deps-android.sh 等等 参考chrome官方文档就好)
liaochong@bytedance:
cd ~/workpace/chromium/src
cherry pick
gn gen  out/Dx1

先编译下demo工程，生成 libwebviewbytedance.so 依赖的java接口文件

# ninja -C out/Dx1  #标志62版本编时使用
src  ./webview_build Dx1
src  ./android_webview/out/run Dx1

//确认下Md5
拷贝生成的 out/Dx1/apks/webview.apk
unzip webview.apk -d xxx/
md5sum  $(find  ./xxx  -name "*.*")

//上传so,修改代码固定ur,build号,上传SDK
//测试TT_Lite

//压缩备份symbol文件
zip  -r  Dx1.zip ./Dx1

//外发版本 安装apk测试查看日志
adb install  xx.apk
```

# mac 《-》 Unbuntu
```
上传run脚本
scp -r /Users/liaochongliang/ycodespace/ttwebview/src/android_webview/out/run  liaochong@10.94.1.106:/home/liaochong/workpace/ttwebview/src/android_webview/out

下载
scp -r liaochong@10.94.1.106:/home/liaochong/apks /Users/liaochongliang/apkTest/x1
scp -r liaochong@10.94.1.106:/home/liaochong/apks/Dx1  /Users/liaochongliang/apkTest/

在本机shell中 执行 
scp -r /Users/liaochongliang/xcodespace/decom  liaochong@10.94.1.106:/home/liaochong/workpace
scp -r /Users/liaochongliang/xcodespace/decom/src  liaochong@10.94.1.106:/home/liaochong/workpace/decom/
```

# andriod 手机相关 
```
上传文件到android手机
cd /Users/liaochongliang/apkTest/x1
adb push libwebview.so /sdcard/Download/libwebview.so
adb shell 
run-as com.bytedance.demo
cp /sdcard/Download/libwebview.so

查看手机文件
adb shell
run-as com.bytedance.com
cd /data/data/com.bytedance.demo/files/webview_bytedance
find .

拷贝手机上的文件
1.adb shell
2.run-as com.bytedance.demo
4.rm -rf /sdcard/Download
3.cp -r /data/data/com.bytedance.demo/files/webview_bytedance/ /sdcard/Download
5.cd ~/apkTest/
6.adb pull /sdcard/Download/webview_bytedance

```

# 常见系统命令
```
md5sum  $(find  ./WebViewDir  -name "*.*")
./gradlew assembleDebug
cmake -DCMAKE_BUILD_TYPE=Debug ../
cmake -DCMAKE_BUILD_TYPE=Release ../
cmake ../ -G "Xcode"
```

# ubuntu调试
```
gdb core-file core
ulimit -a
ulimit -c 10240
gdb ./decompress  core
bt
info f
```

# Mac安装Python MysqlDb
```
1.单独下载安装mysql ,添加环境变了
brew mysql-connector-c   （不单独装Mysql  brew无法装这个）
2.sudo pip install MySQL-Python
3.测试  python  import MySQLdb
4.Image加载的问题
//这个好像修改so加载顺序会失效
otool -L /Library/Python/2.7/site-packages/_mysql.so
sudo install_name_tool -change libmysqlclient.21.dylib /usr/local/mysql/lib/libmysqlclient.21.dylib /Library/Python/2.7/site-packages/_mysql.so
/usr/lib
/usr/local/lib
/usr/local/mysql/lib
# 下面这个有效  （重启 commad +r  进入恢复模式  csrutil disable  否则无法修改）
sudo ln -s  /usr/local/mysql/lib/libssl.1.0.0.dylib   /usr/lib/libssl.1.0.0.dylib
sudo ln -s  /usr/local/mysql/lib/libcrypto.1.0.0.dylib /usr/lib/libcrypto.1.0.0.dylib
```
