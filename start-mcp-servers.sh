#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_DIR="$ROOT_DIR/.mcp-pids"
LOG_DIR="$ROOT_DIR/.mcp-logs"
PYTHON_BIN="$ROOT_DIR/.venv/bin/python"

if [[ ! -x "$PYTHON_BIN" ]]; then
    PYTHON_BIN="python3"
fi

mkdir -p "$PID_DIR" "$LOG_DIR"

start_server() {
    local name="$1"
    local script="$2"
    local pid_file="$PID_DIR/$name.pid"
    local log_file="$LOG_DIR/$name.log"

    if [[ -f "$pid_file" ]]; then
        local existing_pid
        existing_pid="$(cat "$pid_file")"
        if kill -0 "$existing_pid" 2>/dev/null; then
            echo "$name server is already running with PID $existing_pid"
            return
        fi
        rm -f "$pid_file"
    fi

    echo "Starting $name server..."
    (
        cd "$ROOT_DIR"
        setsid "$PYTHON_BIN" "$script" >"$log_file" 2>&1 < /dev/null &
        echo "$!"
    ) >"$pid_file"

    local pid
    pid="$(cat "$pid_file")"

    sleep 1
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "$name server failed to start; see logs: $log_file" >&2
        rm -f "$pid_file"
        return 1
    fi

    echo "$name server started with PID $pid; logs: $log_file"
}

start_server "weather" "servers/weather_server.py"
start_server "math" "servers/math_server.py"

echo "MCP servers started."
