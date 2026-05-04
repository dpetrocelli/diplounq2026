# Glosario — términos del día a día

> Esta página agrupa los términos que aparecen a lo largo de las 4 clases y el TP final, ordenados por concepto. Para buscar uno específico, ctrl-F.

## 1 · Conceptos fundamentales de blockchain 🧱

- **Blockchain** — base de datos distribuida y replicada en miles de nodos, donde el estado se acuerda por consenso y los datos no se editan: solo se agregan. Cada nodo tiene la misma copia, y la verdad es lo que la mayoría confirma.
- **Bloque** — grupo de transacciones empaquetadas, firmadas y enlazadas al bloque anterior por su hash. En Ethereum, un bloque nuevo se cierra cada ~12 segundos (Sepolia L1) o ~2 segundos (Base L2).
- **Hash** — huella digital de tamaño fijo de un input arbitrario. Cambiando un solo bit del input, el hash entero cambia. Es lo que permite encadenar bloques de forma inmutable.
- **Función hash criptográfica** — función one-way determinística usada para construir hashes. Ethereum usa `keccak256` (variante de SHA-3). En el TP final lo van a usar para `studentNameHash` y `documentHash`.
- **Mineado / validación** — proceso por el cual nodos compiten o son elegidos para producir el próximo bloque. **Proof-of-Work** (Bitcoin, Ethereum pre-2022): gana el que resuelve antes un puzzle computacional. **Proof-of-Stake** (Ethereum actual): gana el que stakea ETH y es elegido pseudo-aleatoriamente.
- **Consenso** — el mecanismo por el cual nodos honestos se ponen de acuerdo en cuál es el estado válido. Lo que hace que la blockchain no necesite confiar en una autoridad central.
- **Inmutabilidad** — una vez que una transacción está en un bloque confirmado, no se puede modificar ni borrar. Si querés "corregir" algo, mandás otra transacción que cambie el estado (ej: `revoke` de una credencial).
- **Descentralización** — propiedad de no depender de un servidor o autoridad única. Si se cae un nodo, los otros 9.999 siguen funcionando.
- **Fork** — divergencia en la cadena. Un **soft fork** es compatible hacia atrás (los nodos viejos siguen viendo bloques nuevos como válidos); un **hard fork** rompe compatibilidad y crea dos cadenas (ej: Ethereum / Ethereum Classic, post-DAO 2016).

---

## 2 · Ethereum y EVM 🟪

