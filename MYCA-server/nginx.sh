#/bin/bash 

# $1   #  subdomain 
# $2   #  domain


if [ "$2" = "c9.local.pi" ]; then
    echo 8080
elif [ "$2" = "ca.local.pi" ]; then
    echo 8088
else
    echo 8000
fi

