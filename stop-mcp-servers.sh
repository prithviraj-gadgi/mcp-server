#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_DIR="$ROOT_DIR/.mcp-pids"

stop_server() {
    local name="$1"
    local pid_file="$PID_DIR/$name.pid"

    if [[ ! -f "$pid_file" ]]; then
        echo "$name server is not running; no PID file found"
        return
    fi

    local pid
    pid="$(cat "$pid_file")"

    if kill -0 "$pid" 2>/dev/null; then
        echo "Stopping $name server with PID $pid..."
        kill "$pid"

        for _ in {1..20}; do
            if ! kill -0 "$pid" 2>/dev/null; then
                break
            fi
            sleep 0.1
        done

        if kill -0 "$pid" 2>/dev/null; then
            echo "$name server did not stop after SIGTERM; sending SIGKILL"
            kill -9 "$pid"
        fi

        echo "$name server stopped"
    else
        echo "$name server PID $pid is not running"
    fi

    rm -f "$pid_file"
}

stop_server "weather"
stop_server "math"

echo "MCP servers stopped."
