# Envtester snap

This snap is a PoC for the `env-exporter` program.

`env-exporter` is a program that can dynamically load snap options into environment variables

To build it:

- For all architectures (`amd64`, `arm64` and `riscv64`)
```bash
snapcraft -v
```

- For `amd64`:
```bash
snapcraft -v --build-for=amd64
```

- For `arm64`:
```bash
snapcraft -v --build-for=arm64
```

- For `riscv64`
```bash
snapcraft -v --build-for=riscv64
```
