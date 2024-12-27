# Chaincode

This is the term used in Hyperledger Fabric for the smart contracts that define the business logic of an application. It runs on the peer nodes of the blockchain network and interacts with the ledger database to query or modify its state.

## Chaincode V1 vs V2

| **Aspect**                  | **Fabric v1.x (Shim API)**                                           | **Fabric v2.x (Contract API)**                                       |
|-----------------------------|--------------------------------------------------------------------|----------------------------------------------------------------------|
| **Core Methods**            | Requires `Init` and `Invoke` methods.                             | Does not require `Init` or `Invoke`. Uses modular transaction functions. |
| **Method Routing**          | Developer manually routes logic within `Invoke` method.           | Automatic routing to defined transaction functions by Fabric runtime. |
| **API**                     | Uses **shim API** (`shim.ChaincodeStubInterface`).                | Uses **Contract API** (`contractapi.TransactionContextInterface`).    |
| **Transaction Functions**   | Logic is split manually into helper functions called by `Invoke`. | Each business logic operation is a separate transaction function.    |
| **Initialization**          | Performed in `Init` method during chaincode instantiation.         | Handled by a transaction function (e.g., `InitLedger`).              |
| **Function Registration**   | No explicit registration; functions are routed via `Invoke`.       | Transaction functions are defined and discovered automatically.       |
| **Error Handling**          | Return responses (`shim.Success` or `shim.Error`) explicitly.     | Uses Go `error` type for error handling, improving readability.      |
| **Serialization**           | Developer manages serialization (e.g., using JSON encoding).      | Same approach, but simplified by modern Go libraries.                |
| **State Queries**           | Performed using `stub` methods like `GetState`, `PutState`.       | Similar, but integrated with the Contract API’s context.             |
| **Development Simplicity**  | Requires more boilerplate for method routing and setup.           | Simplified setup with clear modularity and abstraction.              |

Fabric V1.x (Shim API)

```go
func (cc *SmartContract) Init(stub shim.ChaincodeStubInterface) pb.Response {
    // Initialization logic here
    return shim.Success(nil)
}

func (cc *SmartContract) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
    function, args := stub.GetFunctionAndParameters()
    if function == "createAsset" {
        return cc.createAsset(stub, args)
    } else if function == "readAsset" {
        return cc.readAsset(stub, args)
    }
    return shim.Error("Invalid function name.")
}
```

Fabric v2.x (Contract API)

```go
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    // Initialization logic here
    return nil
}

func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id, name string) error {
    // Business logic here
    return nil
}

func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
    // Business logic here
    return nil, nil
}
```

## Development Lifecycle

1. **Development**
    * Write the chaincode using a supported language.
    * Chaincode must define two key functions:
        * **Init**: Invoked during deployment to perform initialization tasks.
        * **Invoke**: Handles transaction logic during runtime.

2. **Package** the chaincode into a format that Hyperledger Fabric can deploy, such as a .tar.gz file.

3. **Install** the chaincode on the endorsing peers.

4. **Approval**: Organizations in the network must approve the chaincode definition.

5. **Commit** the chaincode to the channel, making it available for execution.

6. **Execution**: Once committed, the chaincode can be invoked via client applications.

## Simple Chaincode

For v2

```go
package main

import (
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// Asset represents an asset stored in the ledger
type Asset struct {
	ID       string  `json:"id"`
	Owner    string  `json:"owner"`
	Value    float64 `json:"value"`
}


// SmartContract provides functions for managing assets
type SmartContract struct {
	contractapi.Contract
}

// InitLedger initializes the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	assets := []Asset{
		{ID: "asset1", Owner: "John", Value: 100},
		{ID: "asset2", Owner: "Alice", Value: 200},
	}
	for _, asset := range assets {
		assetJSON, _ := json.Marshal(asset)
		err := ctx.GetStub().PutState(asset.ID, assetJSON)
		if err != nil {
			return fmt.Errorf("Failed to initialize ledger: %v", err)
		}
	}
	return nil
}

// QueryAsset returns an asset
func (s *SmartContract) QueryAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("Failed to read asset: %v", err)
	}
	var asset Asset
	_ = json.Unmarshal(assetJSON, &asset)
	return &asset, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating chaincode: %s", err)
		return
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincode: %s", err)
	}
}
```

1. `InitLedger`: Initializes the ledger with some sample data.
2.	`QueryAsset`: Queries the world state for an asset by its ID.
3.	`PutState` and `GetState`: These are the core methods used to interact with the world state.

