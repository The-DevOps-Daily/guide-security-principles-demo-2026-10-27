"""Stand-in for the ticket shop worker: loads its credential, reports, and waits for jobs."""

import os
import pathlib
import time

creds = os.environ.get('CREDENTIALS_DIRECTORY')
password = pathlib.Path(creds, 'db-password').read_text().strip() if creds else None
print(f'worker running as uid {os.getuid()}; db password loaded: {password is not None}', flush=True)
while True:
    time.sleep(60)
