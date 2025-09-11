## Generate VC

In order to retrieve an actual credential two ways are available:

* Use the account-console and retrieve the credential with a wallet. Currently, we cannot recommend any for a local use
  case.
* Get the credential via http-requests through the `SameDevice-Flow`:

> :warning: The pre-authorized code and the offer expire within 30s for security reasons. Be fast.

> :bulb: In case you did the demo before, you can use the following snippet to unset the env-vars:
> ```shell
>           unset ACCESS_TOKEN; unset OFFER_URI; unset PRE_AUTHORIZED_CODE; \
>           unset CREDENTIAL_ACCESS_TOKEN; unset VERIFIABLE_CREDENTIAL; unset HOLDER_DID; \
>           unset VERIFIABLE_PRESENTATION; unset JWT_HEADER; unset PAYLOAD; unset SIGNATURE; unset JWT; \
>           unset VP_TOKEN; unset DATA_SERVICE_ACCESS_TOKEN;
> ```

Get an AccessToken from Keycloak:

```shell
  export ACCESS_TOKEN=$(curl -s -k -x localhost:8888 -X POST https://keycloak-consumer.127.0.0.1.nip.io/realms/test-realm/protocol/openid-connect/token \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=password \
    --data client_id=account-console \
    --data username=employee \
    --data password=test | jq '.access_token' -r); echo ${ACCESS_TOKEN}
```

(Optional, since in the local case we know all of the values in advance)
Get the credentials issuer information:

```shell
  curl -k -x localhost:8888 -X GET https://keycloak-consumer.127.0.0.1.nip.io/realms/test-realm/.well-known/openid-credential-issuer | python3 -m json.tool
```