- **EVM (Ethereum Virtual Machine)** — la "computadora virtual" que ejecuta el bytecode de los smart contracts. Cada nodo de Ethereum corre la misma EVM y por eso llega al mismo resultado. Cualquier chain compatible (Base, Polygon, Arbitrum) corre la misma EVM.
- **Gas** — unidad de medida del costo computacional de una operación en la EVM. Cada opcode cuesta cierta cantidad de gas; el total se paga en ETH. Si te quedás sin gas, la transacción revierte y perdés lo gastado igual.
- **Gas limit / gas price** — el `gas limit` es el máximo de gas que autorizás a usar; el `gas price` es lo que pagás por unidad. Ejemplo: un mint cuesta ~70.000 gas a 20 gwei = 0.0014 ETH. En L2 son fracciones de centavo (visto en clase 4).
- **Wei / Gwei / Ether** — `1 ETH = 10⁹ gwei = 10¹⁸ wei`. Wei es la unidad mínima (entera, sin decimales). Gwei se usa para gas prices. Ether para mostrarle al usuario.
- **Address (dirección)** — identificador de 20 bytes (40 caracteres hex) con prefijo `0x`, ej: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`. Identifica tanto wallets (EOA) como contratos.
- **Nonce** — contador incremental por cuenta. Cada transacción que mandás tiene un nonce uno más alto que la anterior. Sirve para evitar replays y ordenar transacciones.
- **Mainnet vs testnet** — **Mainnet** es la red de producción (con ETH real, plata real). **Testnet** es la red de prueba (ETH falso, sin valor) — ej: Sepolia, Holesky.
- **L1 vs L2** — **L1** es la capa base (Ethereum). **L2** es una capa por encima que ejecuta más barato y rápido, pero hereda la seguridad de L1 (Base, Polygon, Arbitrum, Optimism).
- **Sepolia** — la testnet de Ethereum L1 que usamos en clases 1-3. Chain ID `11155111`. Bloques cada ~12 s.
- **Base Sepolia** — la testnet de Base (L2 de Coinbase) usada en clase 4 y obligatoria en el TP final. Chain ID `84532`. Bloques cada ~2 s. Explorer: `sepolia.basescan.org`.

---

## 3 · Wallets y claves 🔑

- **Wallet** — software que custodia tus claves privadas y firma transacciones. NO guarda ETH (el ETH vive on-chain) — guarda la **clave** que prueba que sos vos.
- **EOA (Externally Owned Account)** vs **smart contract** — una **EOA** es controlada por una clave privada (las wallets de personas). Un **smart contract** es código que vive en una address y se ejecuta cuando alguien lo llama. Ambos tienen address `0x...`.
- **Private key (clave privada)** — número de 256 bits que prueba que sos dueño de una cuenta. Si la perdés, perdés acceso. Si la filtran, te vacían la wallet. Nunca digital, nunca en la nube, nunca en chats con LLMs.
- **Public key** — derivada de la privada. La address `0x...` es básicamente los últimos 20 bytes del hash de la public key.
- **Frase BIP-39 / seed phrase** — las 12 o 24 palabras que MetaMask te muestra al crear una wallet. De ahí se derivan TODAS las private keys de TODAS las cuentas. **Es lo más sensible que tenés** — anotar en papel, nunca digital.
- **MetaMask** — wallet en forma de extensión de navegador, el estándar de facto para interactuar con dApps. Usada en las 4 clases.
- **WalletConnect** — protocolo para que una dApp se comunique con cualquier wallet (especialmente móviles) por QR o deeplink. En clase 4 conseguís un Project ID gratis para usarlo desde RainbowKit.
- **HD Wallet (Hierarchical Deterministic)** — wallet que deriva múltiples cuentas a partir de una sola seed phrase, siguiendo un árbol determinístico (BIP-32/BIP-44). Por eso de una frase de 12 palabras salen N cuentas.

---

## 4 · Smart contracts 📜

- **Smart contract** — código (bytecode) deployado en una address de la blockchain. Cualquiera puede llamarlo; ejecuta lo que dice su código y modifica su propio estado.
- **Solidity** — el lenguaje de programación de smart contracts en EVM. Tipado, parecido a JavaScript/Java. Versión usada en el curso: `^0.8.x`.
- **Bytecode** — el binario que se sube a la blockchain. Es lo que la EVM ejecuta. Es público y leíble por cualquiera (no está encriptado), simplemente está compilado (visto en clase 2).
- **ABI (Application Binary Interface)** — JSON que describe las funciones, parámetros, eventos y errores de un contrato. Es el "menú" que el frontend (wagmi/viem) y `cast` usan para saber cómo llamar al contrato. Foundry lo genera en `out/<Contrato>.json`.
- **Constructor** — función especial que se ejecuta **una sola vez**, en el deploy. Sirve para inicializar estado (ej: setear el owner inicial, el nombre del NFT).
- **Storage / memory / calldata** — los 3 lugares donde puede vivir una variable en Solidity. **Storage**: estado permanente del contrato (caro). **Memory**: RAM temporal durante la ejecución (barato, se borra al terminar la tx). **Calldata**: los argumentos de entrada (read-only, lo más barato).
- **State variable** — variable declarada en el cuerpo del contrato. Vive en `storage`, persiste entre transacciones, cuesta gas modificarla.
- **`view` / `pure`** — modifiers de función. `view`: solo lee estado, no modifica. `pure`: ni siquiera lee estado. Ambas son **gratis si las llamás desde afuera** (no son transacciones).
- **`payable`** — modifier que permite a una función recibir ETH adjunto en la llamada. Sin `payable`, mandar ETH revierte.
- **Modifier** — pieza de código reutilizable que envuelve a una función. El más típico es `onlyOwner` (revierte si quien llama no es el dueño). Visto en clase 3 con OpenZeppelin.
- **Event / Log** — los contratos emiten eventos con `emit`. Quedan en los logs de la transacción, son baratos y los lee Etherscan, The Graph y los frontends. **No son legibles desde otro contrato** — son para el mundo off-chain.
- **Custom errors vs require strings** — `require(x, "mensaje")` es legible pero costoso. `error MyError(); revert MyError();` (custom errors, Solidity 0.8.4+) gasta menos gas y permite parámetros tipados.
- **Reentrancy** — vulnerabilidad clásica: un contrato externo, mientras le mandás ETH, te re-llama antes de que actualices tu estado, y vacía fondos. El bug que costó $60M en The DAO (2016) (visto en clase 4).
- **CEI pattern (Checks-Effects-Interactions)** — la mitigación de reentrancy. Orden obligatorio: 1) **Checks** (validar con `require`), 2) **Effects** (actualizar tu propio estado), 3) **Interactions** (llamar contratos externos).
- **ReentrancyGuard** — el modifier `nonReentrant` de OpenZeppelin. Pone un mutex que revierte si la función se reentra. Alternativa al CEI cuando la lógica es compleja.

---

## 5 · Estándares ERC 🪙

- **ERC-20** — estándar de **tokens fungibles**: cada unidad es idéntica e intercambiable. Ej: USDC, DAI, WETH. Tiene `transfer`, `balanceOf`, `approve`.
- **ERC-721** — estándar de **NFTs (Non-Fungible Tokens)**: cada token es único, identificado por `tokenId`. Lo usamos para representar credenciales académicas (visto en clase 3).
- **ERC-1155** — estándar **multi-token**: un mismo contrato puede manejar múltiples tipos de tokens (fungibles y no fungibles). Útil para inventarios de juegos. No lo usamos en el curso.
- **`tokenURI`** — método de ERC-721 que devuelve la URL de la metadata de un token. Típicamente un `ipfs://...` o `https://...` que apunta a un JSON.
- **Metadata JSON** — archivo apuntado por `tokenURI`, con campos estándar: `name`, `description`, `image`, `attributes`. Es lo que MetaMask, OpenSea y los frontends muestran.
- **Soulbound** — un NFT **NO transferible**, atado a la wallet a la que se emitió. Concepto del paper de Vitalik Buterin et al. (2022, *Decentralized Society*). Se implementa overriding `_update` para revertir transfers. Es lo que pide el TP final para que un título no se pueda vender ni "regalar".

