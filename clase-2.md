---
title: "Guion clase 2 — Diplomatura Blockchain UNQ"
subtitle: "Lo que digo, lo que hago, lo que sale"
author: "David Petrocelli"
date: "2026-04-27 — 18:00 a 19:35"
geometry: "margin=2cm"
fontsize: 11pt
---

# Slide de apertura — qué vamos a cubrir hoy

Mostrar este resumen al inicio (proyectarlo o tenerlo de fondo durante la intro):

> **Clase 2 — De Remix a la línea de comandos**
>
> 1. **Repaso clase 1** y respuesta a las dudas que quedaron al aire
> 2. **Instalación de Foundry** (forge / cast / anvil) y extensión Solidity de VS Code
> 3. **Clonar el repo del ejercicio**:
>    `git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase2.git`
> 4. **Compilar y entender** un smart contract: bytecode + ABI
> 5. **Tour de Solidity**: state variables, eventos, funciones, visibility
> 6. **Tests automáticos con Foundry**: assertions, cheatcodes, fuzz testing
> 7. **Anvil**: blockchain local para desarrollo, deploy y `cast` interactivo
> 8. **Deploy real a Sepolia** y verificación en Etherscan
> 9. **Tarea** y handoff a Ciro
>
> *Objetivo: al terminar esta clase tienen el flujo profesional completo — write, test, deploy local, deploy testnet — funcionando en su máquina.*

## Repo del ejercicio (público)

> **<https://github.com/dpetrocelli/diplo-unq-blockchain-clase2>**

Los alumnos solo necesitan eso. Un único `git clone` y arrancan. El repo tiene:

- `src/SimpleStorage.sol` — el contrato
- `test/SimpleStorage.t.sol` — los tests (10 tests, todos verdes)
- `script/Deploy.s.sol` — script de deploy
- `foundry.toml` — configuración (solc 0.8.28, fuzz runs 256)
- `README.md` — instrucciones mínimas con los comandos clave

> **Verificado**: `git clone` → `forge install foundry-rs/forge-std --shallow` → `forge build` → `forge test` da **10 passed; 0 failed**.

---

# 0. Pre-flight: qué está instalado y cómo lo instalé

Esto YA está corriendo en tu máquina. Si querés repetir el setup en otro lado o ayudar a un alumno trabado, son exactamente estos comandos.

## 0.1 — Instalación de Foundry

```bash
# Bajar el instalador (foundryup)
curl -L https://foundry.paradigm.xyz | bash
```

**Output esperado**: te dice que detectó tu shell (zsh o bash), agrega el PATH a tu rc file, y te pide reabrir terminal o hacer `source`.

```bash
# Recargar el shell (zsh) o reabrir terminal
source ~/.zshenv      # zsh
# source ~/.bashrc    # bash

# Bajar los binarios reales (forge, cast, anvil, chisel)
foundryup
```

**Output esperado** (1 min aprox):

```
foundryup: installing foundry (version stable, tag stable)
foundryup: downloading forge, cast, anvil, and chisel for stable version
forge
cast
anvil
chisel
foundryup: forge verified ✓
foundryup: cast verified ✓
foundryup: anvil verified ✓
foundryup: chisel verified ✓
```

```bash
# Verificar que están en el PATH
forge --version
cast --version
anvil --version
```

**Output**:

```
forge Version: 1.5.1-stable
cast Version: 1.5.1-stable
anvil Version: 1.5.1-stable
```

> **Plan B si falla**: en Windows sin WSL, esto no anda. Solución: instalar WSL2. Mientras se instala, ese alumno hace Remix.

## 0.2 — Setup del proyecto (cosas que tuve que arreglar)

El proyecto `module-2/simple-storage` venía limpio (sin `lib/` y sin `.git/`). Para que `forge install` funcione, hace falta un repo git inicializado:

```bash
cd /home/dp-note/code/teacher/blockchain-development/class-content/module-2/simple-storage
git init -q
forge install foundry-rs/forge-std --shallow
```

**Output**:

