
![image](./Docs/Git/Image1.png)
![image](./Docs/Git/Image2.jpg)  
记录一些常用的GIT命令先来2个网上找的原理图，方便理解。  
本质上GIT是多颗树  
`workspace` 			一个是本地工作区  
`index`					一个是本地暂存区，也就是我们add但是还未commit的  
`Local repository`		一个是本地历史提交记录仓库。涵盖了我们在本地的所有提交  
`Remote repository`		最后一个就是，远端的代码仓库区

# 一些参考链接
>https://backlog.com/git-tutorial/cn/stepup/stepup7_1.html  
http://www.ruanyifeng.com/blog/2014/06/git_remote.html  
[Git-工具-重置揭密](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E9%87%8D%E7%BD%AE%E6%8F%AD%E5%AF%86)  
[Git-Replace](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E6%9B%BF%E6%8D%A2)
[git简单命令](https://blog.csdn.net/zhangskd/article/details/8950939)
# 标准流程
```
git status			//查看未提交到本地仓库的文件
git checkout			//查看和原创仓库的差异情况
git log --graph --oneline
git log --pretty=oneline
git log --oneline
git fetch
git checkout 			//查看差异情况
git diff mater origin/master  	//查看细节差异
git  merge origin/master  	//merge到本地
```

# 基本的操作
- vim操作
	```shell
	ESC: wq!
	```
- 查看远程仓库地址
 	```shell
 	 git remote -v  
	 git remote show origin
	```
	
- 创建并切换分支
	```shell
	git branch -b  newbxxx oldxxx
	```

- 切换分支  
	
	```shell
	git checkout  master
	git checkout newxxx
	```

- 删除分支
  	
	```shell
	git branch -d deltexxx
	```

- 查看分支
	```shell
	git branch -avv(-vv)
	```

- 回滚当前分支所有修改`修改workspace`  
	- git reset --hard HEAD  //会删除本地的修改  
	- 如果只是需要回归 add commit不用使用hard。

- 注意如果需要修改 `Remote repository` 
	- 一般都是 push -f。。 多人协作会有问题  
	- git reset --hard HEAD~1  //回滚当前分支某个提交   
	- git push master -f  //因为落后远程库一个版本需要强制提交		
	- 多人协同时，比较安全的是revert，本质上会产生一次额外的提交，进而回滚某次提交	


# 高级操作

- 多个分支merge合入主线，GITlog 记录好看一点  
	>多个分支何如到master时，先merge一个，然后rebase  
	git checkout master  
	git merge issue2  
	git checkout issue3  
	git rebase master  
	git add myfile.txt  //修改冲突后手动add
	git rebase —continue (—abort)  
	注意这里可以加上merge的时候可以加上一个 --no--ff [参考链接](https://nvie.com/posts/a-successful-git-branching-model/) 

- 如果想维护history的线性,想维持树的整洁
	>每次提交前，先git fetch   
	然后如果commit有冲突.在不用-f的前提下  
	在git push之前  
	先git fetch  
	再git rebase  
	git fetch origin master  
	git rebase origin/master  
	git push  

- 删除上一次`远程仓库`的提交，修改上次提交的代码，做一次更完美的commit。
	>git reset commitId （注：不要带–hard）到上个版本  
	git stash 暂存修改  
	git push --force 强制push，远程的最新的一次commit被删除  
	git stash pop 释放暂存的修改，开始修改代码  
	git add . -> git commit -m "massage" -> git push  


- 针对本地、删除某一次也是类似  
	>git rebase -i ‘commit id'^　　　//弹出的窗口中 删除不要的pick  
	git push master -f	//remote 才需要

- 针对本地 修改历史某次提交  
	>git rebase -i ‘commit id'^　　　//弹出的窗口中pick改成Edit  
	git add .  
	git commit --amend  
	git rebase --continue      

- 修改本地最近一条commit记录  
	>git commit --amend  即可  
	git reset HEAD@{1} //回滚错误的修改  
	git reflog 	   //查看历史
# svn  GIT 互相转换
- svn 转到 GIT管理，不想丢失之前的commit记录
	>通过 git svn clone urlxxx 
	//新建分支，用GIT开发  
	git checkout -b dev   
	
	>//只保留一次提交到SVn  
	git checkout master  
	git svn rebase  
	git merge dev  
	git svn dcommit  
	
	>//保留dev的提交记录  
	git checkout master  
	git merge dev  
	git svn rebase  
	git svn dcommit  
	
- 本地SVN地址转到GIT
	- 1.创建SVN本地库(安装SVN Setup-Subversion-1.6.16.msi)，GUI右键操作 or命令行 avnadmin create SvnLoaclBase    
	
	- 2.取得地址 file:///F:\Carry_Blog\SvnLoaclBase 此地址链接我们是可以直接用svn工具进行checkout的，这样相当于吧svn服务器放到本地    
	
	- 3.如果我们想把SVN的历史提交记录，都放到git上    
	
	- 4.切换到一个空的文件夹，git svn init  svn://localhost\F:\Carry_Blog\SvnLoaclBase 然后执行 git svn fetch  
	
	- 4.等价于 git svn clone   
	
	- 5.注意这个svn:://localhost协议，默认不会开启。 需要我们临时手动运行下 svnserve.exe --daemon  
	
	- 6.后续可以在GIT上正常修改，当GIT修改要同步到SVN时，需要调用 git svn dcommit就可以把git的修改记录，都提交到SVN了  
	
	- 7.注意这里可能会出错，需要修改F:\Carry_Blog\SvnLoaclBase\conf\svnserve.conf 增加 anon-access = write  
	
	- 8.当SVN有改动时，git svn fetch 即可 手动fetch后，需要merge到master。简单点的做法是开发在dev线上，然后切换到master，执行git svn rebase。如果Git有改动，需要把dev的改动merge到master。然后用git svn dcommit提交到SVN的服务器。注意首次需要加上name git svn dcommit –-username Gitcarry   
	- 9.git commit --amend --author="Gitcarry<liaochongliang@gmail.com>"  //git svn 方式创建的GIT 总是不识别username    
	- 10.提交到本地时,F:\Carry_Blog\SvnLoaclBase\conf\svnserve.conf 按前面7的设置，会导致 git svn dcommit 提交到SVN时，显示都是无name的所以。这里需要设置为SVN仓库是匿名不可写，然后在passwd中加上Gitcarry = 123456
	
- GIT转SVN
	- 1.首先我们有一个GIT的远程仓库，拉取到本地现在我们想把远程的GIT仓库和一个本地的SVN库，关联起来  
	
	- 2.首先和上面一样，也需要创建一个SVN的本地仓库 获得地址 svn://localhost\F:\Git_Test\SvnLoaclBase   
	
	- 3.在本地拉取远端的git仓库  git clone https://github.com/liaochongliang/windows_tools  
	
	- 4.接着运行 git svn init svn://localhost\F:\Git_Test\SvnLoaclBase  
	
	- 5.拉取SVN的代码 git svn fetch  
	
	- 6.此时git branch -avv 可以看到 我们有2个远程地址，一个是GIT的 一个是SVN的，而且这2个分支没有关联起来，所以不能merge等各种操作。  
	
	- 7.git\info\grafts (系统会提示要我们在运行一次git replace --convert-graft-file)中强行把SVN的提交放到GIT之后，让2个没有任何关系的分支有关联。这样就可以remote/git-svn remoter/master 之前各种merge 各种dcommit，只要建立了映射就很简单了。这里可以理解为，我们git仓库有个远端在github上，同时有一个远端是来自svn的URL（只不过我们这里用的本地）。为什么要这么做？主要是SVN查看历史记录和diff，习惯一点。 当然用https://github.com/liaochongliang/lcl/tree/master/Tools/git 这个里面的\cmd\gitk.exe cmd\git-gui.exe 也是很清晰的。   
	  
	- 8.到现在为止，我们的GIT有SVN本地仓库，也有远端的库。  
	当我们修改GIT时，可以merge的remotes/git-svn,然后git svn dcommit.  
	当我们修改SVN时，可以svn fetch,然后git merge.  
	这里要注意维护线的问题，就是前面有讲的，如果让提交历史更好看。git svn dcommit 会修改本地的GIT提交hash值，这个没法优化。  
	所以需要遵守，以下规范  
	
	
	
	
# windows cmd 显示中文问题  
- 设置操作
	>\*\\depot_tools\\win_tools-2_7_6_bin\\git （本GIT中 Tools\\git） 中打开git-bash.exe 
	右键属性  Text → locale设置为zh_CN  Character set 设置为 UTF-8  
	git config --global core.quotepath false   
	git config --global gui.encoding utf-8  
	git config --global i18n.commit.encoding utf-8   
	git config --global i18n.logoutputencoding gbk   
	export LESSCHARSET=utf-8 //导入到windows环境变量  
	//最后一条命令是因为 git log 默认使用 less 分页，所以需要 bash 对 less 命令进行 utf-8 编码
- 其他
	>另外https://github.com/liaochongliang/lcl/tree/master/Tools/git 是一个绿色版本的GIT  
	可以可视化操作GIT，查看历史记录，还有对应的命令行  
	观察环境变量是否生效 使用 echo %LESSCHARSET% 即可
	
---
