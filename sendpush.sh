#!/bin/bash

# How to use
#
# ./sendpush { device token }

# Properties
deviceToken={ token of your ios device }
authKey={ p8 file path }
authKeyId={ auth key id }
teamId={ your developer account team id }
bundleId={ your specified bundle id for payload viewer }
endpoint={ https://api.development.push.apple.com or https://api.push.apple.com }

# Create payload
read -r -d '' payload <<-'EOF'
{
   "aps": {
      "badge": 2,
      "alert": {
         "title": "my title",
         "subtitle": "my subtitle",
         "body": "my body text message"
      }
   },
   "custom": {
      "mykey": "myvalue"
   }
}
EOF

# --------------------------------------------------------------------------

base64() {
   openssl base64 -e -A | tr -- '+/' '-_' | tr -d =
}

sign() {
   printf "$1" | openssl dgst -binary -sha256 -sign "$authKey" | base64
}

# Create JWT
time=$(date +%s)
header=$(printf '{ "alg": "ES256", "kid": "%s" }' "$authKeyId" | base64)
claims=$(printf '{ "iss": "%s", "iat": %d }' "$teamId" "$time" | base64)
jwt="$header.$claims.$(sign $header.$claims)"

# Call API
curl --verbose \
   --header "content-type: application/json" \
   --header "authorization: bearer $jwt" \
   --header "apns-topic: $bundleId" \
   --header "apns-priority: 10" \
   --header "apns-push-type: alert" \
   --data "$payload" \
   $endpoint/3/device/$deviceToken