---

## 6 · OpenZeppelin 🛡️

- **OpenZeppelin Contracts** — la biblioteca standard de contratos auditados (ERC-20, ERC-721, AccessControl, etc). Usada en producción por Coinbase, Uniswap, Aave. En vez de escribir un ERC-721 desde cero, heredás del de OZ (visto en clase 3).
- **AccessControl** — sistema de **roles** múltiples. Definís roles con `bytes32` constants (ej: `ISSUER_ROLE`, `DEFAULT_ADMIN_ROLE`) y los asignás/revocás. Más flexible que `Ownable`. Obligatorio en el TP final.
- **Ownable** — patrón "un solo dueño". El que deploya queda como `owner`; funciones marcadas `onlyOwner` solo las puede llamar él. Lo usamos en clase 3 antes de pasar a `AccessControl` en el TP.
- **ERC721URIStorage** — extensión que permite asociar una `tokenURI` distinta a cada `tokenId` (con `_setTokenURI`). El ERC721 base solo soporta una URI con prefijo común.
- **ERC721Burnable** — extensión que agrega `burn(tokenId)` público. En el TP usamos `_burn` interno desde `revoke`, sin exponer el burn al público.
- **Pausable** — extensión que agrega `pause()` / `unpause()`. Funciones marcadas `whenNotPaused` revierten cuando el contrato está pausado. Útil como kill switch de emergencia.

---

