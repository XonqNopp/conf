git sub
#######

If you are sharing code in several repository or using third-party code, you are likely to have come to think how to do
it efficiently.
Git provides some ways to do this, but...
All existing solutions suck:

* submodule is nice but painful for users, and for beginner developers
* subtree is nice but painful for developers since push can be wrong
* subrepo is nice but does not allow to change branch easily

So I have come to think that sticking to the basics is maybe better.
**Git sub** is a new way to include git repos in a git repo.
It is simply a clone of the other repo into the main repo and we track all files in the main repo as well.
For repositories with more than one developer, I advise to use sub.

The ``git-sub`` script helps deal with this.

* To introduce a new sub, the following command will clone the repo and stage all files for commit::

     git sub clone my/sub/path/in/repo https://github.com/awesome/repo [branch_name_or_whatever_git_ref]

* If you pulled from the repo and new commits introduce a sub, running the following command will add the .git
  directory in the sub so you can easily change branch, commit or anything::

     git sub init

* Later on, you can also check if there are uncommitted changes with::

     git sub st


Pros
****

* all files available with a simple clone, no additional arg/command required


Cons
****

* if you do changes and commit them in main repo, sub remote won't be update.
  You need to cd there and commit-push as well


HowTo advice
************

* when changes are required in sub, cd there, do the changes, commit, push, and when state is clean (as opposed to
  submodule dirty status), cd back to main repo and commit.
  This way you ensure you use only versions of the sub which are available in the remote.
  To be sure to have everything synchronized on both repos, you can use ``git sub st`` (see above).



See also: http://xonqnopp.github.io/output/git-sub.html

