# Cheat sheet — comandos del día a día

> Esta página es para tener a mano durante el TP final y mientras debuggean. Está agrupado por flujo: setup, contrato, deploy, interactuar, frontend, debugging. Hagan `Ctrl+F` y listo.

---

## 0 · Setup inicial (una sola vez)

Instalar Foundry (`forge`, `cast`, `anvil`):

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Verificar que quedó todo:

```bash
forge --version && cast --version && anvil --version
```

Instalar `jq` (lo usamos para parsear el ABI desde `out/`):

```bash
sudo apt install jq      # Linux
brew install jq          # Mac
```

Crear el `.env` del proyecto (lo cargamos con `source` antes de cada sesión):

```bash
cat > .env <<'EOF'
SEPOLIA_RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
ETHERSCAN_API_KEY=tu_api_key_de_etherscan
BASESCAN_API_KEY=tu_api_key_de_basescan
EOF
echo ".env" >> .gitignore
```

> ⚠️ El `.env` NUNCA va a git. La private key tampoco — usamos `cast wallet import` (sección 7) para encriptarla en disco.

Importar la wallet de desarrollo (queda encriptada con un password local):

```bash
cast wallet import dev-wallet --interactive
```

Cargar el `.env` al arrancar la sesión:

```bash
source .env
```

---

## 1 · Workflow Foundry (build + test)

Iniciar un proyecto nuevo desde cero (rara vez — el TP arranca de un repo):

```bash
forge init mi-proyecto
```

Compilar todo el proyecto:

```bash
forge build
```

Limpiar artefactos (si el cache se rompió o cambiaste de versión de solc):

```bash
forge clean
```

Correr todos los tests:

```bash
forge test
```

Correr un test puntual con call trace completo (lo que más van a usar para debuggear):

```bash
forge test --match-test test_IssuerCanIssue -vvvv
```

Niveles de verbosidad: `-v` falla, `-vv` agrega logs, `-vvv` traces de fallidos, `-vvvv` traces de todo.

Filtrar tests por nombre con regex:

```bash
forge test --match-test "test_(Issue|Revoke).*"
```

Coverage como tabla en la consola (lo que miran para chequear que están en zona):

```bash
forge coverage --report summary
```

Coverage en LCOV — **el TP final pide ≥ 80%** y este es el formato que se entrega:

```bash
forge coverage --report lcov
```

Genera `lcov.info` en la raíz. Lo pueden visualizar con `genhtml lcov.info -o coverage/` y abrir `coverage/index.html`.

Formatear código Solidity (corre antes de commitear):

```bash
forge fmt
```

---

## 2 · Anvil (blockchain local)

Levantar la blockchain local. Queda corriendo en foreground — abrí otra terminal para todo lo demás:

```bash
anvil
```

Por default escucha en `http://127.0.0.1:8545`, chain ID `31337`, y te imprime 10 cuentas con 10.000 ETH cada una más sus private keys.

La cuenta `(0)` que usamos siempre en clase:

```
Address:     0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Private key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

> ⚠️ Esa private key es pública y la conoce todo el mundo. Solo sirve en anvil. Nunca la uses en una red real.

Bajar anvil: `Ctrl+C` en la terminal donde corre. Si quedó zombie:

```bash
pkill anvil
```

---

## 3 · Deploy

### 3.1 Deploy local (anvil)

```bash
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

El primer deploy en anvil siempre devuelve la misma address (es determinístico): `0x5FbDB2315678afecb367f032d93F642f64180aa3`.

### 3.2 Deploy a Sepolia

```bash
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev-wallet \
  --broadcast
```

Tarda ~12 segundos (un bloque). Te devuelve la address — guardala:

```bash
export ADDR=0x...
```

### 3.3 Deploy a Base Sepolia (lo que pide el TP final)

```bash
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --account dev-wallet \
  --broadcast
```

Mismo flujo, solo cambia el RPC. Chain ID `84532`. Bloques de ~2s, costo ~$0.005 por tx.

### 3.4 Deploy + verify en una sola línea

Si tenés la API key bien seteada, podés deployar y verificar en un solo comando:

