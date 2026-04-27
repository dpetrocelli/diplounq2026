# Clase 2 — Foundry + SimpleStorage

**Cuándo:** lunes 27/04/2026, 18:00 a 19:35 (sincrónica)
**Docentes:** Dr. David Petrocelli + Ciro
**Duración total:** ~95 minutos

---

## Qué vamos a hacer hoy

1. **Repaso clase 1** y resolución de dudas que quedaron al aire
2. **Instalar Foundry** (`forge`, `cast`, `anvil`) y la extensión de Solidity en VS Code
3. **Clonar el repo del ejercicio** y compilarlo
4. **Tour del contrato `SimpleStorage`** en Solidity — entender bytecode, ABI, eventos
5. **Tests automáticos**: ver pasar 10 tests, escribir uno nuevo en vivo
6. **Anvil**: blockchain local para desarrollo, deploy y `cast` interactivo
7. **Deploy real a Sepolia** y verificación en Etherscan
8. **Tarea para la próxima clase**

> **Objetivo:** al terminar tienen el flujo profesional completo — write, test, deploy local, deploy testnet — funcionando en su máquina.

---

## Repo del ejercicio

> **<https://github.com/dpetrocelli/diplo-unq-blockchain-clase2>**

Una sola línea para clonar:

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase2.git
cd diplo-unq-blockchain-clase2
```

---

## Pre-requisitos (traerlos hechos)

- ✅ MetaMask instalada y configurada en **Sepolia** (chain ID `11155111`)
- ✅ Saldo > 0.01 ETH de Sepolia (faucet recomendada: <https://cloud.google.com/application/web3/faucet/ethereum/sepolia>)
- ✅ VS Code instalado
- ✅ Git instalado

Foundry y la extensión de Solidity los instalamos juntos en clase, no hace falta traerlo hecho.

---

## Setup en clase

### 1. Instalar Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Después de eso, reabrir terminal o:

```bash
source ~/.bashrc      # bash
# source ~/.zshenv    # zsh
foundryup
```

Verificar:

```bash
forge --version
cast --version
anvil --version
```

### 2. Instalar la extensión Solidity en VS Code

```bash
code --install-extension juanblanco.solidity
```

### 3. Clonar el repo y compilar

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase2.git
cd diplo-unq-blockchain-clase2
forge install foundry-rs/forge-std --shallow
forge build
forge test
```

Tienen que ver `10 passed; 0 failed`.

---

## Comandos clave (cheat sheet)

### Compilar y testear

```bash
forge build              # compilar contratos
forge test               # correr todos los tests
forge test -vvv          # tests con output detallado
forge test --match-test test_StoreNumber  # un test específico
```

### Blockchain local con Anvil

Terminal 1 (dejarla abierta):

```bash
anvil
```

Terminal 2 (deploy + interacción):

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast

# Reemplazar $ADDR con la address que devolvió forge create
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
cast send $ADDR "store(uint256)" 42 \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

### Deploy real a Sepolia

Importar la priv key de MetaMask como cast wallet (encriptada con password):

```bash
cast wallet import dev-wallet --interactive
```

> ⚠️ **Importante:** usar una cuenta de MetaMask que **solo tenga fondos de testnet**. Nunca exponer la priv key de una cuenta con ETH real.

Deploy:

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```

Después de ~12 segundos van a poder ver el contrato en:

```
https://sepolia.etherscan.io/address/<ADDRESS>
```

---

## Tarea para la próxima clase

1. Agregar función `decrement()` al contrato con `require(favoriteNumber > 0, "underflow")`
2. Escribir un test que valide el revert con `vm.expectRevert("underflow")`
3. Hacer deploy a Sepolia y postear el address en el foro del campus
4. **(Opcional)** Verificar el contrato en Etherscan con `forge verify-contract`

---

## Recursos

| Recurso | URL |
|---|---|
| Repo del ejercicio | <https://github.com/dpetrocelli/diplo-unq-blockchain-clase2> |
| Foundry Book | <https://book.getfoundry.sh/> |
| Solidity Docs | <https://docs.soliditylang.org/> |
| OpenZeppelin Contracts | <https://docs.openzeppelin.com/contracts/> |
| Sepolia Etherscan | <https://sepolia.etherscan.io> |
| Faucet recomendada | <https://cloud.google.com/application/web3/faucet/ethereum/sepolia> |
| Solidity by Example | <https://solidity-by-example.org/> |

---

## Si algo falla

| Problema | Solución |
|---|---|
| `foundryup` falla en Windows | Instalar **WSL2** primero, después correrlo dentro de WSL |
| `forge install` falla por proxy | Probar con VPN o desde otra red |
| Faucet no manda tokens | Probar otra: Alchemy <https://www.alchemy.com/faucets/ethereum-sepolia> |
| RPC de Sepolia lento | Cambiar a `https://rpc.sepolia.org` |
| `forge test` falla con `Member "NumberUpdated" not found` | Verificar que `foundry.toml` tiene `solc = "0.8.28"` (no 0.8.19) |

Lo demás lo resolvemos en vivo o por el foro del campus.
