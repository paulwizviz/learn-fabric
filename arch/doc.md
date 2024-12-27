# Architecture

This section covers aspects of Hyperledger Fabric Architecture.

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

## Transaction Flow

Here’s how a typical transaction in Hyperledger Fabric works:

STEP 1 **Proposal Creation**: A client sends a transaction proposal to endorsing peers.

STEP 2 **Endorsement**: Endorsing peers execute the chaincode and sign the results, sending the endorsement back to the client.

STEP 3 **Transaction Submission**: The client submits the endorsed transaction to the ordering service.

STEP 4 **Ordering and Block Creation**: The ordering service sequences transactions and creates blocks.

STEP 5 **Validation and Commitment**: Peers validate transactions (ensuring they adhere to endorsement policies) and then commit them to the ledger.