1.git+SVN 混合使用
2.GIT可以拉取到本地，完全同步到本地SVN
3.SVN的修改，可以拉取到GIT本地仓库，然后同步到GIT远端。

主要可以方便用SVN本地查看 GIT的各种修改

==========================================
# 建立GIT和本地SVN的桥接
(F:\Git_Test)  
git clone https://github.com/liaochongliang/windows_tools
cd windows_tools
git svn init -s svn://localhost/F:/Carry_Blog/gitsvn_windows_tools/windows_tools_SvnLocalBase
git svn fetch
echo 4fc9ddd1bea6c86480d9d64821149a51237c2956 61fffa86bb8bd94e5dcc28b5cf296b2a3cf8590a >>.git/info/grafts
git replace --convert-graft-file

# 如何把修改，提交到SVN分支  (这个问题等价于,把GIT本地修改，提交到GIT自动的远端分支)
假设SVN有分支remotes/origin/svn-B1
本地有分支dev1 (remotes/origin/svn-B1)
把本地修改推送到远端SVN,需要使用rebase
git rebase remotes/origin/svn-B1 然后在 git svn dcommit
向SVN提交时，会改变hash值，所以，如果有改动要同步，一定是先提交给SVN，在提交给GIT。
注意SVN中删除一个分支，实际上不会影响文件。但是GIT删除会影响。
删除无效的SVN远端分支  git branch -D -r remoter/origin/svn-B1
删除文件 F:\Git_Test\windows_tools\.git\svn\refs\remotes\origin\svn-B1

怎么重命名这个svn的分支？ 修改 .git\config ?


==========================================
1 使用git svn clone 拷贝svn仓库
cd ~/test_repo
git svn clone file:///home/***/Desktop/SVN/svn_repo/ -T trunk -b branches -t tags
2 新建一个git的bare仓库
cd ..
mkdir test.git
cd test.git
git init --bare
3 将git的默认分支和svn的默认分支trunk对应起来
git symbolic-ref HEAD refs/heads/trunk
4 将test_repo推送到test.git中
cd ~/test_repo
git remote add bare ~/test.git
git config remote.bare.push 'refs/remotes/*:refs/heads/*'
git push bare
此时就完成了推送，可以删除test_repo了

5 将git repo中的trunk重命名为master
cd ~/test.git
git branch -m trunk master
6 将svn repo中的tags移动到git repo的相应位置
使用git svn clone导出版本库的时候会将svn中的tags保存成git中的tags/**，而并不是默认的tag，所以要进行移动

cd ~/test.git
git for-each-ref --format='%(refname)' refs/heads/tags |
cut -d / -f 4 |
while read ref
do
  git tag "$ref" "refs/heads/tags/$ref";
  git branch -D "tags/$ref";
done
7 完成迁移，得到test.git
进入工作文件夹，执行

git clone ~/test.git
使用git进行版本管理吧

==========================================

（二）

svn迁移到git仓库并保留commit历史记录
最近在做svn迁移到gitlab，由于之前一直是由svn做版本控制。最简单的方式是将svn的内容export出来，然后添加到gitlab即可。但是，如果svn用的时间很长了，而且很多commit，我们希望保存svn commit的信息以便做版本的控制和比较。幸好git提供了相应的解决办法。

前提
已安装git
已安装gitlab
迁移
1.环境准备：
yum install -y git-svn

2.svn账号与git账号映射，users.txt
svn账号=git账号名称<username@mail.com>
3.svn转换为git
git svn clone svn://ip端口/projectname --no-metadata --authors-file=users.txt --trunk=trunk projectname
cd projectname
4.添加git仓库
git remote add origin git@xxx.xxx.xxx.xxx:root/projectname.git
5.提交到gitlab
git push -u origin master

