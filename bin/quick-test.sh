#!/bin/bash

set -e

http --session account POST http://www.app.local/api/v2/account/identity/sessions email='admin@nagaexchange.id' password='0lDHd9ufs9t@'
http --session account GET http://www.app.local/api/v2/account/resource/users/me
http --session account GET http://www.app.local/api/v2/exchange/account/balances
