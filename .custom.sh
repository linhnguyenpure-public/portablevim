if False; then
    export REMOTE_NAME="/var/tmp/linh/ip"
    alias yr='clip=`pbpaste`; ssh `cat \$REMOTE_NAME` -C "echo $clip | pbcopy"'
fi