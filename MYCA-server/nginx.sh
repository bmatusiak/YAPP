#/bin/bash 

# $1   #  domain


if [ "$1" = "apps.crp.to" ]; then
    echo 8888
elif [ "$1" = "c9.local.pi" ]; then
    echo 8080
elif [ "$1" = "ca.local.pi" ]; then
    echo 8088
else
    echo 8000
fi

