# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tncl is a tiny implementation of `nc -l` (netcat listen mode) written in Zig. It listens on a TCP address/port, pipes received data to stdout, and sends stdin to the connected client. Accepts `port` or `addr:port` as argument. Single connection only.

## Build Commands

```bash
make build          # zig build
make test           # zig test src/main.zig
make run ARGS="8080" # zig run src/main.zig -- <args>
make release-build  # cross-compile for aarch64-linux-musl and x86_64-linux-musl
make clean          # remove .zig-cache and pkg/
```

Zig version: 0.14.0 (managed via mise)

## Architecture

Single-file program (`src/main.zig`, ~75 lines). Uses two threads for bidirectional communication:

- `main()` — parses address from args, starts TCP server, accepts one client, spawns sender/receiver threads
- `sender()` — reads stdin → writes to client stream
- `reciever()` — reads client stream → writes to stdout

Either side closing the connection triggers `std.process.exit(0)`.

## Release Process

Uses [tagpr](https://github.com/Songmu/tagpr) for automated releases on the main branch. GitHub Actions handles test/build on push/PR and release binary uploads via ghr.
