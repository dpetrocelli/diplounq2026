# Clase 3 — Cierre clase 2 + Credenciales académicas (ERC-721)

> **Objetivo de hoy**: pasar de "tengo un contrato testeado en mi máquina" a "tengo un contrato deployado en una blockchain real, lo veo en un explorador, y emito un primer título universitario verificable on-chain". Esto es la base del trabajo final de la diplomatura.

## ¿Qué vamos a hacer?

1. **Cerrar lo que quedó pendiente de clase 2**: levantar una blockchain local con Anvil, deployar `SimpleStorage`, interactuar con `cast`, y después llevarlo a Sepolia y verlo en Etherscan
2. **Aprender qué es un NFT (ERC-721)** y por qué es el estándar correcto para representar títulos universitarios
3. **Clonar y entender** el contrato `AcademicCredentials` — el esqueleto del TP final
4. **Testear** el contrato con Foundry (14 tests)
5. **Deployar a Sepolia** y **emitirse un título**, viéndolo aparecer como NFT en MetaMask

---

## Parte 1 — Cierre de clase 2

### 1.1 ¿Qué es Anvil y para qué sirve?

**Anvil** es una blockchain Ethereum local que viene con Foundry. Corre en tu máquina, sin minería, sin gas real, transacciones instantáneas. Es el equivalente de "localhost:3000" pero para Ethereum.

¿Por qué lo usamos antes de ir a Sepolia?

- **Velocidad**: en anvil un deploy tarda milisegundos. En Sepolia, ~12 segundos por bloque.
- **Costo**: testnet ETH es limitado por las faucets. Anvil te da 10 cuentas con 10.000 ETH cada una.
- **Iteración**: si rompés algo, reiniciás anvil y arrancás de cero.

### 1.2 Levantar Anvil

Abrí dos terminales. En la primera:

```bash
cd diplo-unq-blockchain-clase2
anvil
```

Vas a ver algo como:

```
Available Accounts
==================
(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
...

Private Keys
==================
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
...

Listening on 127.0.0.1:8545
```

> ⚠️ **Importante**: estos private keys son públicos y conocidos por todo el mundo. NUNCA los uses en una red real, solo en anvil.

Anvil queda corriendo. **No la cierres** — la dejamos en esa terminal y abrimos otra.

### 1.3 Deploy local con `forge create`

En la segunda terminal:

```bash
cd diplo-unq-blockchain-clase2
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

¿Qué hace cada flag?

| Flag | Qué hace |
|---|---|
| `src/SimpleStorage.sol:SimpleStorage` | Le decís a forge qué contrato deployar (`archivo:nombreContrato`) |
| `--rpc-url http://localhost:8545` | Apunta a tu anvil local |
| `--private-key 0xac09...` | Cuenta `(0)` de anvil — la "wallet" que paga el deploy |
| `--broadcast` | Manda la transacción real (sin esto solo simula) |

Output esperado:

```
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Transaction hash: 0x...
```

> 💡 La address `0x5FbD...0aa3` es **determinística**: si reiniciás anvil y hacés el primer deploy, te va a dar siempre la misma. Eso ayuda mucho cuando estás iterando.

Guardá la address en una variable:

```bash
export ADDR=0x5FbDB2315678afecb367f032d93F642f64180aa3
```

### 1.4 Interactuar con `cast`

`cast` es la herramienta de Foundry para hablar con la blockchain desde la terminal. Es como `curl` pero para Ethereum.

**Leer** una función `view` (gratis, no manda transacción):

```bash
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

Output: `0` (recién deployado, valor inicial)

**Escribir** (es transacción real, gasta gas):

```bash
cast send $ADDR "store(uint256)" 42 \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

Vas a ver un receipt con `status: 1 (success)`, `gasUsed: 45277`, y un campo `logs` que contiene el evento `NumberUpdated` que emitió el contrato.

**Leer de nuevo**:

```bash
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

Output: `42`. Funcionó.

> 🎯 Esto es exactamente lo que hicieron en Remix la semana pasada con los botones azules. Mismo concepto, otra interfaz: `cast call` = leer, `cast send` = escribir.

### 1.5 Deploy a Sepolia (la blockchain real)

Sepolia es la testnet de Ethereum (chain ID `11155111`). Igual que mainnet pero con ETH falso. Necesitás que tu MetaMask esté conectada a Sepolia y tener algo de ETH de Sepolia.

**Importar tu private key como cast wallet** (encriptada con password):

```bash
cast wallet import dev-wallet --interactive
```

Te va a pedir tu private key (la sacás de MetaMask → ⋮ → Detalles de la cuenta → Mostrar private key) y un password.

> ⚠️ Solo usá una cuenta de MetaMask que **no tenga fondos reales en mainnet**. Para esto creá una cuenta nueva en MetaMask y mandá ahí el ETH de Sepolia.

**Deployar** a Sepolia:

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```

Esto tarda ~12 segundos (un bloque de Sepolia). Te devuelve una nueva address — única, real, en una blockchain pública.

### 1.6 Verlo en Etherscan

