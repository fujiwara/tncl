build:
	zig build -Doptimize=ReleaseSmall

run:
	zig run src/main.zig

test:
	zig test src/main.zig
