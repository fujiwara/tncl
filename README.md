# tncl

tncl is a tiny "nc -l" implementation in [Zig](https://ziglang.org/).

## Usage

### TCP server receiving data

```console
$ tncl 1234 > /tmp/output
```

`tncl` will listen on port 1234 and write the received data to `/tmp/output`.

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

## Limitations

- Only supports TCP.
- Does not accept multiple connections.

## License

MIT
