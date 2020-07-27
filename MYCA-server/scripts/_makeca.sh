
Country="US"
State_Province="National" 
Locality_City="Local"
Organization_Name="PI-CA"
Organizational_Unit="LOCAL-PI-DEVICE"
Common_Name="LOCAL-PI"
Email_Address="admin@localhost"

Domain="local.pi" # wildcard `*.local.pi`

RSA_KEY_SIZE=4096

DAYS_EXPIRE=365

# if [ ! -f "$Organization_Name.ca.key" ]; then
    # echo "$FILE does not exist. Creating!"
    
    openssl genrsa -out $Organization_Name.ca.key $RSA_KEY_SIZE
    
    openssl req -x509 -new -nodes -key $Organization_Name.ca.key -sha256 -days $DAYS_EXPIRE -out $Organization_Name.ca.pem \
        -subj "/C=${Country}/ST=${State_Province}/L=${Locality_City}/O=${Organization_Name}/OU=${Organizational_Unit}/CN=${Common_Name}/emailAddress=${Email_Address}"
    
    
    openssl x509 -in $Organization_Name.ca.pem -text -noout

# fi

cat > my.conf <<- "EOF"
[req_distinguished_name]
countryName = Country Name (2 letter code)
stateOrProvinceName = State or Province Name (full name)
localityName = Locality Name (eg, city)
organizationalUnitName	= Organizational Unit Name (eg, section)
commonName = Common Name (eg, YOUR name)
commonName_max	= 64
emailAddress = Email Address
emailAddress_max = 40

[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[v3_req] 
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
EOF

echo "DNS.1 = $Domain" >> my.conf
echo "DNS.2 = *.$Domain" >> my.conf


openssl genrsa -out $Domain.key $RSA_KEY_SIZE

openssl req -new -key $Domain.key -out $Domain.csr \
    -subj "/C=${Country}/ST=${State_Province}/L=${Locality_City}/O=${Organization_Name}/OU=${Organizational_Unit}/CN=${Domain}/emailAddress=${Email_Address}" \
    -config my.conf
    
    
openssl x509 -req -in $Domain.csr -CA $Organization_Name.ca.pem -CAkey $Organization_Name.ca.key -CAcreateserial \
    -out $Domain.crt -days $DAYS_EXPIRE -sha256 \
    -extfile my.conf -extensions v3_req
    # -ext "subjectAltName=DNS.1:{$Domain},DNS.2:*.{$Domain}," 

openssl x509 -in $Domain.crt -text -noout

rm ./my.conf
rm ./local.pi.csr
rm ./PI-CA.ca.key
rm ./PI-CA.ca.srl

sudo service nginx restart