```bash
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev-wallet \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

Si `--verify` falla durante el deploy (timing, rate limit, lo que sea), no hay drama — el contrato quedó deployado, lo verifican aparte con `forge verify-contract` (sección 4).

### 3.5 `forge create` vs `forge script`

| Cuándo | Herramienta |
|---|---|
| Un único contrato sin args complejos | `forge create` (lo que usamos en clase) |
| Múltiples contratos, args calculados, lógica de deploy | `forge script script/Deploy.s.sol --broadcast --rpc-url ...` |

Para el TP, `forge create` alcanza. `forge script` queda para cuando tengan que orquestar deploys con dependencias entre contratos.

---

## 4 · Verificación post-deploy

Verificar el contrato en Etherscan (Sepolia). **El TP final exige el contrato verificado en Basescan.**

```bash
forge verify-contract \
  $ADDR \
  src/AcademicCredentials.sol:AcademicCredentials \
  --chain-id 11155111 \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --watch
```

El flag `--watch` te deja la terminal esperando hasta que Etherscan termine de procesar (no tenés que recargar manualmente).

Verificar en **Base Sepolia (Basescan)**:

```bash
forge verify-contract \
  $ADDR \
  src/AcademicCredentials.sol:AcademicCredentials \
  --chain-id 84532 \
  --verifier-url https://api-sepolia.basescan.org/api \
  --etherscan-api-key $BASESCAN_API_KEY \
  --watch
```

Si el contrato tiene argumentos en el constructor, hay que pasarlos encodeados:

```bash
forge verify-contract $ADDR src/AcademicCredentials.sol:AcademicCredentials \
  --chain-id 84532 \
  --constructor-args $(cast abi-encode "constructor(string,string)" "UNQ Academic Credential" "UNQ-CRED") \
  --etherscan-api-key $BASESCAN_API_KEY \
  --watch
```

> Si verify falla con "bytecode mismatch": revisá que `foundry.toml` tenga la misma versión de solc y los mismos `optimizer_runs` con los que compilaste el deploy. Lo más común es que cambiaste algo y redeployaste con bytecode distinto.

---

## 5 · Cast — leer del contrato (call)

`cast call` ejecuta una función `view` / `pure`. No manda transacción, no cuesta gas, no necesita private key.

Patrón básico:

```bash
cast call $ADDR "name()(string)" --rpc-url $SEPOLIA_RPC_URL
```

El `(string)` al final le dice a cast que decodee la respuesta como string. Sin eso te devuelve hex crudo.

Leer el dueño de un NFT:

```bash
cast call $ADDR "ownerOf(uint256)(address)" 1 --rpc-url $SEPOLIA_RPC_URL
```

Leer la URI de la metadata:

```bash
cast call $ADDR "tokenURI(uint256)(string)" 1 --rpc-url $SEPOLIA_RPC_URL
```

Si te olvidás del decode, te devuelve hex. Convertilo a mano:

```bash
cast call $ADDR "favoriteNumber()" --rpc-url $SEPOLIA_RPC_URL
# 0x000000000000000000000000000000000000000000000000000000000000002a
```

Convertir hex → decimal:

```bash
cast --to-dec 0x2a            # 42
```

Convertir hex → ascii (útil cuando devuelve un string ABI-encoded):

```bash
cast --to-ascii 0x554e51       # UNQ
```

Ver si una address tiene un rol (lo que van a usar mucho con `AccessControl` del TP):

```bash
ROLE=$(cast keccak "ISSUER_ROLE")
cast call $ADDR "hasRole(bytes32,address)(bool)" $ROLE 0xTU_ADDRESS --rpc-url $SEPOLIA_RPC_URL
```

---

## 6 · Cast — escribir al contrato (send)

`cast send` manda una transacción real. Cuesta gas, requiere wallet, tarda un bloque.

Emitir una credencial al estilo `AcademicCredentials` de clase 3:

```bash
cast send $ADDR \
  "issueCredential(address,uint256,string)" \
  $YOU 1 "ipfs://bafy.../titulo-licenciatura-sistemas.json" \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev-wallet
```

Mandar ETH junto con el call (`payable`):

```bash
cast send $ADDR "deposit()" \
  --value 0.01ether \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev-wallet
```

Estimar gas antes de mandar (no firma nada, solo simula):

```bash
cast estimate $ADDR "issueCredential(address,uint256,string)" \
  $YOU 2 "ipfs://demo" \
  --rpc-url $SEPOLIA_RPC_URL
