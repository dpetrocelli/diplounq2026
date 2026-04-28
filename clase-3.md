# Clase 3 — Cierre clase 2 + Credenciales académicas (ERC-721)

## Repo del ejercicio

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase3.git
cd diplo-unq-blockchain-clase3
forge install foundry-rs/forge-std --shallow
forge install OpenZeppelin/openzeppelin-contracts --shallow
forge build
forge test
```

Tienen que ver `14 passed; 0 failed`.

## Comandos clave

```bash
forge build              # compilar
forge test               # tests
forge test -vvv          # con detalle
anvil                    # blockchain local
```

## Deploy local (con anvil corriendo)

```bash
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

## Emitir un título a alice (cast)

```bash
export ADDR=<address que devolvió forge create>
export ALICE=0x70997970C51812dc3A010C7d01b50e0d17dc79C8

cast send $ADDR \
  "issueCredential(address,uint256,string)" \
  $ALICE 1 "ipfs://bafy.../titulo.json" \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## Verificar el título

```bash
cast call $ADDR "ownerOf(uint256)" 1 --rpc-url http://localhost:8545
cast call $ADDR "tokenURI(uint256)" 1 --rpc-url http://localhost:8545
cast call $ADDR "isValid(uint256)" 1 --rpc-url http://localhost:8545
```

## Deploy a Sepolia

```bash
cast wallet import dev-wallet --interactive

forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```
