package gripmock_sdk_go

import (
	"bytes"
	"encoding/json"
)

func jsonUnmarshal(data []byte, v any) error {
	decoder := json.NewDecoder(bytes.NewReader(data))
	decoder.UseNumber()

	if err := decoder.Decode(&v); err != nil {
		return err
	}

	return nil
}
