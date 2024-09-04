
alias ls="ls --color"
alias git-update="git commit --amend --date=\"\$(git log -n 1 --format=%aD)\""
alias bump-maug="cd maug && git pull && cd .. && git commit maug -m \"Maug bump.\""
alias git-maug="git -C maug"
alias vimsn="vim --servername"

if [[ $- == *i* ]]; then
   echo "= aliases ="
   alias | grep -v ls | grep -v grep | awk -F '=' '{print $1}' | awk '{print $2}'
fi

