#!/bin/bash
if [ ! -z "$(git status --untracked-files=no --porcelain)" ]; then
	echo "Error: There are modified or staged files. This is not allowed."
	exit 1
fi

# Clean previous tests
rm -rf test_*

if [ $# != 0 ]; then
	DEBUG=1
fi


root=$PWD
notRepo="/tmp/notRepo"
gitsub="$root/git-sub"
subDir="$root/test_sub"
subSrc="$subDir.git"
testDir="$root/test_git_sub"
testSrc="$testDir.git"
testDir2="$root/test_git_sub_again"

helpString="Usage:
	git sub clone <remote path> [<destination directory> [<commitish>]]
	git sub init  # only the first time you want to work in an existing sub
	git sub status  # git status of main repo and all subs"

##########################################

function newClone() {
	newDir=$1
	git clone $testSrc $newDir > /dev/null 2>&1
	cd $newDir
}


function mkdirP() {
	newDir="$1"

	if [ -e "$newDir" ]; then
		echo "Cannot create directory, already exists: $newDir"
		exit 1
	fi

	mkdir "$newDir"
}

##########################################

function oneTimeSetUp() {
	# Prepare dummy git repo

	# Print values for debug purpose
	echo "root=$root"
	echo "gitsub=$gitsub"
	echo "subDir=$subDir"
	echo "subSrc=$subSrc"
	echo "testDir=$testDir"
	echo "testSrc=$testSrc"
	echo "testDir2=$testDir2"

	# Prepare dummy sub
	mkdirP $subSrc
	cd $subSrc
	git init --bare > /dev/null
	cd $root

	git clone $subSrc > /dev/null 2>&1
	cd $subDir
	echo "Sub repo" > README
	git add README
	git commit -m "initial sub commit" > /dev/null 2>&1
	echo "More stuff" >> README
	git commit -m "sub needs more than one commit" README > /dev/null 2>&1
	git push > /dev/null 2>&1
	cd $root

	# Prepare dummy repo (2x)
	mkdirP $testSrc
	cd $testSrc
	git init --bare > /dev/null
	cd $root

	git clone $testSrc > /dev/null 2>&1
	cd $testDir
	echo "Main project repo" > README
	git add README
	git commit -m "initial project commit" > /dev/null 2>&1
	git push > /dev/null 2>&1
	cd $root

	git clone $testSrc $testDir2 > /dev/null 2>&1
}

function tearDown() {
	# Be sure to be at the right place

	cd $root
	if [ ! -z "$(git status --untracked-files=no --porcelain)" ]; then
		git reset --hard > /dev/null 2>&1
	fi
}

##########################################

function test_notGitRepo() {
	# Test what happens outside of git repository

	mkdir -p $notRepo
	cd $notRepo

	myStdout=$($gitsub)

	assertEquals 'exit value' 128 $?
	assertContains "$myStdout" "Not a git repository"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_help() {
	# Test the help method

	myStdout=$($gitsub)
	assertEquals 'exit value' 1 $?
	assertEquals 'help message mismatch' "$helpString" "$myStdout"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_wrongArg() {
	# Test a wrong arg aborts

	myStdout=$($gitsub)
	assertEquals 'exit value' 1 $?
	assertEquals 'help message mismatch' "$helpString" "$myStdout"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_clone1args() {
	# Test clone of sub with 1 args

	cd $testDir

	subName="test_sub"
	myStdout=$($gitsub clone $subSrc)
	ret=$?

	git push > /dev/null 2>&1

	assertEquals 'exit value' 0 $ret

	assertContains "$myStdout" "Your branch is up-to-date with 'origin/master'."
	assertContains "$myStdout" "git commit: adding new sub $subName@"
	assertContains "$myStdout" "= master from $subSrc"
	assertContains "$myStdout" "[master "
	assertContains "$myStdout" "2 files changed, 3 insertions(+)"
	assertContains "$myStdout" "create mode 100644 .gitsub"
	assertContains "$myStdout" "create mode 100644 $subName/README"
	assertContains "$myStdout" "## master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_clone2args() {
	# Test clone of sub with 2 args

	cd $testDir

	subName="subb"
	myStdout=$($gitsub clone $subSrc $subName)
	ret=$?

	git push > /dev/null 2>&1

	assertEquals 'exit value' 0 $ret

	assertContains "$myStdout" "Your branch is up-to-date with 'origin/master'."
	assertContains "$myStdout" "git commit: adding new sub $subName@"
	assertContains "$myStdout" "= master from $subSrc"
	assertContains "$myStdout" "[master "
	assertContains "$myStdout" "2 files changed, 3 insertions(+)"
	assertContains "$myStdout" "create mode 100644 $subName/README"
	assertContains "$myStdout" "## master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_clone3args() {
	# Test clone of sub with 3 args

	cd $testDir

	subName="subbb"
	myStdout=$($gitsub clone $subSrc $subName master)
	ret=$?

	git push > /dev/null 2>&1

	assertEquals 'exit value' 0 $ret

	assertContains "$myStdout" "Your branch is up-to-date with 'origin/master'."
	assertContains "$myStdout" "git commit: adding new sub $subName@"
	assertContains "$myStdout" "= master from $subSrc"
	assertContains "$myStdout" "[master "
	assertContains "$myStdout" "2 files changed, 3 insertions(+)"
	assertContains "$myStdout" "create mode 100644 $subName/README"
	assertContains "$myStdout" "## master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_cloneErrorModifications() {
	# Test clone with local modification before

	newClone "test_cloneErrorModifications"
	echo "# new line" >> README

	subName="sub4"
	myStdout=$($gitsub clone $subSrc $subName master)
	assertEquals 'exit value' 1 $?
	assertContains "$myStdout" "Error: There are modified or staged files. This is not allowed."

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_cloneErrorPathExists() {
	# Test clone when path already exists

	newClone "test_cloneErrorPathExists"

	subName="README"
	myStdout=$($gitsub clone $subSrc $subName master)
	assertEquals 'exit value' 1 $?
	assertContains "$myStdout" "Error: path '$subName' already exists"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_cloneErrorSubExists() {
	# Test clone when sub already exists

	subName="subb"

	newClone "test_cloneErrorSubExists"
	mv $subName subbus
	git commit -am "moving around" > /dev/null 2>&1

	myStdout=$($gitsub clone $subSrc $subName master)
	assertEquals 'exit value' 1 $?
	assertContains "$myStdout" "Error: sub '$subName' already in .gitsub file"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_init() {
	# Test init of subs

	cd $testDir2
	git pull > /dev/null 2>&1

	myStdout=$($gitsub init 2>&1)
	assertEquals 'exit value' 0 $?

	assertContains "$myStdout" "git sub [test_sub]: init remote=$subSrc"
	assertContains "$myStdout" "Initialized empty Git repository in"
	assertContains "$myStdout" "Add remote origin: $subSrc"
	assertContains "$myStdout" "Fetching..."
	assertContains "$myStdout" "From $subDir"
 	assertContains "$myStdout" "* [new branch]      master     -> origin/master"
	assertContains "$myStdout" "You are in 'detached HEAD' state. You can look around, make experimental"
	assertContains "$myStdout" "changes and commit them, and you can discard any commits you make in this"
	assertContains "$myStdout" "state without impacting any branches by performing another checkout."
	assertContains "$myStdout" "git sub [subb]: init remote=$subSrc ref="
	assertContains "$myStdout" "git sub [subbb]: init remote=$subSrc ref="

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusUninit() {
	# Test sub status sub is not init

	newClone "test_statusUninit"
	myStdout=$($gitsub status)
	assertEquals 'exit value' 1 $?

	assertContains "$myStdout" "Not a git repository, are you sure you ran 'git sub init' in parent git repo yet?"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusCleanNothing() {
	# Test sub status when all is OK

	cd $testDir
	myStdout=$($gitsub status)
	assertEquals 'exit value' 0 $?

	assertContains "$myStdout" "## master"
	assertContains "$myStdout" "test_sub: clean @"
	assertContains "$myStdout" "subb: clean @"
	assertContains "$myStdout" "subbb: clean @"
	assertContains "$myStdout" "= master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusCleanNoRemote() {
	# Test sub status with sub's branch having no remote

	newClone "test_statusCleanNoRemote"
	$gitsub init > /dev/null 2>&1

	subName="subb"
	# Do something inside subb
	cd $subName
	git checkout master > /dev/null 2>&1
	git branch --unset-upstream
	cd - > /dev/null 2>&1

	myStdout=$($gitsub status)
	assertEquals 'exit value' 1 $?

	assertContains "$myStdout" "WARNING: the branch of sub '$subName' is not remotely tracked yet."
	assertContains "$myStdout" "Please push it to the remote ASAP."

	assertContains "$myStdout" "## master"
	assertContains "$myStdout" "$subName: clean @"
	assertContains "$myStdout" "= master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_satusCleanLocalCommits() {
	# Test sub status with sub having local commits

	newClone "test_statusCleanLocalCommits"
	$gitsub init > /dev/null 2>&1

	subName="subb"
	# Do something inside subb
	cd $subName
	git checkout master > /dev/null 2>&1
	touch new_file
	git add new_file
	git commit -m "new file" > /dev/null 2>&1
	cd - > /dev/null 2>&1

	myStdout=$($gitsub status)
	assertEquals 'exit value' 1 $?

	assertContains "$myStdout" "WARNING: sub '$subName' local commits differ from its remote."
	assertContains "$myStdout" "Please sync with the remote ASAP."

	assertContains "$myStdout" "## master"
	assertContains "$myStdout" "$subName: clean @"
	assertContains "$myStdout" "= master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusDirtyNothing() {
	# Test sub status with uncommitted changes in sub

	newClone "test_statusDirtyNothing"
	$gitsub init > /dev/null 2>&1

	subName="subb"
	# Do something inside subb
	cd $subName
	git checkout master > /dev/null 2>&1
	echo "# one more line" >> README
	cd - > /dev/null 2>&1

	myStdout=$($gitsub status)
	assertEquals 'exit value' 0 $?

	assertContains "$myStdout" "## master"
	assertContains "$myStdout" "$subName: dirty @"
	assertContains "$myStdout" "= master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusDirtyNoBranch() {
	# Test sub status with committed changes in sub without branch

	newClone "test_statusDirtyNoBranch"
	$gitsub init > /dev/null 2>&1

	subName="subb"
	# Do something inside sub
	cd $subName
	echo "# one more line" >> README
	cd - > /dev/null 2>&1

	myStdout=$($gitsub status)
	assertEquals 'exit value' 1 $?

	assertContains "$myStdout" "WARNING: there are changes in the sub '$subName' but it is not on a branch"
	assertContains "$myStdout" "Please checkout to a branch in sub ASAP."
	assertContains "$myStdout" "## master"
	assertContains "$myStdout" "$subName: dirty @"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusDirtyUncommitted() {
	# Test sub status with uncommitted changes in sub ALREADY committed in main

	newClone "test_statusDirtyUncommited"
	$gitsub init > /dev/null 2>&1

	subName="subb"
	# Do something inside sub
	cd $subName
	git checkout master > /dev/null 2>&1
	echo "# one more line" >> README
	cd - > /dev/null 2>&1

	# Commit in main
	git add $subName/README
	git commit -m "committing here but not in sub" > /dev/null 2>&1

	myStdout=$($gitsub status)
	assertEquals 'exit value' 1 $?

	assertContains "$myStdout" "WARNING: we have changes committed to main repo BUT NOT to the remote of sub '$subName'."
	assertContains "$myStdout" "Please commit and push in sub ASAP."
	assertContains "$myStdout" "## master"
	assertContains "$myStdout" "$subName: dirty @"
	assertContains "$myStdout" "= master"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusUpdateRef() {
	# Test sub status updates ref if required

	newClone "test_statusUpdateRef"
	$gitsub init > /dev/null 2>&1

	# Prepare subs branches
	for sub in $(cat .gitsub | cut -f1); do
		cd $sub
		git checkout master > /dev/null 2>&1
		cd - > /dev/null 2>&1
	done

	# Do something inside subb
	cd subb
	echo "again" >> README
	git commit -m "changes coming" README > /dev/null 2>&1
	git push > /dev/null 2>&1
	cd - > /dev/null 2>&1

	myStdout=$($gitsub status)
	assertEquals 'exit value' 0 $?

	assertContains "$myStdout" "M  .gitsub"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_statusUpdateRefSlash() {
	# Test sub status updates ref if required

	newClone "test_statusUpdateRefSlash"
	$gitsub init > /dev/null 2>&1

	mkdirP newdir
	subName="newdir/subb"
	$gitsub clone $subSrc $subName > /dev/null 2>&1

	# Prepare subs branches
	for sub in $(cat .gitsub | cut -f1); do
		cd $sub
		git checkout master > /dev/null 2>&1
		cd - > /dev/null 2>&1
	done

	# Do something inside subb
	cd $subName
	echo "again" >> README
	git commit -m "changes coming" README > /dev/null 2>&1
	git push > /dev/null 2>&1
	cd - > /dev/null 2>&1

	myStdout=$($gitsub status)
	assertEquals 'exit value' 0 $?

	assertContains "$myStdout" "M  .gitsub"

	if [ "$DEBUG" = "1" ]; then
		echo "$myStdout"
	fi
}

function test_update() {
}

##########################################

if [ "$DEBUG" = "" ]; then
	. shunit2-master/shunit2
fi

