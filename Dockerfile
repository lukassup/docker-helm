FROM golang:1.10 as kube-build

ENV KUBE_VERSION=v1.9.5

RUN apt-get update && apt-get install -y rsync

RUN mkdir -p src/k8s.io/kubernetes && \
    cd src/k8s.io/kubernetes && \
    git clone --depth=1 --branch="${KUBE_VERSION}" https://github.com/kubernetes/kubernetes.git . && \
    export GOOS=linux GOARCH=amd64 CGO_ENABLED=0 && \
    make clean && \
    KUBE_BUILD_PLATFORMS=linux/amd64 make WHAT=cmd/kubectl

FROM golang:1.10 as helm-build

ENV HELM_VERSION=v2.8.2

RUN mkdir -p src/k8s.io/helm && \
    cd src/k8s.io/helm && \
    git clone --depth=1 --branch="${HELM_VERSION}" https://github.com/kubernetes/helm.git . && \
    export GOOS=linux GOARCH=amd64 CGO_ENABLED=0 && \
    make TARGETS=linux/amd64 BINARIES=helm bootstrap build

FROM alpine:3.7

RUN apk add --no-cache ca-certificates

COPY --from=helm-build /go/src/k8s.io/helm/bin/helm /usr/local/bin/helm
COPY --from=kube-build /go/src/k8s.io/kubernetes/_output/local/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN adduser kube -D

USER kube

WORKDIR kube

VOLUME /home/kube/.kube

VOLUME /home/kube/.helm

ENTRYPOINT ["/usr/local/bin/helm"]