```
Installing forge-std in .../lib/forge-std (url: https://github.com/foundry-rs/forge-std)
Cloning into '.../lib/forge-std'...
    Installed forge-std
```

> **Nota**: la sintaxis vieja `--no-commit` ya no existe en Foundry 1.5+. Es `--shallow` ahora.

## 0.3 — Fix necesario en `foundry.toml`

El `foundry.toml` original tenía dos cosas que rompían con Foundry 1.5+:

1. `solc = "0.8.19"` — pero el test usa la sintaxis `SimpleStorage.NumberUpdated(...)` que requiere Solidity **0.8.21+**
2. `fuzz_runs = 256` — la sintaxis vieja, ahora va en bloque `[fuzz]`

**Ya lo arreglé**, queda así:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.28"

# Optimizer settings
optimizer = true
optimizer_runs = 200

# Testing
[fuzz]
runs = 256
```

## 0.4 — Verificación final del proyecto

```bash
forge build
```

**Output**:

```
Compiling 23 files with Solc 0.8.28
Solc 0.8.28 finished in 908ms
Compiler run successful!
```

```bash
forge test
```

**Output**:

```
Ran 10 tests for test/SimpleStorage.t.sol:SimpleStorageTest
[PASS] testFuzz_IncrementNoOverflow(uint256) (runs: 256, μ: 35977, ~: 35977)
[PASS] testFuzz_Store(uint256) (runs: 256, μ: 29577, ~: 30199)
[PASS] test_AnyoneCanStore() (gas: 41137)
[PASS] test_EventRecordsCorrectCaller() (gas: 36524)
[PASS] test_Increment() (gas: 33023)
[PASS] test_IncrementEmitsEvent() (gas: 36730)
[PASS] test_InitialValueIsZero() (gas: 7570)
[PASS] test_RetrieveMatchesFavoriteNumber() (gas: 30900)
[PASS] test_StoreEmitsEvent() (gas: 33869)
[PASS] test_StoreNumber() (gas: 30118)
Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 29.06ms
```

> **Nota**: El repo público está limpio (10 tests, sin `test_DoubleIncrement`). Ese test lo escribimos en vivo con los alumnos en el bloque 3.4.

## 0.5 — Verificación de Sepolia (sin gastar tokens)

```bash
cast chain-id --rpc-url https://ethereum-sepolia-rpc.publicnode.com
# 11155111

cast block-number --rpc-url https://ethereum-sepolia-rpc.publicnode.com
# 10744491 (o el bloque actual)

