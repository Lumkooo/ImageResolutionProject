from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer

class Server(BaseHTTPRequestHandler):
    def run(server_class=HTTPServer):
        serverPort = 8080
        server_address = ('', serverPort)
        httpd = server_class(server_address, Server)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            httpd.server_close()

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write('<html><head><meta charset="utf-8">'.encode())
        self.wfile.write('<title>Простой HTTP-сервер.</title></head>'.encode())
        self.wfile.write('<body>Был получен GET-запрос.</body></html>'.encode())
