## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# To load the variables in the .env file

source .env

# To deploy and verify our contract

forge script script/LocalDeploy.s.sol:LocalDeployScript --broadcast -vvvv --private-key $PRIVATE_KEY --rpc-url 'http://127.0.0.1:8545'

forge script script/BlindBox.s.sol:BlindBoxScript --rpc-url $TELOS_TESTNET_RPC_URL --broadcast --legacy --verify --verifier sourcify -vvvv

box: 0x48a2b70b834085A1C76CFF1523A94a072e161fe3
market: 0xD60d331B1999824C84A0A702D07368Fde493dF94
nft: 0xf3981B00662D7C43C805Ce0ed65B521893B9C3e6
open price: 12300000000000000

forge script script/BlindBoxCardNFT.s.sol:BlindBoxCardNFTScript 0x48a2b70b834085A1C76CFF1523A94a072e161fe3 --sig 'run(address)' --rpc-url $TELOS_TESTNET_RPC_URL --broadcast --legacy --verify --verifier sourcify -vvvv

forge script script/RegisterToken.s.sol:RegisterTokenScript 0x48a2b70b834085A1C76CFF1523A94a072e161fe3 0xf3981B00662D7C43C805Ce0ed65B521893B9C3e6 --sig 'run(address,address)' --rpc-url $TELOS_TESTNET_RPC_URL --legacy --broadcast -vvvv

forge verify-contract 0x48a2b70b834085A1C76CFF1523A94a072e161fe3 \
 src/BlindBox.sol:BlindBox \
 --watch \
 --chain-id 41 \
 --verifier sourcify

forge verify-contract 0xD60d331B1999824C84A0A702D07368Fde493dF94 \
 src/NFTMarket.sol:NFTMarket \
 --watch \
 --chain-id 41 \
 --verifier sourcify

forge verify-contract 0xf3981B00662D7C43C805Ce0ed65B521893B9C3e6 \
 src/BlindBoxCardNFT.sol:BlindBoxCardNFT \
 --watch \
 --chain-id 41 \
 --verifier sourcify
