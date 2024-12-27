# Architecture

This section covers aspects of Hyperledger Fabric Architecture.

## Version 1 vs Version 2

| **Aspect**               | **Fabric v1.x**                              | **Fabric v2.x**                              |
|--------------------------|---------------------------------------------|---------------------------------------------|
| **Chaincode Lifecycle**  | Centralised, single admin deploys and instantiates. | Decentralised, each organisation approves chaincode definitions independently. |
| **Chaincode API**        | Uses the **shim API** with `Init` and `Invoke` methods. | Uses the **Contract API**, modular with automatic routing for transaction functions. |
| **Private Data**         | Basic support for private data collections. | Enhanced with **state-based endorsement** and key-level policies. |
| **Governance**           | Implicit trust for chaincode by all organisations. | Organisations approve chaincode individually before deployment. |
| **Performance**          | Limited optimisations for transaction processing. | Improved peer transaction processing and scalability for larger networks. |
| **Development Model**    | Manual method routing and configuration management. | Easier programming with better SDKs and tools for debugging. |
| **Docker Dependency**    | Chaincode executes in Docker containers.     | Supports **external chaincode launchers**, enabling execution outside Docker. |
| **Endorsement Policies** | Static endorsement policies for transactions. | Supports dynamic and key-level endorsement policies. |
| **Security**             | Limited controls for independent chaincode approval. | Better security with decentralised approval processes. |
| **Ledger Updates**       | Static endorsement for ledger updates.       | Allows dynamic endorsement and key-level endorsements. |


## Key Components

* **Peers** - Nodes that maintain the ledger and execute smart contracts. They can be:
    * **Endorsing Peers**: Execute chaincode to validate transactions.
    * **Committing Peers**: Validate and commit transactions to the ledger.

* **Orderer (Ordering Service)**: Ensures the proper sequencing of transactions in the blockchain. Common implementations include:
	•	Kafka-based consensus
	•	Raft consensus

* **Ledger**: A tamper-proof, append-only database that stores the blockchain. It has two parts:
    * Blockchain: The immutable record of all transactions.
    * State Database (World State): Represents the current state of the ledger.

* **Membership Service Provider (MSP)**: Manages identities and access control in the network. MSP issues digital certificates via a CA (Certificate Authority).

* **Channel**: A private “sub-network” within the blockchain network, allowing specific participants to have their own communication and ledger.

## Ordering Service

| **Aspect**                  | **Fabric v1.x**                                               | **Fabric v2.x**                                               |
|-----------------------------|-------------------------------------------------------------|-------------------------------------------------------------|
| **Consensus Mechanism**     | Focused on **Solo**, **Kafka**, and **Raft**.                | Transitioned to **Raft** as the primary mechanism; Kafka is deprecated. |
| **Solo Ordering Service**   | Supported for testing and development but not production.    | Solo ordering service remains for testing but is discouraged for all environments. |
| **Kafka Ordering Service**  | Supported for production environments but complex to manage. | Deprecated in favor of Raft due to Kafka’s operational complexity. |
| **Raft Ordering Service**   | Introduced as a **production-ready option** in later 1.x.    | Raft is the default and only supported production ordering service in v2.x. |
| **Fault Tolerance**         | Kafka required an external Zookeeper service for fault tolerance. | Raft is **built-in**, simpler to configure, and provides better fault tolerance. |
| **Ease of Management**      | Kafka setup is complex and requires additional expertise.    | Raft offers a **simpler configuration** and easier management. |
| **Dynamic Membership**      | Kafka requires stopping the ordering service to add/remove nodes. | Raft supports **dynamic reconfiguration**, allowing nodes to be added or removed without downtime. |
| **State Maintenance**       | Kafka depends on external services for replication and state. | Raft maintains state internally, simplifying operations. |
| **Performance**             | Kafka provides high throughput but at the cost of complexity. | Raft delivers high performance while being easier to deploy and manage. |
| **Operational Complexity**  | Kafka demands expertise in Kafka/Zookeeper.                  | Raft is integrated into Fabric, reducing operational overhead. |
| **Future Support**          | Kafka is deprecated; no new features or bug fixes.           | Raft is actively maintained and enhanced in newer versions. |


## Transaction Flow

Here’s how a typical transaction in Hyperledger Fabric works:

STEP 1 **Proposal Creation**: A client sends a transaction proposal to endorsing peers.

STEP 2 **Endorsement**: Endorsing peers execute the chaincode and sign the results, sending the endorsement back to the client.

STEP 3 **Transaction Submission**: The client submits the endorsed transaction to the ordering service.

STEP 4 **Ordering and Block Creation**: The ordering service sequences transactions and creates blocks.

STEP 5 **Validation and Commitment**: Peers validate transactions (ensuring they adhere to endorsement policies) and then commit them to the ledger.