```

Otorgar `ISSUER_ROLE` a una address (si extendieron a `AccessControl` para el TP):

```bash
ROLE=$(cast keccak "ISSUER_ROLE")
cast send $ADDR "grantRole(bytes32,address)" $ROLE 0xDECANO_ADDR \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev-wallet
```

Revocar una credencial:

```bash
cast send $ADDR "revoke(uint256)" 1 \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev-wallet
```

---

## 7 · Cast — utilidades varias

Crear una wallet nueva (te imprime address + private key — guardala bien):

```bash
cast wallet new
```

Ver la address asociada a una private key:

```bash
cast wallet address --private-key 0xac09...
```

Importar una wallet existente para usarla con `--account` (no la repetís nunca más en CLI):

```bash
cast wallet import dev-wallet --interactive
```

Listar wallets importadas:

```bash
cast wallet list
```

Inspeccionar una transacción por hash:

```bash
cast tx 0xHASH --rpc-url $SEPOLIA_RPC_URL
```

El receipt (status, gasUsed, logs):

```bash
cast receipt 0xHASH --rpc-url $SEPOLIA_RPC_URL
```

Filtrar logs/eventos de un contrato:

```bash
cast logs --address $ADDR --rpc-url $SEPOLIA_RPC_URL
```

Balance de una wallet:

```bash
cast balance 0xTU_ADDRESS --rpc-url $SEPOLIA_RPC_URL --ether
```

Último bloque de la red:

```bash
cast block-number --rpc-url $SEPOLIA_RPC_URL
```

Calcular el `bytes32` de un rol (para `AccessControl`):

```bash
cast keccak "ISSUER_ROLE"
# 0x...
```

Hashear datos del estudiante (lo que pide el TP para `studentNameHash`):

```bash
cast keccak "Juan Perez|DNI:12345678"
```

---

## 8 · Variables de entorno (.env)

Plantilla mínima para el TP:

```bash
# .env
SEPOLIA_RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
ETHERSCAN_API_KEY=XXXXXXXXXXXXXXXXXXXXXX
BASESCAN_API_KEY=XXXXXXXXXXXXXXXXXXXXXX

# Útiles para iterar
ADDR=0xCONTRATO_DEPLOYADO
YOU=0xTU_METAMASK
```

Cargarlo en la sesión actual:

```bash
source .env
```

Confirmar que se cargó:

```bash
echo $SEPOLIA_RPC_URL
```

> Reglas de oro: `.env` está en `.gitignore`. La private key NO va al `.env` — usá `cast wallet import` y `--account dev-wallet`.

---

## 9 · OpenZeppelin

Instalar la librería como submódulo de git:

```bash
forge install OpenZeppelin/openzeppelin-contracts --shallow
```

`--shallow` solo trae el último commit (más rápido, ocupa menos).

Verificar que `remappings.txt` tenga la línea (o agregala):

```
@openzeppelin/=lib/openzeppelin-contracts/
```

Imports más usados en el TP:

```solidity
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
```

Actualizar a la última versión:

```bash
forge update lib/openzeppelin-contracts
```

Si `forge install` se cuelga 30+ segundos: cancelá y probá con VPN o desde otra red. Como último recurso, `git clone` manual del repo OZ adentro de `lib/`.

---

## 10 · Frontend (Next.js + wagmi)

Crear un proyecto Next.js (la diplomatura usa el starter, pero por si arrancan de cero):

```bash
npx create-next-app@latest frontend
cd frontend
```

Instalar las dependencias de la DApp:

```bash
npm install wagmi viem @rainbow-me/rainbowkit @tanstack/react-query
```

Levantar el frontend en local:

```bash
npm run dev
```

Abre en `http://localhost:3000`.

Conseguir el ABI del contrato (lo necesitás para los hooks de wagmi):

```bash
forge build
jq '.abi' out/AcademicCredentials.sol/AcademicCredentials.json > frontend/abi.json
```

Conseguir la address del último deploy (si usaron `forge script`):

```bash
jq '.transactions[0].contractAddress' broadcast/Deploy.s.sol/11155111/run-latest.json
```

> Para el frontend del TP final hay un starter en <https://github.com/dpetrocelli/diplo-unq-blockchain-tp-final-starter>. Forkean, cambian `CREDENTIALS_ADDRESS` y el ABI, y arrancan.

Build de producción para deployar a Vercel:

```bash
npm run build
```

---

## 11 · Slither (análisis estático)

Instalar (necesita Python 3.8+):

```bash
pip install slither-analyzer
```

Si Slither no encuentra `solc`, instalalo con `solc-select`:

```bash
pip install solc-select
solc-select install 0.8.28
solc-select use 0.8.28
```

Correrlo sobre todo el proyecto:

```bash
slither .
```

Sobre un archivo puntual:

```bash
slither src/AcademicCredentials.sol
```