cast gas-price --rpc-url https://ethereum-sepolia-rpc.publicnode.com
# 36689734 (gwei en wei, ~36 gwei)
```

---

# 1. Mapa de tiempos

| Slot | Duración | Quién | Qué |
|---|---|---|---|
| 18:00 – 18:15 | 15 min | David | Intro + repaso clase 1 + Q&A pendiente + check faucets |
| 18:15 – 19:00 | 45 min | David | Foundry: install → build → tour SimpleStorage → tests |
| 19:00 – 19:05 | 5 min | — | Break corto |
| 19:05 – 19:35 | 30 min | David | Anvil + cast local → deploy a Sepolia → verify en Etherscan |
| 19:35 – fin | — | Ciro | Cierre, anticipo Mod 3, dudas finales |

**Material base**: `/home/dp-note/code/teacher/blockchain-development/class-content/module-2/`

**Decisión de stack**: Foundry + VS Code + **Sepolia** (no Base Sepolia, para mantener continuidad con clase 1 de Ciro). Base Sepolia se introduce en Mod 3.

---

# 2. Bloque 1 — Intro + repaso (18:00 – 18:15, 15 min)

## 2.1 — Saludo (2 min)

> *"Buenas, ¿cómo andan? Bienvenidos a la clase 2 del módulo de desarrollo de smart contracts. Soy David, hoy doy la primera parte y al final me toma la posta Ciro. Primero lo bueno: los foros del campus están arreglados, ya pueden postear. Si tuvieron algún problema con la faucet la semana pasada, en 5 minutos lo resolvemos. La idea de hoy es bajar de Remix a la línea de comandos, con la herramienta que se usa profesionalmente. Eso es Foundry."*

## 2.2 — Repaso lightning de clase 1 (3 min)

> *"Recordemos qué hicieron la semana pasada con Ciro. Instalaron MetaMask, agregaron la red Sepolia, pidieron tokens a una faucet, abrieron Remix en el navegador, escribieron un contratito, lo desplegaron y le mandaron transacciones. Todo eso desde una interfaz gráfica.*
>
> *Hoy vamos a hacer exactamente lo mismo — escribir un contrato, deployarlo, interactuar — pero desde la terminal, con Foundry. ¿Por qué? Porque cuando tu proyecto crece, vas a querer tests automáticos, control de versiones, scripts reproducibles, integración con CI/CD. Eso Remix no te lo da. Foundry sí."*

## 2.3 — Q&A pendiente (5 min)

Tres dudas que quedaron sin cerrar bien la semana pasada:

### Pregunta 1 — Alfredo: "¿qué tipo de archivo es la blockchain?"

> *"Alfredo preguntó la semana pasada qué tipo de archivo es la blockchain. La respuesta corta: en cada nodo, la blockchain vive como una **base de datos clave-valor en disco**. El cliente Geth usa LevelDB, el cliente Erigon usa MDBX. No es un archivo de texto. Cada nodo tiene su copia, y se sincronizan entre sí por el algoritmo de consenso que vimos. Entonces cuando hablamos de 'la blockchain', es una BD distribuida, replicada en miles de nodos, con un mecanismo de consenso que asegura que todos vean lo mismo."*

### Pregunta 2 — Alfredo: "¿Ethereum está en C++ o en Rust?"

> *"La trampa de esta pregunta es que **Ethereum no es un programa, es una especificación**. Lo que existe son varios programas distintos — los llamamos 'clientes' — que implementan esa especificación, cada uno en el lenguaje que quiso su equipo:*
>
> - *Geth, en Go, es históricamente el más usado*
> - *Reth, en Rust, está creciendo rápido*
> - *Erigon en Go, Nethermind en .NET, Besu en Java*
>
> *Esto se llama **client diversity** y es clave para la seguridad: si todos los nodos corrieran el mismo software, un bug podría tirar Ethereum entera. Con varios clientes, un bug en uno solo no rompe la red."*

### Pregunta 3 — anónimo: "¿el contrato queda encriptado en la blockchain?"

> *"No, queda **público y leíble**. Lo que ven en Etherscan como hex largo es **bytecode EVM**, que NO es lo mismo que estar encriptado. Lo podés descompilar. Cualquiera puede. Lo que define cómo invocarlo se llama el **ABI** — el manual de uso del contrato. En 5 minutos, cuando hagamos `forge build`, les voy a mostrar exactamente eso: el bytecode y el ABI generados a partir del Solidity."*

## 2.4 — Check operativo (5 min)

> *"Antes de meternos: ¿quién todavía no tiene tokens en su MetaMask en Sepolia? Levanten la mano. La faucet que mejor anda hoy es esta:"*

```
https://cloud.google.com/application/web3/faucet/ethereum/sepolia
```

> *"Logueás con cuenta de Google, pegás tu address de MetaMask y te tira 0.05 ETH de Sepolia. Mientras los rezagados piden tokens, el resto: abran VS Code y una terminal."*

---

# 3. Bloque 2 — Foundry: install → build → tests (18:15 – 19:00, 45 min)

## 3.1 — Instalación de Foundry y extensión Solidity (10 min)

> *"Foundry es un toolkit escrito en Rust, mucho más rápido que Hardhat, donde los tests se escriben en Solidity. Eso es importante: el mismo lenguaje del contrato es el lenguaje de los tests. No tenés que aprender otra cosa.*
>
> *Tres comandos que vamos a ver mucho hoy:*
>
> - *`forge`: compilar, testear, deployar*
> - *`cast`: hablar con la blockchain desde la terminal*
> - *`anvil`: blockchain local para desarrollo*
>
> *Tres pasos: instalar Foundry, instalar la extensión Solidity, y verificar."*

### Paso 1 — Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
```

