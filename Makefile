OPENAPI=https://raw.githubusercontent.com/bavix/gripmock-openapi/master/api.yaml

.PHONY: *

gen:
	go run github.com/deepmap/oapi-codegen/v2/cmd/oapi-codegen@latest -generate client,types -package gripmock_sdk_go ${OPENAPI} | sed 's/json\.Unmarshal/jsonUnmarshal/g' > api.gen.go
