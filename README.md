[annapurnashenoy@feserver ~]$ cd /fetools/work_area/frontend/Batch_11/AnnapurnaShe                                                                                      noy
[annapurnashenoy@feserver AnnapurnaShenoy]$ ls
Github  Verilog
[annapurnashenoy@feserver AnnapurnaShenoy]$ cd Github
[annapurnashenoy@feserver Github]$ ls
New
[annapurnashenoy@feserver Github]$ ls -al ~/.ssh
total 20
drwx------  2 annapurnashenoy annapurnashenoy 4096 May  4 13:00 .
drwx------ 22 annapurnashenoy annapurnashenoy 4096 May  4 13:00 ..
-rw-------  1 annapurnashenoy annapurnashenoy  432 May  4 10:58 id_ed25519
-rw-r--r--  1 annapurnashenoy annapurnashenoy  113 May  4 10:58 id_ed25519.pub
-rw-r--r--  1 annapurnashenoy annapurnashenoy  185 May  4 12:27 known_hosts
[annapurnashenoy@feserver Github]$ ssh -T git@github.com
Permission denied (publickey).
[annapurnashenoy@feserver Github]$ cat id_ed25519.pub
cat: id_ed25519.pub: No such file or directory
[annapurnashenoy@feserver Github]$ cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuTn0wFI3oucfW4Er7Olac5dt4Pw5nSqVh5hAgPi6LG a                                                                                      nnapurnasatishshenoy@gmail.com
[annapurnashenoy@feserver Github]$ ^C
[annapurnashenoy@feserver Github]$ ssh -T git@github.com
Hi Annapurnaa14! You've successfully authenticated, but GitHub does not provide sh                                                                                      ell access.
[annapurnashenoy@feserver Github]$ git config --global user.name "Annapurnaa14"                                                                                         [annapurnashenoy@feserver Github]$ git config --global user.email "annapurnasatish                                                                                      shenoy@gmail.com"
[annapurnashenoy@feserver Github]$ cd ..
[annapurnashenoy@feserver AnnapurnaShenoy]$ mkdir ALU
[annapurnashenoy@feserver AnnapurnaShenoy]$ cd ALU
[annapurnashenoy@feserver ALU]$ git clone git@github.com:Annapurnaa14/ALU.git
Cloning into 'ALU'...
warning: remote HEAD refers to nonexistent ref, unable to checkout.

[annapurnashenoy@feserver ALU]$ ls -a
.  ..  ALU
[annapurnashenoy@feserver ALU]$ rm -rf ./ALU
[annapurnashenoy@feserver ALU]$ ls
[annapurnashenoy@feserver ALU]$ git init
Initialized empty Git repository in /fetools/work_area/frontend/Batch_11/Annapurna                                                                                      Shenoy/ALU/.git/
[annapurnashenoy@feserver ALU]$ echo "ALU_Code" >> design.v
[annapurnashenoy@feserver ALU]$ vim design.v
[annapurnashenoy@feserver ALU]$ git add design.v
[annapurnashenoy@feserver ALU]$ git commit -m "Initial commit"
[master (root-commit) 3c25542] Initial commit
 1 file changed, 1 insertion(+)
 create mode 100644 design.v
[annapurnashenoy@feserver ALU]$ git branch -M main
[annapurnashenoy@feserver ALU]$ git remote add origin
usage: git remote add [<options>] <name> <url>

    -f, --fetch           fetch the remote branches
    --tags                import all tags and associated objects when fetching
                          or do not fetch any tag at all (--no-tags)
    -t, --track <branch>  branch(es) to track
    -m, --master <branch>
                          master branch
    --mirror[=<push|fetch>]
                          set up remote as a mirror to push to or fetch from

[annapurnashenoy@feserver ALU]$ git remote add origin git@github.com:Annapurna14/ALU.git
[annapurnashenoy@feserver ALU]$ git push -u origin main
ERROR: Repository not found.
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
[annapurnashenoy@feserver ALU]$ ls
design.v
[annapurnashenoy@feserver ALU]$ git remote add origin git@github.com:Annapurnaa14/ALU.git
fatal: remote origin already exists.
[annapurnashenoy@feserver ALU]$ git push -u origin
warning: push.default is unset; its implicit value is changing in
Git 2.0 from 'matching' to 'simple'. To squelch this message
and maintain the current behavior after the default changes, use:

  git config --global push.default matching

To squelch this message and adopt the new behavior now, use:

  git config --global push.default simple

See 'git help config' and search for 'push.default' for further information.
(the 'simple' mode was introduced in Git 1.7.11. Use the similar mode
'current' instead of 'simple' if you sometimes use older versions of Git)

ERROR: Repository not found.
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
[annapurnashenoy@feserver ALU]$ git branch -v
* main 3c25542 Initial commit
[annapurnashenoy@feserver ALU]$ git remote remove origin
[annapurnashenoy@feserver ALU]$ git remote add origin git@github.com:Annapurnaa14/ALU.git
[annapurnashenoy@feserver ALU]$ git push -u origin
warning: push.default is unset; its implicit value is changing in
Git 2.0 from 'matching' to 'simple'. To squelch this message
and maintain the current behavior after the default changes, use:

  git config --global push.default matching

To squelch this message and adopt the new behavior now, use:

  git config --global push.default simple

See 'git help config' and search for 'push.default' for further information.
(the 'simple' mode was introduced in Git 1.7.11. Use the similar mode
'current' instead of 'simple' if you sometimes use older versions of Git)

No refs in common and none specified; doing nothing.
Perhaps you should specify a branch such as 'master'.
Everything up-to-date
[annapurnashenoy@feserver ALU]$ git push -u origin main
Counting objects: 3, done.
Writing objects: 100% (3/3), 229 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
remote: To git@github.com:Annapurnaa14/ALU.git
 * [new branch]      main -> main
Branch main set up to track remote branch main from origin.
[annapurnashenoy@feserver ALU]$

