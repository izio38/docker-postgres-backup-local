#!/bin/sh

set -e

DOCKER_BAKE_FILE=${1:-"docker-bake.hcl"}
TAGS=${TAGS:-"13"}
GOCRONVER=${GOCRONVER:-"v0.0.10"}
PLATFORMS=${PLATFORMS:-"linux/amd64"}
IMAGE_NAME=${IMAGE_NAME:-"bilikdev/postgres-dump-backup-local"}

cd "$(dirname "$0")"

MAIN_TAG=${TAGS%%" "*} # First tag
TAGS_EXTRA=${TAGS#*" "} # Rest of tags
P="\"$(echo $PLATFORMS | sed 's/ /", "/g')\""

T="\"alpine-latest\""

cat > "$DOCKER_BAKE_FILE" << EOF
group "default" {
	targets = [$T]
}

variable "BUILDREV" {
	default = ""
}

target "common" {
	platforms = [$P]
	args = {"GOCRONVER" = "$GOCRONVER"}
}

target "alpine" {
	inherits = ["common"]
	dockerfile = "alpine.Dockerfile"
}

target "alpine-latest" {
	inherits = ["alpine"]
	args = {"BASETAG" = "$MAIN_TAG-alpine"}
	tags = [
		"$IMAGE_NAME:alpine",
		"$IMAGE_NAME:$MAIN_TAG-alpine",
		notequal("", BUILDREV) ? "$IMAGE_NAME:$MAIN_TAG-alpine-\${BUILDREV}" : ""
	]
}
EOF

for TAG in $TAGS_EXTRA; do cat >> "$DOCKER_BAKE_FILE" << EOF
target "alpine-$TAG" {
	inherits = ["alpine"]
	args = {"BASETAG" = "$TAG-alpine"}
	tags = [
		"$IMAGE_NAME:$TAG-alpine",
		notequal("", BUILDREV) ? "$IMAGE_NAME:$TAG-alpine-\${BUILDREV}" : ""
	]
}
EOF
done