Get a credential offer uri(for the `user-credential), using the retrieved AccessToken:

```shell
  export OFFER_URI=$(curl -s -k -x localhost:8888 -X GET 'https://keycloak-consumer.127.0.0.1.nip.io/realms/test-realm/protocol/oid4vc/credential-offer-uri?credential_configuration_id=user-credential' \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '"\(.issuer)\(.nonce)"' -r); echo ${OFFER_URI}
```

Use the offer uri(e.g. the `issuer`and `nonce` fields), to retrieve the actual offer:

```shell
  export PRE_AUTHORIZED_CODE=$(curl -s -k -x localhost:8888 -X GET ${OFFER_URI} \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '.grants."urn:ietf:params:oauth:grant-type:pre-authorized_code"."pre-authorized_code"' -r); echo ${PRE_AUTHORIZED_CODE}
```

Exchange the pre-authorized code from the offer with an AccessToken at the authorization server:

```shell
  export CREDENTIAL_ACCESS_TOKEN=$(curl -s -k -x localhost:8888 -X POST https://keycloak-consumer.127.0.0.1.nip.io/realms/test-realm/protocol/openid-connect/token \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
    --data pre-authorized_code=${PRE_AUTHORIZED_CODE} | jq '.access_token' -r); echo ${CREDENTIAL_ACCESS_TOKEN}
```

Use the returned access token to get the actual credential:

```shell
  export VERIFIABLE_CREDENTIAL=$(curl -s -k -x localhost:8888 -X POST https://keycloak-consumer.127.0.0.1.nip.io/realms/test-realm/protocol/oid4vc/credential \
    --header 'Accept: */*' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}" \
    --data '{"credential_identifier":"user-credential", "format":"jwt_vc"}' | jq '.credential' -r); echo ${VERIFIABLE_CREDENTIAL}
```

You will receive a jwt-encoded credential to be used within the data space.

---


## Authenticate via OID4VP

> :warning: Those steps assume that interaction with consumer and provider already happend, e.g. a VerifiableCredential
> is available
> and policy/entity are created.

The credential needs to be presented for authentication
through [OID4VP]((https://openid.net/specs/openid-4-verifiable-presentations-1_0.html).
Every required information for that flow can be retrieved via the standard endpoints.

If you try to request the provider api without authentication, you will receive an 401:

```shell
  curl -s -X GET 'http://mp-data-service.127.0.0.1.nip.io:8080/ngsi-ld/v1/entities/urn:ngsi-ld:EnergyReport:fms-1'
```

The normal flow is now to request the oidc-information at the well-known endpoint:

```shell
  export TOKEN_ENDPOINT=$(curl -s -X GET 'http://mp-data-service.127.0.0.1.nip.io:8080/.well-known/openid-configuration' | jq -r '.token_endpoint'); echo $TOKEN_ENDPOINT
```

With that information, the authentication flow at the verifier(e.g.`"https://provider-verifier.127.0.0.1.nip.io:8443`)
can be started.
First, the credential needs to be encoded into a vp_token. If you want to do that manually, first a did and the
corresponding key-material is required.
You can create such via:

```shell
  mkdir cert
  chmod o+rw cert
  docker run -v $(pwd)/cert:/cert quay.io/wi_stefan/did-helper:0.1.1
  # unsecure, only do that for demo
  sudo chmod -R o+rw cert/private-key.pem
```

This will produce the files cert.pem, cert.pfx, private-key.pem, public-key.pem and did.json, containing all required
information for the generated did:key.
Find the did here:

```shell
  export HOLDER_DID=$(cat cert/did.json | jq '.id' -r); echo ${HOLDER_DID}
```

As a next step, a VerifiablePresentation, containing the Credential has to be created:

```shell
  export VERIFIABLE_PRESENTATION="{
    \"@context\": [\"https://www.w3.org/2018/credentials/v1\"],
    \"type\": [\"VerifiablePresentation\"],
    \"verifiableCredential\": [
        \"${VERIFIABLE_CREDENTIAL}\"
    ],
    \"holder\": \"${HOLDER_DID}\"
  }"; echo ${VERIFIABLE_PRESENTATION}
```

Now, the presentation has to be embedded into a signed JWT:

Setup the header:

```shell
  export JWT_HEADER=$(echo -n "{\"alg\":\"ES256\", \"typ\":\"JWT\", \"kid\":\"${HOLDER_DID}\"}"| base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo Header: ${JWT_HEADER}
```

Setup the payload:

```shell
  export PAYLOAD=$(echo -n "{\"iss\": \"${HOLDER_DID}\", \"sub\": \"${HOLDER_DID}\", \"vp\": ${VERIFIABLE_PRESENTATION}}" | base64 -w0 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//); echo Payload: ${PAYLOAD};   
```

Create the signature:

```shell
  export SIGNATURE=$(echo -n "${JWT_HEADER}.${PAYLOAD}" | openssl dgst -sha256 -binary -sign cert/private-key.pem | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo Signature: ${SIGNATURE}; 
```

Combine them to the JWT:

```shell
  export JWT="${JWT_HEADER}.${PAYLOAD}.${SIGNATURE}"; echo The Token: ${JWT}
```

The JWT representation of the JWT has to be Base64-encoded(no padding!):

```shell
  export VP_TOKEN=$(echo -n ${JWT} | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo ${VP_TOKEN}
```

The vp_token can then be exchanged for the access-token

```shell
  export DATA_SERVICE_ACCESS_TOKEN=$(curl -s -k -x localhost:8888 -X POST $TOKEN_ENDPOINT \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=vp_token \
    --data vp_token=${VP_TOKEN} \
    --data scope=default | jq '.access_token' -r ); echo ${DATA_SERVICE_ACCESS_TOKEN}
```

With that token, try to access the data again:

```shell
  curl -s -X GET 'http://mp-data-service.127.0.0.1.nip.io:8080/ngsi-ld/v1/entities/urn:ngsi-ld:EnergyReport:fms-1' \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer ${DATA_SERVICE_ACCESS_TOKEN}"
```