## 7 · Foundry y desarrollo ⚒️

- **Foundry** — toolkit de Paradigm para desarrollar smart contracts. Escrito en Rust, muy rápido. Reemplaza a Hardhat/Truffle. Estándar de la industria desde ~2023.
- **`forge`** — el compilador + test runner. Comandos: `forge build`, `forge test`, `forge create`, `forge install`.
- **`cast`** — CLI para leer y escribir contratos desde la terminal. `cast call` (lectura, gratis), `cast send` (escritura, transacción).
- **`anvil`** — blockchain local para desarrollo. 10 cuentas con 10.000 ETH cada una, transacciones instantáneas, sin gas real (visto en clase 3).
- **`chisel`** — REPL interactivo de Solidity. Útil para probar snippets sin crear un proyecto entero.
- **`forge-std`** — biblioteca de testing que viene con Foundry. Te da `Test`, `console.log`, `vm`, `assertEq`. Se instala con `forge install foundry-rs/forge-std --shallow`.
- **Cheatcodes (`vm.*`)** — funciones mágicas de Foundry que solo existen en tests, no en producción. Ejemplos: `vm.prank(alice)` (la próxima call la hace alice), `vm.expectRevert()` (espera que revierta), `vm.warp(timestamp)` (mueve el reloj), `vm.expectEmit(...)` (chequea que se emita un evento).
- **Fuzz testing** — Foundry detecta funciones `testFuzz_*` y les pasa argumentos random 256 veces. Encuentra edge cases que no se te ocurrieron (visto en clase 2).
- **Fork testing** — testear tu contrato contra un snapshot real de mainnet/testnet (`vm.createFork(rpcUrl)`). Útil para integrar con contratos productivos.
- **Coverage** — qué porcentaje del código está ejecutado por los tests. Se mide con `forge coverage`. El TP final pide ≥ 80%.

---

## 8 · Frontend Web3 💻

- **dApp** — Decentralized Application. Frontend tradicional (Next.js/React) cuyo "backend" es un smart contract on-chain y cuya "auth" es una wallet (visto en clase 4).
- **wagmi** — biblioteca de **React hooks** para Ethereum. Hooks como `useAccount`, `useReadContract`, `useWriteContract`, `useWaitForTransactionReceipt`. Maneja cache, refetching y loading states.
- **viem** — biblioteca low-level (encoding de calldata, ABIs, RPC calls) sobre la que está construida wagmi. Reemplazo moderno de `ethers.js`.
- **RainbowKit** — librería que te da un botón **"Connect Wallet"** listo, con modal y soporte para múltiples wallets. Construido sobre wagmi.
- **Provider / RPC** — endpoint HTTP/WS al que el frontend o `cast` le hacen `eth_call`, `eth_sendTransaction`, etc. Públicos (publicnode, Sepolia.org) o de pago/freemium (Alchemy, Infura).
- **Reading from contract** — con `useReadContract({ address, abi, functionName, args })`. Es gratis, no firma nada, no abre MetaMask.
- **Writing to contract** — con `useWriteContract` + `useWaitForTransactionReceipt`. Abre MetaMask para firmar; estados típicos: `isPending` (esperando firma), `isConfirming` (esperando que mine), `isSuccess`.

---

## 9 · Almacenamiento off-chain 🗄️

- **IPFS (InterPlanetary File System)** — sistema de almacenamiento **distribuido y direccionado por contenido**. En vez de "esta URL", decís "este hash" y el archivo viene de cualquier nodo que lo tenga. Lo usamos para guardar el JSON de metadata y el PDF del título.
- **CID (Content Identifier)** — el hash que identifica un archivo en IPFS, ej: `bafybeih...`. Si dos archivos tienen el mismo contenido, tienen el mismo CID. Si un archivo cambia un bit, cambia el CID entero.
- **Pinning** — pagarle a un nodo IPFS para que **garantice mantener tu archivo** disponible. Sin pin, los nodos pueden borrar tu CID si nadie lo pide hace tiempo.
- **Pinata / web3.storage** — servicios de pinning con plan gratuito. Subís el archivo, te dan el CID, y se aseguran de mantenerlo. El TP final tiene un bonus de +5 puntos por integrar Pinata real.

