# Secure Vault System

## Overview

This project implements a secure, two-contract vault architecture where
fund withdrawals are permitted **only after explicit on-chain authorization
validation**.

The system separates:
- **Asset custody** (Vault contract)
- **Permission validation** (Authorization Manager contract)

This mirrors real-world decentralized protocol design patterns where
trust boundaries are intentionally split for security and clarity.

---

## System Architecture

The system consists of two smart contracts:

### 1. SecureVault
- Holds native blockchain currency (ETH)
- Accepts deposits from any address
- Executes withdrawals only after authorization approval
- Does **not** perform cryptographic signature verification

### 2. AuthorizationManager
- Validates withdrawal permissions
- Verifies off-chain generated authorizations
- Tracks authorization usage to prevent replay
- Ensures each authorization is consumed exactly once

The Vault relies **exclusively** on the AuthorizationManager for permission checks.

---

## Authorization Design

Withdrawal permissions are generated **off-chain** and validated **on-chain**.

Each authorization is deterministically bound to:
- Vault contract address
- Blockchain network (chain ID)
- Recipient address
- Withdrawal amount
- Unique authorization identifier (nonce)
- Cryptographic signature

This tight binding prevents misuse across:
- Different vaults
- Different networks
- Different recipients or amounts

---

## Replay Protection

Replay protection is enforced by the AuthorizationManager:

- Each authorization has a unique identifier
- Once successfully used, it is marked as **consumed**
- Any attempt to reuse the same authorization **reverts**

This guarantees:
- Exactly-once execution
- No duplicated withdrawals
- Deterministic failure on replay attempts

---

## State Safety Guarantees

The system enforces the following invariants:

- Vault balance can never become negative
- Internal state updates occur **before** value transfer
- Unauthorized callers cannot trigger privileged actions
- Initialization logic is protected against multiple execution
- Cross-contract calls cannot cause duplicated effects

---

## Events & Observability

The system emits events for:
- Deposits
- Authorization consumption
- Successful withdrawals

Failed withdrawals revert deterministically without partial state changes.

---

## Local Deployment (Dockerized)

### Prerequisites
- Docker
- Docker Compose

### Run the system
```bash
docker-compose up --build
This will:

Start a local Ganache blockchain

Deploy AuthorizationManager

Deploy SecureVault with AuthorizationManager address

Expose RPC at http://localhost:8545

Output deployed contract addresses to logs

No manual steps are required.

Testing & Validation
Automated tests demonstrate:

Successful deposits

Authorized withdrawals succeed exactly once

Invalid or replayed authorizations are rejected

Run tests locally:

bash
Copy code
npx hardhat test
Assumptions & Limitations
Authorization signing key is assumed to be securely managed off-chain

The system uses a local development blockchain (Ganache) for evaluation

No frontend is included, as it—all interactions are programmatic

Conclusion
This project demonstrates secure multi-contract design, strict authorization
enforcement, replay protection, and deterministic behavior under adversarial
conditions, following production-grade Web3 engineering practices.

