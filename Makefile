build:
	zig build

release-build:
	rm -fr pkg
	mkdir -p pkg
	for target in aarch64-linux-musl x86_64-linux-musl; do \
		zig build -Doptimize=ReleaseSmall -Dtarget=$$target; \
		cp zig-out/bin/tncl pkg/tncl-$$target; \
	done

run:
	zig run src/main.zig -- $(ARGS)

test:
	zig test src/main.zig

clean:
	rm -rf .zig-cache pkg/
