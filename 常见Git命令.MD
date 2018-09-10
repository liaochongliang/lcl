记录一些常用的GIT命令先来2个网上找的原理图，方便理解。  
本质上GIT是多颗树  
>`workspace` 			一个是本地工作区  
`index`					一个是本地暂存区，也就是我们add但是还未commit的  
`Local repository`		一个是本地历史提交记录仓库。涵盖了我们在本地的所有提交  
`Remote repository`		最后一个就是，远端的代码仓库区

# 一些参考链接
>https://backlog.com/git-tutorial/cn/stepup/stepup7_1.html
http://www.ruanyifeng.com/blog/2014/06/git_remote.html  
[Git-工具-重置揭密](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E9%87%8D%E7%BD%AE%E6%8F%AD%E5%AF%86)


# 基本的操作
- vim操作
	```
	ESC: wq!
	```

- 创建并切换分支
	```
	git branch -b  newbxxx oldxxx
	```

- 切换分支  
	
	```
	git checkout  master
	git checkout newxxx
	```

- 删除分支
  	
	```
	git branch -d deltexxx
	```

- 查看分支
	```
	git branch -avv(-vv)
	```

- 回滚当前分支所有修改`修改workspace`  
	- git reset --hard HEAD  //会删除本地的修改  
	- 如果只是需要回归 add commit不用使用hard。

- 注意如果需要修改 `Remote repository` 
	- 一般都是 push -f。。 多人协作会有问题
		git reset --hard HEAD~1            //回滚当前分支某个提交 
		git push master -f                 //因为落后远程库一个版本需要强制提交		               
	- 多人协同时，比较安全的是revert，本质上会产生一次额外的提交，进而回滚某次提交


# 高级操作

- 多个分支merge合入主线，GITlog 记录好看一点  
	>多个分支何如到master时，先merge一个，然后rebase  
	git checkout master  
	git merge issue2  
	git checkout issue3  
	git rebase master  
	git add myfile.txt  
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




---
![image](./Docs/Git/Image1.png)
![image](./Docs/Git/Image2.jpg)
