# LedgerChain Smart Contract

LedgerChain is a decentralized proof-of-ownership registry for properties built on the Stacks blockchain using Clarity smart contracts.

## Description

LedgerChain enables users to register properties by minting unique NFTs as proof of ownership. The smart contract provides comprehensive functionality for property management, including:

- Property registration
- Ownership transfer with cryptographic signature verification
- Property details storage and retrieval
- Property valuation updates
- Geographic and zoning information management
- Cryptocurrency-based property purchase

## Smart Contract Features

- Non-fungible token (NFT) representation of property ownership
- Secure property registration with validation checks
- Property ownership transfer with digital signature authentication
- Property details tracking, including:
  - Current owner
  - Property information
  - Valuation
  - Geographic data
  - Zoning information
- Ability to update property details (valuation, geographic data, zoning info)
- Placeholder cryptocurrency payment integration

## Function Overview

### `register-property`
Registers a new property as an NFT with the following parameters:
- `property-info`: Descriptive information about the property
- `valuation`: Property's monetary value
- `geographic-data`: Location and geographic details
- `zoning-info`: Zoning classification

### `transfer-property`
Transfers property ownership with:
- Signature verification
- Ownership transfer restrictions
- Digital signature validation

### `update-property-valuation`
Allows property owner to update the property's valuation

### `update-geographic-data`
Enables owner to update the property's geographic information

### `update-zoning-info`
Permits owner to modify the property's zoning classification

### `purchase-property`
Facilitates property purchase using cryptocurrency (currently a placeholder implementation)

## Usage Examples

### Register a Property
```clarity
(contract-call? .ledgerchain register-property 
  "123 Main St, Anytown, USA" 
  u500000 
  "Coordinates: 40.7128° N, 74.0060° W" 
  "Residential")
```

### Transfer Property
```clarity
(contract-call? .ledgerchain transfer-property 
  u1 
  'ST2CY5V39MWFZXM5BN5CXYJ4GQTFZGBWQD9DRHK 
  (signature))
```

### Update Property Valuation
```clarity
(contract-call? .ledgerchain update-property-valuation 
  u1 
  u550000)
```

## Security Considerations

- Implements signature verification for ownership transfers
- Includes validation checks for property registration
- Restricts property updates to current owner
- Placeholder cryptocurrency payment validation

## Limitations and Recommendations

- Signature verification is a simplified implementation
- Cryptocurrency payment integration is currently a placeholder
- Recommended to conduct thorough smart contract audits before mainnet deployment
- Additional off-chain components may be necessary for full functionality

