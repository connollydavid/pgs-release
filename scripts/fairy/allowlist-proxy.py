#!/usr/bin/env python
"""CONNECT-only allowlist proxy: the wrapper process's egress gate.

Permits CONNECT to the named destinations and refuses everything else,
so the review wrapper's HTTP stack can reach the LLM endpoint and
nothing else. Advisory for well-behaved clients (it works via proxy env
vars); the hard egress block for the model itself is the --internal
podman network the review containers run on.
"""
import socket
import threading

ALLOW = {("ollama.com", 443)}
LISTEN = ("127.0.0.1", 15313)


def _pipe(a: socket.socket, b: socket.socket) -> None:
    try:
        while True:
            data = a.recv(65536)
            if not data:
                break
            b.sendall(data)
    except OSError:
        pass
    finally:
        for s in (a, b):
            try:
                s.shutdown(socket.SHUT_RDWR)
            except OSError:
                pass


def _handle(conn: socket.socket) -> None:
    try:
        req = b""
        while b"\r\n\r\n" not in req:
            chunk = conn.recv(4096)
            if not chunk:
                conn.close()
                return
            req += chunk
        line = req.split(b"\r\n", 1)[0].decode("latin-1")
        parts = line.split()
        if len(parts) < 2 or parts[0] != "CONNECT":
            conn.sendall(b"HTTP/1.1 405 Method Not Allowed\r\n\r\n")
            conn.close()
            return
        host, _, port = parts[1].rpartition(":")
        target = (host, int(port))
        if target not in ALLOW:
            conn.sendall(b"HTTP/1.1 403 Forbidden (allowlist)\r\n\r\n")
            print(f"BLOCKED {parts[1]}", flush=True)
            conn.close()
            return
        upstream = socket.create_connection(target, timeout=15)
        conn.sendall(b"HTTP/1.1 200 Connection Established\r\n\r\n")
        print(f"ALLOWED {parts[1]}", flush=True)
        threading.Thread(target=_pipe, args=(conn, upstream), daemon=True).start()
        _pipe(upstream, conn)
    except Exception as exc:  # noqa: BLE001 - proxy must survive anything
        print(f"ERR {type(exc).__name__}: {exc}", flush=True)
        try:
            conn.close()
        except OSError:
            pass


def main() -> None:
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(LISTEN)
    server.listen(64)
    print(f"allowlist proxy on {LISTEN[0]}:{LISTEN[1]} permitting {sorted(ALLOW)}", flush=True)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=_handle, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    main()
