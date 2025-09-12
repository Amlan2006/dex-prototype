# Decentralized Exchange (DEX) Prototype

A decentralized exchange prototype built on Ethereum using Solidity smart contracts. This project demonstrates core DEX functionalities including token swapping, liquidity provision, and fee collection.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Deployment](#deployment)
- [Usage](#usage)
- [Smart Contracts](#smart-contracts)
- [Testing](#testing)
- [License](#license)

## Overview

This DEX prototype implements a simplified version of a decentralized exchange with automated market making (AMM) functionality. Users can swap between two tokens (Rayverse and SonarTaka), provide liquidity to token pools, and earn fees from trades.

## Features

- **Token Swapping**: Exchange Rayverse (RAY) tokens for SonarTaka (STK) tokens and vice versa
- **Liquidity Provision**: Add or remove liquidity to token pools to earn trading fees
- **Fee Collection**: Liquidity providers can claim their share of trading fees
- **Price Calculation**: View price quotes before executing swaps
- **Liquidity Pool Management**: Monitor and manage liquidity positions

## Technology Stack

- **Solidity**: Smart contract programming language (version 0.8.20)
- **Foundry**: Ethereum development toolkit for building, testing, and deploying smart contracts
- **OpenZeppelin**: Industry-standard library for secure smart contract development
- **ERC-20**: Standard for fungible tokens on Ethereum

## Project Structure

```
.
├── script/                 # Deployment scripts
│   └── DeployDEX.s.sol     # DEX deployment script
├── src/                    # Smart contracts
│   ├── DEX.sol             # Main DEX contract with AMM functionality
│   ├── Rayverse.sol        # Rayverse (RAY) ERC-20 token
│   └── SonarTaka.sol       # SonarTaka (STK) ERC-20 token
├── lib/                    # External libraries
│   ├── forge-std           # Foundry standard library
│   └── openzeppelin-contracts # OpenZeppelin contracts
├── foundry.toml            # Foundry configuration
└── README.md               # This file
```

## Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) - Ethereum development toolkit
- [Rust](https://www.rust-lang.org/) - Required for Foundry installation

### Installation

1. Install Foundry:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Clone the repository:
   ```bash
   git clone <repository-url>
   cd dex-prototype
   ```

3. Install dependencies:
   ```bash
   forge install
   ```

## Deployment

### Local Development

1. Start a local Ethereum node:
   ```bash
   anvil
   ```

2. Deploy the contracts:
   ```bash
   forge script script/DeployDEX.s.sol:DeployDEXScript --rpc-url http://127.0.0.1:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast
   ```

### Testnet/Mainnet Deployment

Replace the RPC URL and private key with your own:
```bash
forge script script/DeployDEX.s.sol:DeployDEXScript --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

## Usage

### Building Contracts

```bash
forge build
```

### Formatting Code

```bash
forge fmt
```

### Gas Snapshots

```bash
forge snapshot
```

## Smart Contracts

### DEX.sol

The main contract implementing the decentralized exchange functionality:

- **Token Swapping**: `swapRayverseToSonarTaka()` and `swapSonarTakaToRayverse()`
- **Liquidity Management**: `addLiquidityForRayverse()`, `addLiquidityForSonarTaka()`, `removeLiquidityForRayverse()`, `removeLiquidityForSonarTaka()`
- **Fee Collection**: `recieveFeesRayverse()` and `recieveFeesSonarTaka()`
- **Price Queries**: `checkPriceRayverseToSonarTaka()` and `checkPriceSonarTakaToRayverse()`

### Rayverse.sol

ERC-20 token contract for Rayverse (RAY) token with minting functionality.

### SonarTaka.sol

ERC-20 token contract for SonarTaka (STK) token with minting functionality.

## Testing

Run the test suite:
```bash
forge test
```

Generate gas reports:
```bash
forge test --gas-report
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Additional Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Solidity Documentation](https://docs.soliditylang.org/)