Output en JSON (útil para incluir en el `SECURITY.md` del TP):

```bash
slither . --json slither-report.json
```

Severidades que reporta Slither:

| Severidad | Significa |
|---|---|
| `High` | Vulnerabilidad real, hay que arreglarla |
| `Medium` | Sospechoso, revisar y justificar |
| `Low` | Mejora menor, pueden documentarla |
| `Informational` | Estilo / convención, opcional |
| `Optimization` | Ahorro de gas, opcional |

> Para el TP: cada finding (incluso los false positives) tiene que estar documentado en `SECURITY.md` con el porqué.

---

## 12 · Git para el TP

Clonar el starter (clase 3) y desligarlo del fork original:

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase3.git mi-tp
cd mi-tp
git remote remove origin
```

Crear el repo nuevo en GitHub y enlazarlo:

```bash
git remote add origin https://github.com/USUARIO/mi-tp.git
git branch -M main
git push -u origin main
```

Workflow día a día:

```bash
git status
git add src/AcademicCredentials.sol test/AcademicCredentials.t.sol
git commit -m "feat: add ISSUER_ROLE and soulbound override"
git push
```

Commitear el `.env` por accidente — el desastre clásico. Si pasó:

```bash
git rm --cached .env
echo ".env" >> .gitignore
git commit -m "remove .env from tracking"
git push
```

⚠️ Eso saca el archivo del último commit pero **el secreto sigue en el historial**. Si era una private key real, asumila comprometida y rotala.

---

## Errores frecuentes — lookup rápido

| Error | Fix |
|---|---|
| `insufficient funds for gas` | Pedí más SepoliaETH al [faucet de Google Cloud](https://cloud.google.com/application/web3/faucet/ethereum/sepolia) o cambiá de cuenta |
| `nonce too high` / `nonce too low` | En MetaMask: Settings → Advanced → Clear activity tab data (resetea el nonce de la cuenta) |
| `could not detect network` | El RPC está caído. Probá `https://rpc.sepolia.org` o `https://sepolia.gateway.tenderly.co` |
| `contract creation code storage out of gas` | El contrato es muy grande para el gas limit. Subí el optimizador (`runs = 200`) o partí el contrato |
| `underlying transport error` | Red caída o RPC con rate limit. Reintentá; si persiste cambiá de RPC |
| `ContractFunctionExecutionError: revert ...` | El contrato revirtió. Mirá el mensaje (`require`/`error`) o corré la misma tx con `cast call` para ver el motivo |
| `forge install` se cuelga > 30s | VPN o `git clone` manual del repo dentro de `lib/` |
| Verify: `Already Verified` | Es feature, no bug. El contrato ya estaba verificado |
| Verify: `bytecode mismatch` | Revisá que `foundry.toml` tenga el mismo `solc` y `optimizer_runs` con los que compilaste el deploy |
| `WalletConnect Project ID is not valid` | Confirmá que copiaste el Project ID desde [cloud.walletconnect.com](https://cloud.walletconnect.com/) en `wagmi.ts` |
| MetaMask no muestra el NFT | Verificá la red (Sepolia o Base Sepolia) y hacé "Import NFT" manual con address + tokenId |
| `forge test` falla solo en CI | El cache local te miente. `forge clean && forge test` y replicalo en local |

---

## Flujos de referencia (los más usados)

**Deploy a Base Sepolia + verify (TP final):**

```bash
source .env
forge build
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --account dev-wallet \
  --broadcast
# guardás la address que devuelve →
export ADDR=0x...
forge verify-contract $ADDR src/AcademicCredentials.sol:AcademicCredentials \
  --chain-id 84532 \
  --verifier-url https://api-sepolia.basescan.org/api \
  --etherscan-api-key $BASESCAN_API_KEY \
  --watch
```

**Emitir + verificar una credencial:**

```bash
cast send $ADDR "issueCredential(address,uint256,string)" \
  $YOU 1 "ipfs://demo/titulo-001.json" \
  --rpc-url $BASE_SEPOLIA_RPC_URL --account dev-wallet
cast call $ADDR "ownerOf(uint256)(address)" 1 --rpc-url $BASE_SEPOLIA_RPC_URL
cast call $ADDR "tokenURI(uint256)(string)" 1 --rpc-url $BASE_SEPOLIA_RPC_URL
```

**Coverage report para entregar:**

```bash
forge coverage --report lcov
genhtml lcov.info -o coverage/
open coverage/index.html
```

---

> Volver al [material de cursada](index.html).
