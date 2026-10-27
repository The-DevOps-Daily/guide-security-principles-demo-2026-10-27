"""Print the claims of a JWT. Only the payload is decoded; the signature is not checked."""

import base64
import json
import sys

payload = open(sys.argv[1]).read().strip().split('.')[1]
print(json.dumps(json.loads(base64.urlsafe_b64decode(payload + '=' * (-len(payload) % 4))), indent=2))
