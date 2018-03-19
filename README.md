# `helm` Docker image

## BUILD

```bash
$ docker build -t helm .
```

## RUN

```bash
$ alias helm='docker run --rm -ti -v "$HOME/.kube:/home/kube/.kube:ro" -v "$HOME/.helm:/home/kube/.helm:ro" -v "$(pwd):$(pwd):ro" -w "$(pwd)" --read-only helm'
$ helm version --client --short
Client: v2.8.2+ga802316
```
