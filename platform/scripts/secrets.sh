#!/bin/sh

OUTPUT=secrets

rm -fR $OUTPUT

mkdir -p $OUTPUT

echo '[extended]\nextendedKeyUsage=serverAuth,clientAuth\nkeyUsage=digitalSignature,keyAgreement' > $OUTPUT/openssl.cnf

## Create keystore for JWT authentication
keytool -genseckey -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg HMacSHA256 -keysize 2048 -alias HS256 -keypass secret
keytool -genseckey -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg HMacSHA384 -keysize 2048 -alias HS384 -keypass secret
keytool -genseckey -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg HMacSHA512 -keysize 2048 -alias HS512 -keypass secret
keytool -genkey -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg RSA -keysize 2048 -alias RS256 -keypass secret -sigalg SHA256withRSA -dname "CN=myself" -validity 365
keytool -genkey -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg RSA -keysize 2048 -alias RS384 -keypass secret -sigalg SHA384withRSA -dname "CN=myself" -validity 365
keytool -genkey -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg RSA -keysize 2048 -alias RS512 -keypass secret -sigalg SHA512withRSA -dname "CN=myself" -validity 365
keytool -genkeypair -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg EC -keysize 256 -alias ES256 -keypass secret -sigalg SHA256withECDSA -dname "CN=myself" -validity 365
keytool -genkeypair -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg EC -keysize 256 -alias ES384 -keypass secret -sigalg SHA384withECDSA -dname "CN=myself" -validity 365
keytool -genkeypair -keystore $OUTPUT/keystore-auth.jceks -storetype JCEKS -storepass secret -keyalg EC -keysize 256 -alias ES512 -keypass secret -sigalg SHA512withECDSA -dname "CN=myself" -validity 365

## Create certificate authority (CA)
openssl req -new -x509 -keyout $OUTPUT/ca_key.pem -out $OUTPUT/ca_cert.pem -days 365 -passin pass:secret -passout pass:secret -subj "/CN=myself"

## Create client keystore
keytool -noprompt -keystore $OUTPUT/keystore-client.jks -genkey -alias selfsigned -dname "CN=myself" -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 365 -storepass secret -keypass secret

## Create server keystore
keytool -noprompt -keystore $OUTPUT/keystore-server.jks -genkey -alias selfsigned -dname "CN=myself" -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 365 -storepass secret -keypass secret

## Sign client certificate
keytool -noprompt -keystore $OUTPUT/keystore-client.jks -alias selfsigned -certreq -file $OUTPUT/client_csr.pem -storepass secret
openssl x509 -extfile $OUTPUT/openssl.cnf -extensions extended -req -CA $OUTPUT/ca_cert.pem -CAkey $OUTPUT/ca_key.pem -in $OUTPUT/client_csr.pem -out $OUTPUT/client_cert.pem -days 365 -CAcreateserial -passin pass:secret

## Sign server certificate
keytool -noprompt -keystore $OUTPUT/keystore-server.jks -alias selfsigned -certreq -file $OUTPUT/server_csr.pem -storepass secret
openssl x509 -extfile $OUTPUT/openssl.cnf -extensions extended -req -CA $OUTPUT/ca_cert.pem -CAkey $OUTPUT/ca_key.pem -in $OUTPUT/server_csr.pem -out $OUTPUT/server_cert.pem -days 365 -CAcreateserial -passin pass:secret

## Import CA and client signed certificate into client keystore
keytool -noprompt -keystore $OUTPUT/keystore-client.jks -alias CARoot -import -file $OUTPUT/ca_cert.pem -storepass secret
keytool -noprompt -keystore $OUTPUT/keystore-client.jks -alias selfsigned -import -file $OUTPUT/client_cert.pem -storepass secret

## Import CA and server signed certificate into server keystore
keytool -noprompt -keystore $OUTPUT/keystore-server.jks -alias CARoot -import -file $OUTPUT/ca_cert.pem -storepass secret
keytool -noprompt -keystore $OUTPUT/keystore-server.jks -alias selfsigned -import -file $OUTPUT/server_cert.pem -storepass secret

## Import CA into client truststore
keytool -noprompt -keystore $OUTPUT/truststore-client.jks -alias CARoot -import -file $OUTPUT/ca_cert.pem -storepass secret

## Import CA into server truststore
keytool -noprompt -keystore $OUTPUT/truststore-server.jks -alias CARoot -import -file $OUTPUT/ca_cert.pem -storepass secret

openssl pkcs12 -in $OUTPUT/keystore-client.jks -nocerts -nodes -passin pass:secret -out $OUTPUT/client_key.pem
openssl pkcs12 -in $OUTPUT/keystore-server.jks -nocerts -nodes -passin pass:secret -out $OUTPUT/server_key.pem

cat $OUTPUT/server_cert.pem > $OUTPUT/../integration/nginx/etc/nginx/ca_and_server_cert.pem
cat $OUTPUT/ca_cert.pem >> $OUTPUT/../integration/nginx/etc/nginx/ca_and_server_cert.pem
cp $OUTPUT/server_key.pem $OUTPUT/../integration/nginx/etc/nginx/server_key.pem