Abrí en el browser:

```
https://sepolia.etherscan.io/address/<TU_ADDRESS>
```

Vas a ver:
- La transacción de creación
- El **bytecode** del contrato (mismo hex que vieron en `out/SimpleStorage.sol/SimpleStorage.json` cuando hicieron `forge build`)
- Tab "Contract" → "Source code not verified" — eso queda como tarea para después

Mandá una transacción que emita evento:

```bash
cast send $ADDR "store(uint256)" 123 \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet
```

Esperá 12 segundos, recargá Etherscan, y andá al tab **"Logs"**. Vas a ver el evento `NumberUpdated` decodificado: `oldNumber`, `newNumber`, y `updatedBy` con tu address.

> 🎯 Ese `indexed` que pusimos en el evento (`address indexed updatedBy`) es lo que permite a Etherscan filtrar y mostrar quién llamó. Cierra el loop completo: del Solidity al log decodificado en el explorador.

---

## Parte 2 — NFTs y ERC-721 (conceptual)

### ¿Qué es un NFT?

NFT = Non-Fungible Token = "token no fungible".

- **Fungible** (ERC-20): cada unidad es **idéntica e intercambiable**. 1 USDC = 1 USDC. No tiene identidad propia, solo un balance.
- **No fungible** (ERC-721): cada unidad es **única**, con su propia identidad. Como un cuadro, una escritura, un título universitario.

Cada NFT tiene:
- Un **`tokenId`** (número único)
- Un **`ownerOf(tokenId)`** (la wallet que es dueña)
- Un **`tokenURI(tokenId)`** (link a la metadata: nombre, descripción, imagen, atributos — usualmente en IPFS)

### ¿Por qué ERC-721 para títulos universitarios?

- Cada título es **único**: tu Licenciatura en Sistemas no es la misma que la de otro alumno
- Tiene **metadata propia**: tu nombre, fecha, materias, hash del PDF
- Lo "tenés" en tu wallet — nadie te lo puede sacar (salvo que el emisor lo revoque)
- Es **verificable públicamente**: cualquiera puede chequear `ownerOf(tokenId)` y `tokenURI(tokenId)` y validar que tu título existe

---

## Parte 3 — OpenZeppelin

### ¿Qué es?

