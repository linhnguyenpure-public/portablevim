#https://github.com/mobile-shell/mosh/issues/102
#The problem is that /usr/local/bin is not in you server's PATH. This is probably because Mosh invokes Bash as an interactive non-login session. This means that your ~/.bashrc is read while you ~/.bash_profile is not, so you should make sure you have something like this in your ~/.bashrc:

if [[ "$OSTYPE" == "cygwin" ]]; then
    [[ "$-" != *i* ]] && return
else
    export PATH=/usr/local/bin:$PATH
fi