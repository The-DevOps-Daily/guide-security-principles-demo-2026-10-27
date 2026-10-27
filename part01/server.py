"""Stand-in for the ticket shop API: just enough HTTP to show probes and policies."""

import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

DB = (os.environ.get('DB_HOST', 'postgres'), int(os.environ.get('DB_PORT', '5432')))


def database_reachable():
    try:
        with socket.create_connection(DB, timeout=1):
            return True
    except OSError:
        return False


class Handler(BaseHTTPRequestHandler):
    def reply(self, code, text):
        body = (text + '\n').encode()
        self.send_response(code)
        self.send_header('Content-Type', 'text/plain')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == '/healthz':  # liveness: can this process still answer at all?
            self.reply(200, 'ok')
        elif self.path == '/readyz':  # readiness: can it serve real requests right now?
            if database_reachable():
                self.reply(200, 'ready')
            else:
                self.reply(503, 'database unreachable')
        else:
            self.reply(200, f'api {socket.gethostname()}: {self.command} {self.path}')

    do_POST = do_GET

    def log_message(self, *args):
        pass


ThreadingHTTPServer(('', 8080), Handler).serve_forever()
