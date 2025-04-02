# gripmock-sdk-go

Go client library for interacting with the [GripMock API](https://bavix.github.io/gripmock-openapi/), generated from OpenAPI specification. Simplifies programmatic management of gRPC mock stubs and service health checks.

## Installation

```bash
go get github.com/bavix/gripmock-sdk-go
```

## Initialization

```go
import "github.com/bavix/gripmock-sdk-go"

client, err := gripmock_sdk_go.NewClient("http://localhost:4771",
    gripmock_sdk_go.WithHTTPClient(http.DefaultClient),
)
if err != nil {
    log.Fatal(err)
}
```

## Core Features

### Health Checks
Verify server status:
```go
// Check liveness
livenessResp, _ := client.LivenessWithResponse(context.Background())
fmt.Println("Liveness:", livenessResp.JSON200.Message)

// Check readiness
readinessResp, _ := client.ReadinessWithResponse(context.Background())
fmt.Println("Readiness:", readinessResp.JSON200.Message)
```

### Service Discovery
List available services and methods:
```go
// Get all services
servicesResp, _ := client.ServicesListWithResponse(context.Background())
for _, svc := range *servicesResp.JSON200 {
    fmt.Printf("Service: %s (%s)\n", svc.Name, svc.Package)
    
    // Get service methods
    methodsResp, _ := client.ServiceMethodsListWithResponse(context.Background(), svc.Id)
    for _, method := range *methodsResp.JSON200 {
        fmt.Printf("  - %s\n", method.Name)
    }
}
```

### Stub Management

#### Create Stub
```go
stub := gripmock_sdk_go.Stub{
    Service: "YourService",
    Method:  "YourMethod",
    Input: gripmock_sdk_go.StubInput{
        Equals: map[string]interface{}{
            "key": "expected_value",
        },
    },
    Output: gripmock_sdk_go.StubOutput{
        Data: map[string]interface{}{
            "response_key": "mock_value",
        },
        Code: (*codes.Code)(proto.Int32(int32(codes.OK))),
    },
}

resp, _ := client.AddStubWithResponse(context.Background(), stub)
fmt.Println("Created stub ID:", resp.HTTPResponse.Header.Get("Stub-Id"))
```

#### List Stubs
```go
stubsResp, _ := client.ListStubsWithResponse(context.Background())
for _, stub := range *stubsResp.JSON200 {
    fmt.Printf("Stub: %s | %s.%s\n", stub.Id, stub.Service, stub.Method)
}
```

#### Find Stub by ID
```go
stubID := "a1b2c3d4-e5f6-7890-g1h2-i3j4k5l6m7n8"
resp, _ := client.FindByIDWithResponse(context.Background(), stubID)
if resp.JSON200 != nil {
    fmt.Printf("Found stub: %+v\n", resp.JSON200)
}
```

#### Delete Stub
```go
deleteResp, _ := client.DeleteStubByIDWithResponse(context.Background(), stubID)
if deleteResp.StatusCode() == http.StatusOK {
    fmt.Println("Stub deleted successfully")
}
```

### Advanced Operations

#### Batch Delete
```go
ids := []gripmock_sdk_go.ID{"id1", "id2"}
client.BatchStubsDeleteWithResponse(context.Background(), ids)
```

#### Search Stubs
```go
searchReq := gripmock_sdk_go.SearchStubsJSONRequestBody{
    Service: "YourService",
    Method:  "YourMethod",
    Data: map[string]interface{}{
        "search_key": "value",
    },
}

resultsResp, _ := client.SearchStubsWithResponse(context.Background(), searchReq)
for _, result := range resultsResp.JSON200.Data {
    fmt.Printf("Match: %+v\n", result)
}
```

#### Purge All Stubs
```go
client.PurgeStubsWithResponse(context.Background())
```

## Configuration Options

### Custom HTTP Client
```go
httpClient := &http.Client{
    Timeout: 10 * time.Second,
}

client, _ = gripmock_sdk_go.NewClient("http://localhost:4771",
    gripmock_sdk_go.WithHTTPClient(httpClient),
)
```

### Request Interceptors
Add authentication headers:
```go
authMiddleware := func(ctx context.Context, req *http.Request) error {
    req.Header.Add("Authorization", "Bearer YOUR_TOKEN")
    return nil
}

client, _ = gripmock_sdk_go.NewClient("http://localhost:4771",
    gripmock_sdk_go.WithRequestEditorFn(authMiddleware),
)
```

## Error Handling
```go
resp, err := client.FindByIDWithResponse(context.Background(), "invalid-id")
if err != nil {
    log.Fatal("Request failed:", err)
}

if resp.StatusCode() == http.StatusNotFound {
    fmt.Println("Stub not found")
} else if resp.StatusCode() >= 400 {
    fmt.Printf("Error: %s\n", string(resp.Body))
}
```

## Response Handling
Structured data access example:
```go
searchResp, _ := client.SearchStubsWithResponse(context.Background(), searchReq)
if searchResp.JSON200 != nil {
    fmt.Printf("Found %d matches\n", len(searchResp.JSON200.Data))
    for _, item := range searchResp.JSON200.Data {
        fmt.Printf("Response data: %+v\n", item)
    }
}
```

## Documentation
- [GripMock API Reference](https://bavix.github.io/gripmock-openapi/)
- [GripMock Documentation](https://bavix.github.io/gripmock/)

## License
This project is licensed under the [Apache License 2.0](https://github.com/bavix/gripmock/blob/master/LICENSE)