> *"Eso instala el gestor `foundryup`. Reabrimos la terminal o hacemos source:"*

```bash
source ~/.bashrc      # bash
# source ~/.zshenv    # zsh
foundryup
```

> *"Eso baja los binarios reales. Tarda menos de un minuto."*

### Paso 2 — Extensión Solidity de VS Code

Una sola extensión, la mínima necesaria. Resaltado de sintaxis y autocompletado:

```bash
code --install-extension juanblanco.solidity
```

> *"Si quieren más adelante pueden agregar `tamasfe.even-better-toml` para el foundry.toml y `esbenp.prettier-vscode` para formateo, pero hoy con esta una alcanza."*

### Paso 3 — Verificar

```bash
forge --version
cast --version
anvil --version
```

**Output esperado**:

```
forge Version: 1.5.1-stable
cast Version: 1.5.1-stable
anvil Version: 1.5.1-stable
```

> *"Si están en Windows sin WSL, esto va a fallar. La solución es instalar WSL2. Si alguien tiene ese problema, lo resolvemos individual y mientras tanto hace Remix."*

## 3.2 — Clonar el repo del ejercicio y `forge build` (10 min)

> *"Ahora clonamos el repo del ejercicio. Es público, está en mi GitHub, una sola línea:"*

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase2.git
cd diplo-unq-blockchain-clase2
```

```bash
ls
```

**Output esperado**:

```
README.md  foundry.toml  script  src  test
```

> *"Esa es la estructura clásica de un proyecto Foundry:*
>
> - *`src/` — los contratos*
> - *`test/` — los tests*
> - *`script/` — scripts de deploy*
> - *`foundry.toml` — configuración*
>
> *Antes de compilar tenemos que bajar la única dependencia que usa: `forge-std`, la librería estándar de Foundry para escribir tests."*

```bash
forge install foundry-rs/forge-std --shallow
```

**Output esperado**:

```
Installing forge-std in lib/forge-std
Cloning into 'lib/forge-std'...
    Installed forge-std
```

> *"Eso clona forge-std en `lib/`. Ahora compilamos:"*

```bash
forge build
```

**Output esperado**:

```
Compiling 23 files with Solc 0.8.28
Solc 0.8.28 finished in 908ms
Compiler run successful!
```

> *"23 archivos en menos de un segundo. Eso es Rust corriendo el compilador, mucho más rápido que Hardhat. Ahora les muestro algo importante. Esto compiló y dejó la salida en una carpeta `out/`."*

```bash
ls out/SimpleStorage.sol/
```

```bash
cat out/SimpleStorage.sol/SimpleStorage.json | jq '.bytecode.object' | head -c 250
```

**Output esperado**:

```
"0x6080604052348015600e575f5ffd5b5061019d8061001c5f395ff3fe608060...
```

> *"Esto que ven es el **bytecode** del contrato. Esto es exactamente lo que se sube a la blockchain. Lo que está adentro de la EVM. ¿Se ve que es leíble? Es hex, pero hay disassemblers. No está encriptado. Esa era la duda que dejamos al aire."*

```bash
cat out/SimpleStorage.sol/SimpleStorage.json | jq '.abi'
```

**Output esperado** (extracto):

```json
[
  {
    "type": "function",
    "name": "favoriteNumber",
    "inputs": [],
    "outputs": [{"name": "", "type": "uint256"}],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "store",
    "inputs": [{"name": "_number", "type": "uint256"}],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "NumberUpdated",
    "inputs": [
      {"name": "oldNumber", "type": "uint256", "indexed": false},
      {"name": "newNumber", "type": "uint256", "indexed": false},
      {"name": "updatedBy", "type": "address", "indexed": true}
    ]
  }
]
```

> *"Y esto es el **ABI**. Es el manual del contrato. Lo que un frontend, o cast, o Remix, usa para saber cómo llamar a `store(uint256)` o cómo decodificar el resultado de `favoriteNumber()`. Bytecode + ABI = todo lo que necesita el mundo para hablarle a este contrato."*

## 3.3 — Tour de `SimpleStorage.sol` (10 min)

Abrir `src/SimpleStorage.sol` en VS Code y caminar línea por línea:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage {
    uint256 public favoriteNumber;

    event NumberUpdated(
        uint256 oldNumber,
        uint256 newNumber,
        address indexed updatedBy
    );

    function store(uint256 _number) public {
        uint256 oldNumber = favoriteNumber;
        favoriteNumber = _number;
        emit NumberUpdated(oldNumber, _number, msg.sender);
    }

    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    function increment() public {
        uint256 oldNumber = favoriteNumber;
        favoriteNumber += 1;
        emit NumberUpdated(oldNumber, favoriteNumber, msg.sender);
    }
}
```