---

## 10 · Verificación e indexación 🔍

- **Etherscan / Basescan** — block explorers. Web donde pegás una address o tx hash y ves todo: balance, transacciones, eventos, código. `sepolia.etherscan.io` para Sepolia, `sepolia.basescan.org` para Base Sepolia.
- **Verificación de contrato** — subís el source code de Solidity al explorer. El explorer lo recompila y, si el bytecode resultante coincide, queda **"Verified"** y muestra el código + permite llamar funciones desde la web. Obligatorio en el TP final.
- **The Graph** — protocolo descentralizado de indexación. Te permite consultar eventos históricos con GraphQL en vez de barrer logs uno por uno. Útil cuando tu dApp tiene muchos eventos para listar.
- **Subgraph** — schema (GraphQL) + mappings (TypeScript) que define qué eventos de qué contratos indexar y cómo. Se deploya a The Graph y queda accesible vía endpoint GraphQL.

---

## 11 · Seguridad 🔒

- **Slither** — herramienta de **análisis estático** de Solidity (lee el código sin ejecutarlo). Detecta reentrancy, uso inseguro de `tx.origin`, variables no inicializadas, etc. Obligatorio correrlo y reportar en `SECURITY.md` para el TP final (visto en clase 4).
- **Auditoría** — revisión humana profesional de seguridad de un contrato antes de deployar a producción con dinero real. Empresas: Trail of Bits, OpenZeppelin, ConsenSys Diligence. Cuesta decenas de miles de USD.
- **Vulnerabilidades comunes** — **reentrancy** (clase 4); **integer overflow/underflow** (resuelto en Solidity 0.8+ con check automático); **uso de `tx.origin`** para auth (vulnerable a phishing — usar `msg.sender`); **blockhash/timestamp predecible** como fuente de randomness (los validadores los manipulan); **signature replay** (firmar sin nonce o sin chain ID).
- **CWE / SWC** — **Common Weakness Enumeration** (catálogo MITRE de vulnerabilidades software, ej: `CWE-841`). **Smart Contract Weakness Classification** (catálogo específico de Solidity, ej: `SWC-107` = reentrancy). Se citan en `SECURITY.md`.

---

## 12 · Conceptos avanzados (mencionados pero no profundizados) 🧠

- **Verifiable Credentials (W3C VC 2.0)** — estándar W3C (oficial desde 2025) para credenciales digitales firmadas, verificables sin contactar al emisor. Puede correr sobre blockchain o no. Es el modelo conceptual detrás del TP, aunque el TP usa SBT específicamente.
- **Soulbound Tokens (SBT)** — concepto del paper *Decentralized Society: Finding Web3's Soul* (Ohlhaver, Weyl & Buterin, 2022). NFTs **no transferibles** atados a una identidad. Casos: títulos, certificaciones, reputación, membresías.
- **Account Abstraction (ERC-4337)** — propuesta para que las **wallets sean smart contracts** en vez de EOAs. Permite recovery social, pagar gas en otros tokens, batched transactions, sin cambiar el protocolo base de Ethereum.
- **Meta-transactions** — un **relayer** firma y manda la transacción on-chain pagando el gas, en nombre del usuario que solo firma off-chain. UX: el usuario no necesita ETH para usar la dApp.
- **Multisig** — wallet (smart contract) que requiere **N de M firmas** para ejecutar. Implementación más usada: **Gnosis Safe**. Estándar para tesorerías de DAOs y operaciones sensibles.
- **DAO (Decentralized Autonomous Organization)** — organización cuyas decisiones se ejecutan on-chain por votación de los holders de un token de gobernanza. Ejemplos: MakerDAO, Uniswap, ENS.
- **Governance** — los mecanismos on-chain de votación. Típicamente: 1 token = 1 voto, propuestas con tiempo de discusión, quorum mínimo, ejecución vía timelock.

---

> Volver al [material de cursada](index.html)