[OpenZeppelin](https://www.openzeppelin.com/contracts) es una librería de contratos auditados, usados en miles de proyectos productivos (Coinbase, Uniswap, Aave, etc). En lugar de escribir un ERC-721 desde cero — con todos los riesgos de seguridad que eso implica — **heredás** del contrato de OpenZeppelin.

### Los contratos que vamos a usar

| Contrato | Qué da |
|---|---|
| `ERC721` | El estándar base: `mint`, `transfer`, `ownerOf`, `balanceOf`, `tokenURI` |
| `ERC721URIStorage` | Extensión que permite asociar una URI distinta a cada `tokenId` |
| `Ownable` | Control de acceso simple: una sola wallet puede llamar funciones marcadas `onlyOwner` |

---

## Parte 4 — Setup del repo de clase 3

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase3.git
cd diplo-unq-blockchain-clase3
```

Bajamos las dependencias:

```bash
forge install foundry-rs/forge-std --shallow
forge install OpenZeppelin/openzeppelin-contracts --shallow
```

Compilamos y testeamos:

```bash
forge build
forge test
```

Tienen que ver `14 passed; 0 failed`.

---

## Parte 5 — Tour del contrato `AcademicCredentials`

Abran `src/AcademicCredentials.sol`. Repasamos las partes clave:

### Imports

```solidity
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
```

### Herencia múltiple

```solidity
contract AcademicCredentials is ERC721URIStorage, Ownable {
```

Solidity permite heredar de varios contratos a la vez. Acá heredamos de los **dos** de OpenZeppelin.

### Constructor

```solidity
constructor()
    ERC721("UNQ Academic Credential", "UNQ-CRED")
    Ownable(msg.sender)
{}
```

Pasamos argumentos a los constructores de los contratos padre:
- `ERC721("UNQ Academic Credential", "UNQ-CRED")` → name + symbol del NFT
- `Ownable(msg.sender)` → la wallet que deploya queda como owner (el "issuer")

### Función `issueCredential` (emitir un título)

```solidity
function issueCredential(address student, uint256 tokenId, string memory metadataURI)
    public
    onlyOwner
{
    _mint(student, tokenId);
    _setTokenURI(tokenId, metadataURI);
    emit CredentialIssued(student, tokenId, metadataURI);
}
```

- `onlyOwner`: solo el issuer (la universidad) puede llamarla
- `_mint(student, tokenId)`: crea el NFT y lo asigna a la wallet del estudiante
- `_setTokenURI(tokenId, metadataURI)`: guarda la URI con la metadata
- `emit CredentialIssued(...)`: emite un evento que el frontend va a escuchar

### Función `revoke`

```solidity
function revoke(uint256 tokenId) public onlyOwner {
    _burn(tokenId);
    emit CredentialRevoked(tokenId);
}
```

Si la universidad detecta un fraude o un error, puede revocar (quemar) el título. El NFT desaparece y `ownerOf(tokenId)` revierte.

### Función `isValid`

```solidity
function isValid(uint256 tokenId) public view returns (bool) {
    return _ownerOf(tokenId) != address(0);
}
```

Helper para verificación pública. Cualquiera puede llamarla, no cuesta gas.

---

## Parte 6 — Tests con Foundry

```bash
forge test
```

Los 14 tests cubren:
- Nombre, símbolo, ownership inicial
- Issue / revoke (camino feliz + casos de error)
- Eventos (`CredentialIssued`, `CredentialRevoked`)
- Verificación (`isValid`, `tokenURI`, `ownerOf`)
- Fuzz tests (256 casos random)

Para ver el detalle de un test:

```bash
forge test --match-test test_IssuerCanIssue -vvvv
```

Vas a ver el call trace completo: deploy → mint event → setTokenURI → CredentialIssued event.

> 💡 Para escribir tests propios: cada función que empieza con `test_` se ejecuta. Las que empiezan con `testFuzz_` reciben argumentos random y corren 256 veces.

---

## Parte 7 — Deploy a Sepolia + emitir tu primer título

### Deploy

Asumiendo que ya importaste tu wallet en clase 2:

```bash
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```

Te devuelve la address del nuevo contrato. **La wallet que deployó es el issuer**.

Guardala:

```bash
export ADDR=<address que devolvió forge create>
```

### Emitirte un título a vos mismo

Tomá tu address de MetaMask:

```bash
export YOU=<tu address de MetaMask>
```

Y emití:

```bash
cast send $ADDR \
  "issueCredential(address,uint256,string)" \
  $YOU 1 "ipfs://bafy.../titulo-licenciatura-sistemas.json" \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet
```

Esperá 12 segundos. Verificá:

```bash
cast call $ADDR "ownerOf(uint256)" 1 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
cast call $ADDR "tokenURI(uint256)" 1 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
cast call $ADDR "isValid(uint256)" 1 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

Tienen que devolver tu address, la URI que pusiste, y `true`.

### Verlo en Etherscan

```
https://sepolia.etherscan.io/address/<TU_ADDRESS_DE_CONTRATO>
```

En "Logs" vas a ver `CredentialIssued` con tus datos decodificados.

---

## Parte 8 — Verlo como NFT en MetaMask

1. Abrí MetaMask
2. Tab "NFTs"
3. "Import NFT"
4. Address: la address de tu contrato
5. Token ID: `1`

Ahora MetaMask muestra que sos dueño de un NFT del contrato `UNQ-CRED`. Si la metadata estuviera en IPFS, también vería el JSON con tu nombre, fecha, materias.

> 🎉 Eso es un título universitario verificable on-chain. Cualquier persona en el mundo, con la address de este contrato y tu tokenId, puede verificar que sos egresado UNQ.

---

## Parte 9 — ¿Y para el TP final?

Lo que escribimos hoy es el **esqueleto** del TP final. Para el trabajo final lo van a extender con:

- **`AccessControl`** con roles `ISSUER_ROLE` (decanos) y `DEFAULT_ADMIN_ROLE` (rector)
- **Soulbound**: que los títulos NO sean transferibles (override `_update` para revertir transfers)
- **Estructura de datos** completa (`Credential` con nombre, fecha, hash del PDF)
- **Frontend con dos modos**: panel admin para emitir + verificador público para que cualquiera consulte
- **Metadata real** en IPFS con foto + firma digital
- **`SECURITY.md`** con análisis de Slither

El spec completo se va a publicar en el campus.

---

## Tarea para clase 4

1. **Deployar tu propio `AcademicCredentials`** en Sepolia (vos sos el issuer)
2. **Emitirte un título a vos mismo** con un `tokenURI` placeholder
3. **Postear en el foro** del campus:
   - La address de tu contrato
   - El `tokenId` del título emitido
   - El hash de la transacción de emisión
4. **(Opcional)** Subir un JSON real a [Pinata](https://www.pinata.cloud/) (cuenta gratis), copiar el CID, y usarlo como `tokenURI`. La metadata queda como:

```json
{
  "name": "Licenciatura en Sistemas de Información",
  "description": "Título emitido por la Universidad Nacional de Quilmes",
  "issueDate": "2026-04-27",
  "studentName": "Tu Nombre",
  "image": "ipfs://bafy.../tu-foto.png"
}
```

---

## Si algo falla

| Problema | Solución |
|---|---|
| `forge install` lento o falla | Probá con VPN o desde otra red |
| Faucet de Sepolia no manda tokens | Probar [Google Cloud Web3 Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia) |
| RPC público lento | Cambiar a `https://rpc.sepolia.org` o `https://sepolia.gateway.tenderly.co` |
| `forge create` tarda > 30 seg | Normal por congestión. Si pasan 60s, revisar con `cast tx <hash>` |
| MetaMask no muestra mi NFT | Verificá que estés en Sepolia y que la address del contrato esté bien |

Lo demás lo resolvemos en el foro del campus.
