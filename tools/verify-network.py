"""Exercise an authored TAB world over its real loopback MUDSocket."""
import os
import re
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path

root, fennel, starting_room, thing, description, direction, destination = sys.argv[1:]
root = Path(root).resolve()


def listen_address(server, log):
    for _ in range(200):
        output = log.read_text(errors="replace")
        match = re.search(r"^TAB listening on 127\.0\.0\.1:(\d+)$", output, re.M)
        if match:
            return "127.0.0.1", int(match[1])
        if server.poll() is not None:
            raise RuntimeError(output)
        time.sleep(0.05)
    raise TimeoutError("The authored MUD server did not listen")


def read_prompt(connection):
    data = bytearray()
    while not data.endswith(b"\n> "):
        chunk = connection.recv(4096)
        if not chunk:
            raise EOFError(data.decode())
        data.extend(chunk)
    return data.decode()


def play(address, moves):
    with socket.create_connection(address, timeout=5) as connection:
        greeting = read_prompt(connection)
        assert "commands, look, move, and quit" in greeting, greeting
        for command, expected in moves:
            connection.sendall((command + "\n").encode())
            actual = read_prompt(connection)
            assert expected in actual, (command, expected, actual)
        connection.sendall(b"quit\n")
        assert "Quitting now" in read_prompt(connection)
        assert connection.recv(1) == b""


with tempfile.TemporaryDirectory(prefix="tab-play-") as temp:
    log = Path(temp) / "server.log"
    with log.open("wb") as out:
        server = subprocess.Popen(
            [fennel, "--add-fennel-path", str(root / "?.fnl"), str(root / "tools/serve-world.fnl")],
            env={**os.environ, "TAB_ROOT": str(root), "TAB_PORT": "0"},
            stdout=out, stderr=subprocess.STDOUT,
        )
    try:
        address = listen_address(server, log)
        play(address, [("look", starting_room), ("look " + thing, description), ("move " + direction, destination)])
        play(address, [("look", starting_room)])
    finally:
        server.terminate()
        server.wait(timeout=5)
print(f"TCP visitor inspected {thing}, moved to {destination}, quit and rejoined at {starting_room}.")
