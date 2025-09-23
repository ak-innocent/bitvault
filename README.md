# BitVault Protocol

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Clarity](https://img.shields.io/badge/Language-Clarity-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Blockchain-Stacks-orange.svg)](https://stacks.org/)

> **Decentralized Bitcoin Layer 2 Lending Platform**

BitVault is a cutting-edge DeFi lending protocol built natively on the Stacks blockchain, bringing sophisticated financial primitives to Bitcoin's Layer 2 ecosystem. The protocol enables users to unlock liquidity from their STX holdings through over-collateralized lending positions.

## 🎯 Core Features

- **Capital-Efficient STX Collateralization** - Maximize your capital efficiency while maintaining protocol security
- **Automated Liquidation Engine** - Autonomous liquidation system protects protocol solvency
- **Dynamic Risk Management** - Configurable parameters adapt to market conditions
- **Bitcoin-Native Security** - Inherits Bitcoin's security through Stacks consensus
- **Zero-Counterparty Risk** - Fully automated smart contract execution

## 🏗️ Architecture Overview

BitVault implements a sophisticated lending protocol with the following key components:

### Core Contracts

- **BitVault Core** (`bitvault.clar`) - Main lending protocol implementation

### Key Data Structures

- **Lending Positions** - Individual loan tracking with comprehensive metadata
- **Account Portfolios** - Aggregated user position summaries
- **Protocol Metrics** - System-wide health and utilization statistics

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development toolkit
- [Node.js](https://nodejs.org/) v16+ for testing framework
- [TypeScript](https://www.typescriptlang.org/) knowledge for test development

### Installation

```bash
# Clone the repository
git clone https://github.com/ak-innocent/bitvault.git
cd bitvault

# Install dependencies
npm install

# Check contract syntax
clarinet check

# Run comprehensive test suite
npm test
```

### Development Environment

```bash
# Start local development blockchain
clarinet integrate

# Deploy contracts to local testnet
clarinet deploy --testnet

# Format code according to Clarity standards
clarinet fmt --in-place
```

## 📊 Protocol Mechanics

### Collateralization System

BitVault operates on an over-collateralized lending model:

- **Minimum Collateral Ratio**: 150% (configurable by governance)
- **Liquidation Threshold**: 130% (configurable by governance)
- **Maximum Collateral Ratio**: 500% (hard-coded safety limit)

### Risk Parameters

| Parameter | Default Value | Range | Description |
|-----------|---------------|-------|-------------|
| Collateral Requirement | 150% | 110% - 500% | Minimum collateralization ratio |
| Liquidation Boundary | 130% | 110% - Collateral Requirement | Health factor threshold |
| Protocol Fee | 1% | 0% - 10% | Treasury fee for sustainability |

## 🔧 Core Functions

### User Operations

#### Deposit Collateral

```clarity
(define-public (deposit-collateral))
```

Locks user's entire STX balance as collateral for future borrowing.

#### Borrow STX

```clarity
(define-public (borrow-stx (requested-amount uint)))
```

Enables users to borrow STX against their deposited collateral while maintaining healthy collateralization.

#### Repay Debt

```clarity
(define-public (repay-debt (repayment-amount uint)))
```

Allows users to repay borrowed STX and improve their health factor.

#### Withdraw Collateral

```clarity
(define-public (withdraw-collateral (withdrawal-amount uint)))
```

Enables users to withdraw excess collateral while maintaining minimum health factor.

### Liquidation System

#### Liquidate Position

```clarity
(define-public (liquidate-position (target-account principal)))
```

Allows third parties to liquidate unhealthy positions, earning the collateral as reward.

### Data Queries

#### Get Account Portfolio

```clarity
(define-read-only (get-account-portfolio (account principal)))
```

Returns comprehensive view of user's lending position and exposure.

#### Get Protocol Metrics

```clarity
(define-read-only (get-protocol-metrics))
```

Provides system-wide metrics for protocol monitoring and risk assessment.

#### Calculate Position Health

```clarity
(define-read-only (calculate-position-health (account principal)))
```

Real-time risk assessment utility for any account's lending position.

## 🛡️ Security Features

### Access Control

- **Protocol Owner**: Immutable contract authority set at deployment
- **Self-Liquidation Protection**: Users cannot liquidate their own positions
- **Parameter Bounds**: All governance parameters have hard-coded safety limits

### Risk Management

- **Health Factor Monitoring**: Continuous position health assessment
- **Automated Liquidation**: Immediate liquidation when positions fall below threshold
- **Collateral Safety Checks**: All operations verify position health before execution

### Error Handling

Comprehensive error registry with descriptive error codes:

- `E_UNAUTHORIZED_ACCESS` (100): Access control violations
- `E_COLLATERAL_INSUFFICIENT` (101): Insufficient collateral for operation
- `E_AMOUNT_INVALID` (102): Invalid amount parameters
- `E_POSITION_NOT_FOUND` (103): Position lookup failures
- `E_LIQUIDATION_UNAVAILABLE` (106): Liquidation conditions not met
- `E_PARAMETER_OUT_OF_BOUNDS` (107): Governance parameter violations

## 🧪 Testing

The protocol includes a comprehensive test suite covering:

- **Unit Tests**: Individual function validation
- **Integration Tests**: End-to-end workflow testing
- **Edge Cases**: Boundary condition testing
- **Security Tests**: Attack vector validation

```bash
# Run all tests
npm test

# Run specific test file
npm test -- bitvault.test.ts

# Run tests with coverage
npm run test:coverage
```

## 📈 Economic Model

### Utilization Rate

```text
Utilization Rate = (Total Debt / Total Collateral) × 100
```

### Health Ratio Calculation

```text
Health Ratio = (Collateral Value / Outstanding Debt) × 100
```

### Liquidation Mechanics

- **Liquidator Reward**: 100% of collateral (full liquidation model)
- **Liquidation Trigger**: Health ratio below liquidation boundary
- **Protocol Protection**: Immediate debt removal upon liquidation

## 🏛️ Governance

### Parameter Updates

The protocol owner can adjust key parameters within safe bounds:

#### Update Collateral Requirement

```clarity
(define-public (update-collateral-requirement (new-ratio uint)))
```

#### Update Liquidation Boundary

```clarity
(define-public (update-liquidation-boundary (new-threshold uint)))
```

#### Update Protocol Fee

```clarity
(define-public (update-protocol-fee (new-fee-rate uint)))
```

All governance actions emit events for transparency and monitoring.

## 🔍 Monitoring & Analytics

### Key Metrics to Monitor

- **Total Value Locked (TVL)**: `aggregate-collateral`
- **Total Borrowed**: `aggregate-debt`
- **Utilization Rate**: Debt-to-collateral ratio
- **Average Health Factor**: Protocol-wide position health
- **Liquidation Events**: Frequency and volume of liquidations

### Event Emissions

The protocol emits structured events for:

- Parameter updates
- Large position changes
- Liquidation events

## 🚨 Risk Considerations

### Smart Contract Risks

- **Code Audits**: Ensure thorough security auditing before mainnet deployment
- **Formal Verification**: Consider formal verification for critical functions
- **Upgrade Mechanisms**: Protocol is immutable by design for security

### Economic Risks

- **Market Volatility**: STX price fluctuations affect collateral values
- **Liquidation Cascades**: Monitor for potential cascade liquidation events
- **Parameter Risk**: Governance parameter changes affect protocol behavior

### Operational Risks

- **Stacks Network**: Protocol depends on Stacks blockchain availability
- **Block Time Variations**: Interest calculations based on block height
- **Transaction Fees**: Network congestion may affect user operations

## 🤝 Contributing

We welcome contributions to the BitVault Protocol! Please follow these guidelines:

1. **Fork the Repository**: Create your feature branch from `main`
2. **Write Tests**: Ensure comprehensive test coverage for new features
3. **Follow Standards**: Use Clarity best practices and formatting
4. **Documentation**: Update documentation for new features
5. **Security Focus**: Consider security implications of all changes

### Development Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and test
clarinet check
npm test

# Format code
clarinet fmt --in-place

# Commit and push
git commit -m "feat: description of changes"
git push origin feature/your-feature-name
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ on Stacks • Securing Bitcoin L2 DeFi
