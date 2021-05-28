group "default" {
	targets = ["alpine-latest"]
}

variable "BUILDREV" {
	default = ""
}

target "common" {
	platforms = ["linux/amd64"]
	args = {"GOCRONVER" = "v0.0.10"}
}

target "alpine" {
	inherits = ["common"]
	dockerfile = "alpine.Dockerfile"
}

target "alpine-latest" {
	inherits = ["alpine"]
	args = {"BASETAG" = "13-alpine"}
	tags = [
		"bilikdev/postgres-dump-restore-local:alpine",
		"bilikdev/postgres-dump-restore-local:13-alpine",
		notequal("", BUILDREV) ? "bilikdev/postgres-dump-restore-local:13-alpine-${BUILDREV}" : ""
	]
}
target "alpine-13" {
	inherits = ["alpine"]
	args = {"BASETAG" = "13-alpine"}
	tags = [
		"bilikdev/postgres-dump-restore-local:13-alpine",
		notequal("", BUILDREV) ? "bilikdev/postgres-dump-restore-local:13-alpine-${BUILDREV}" : ""
	]
}