**Línea 1-2 — license + pragma**:

> *"`SPDX-License-Identifier: MIT` — el compilador te exige declarar la licencia. Es metadata, no afecta la lógica.*
> *`pragma solidity ^0.8.19` — versión mínima del compilador. El `^` significa 'esta versión o cualquier 0.8.x posterior'. La `0.8` es importante: desde la 0.8 el compilador detecta overflow automáticamente, no como Solidity 0.7 donde te tenías que defender vos."*

**Línea 14 — state variable**:

> *"`uint256 public favoriteNumber` — variable de estado, vive en el storage del contrato. Es persistente, sobrevive entre transacciones. El modificador `public` es magia: Solidity te genera automáticamente un getter llamado `favoriteNumber()`. Eso responde a la pregunta de cómo se interactúa con un contrato — algunas cosas son funciones explícitas, otras Solidity te las genera."*

**Líneas 16-20 — event**:

> *"`event NumberUpdated(uint256 oldNumber, uint256 newNumber, address indexed updatedBy)` — esto es un log. Se queda en la blockchain pero no en el storage del contrato — vive aparte, en los receipts de las transacciones. Es mucho más barato que escribir storage. La palabra clave `indexed` permite filtrar por ese campo después. En 30 minutos vamos a ver esto exacto en Etherscan."*

**Líneas 22-26 — store**:

> *"Una función pública que escribe estado y emite el evento. `msg.sender` es la address del que está llamando ahora. Cada vez que se llama una función, `msg.sender` cambia."*

**Línea 28 — retrieve**:

> *"Función `view` — declara que solo lee, no modifica. Si la llamás desde fuera, no cuesta gas. Si la llamás desde otro contrato, sí cuesta porque ese otro contrato sí está pagando gas."*

## 3.4 — Tests (15 min)

> *"Ahora la parte que Remix no les daba: tests automatizados."*

```bash
forge test
```

**Output esperado**:

```
Ran 10 tests for test/SimpleStorage.t.sol:SimpleStorageTest
[PASS] testFuzz_IncrementNoOverflow(uint256) (runs: 256, μ: 35977)
[PASS] testFuzz_Store(uint256) (runs: 256, μ: 29577)
[PASS] test_AnyoneCanStore() (gas: 41137)
[PASS] test_EventRecordsCorrectCaller() (gas: 36524)
[PASS] test_Increment() (gas: 33023)
[PASS] test_IncrementEmitsEvent() (gas: 36730)
[PASS] test_InitialValueIsZero() (gas: 7570)
[PASS] test_RetrieveMatchesFavoriteNumber() (gas: 30900)
[PASS] test_StoreEmitsEvent() (gas: 33869)
[PASS] test_StoreNumber() (gas: 30118)
Suite result: ok. 10 passed; 0 failed; 0 skipped
```

> *"10 tests, 30 milisegundos. En Remix esto era imposible. Vamos a abrir el archivo y entender qué hace cada uno."*

Abrir `test/SimpleStorage.t.sol`:

