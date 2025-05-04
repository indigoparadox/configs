
alias ls="ls --color"
alias git-update="git commit --amend --date=\"\$(git log -n 1 --format=%aD)\""
alias bump-maug="cd maug && git pull && cd .. && git commit maug -m \"Maug bump.\""
alias git-maug="git -C maug"
alias gm="git -C maug"
alias vimsn="vim --servername"
alias vimslw="vimsaver -s webdev load -i webdev.json"
alias vimssw="vimsaver -s webdev save -o webdev.json"
alias vimsls="vimsaver -s vimsaver load -i vimsaver.json"
alias vimsss="vimsaver -s vimsaver save -o vimsaver.json"
alias yt720="yt-dlp -f \"bestvideo[height<=?720][ext=mp4]+bestaudio/best[ext=mp4]/best\" --recode mp4"
alias yt360="yt-dlp -f \"bestvideo[height<=?360][ext=mp4]+bestaudio/best[ext=mp4]/best\" --recode mp4"
alias ytm="yt-dlp -f bestaudio -x --audio-format mp3 --audio-quality 0"

if [[ $- == *i* ]]; then
   echo "= aliases ="
   alias | grep -v ls | grep -v grep | awk -F '=' '{print $1}' | awk '{print $2}'
fi

