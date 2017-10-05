# Build

```
docker build . --tag="maitredede/qemupi"
```

# Compile

```
docker run --rm -it --privileged --mount type=bind,source="$(pwd)",target=/data -w /data "maitredede/qemupi" "build.sh"
```