> *"`setUp()` — se ejecuta antes de **cada** test. Cada test arranca con un contrato limpio. Si test 1 cambia el favoriteNumber, test 2 no lo ve.*
>
> *`assertEq(a, b)` — la aserción más usada. Si `a != b`, falla el test.*
>
> *`vm.prank(alice)` — esto es magia de Foundry. La próxima llamada se hace **como si** la hiciera la address `alice`. Sirve para testear que solo el owner puede llamar `transferOwnership`, por ejemplo.*
>
> *`vm.expectEmit(true, true, true, true)` — la próxima transacción debe emitir el evento exacto que viene después.*
>
> *`testFuzz_Store(uint256 _number)` — esto se llama **fuzz testing**. Foundry te genera 256 valores random para `_number`, corre el test 256 veces, y si alguno falla te lo muestra. Encuentra bugs que vos nunca pensaste."*

### Ejercicio en vivo: agregar `test_DoubleIncrement` (8 min)

> *"Vamos a escribir un test juntos. La idea: si llamo `increment()` dos veces seguidas, el número tiene que aumentar en 2. ¿Cómo lo escribirían?"*

(Que un alumno dicte. Implementar esto al final del archivo, dentro del contract:)

```solidity
function test_DoubleIncrement() public {
    simpleStorage.store(5);
    simpleStorage.increment();
    simpleStorage.increment();
    assertEq(simpleStorage.favoriteNumber(), 7);
}
```

> *"Ese 7 es a propósito: arrancamos en 5, sumamos 1 dos veces, da 7. Corrámoslo:"*

```bash
forge test --match-test test_DoubleIncrement -vvv
```

**Output esperado**:

```
[PASS] test_DoubleIncrement() (gas: 35838)
Suite result: ok. 1 passed; 0 failed
```

> *"Pasa. Ahora vamos a hacer algo educativo: lo rompemos a propósito. Cambien el 7 por un 8 y corran de nuevo."*

```bash
forge test --match-test test_DoubleIncrement -vvv
```

**Output esperado** (al fallar):

```
[FAIL: assertion failed: 7 != 8] test_DoubleIncrement()
```

> *"¿Ven? Te dice exactamente cuál fue el valor real (7) y cuál esperabas (8). Esto es un loop de feedback de **milisegundos**. Después de 5 fails sentís que estás en `pdb` con el contrato. Vuelvan a ponerlo en 7 y compilen para volver al verde."*

---

# 4. Break (19:00 – 19:05, 5 min)

> *"5 minutos, agua, estiren las piernas. Cuando volvemos, lo mejor: deploy real."*

---

# 5. Bloque 3 — Anvil + deploy real (19:05 – 19:35, 30 min)

## 5.1 — Anvil: blockchain local instantánea (8 min)

> *"Antes de gastar nuestros tokens de Sepolia que tanto nos costó conseguir, vamos a probar todo en una blockchain local. Foundry trae una herramienta llamada **anvil** que es exactamente eso: una Ethereum local, en tu máquina, con cuentas pre-cargadas, transacciones instantáneas, gratis."*

**Terminal 1**:

```bash
anvil
```

**Output esperado**:

