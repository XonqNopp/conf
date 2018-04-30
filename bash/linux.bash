## Linux stuff ##
##
export ki="/media/$kiName"
##
##
## LS colors: http://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
alias ls="ls -Ah --color=always"
alias aptgetuu="sudo apt-get autoremove && sudo apt-get update && sudo apt-get upgrade"
#alias nobodyKill="perl ~/.vash/perl/nobodyKill.pl"
alias damn_linux="egrep -inHR \"(fuck|bastard|damn|bitch)\" /usr/src/linux* 2> /dev/null"
#alias which="alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde"
alias du="du -h --max-depth=0"
alias getuuid="sudo vol_id -u"
alias deborphan="deborphan -zs"
alias lpsf="lpstat -H -R -t -l"
function acroread() {
	for i in "$@"; do
		evince "$i" 2> /dev/null &
	done
}
##
## Queue
alias sq="squeue --format='%.8i %2t %8u %24j %.12M %.12l %.3C %.5m %.15E' --sort='i'"
export SACCT_FORMAT=""
function saac() {
	sac="sacct -a"
	back="$sac --format=JobID%8,JobName%-23,User%-8,Account%-8,State%7,Elapsed%12,NCPUS%4,ReqCPUS%6,ReqMem%7"
	if (( $# >= 1 )); then
		if [[ ${1:0:1} == "-" ]]; then
			back="$back $@"
		else
			if [[ $1 == "l" || $1 == "al" ]]; then
				back="$sac --format=JobID%8,JobName%-23,User%-8,Account%-8,State%6,TimeLimit%12,Elapsed%12,Suspended,NCPUS%4,ReqCPUS%6,ReqMem%7"
			elif [[ $1 == "t" || $1 == "at" ]]; then
				back="$sac --format=JobID%8,JobName%-23,User%-8,Account%-8,State%6,TimeLimit%12,Elapsed%12,Suspended,CPUTime%12,Submit,Eligible,Start,End"
			fi
			if [[ ${1:0:1} == "a" ]]; then
				back="$back -S 2015-01-01"
			fi
		fi
	fi
	$back | grep -Ev "[0-9]+\\.bat"
}

function scpu() {
	oifs=$IFS
	IFS=$'\n'
	sum=0
	for i in $(sq | egrep '[0-9]+ *R' | sed 's/^.*[0-9][0-9]:[0-9][0-9] *\([0-9]\+\) *[0-9K]\+ *$/\1/'); do
		((sum += $i))
	done
	IFS=$oifs
	echo "Cores used in queue: $sum"
}

# SUSE
#alias which="alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde"

