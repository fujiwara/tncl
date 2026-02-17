# tncl

tncl is a tiny "nc -l" implementation in [Zig](https://ziglang.org/).

## Usage

```
tncl <port>
tncl <addr:port>
```

If only a port number is given, `tncl` listens on `0.0.0.0` (all interfaces). You can also specify a bind address explicitly.

### TCP server receiving data

```console
$ tncl 1234 > /tmp/output
$ tncl 127.0.0.1:1234 > /tmp/output
```

`tncl` will listen on the specified address/port and write the received data to `/tmp/output`.

When the client disconnects, `tncl` will exit.

### TCP server sending data

```console
$ cat /tmp/input | tncl 1234
```
or

```console
$ tncl 1234 < /tmp/input
```

`tncl` will listen on port 1234 and send the data from `/tmp/input` to the client.

When the all data is sent, `tncl` will close the connection and exit.

## Notes

`tncl` exits with status 0 when the client disconnects OR the stdin is closed.

## Limitations

- Only supports TCP.
- Does not accept multiple connections.

## License

MIT
