
- 文件夹权限设置相关
  - sudo su jenkins
  - ls -ahl  $(find  .  -name "*.*")
  - chown -R jenkins:jenkins .
  - chmod 777 * -R


- git 批量删除分支
  - git branch |grep 'branchName' |xargs git branch -D