```
                             _   _
                            (_) | |
      __ _   _ __   __   __  _  | |
     / _` | | '_ \  \ \ / / | | | |
    | (_| | | | | |  \ V /  | | | |
     \__,_| |_| |_|   \_/   |_| |_|

    1.5.1-stable

Available Accounts
==================
(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
... (10 cuentas, todas con 10000 ETH)

Private Keys
==================
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
... (10 priv keys públicas, NO USAR EN MAINNET)

Listening on 127.0.0.1:8545
```

> *"Tienen 10 cuentas con 10.000 ETH cada una. Estos private keys son **públicos**, todo el mundo los conoce, **jamás** usar en mainnet. Pero para desarrollo, oro puro. Esta blockchain corre en `localhost:8545`."*

## 5.2 — Deploy local con `forge create` (5 min)

**Terminal 2** (dejar anvil corriendo en la 1):

```bash
cd module-2/simple-storage
```

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

**Output esperado**:

```
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Transaction hash: 0x01f608d7772dd19b56596ff20e69c3893ca1fe6856487c186adc7c9720dcc7a9
```

> *"Listo, contrato deployado a `0x5FbD...0aa3`. Esa address es **determinística** en anvil — si reinician anvil y hacen el primer deploy, siempre les da la misma. Eso ayuda mucho cuando estás iterando.*
>
> *Guardamos la address en una variable para no copiarla cada vez:"*

```bash
export ADDR=0x5FbDB2315678afecb367f032d93F642f64180aa3
```

## 5.3 — Interactuar con `cast` (7 min)

> *"`cast` es como curl pero para blockchain. Vamos a leer el estado, escribirlo, y leer de nuevo."*

**Leer el valor inicial** (gratis, no manda transacción):

```bash
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

**Output**:

```
0
```

> *"Cero, perfecto, contrato recién deployado. `cast call` es free, no manda transacción, solo consulta."*

**Escribir un valor** (esto sí es transacción y gasta gas):

```bash
cast send $ADDR "store(uint256)" 42 \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

**Output esperado** (extracto):

```
blockNumber          2
gasUsed              45277
status               1 (success)
transactionHash      0x6a201cdc4ea688550f8e088bf1a08ee7047480fb3a2cc7459860521c468fb7d5
logs                 [{"topics":["0x2b78c2c16beca88a8dce3d4d00cfce4cf73f6daca288a7fdc65f29c97d045fe6","0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266"],"data":"0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a"}]
```

> *"Status 1 = éxito. Gas usado: 45.277. Y miren los `logs`: ahí está el evento `NumberUpdated`. Ese `2a` al final del data es **42 en hex**. El evento se emitió.*
>
> *Y no es una casualidad: el `topic[0]` que ven es el hash de la firma del evento. Lo podemos calcular:"*

```bash
cast keccak "NumberUpdated(uint256,uint256,address)"
```

**Output**:

```
0x2b78c2c16beca88a8dce3d4d00cfce4cf73f6daca288a7fdc65f29c97d045fe6
```

> *"Mismo número que el `topic[0]` del log. Eso es lo que permite a un frontend filtrar 'dame todos los `NumberUpdated` de este contrato'."*

**Leer de nuevo**:

```bash
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

**Output**:

```
42
```

> *"42. Esto es lo mismo que hicieron en Remix la semana pasada con los botones azules. Mismo concepto, otra interfaz."*

**Bonus — Increment**:

```bash
cast send $ADDR "increment()" \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

```bash
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

**Output**:

```
43
```

## 5.4 — Deploy a Sepolia + Etherscan (10 min)

> *"Ahora lo subimos a la blockchain real. Sepolia. Misma red que la semana pasada con Remix. Antes de eso, una clave de seguridad: **nunca expongan su private key en pantalla compartida si tiene fondos reales**. Lo que vamos a usar es una cuenta de prueba, solo para Sepolia."*

**Importar private key como cast wallet** (recomendado, evita escribir la key en pantalla):

```bash
cast wallet import dev-wallet --interactive
```

> *"Te pide la priv key (la que copiaste de MetaMask) y una contraseña. La encripta y la guarda. Después usás `--account dev-wallet` y te pide la contraseña en cada deploy."*

**Verificar Sepolia online**:

```bash
cast chain-id --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

**Output**:

```
11155111
```

> *"11.155.111 es el chain ID oficial de Sepolia. Sirve también para responder la duda de la semana pasada: '¿cómo sé que es testnet?'. Porque chainlist.org te lista todas las redes con su chain ID y dice cuáles son testnet."*

```bash
cast block-number --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

**Output**: número de bloque actual (ej: `10744491`)

```bash
cast gas-price --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

**Output**: gas price actual en wei (ej: `36689734` = ~36 gwei)

**Deploy real** (esto SÍ gasta tokens de Sepolia):

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```

**Output esperado** (~12 segundos):

```
Deployer: 0x... (tu cuenta)
Deployed to: 0x... (nueva address en Sepolia)
Transaction hash: 0x...
```

> *"Eso tarda 12 segundos porque Sepolia tiene bloques cada ~12 segundos. Anvil era instantáneo, esto no."*

**Abrir Etherscan**:

```
https://sepolia.etherscan.io/address/[ADDRESS_AQUI]
```

> *"Esa es la address en la blockchain real. Si abren la transacción de creación, van a ver el bytecode — el mismo hex que vimos al principio en `out/`. Click en 'Contract' → 'Code' verán que dice 'Source code not verified'. Eso queda como tarea: verificarlo. Pero el bytecode ya está, es público, cualquiera puede llamar funciones."*

**Mandar una transacción que emita evento**:

```bash
cast send $ADDR "store(uint256)" 123 \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet
```

> *"Esperan 12 segundos, recargan Etherscan y van al tab 'Logs'. Van a ver el evento `NumberUpdated` decodificado: `oldNumber=0`, `newNumber=123`, y `updatedBy` con su address. Ese `indexed` que pusimos en el evento es lo que permite a Etherscan filtrar por la address que llamó. Eso cierra el loop completo: del Solidity al log decodificado en el explorador."*

---

# 6. Handoff a Ciro (19:35)

**Resumen express para arrancar el cierre**:

> *"Para cerrar mi parte: hoy bajamos del Remix de la clase pasada a la línea de comandos. Instalamos Foundry, escribimos un contrato Solidity, lo testeamos con `forge test` y agregamos un test nuevo en vivo, lo deployamos local con anvil, y después lo deployamos real a Sepolia y vimos el evento decodificado en Etherscan. Esto es el flujo profesional. La próxima clase con Ciro arrancan con módulo 3: reemplazamos este `SimpleStorage` por un token ERC-20 con OpenZeppelin y le ponemos un frontend en React. Te paso, Ciro."*

## Tarea para la próxima

1. Agregar función `decrement()` con `require(favoriteNumber > 0, "underflow")` en `SimpleStorage.sol`
2. Escribir test que valide el revert con `vm.expectRevert("underflow")`
3. Hacer deploy a Sepolia y postear el address en el foro
4. (Opcional) Verificar el contrato en Etherscan con `forge verify-contract`

---

# 7. Riesgos y planes B

| Riesgo | Plan B en vivo |
|---|---|
| `foundryup` falla en Windows sin WSL | Que ese alumno siga con Remix por hoy. WSL2 install link al foro. |
| `forge install forge-std` falla | El proyecto ya tiene `lib/forge-std/` instalado |
| Faucet no da tokens en vivo | Pasar a Google Cloud faucet. Si igual no anda, deploy a anvil y mostrar Sepolia con un contrato pre-deployado tuyo |
| Alumno expone priv key real | Cortar inmediatamente. Recordar que tiene que crear una cuenta nueva en MetaMask solo para esto |
| RPC público de Sepolia rate-limited / lento | Plan B URL: `https://rpc.sepolia.org` o `https://sepolia.gateway.tenderly.co` |
| `forge create` tarda 30+ segundos en Sepolia | Normal por congestión. Si pasan 60s sin confirmación, mostrar `cast tx <hash>` para chequear estado |
| Algún test en vivo falla por typo | Es educativo. Leer juntos el error de Foundry, arreglar, correr de nuevo |

---

# 8. Checklist final pre-clase (chequear 10 min antes)

- [ ] `forge --version`, `cast --version`, `anvil --version` funcionan
- [ ] `git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase2.git` corre limpio
- [ ] En el repo clonado: `forge install foundry-rs/forge-std --shallow && forge build && forge test` → **10 verde**
- [ ] `anvil` arranca y muestra las 10 cuentas
- [ ] `cast chain-id --rpc-url https://ethereum-sepolia-rpc.publicnode.com` devuelve `11155111`
- [ ] MetaMask abierta, en Sepolia, con saldo > 0.01 ETH
- [ ] VS Code con extensión Solidity (`juanblanco.solidity`) instalada
- [ ] 2 terminales abiertas (anvil + cast)
- [ ] Etherscan Sepolia abierto en pestaña
- [ ] Faucet de Google Cloud abierta en pestaña
- [ ] Pantalla compartida testeada con fuente legible (sugerencia: VS Code zoom 1.5x, terminal 16pt)
- [ ] URL del repo a la mano para pegarla en el chat: <https://github.com/dpetrocelli/diplo-unq-blockchain-clase2>
