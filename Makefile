build:
	zig build

release-build:
	zig build -Doptimize=ReleaseSmall

run:
	zig run src/main.zig -- $(ARGS)

test:
	zig test src/main.zig

clean:
	rm -rf .zig-cache
