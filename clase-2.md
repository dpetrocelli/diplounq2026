# Clase 2 — Foundry + tu primer smart contract

> **Objetivo de hoy**: pasar de "instalé Remix en clase 1 y deployé un contrato con la GUI" a "tengo el toolkit profesional instalado, escribo y testeo contratos desde la terminal, y entiendo el flujo de desarrollo que se usa en la industria".

## ¿Qué vamos a hacer?

### 🏫 En clase (en vivo con David + Ciro) {#en-clase}

1. **Instalar Foundry** (`forge`, `cast`, `anvil`) — el toolkit estándar para desarrollo de smart contracts.
2. **Instalar la extensión de Solidity** en VS Code para tener resaltado de sintaxis y autocompletado.
3. **Clonar el repo del ejercicio** con un proyecto Foundry listo (contrato `SimpleStorage`).
4. **Compilar el contrato** con `forge build` y entender qué genera Foundry.
5. **Caminar por el contrato `SimpleStorage`** línea por línea para entender la sintaxis básica de Solidity.
6. **Correr los 10 tests** con `forge test` y entender cómo funcionan los tests en Foundry.

### 🏠 Tarea para entregar antes de clase 3

1. Asegurarte de que `forge test` te devuelve **10 passed; 0 failed** en tu máquina.
2. Si algo falla en la instalación, postearlo en el foro del campus para resolverlo antes de la próxima clase.
3. Repasar el contrato `SimpleStorage.sol` y el archivo de tests para entender qué hace cada uno.

> El detalle completo de la tarea está al final de esta página. La parte de deploy a Sepolia y verificación en Etherscan se ve en clase 3.

---

## Parte 1 — ¿Qué es Foundry?

**Foundry** es un toolkit para desarrollar smart contracts en Solidity. Es lo que usan empresas como Uniswap, OpenSea y Paradigm en producción. Está escrito en Rust, lo que lo hace **muy** rápido — los tests corren en milisegundos, no segundos.

Foundry trae tres herramientas principales:

| Herramienta | Para qué sirve |
|---|---|
| `forge` | Compilar contratos, correr tests, deployar |
| `cast` | Hablar con la blockchain desde la terminal (leer estado, mandar transacciones) |
| `anvil` | Levantar una blockchain local para desarrollo (lo vamos a usar en clase 3) |

### ¿Por qué Foundry y no Remix?

Remix (lo que vieron en clase 1) es excelente para empezar — todo en el browser, cero instalación. Pero para proyectos reales hace falta más:

| Capacidad | Remix | Foundry |
|---|---|---|
| Editor con autocompletado | Limitado | VS Code con extensión |
| Tests automatizados | No | Sí, con fuzzing incluido |
| Control de versiones (Git) | No | Sí, todo en archivos |
| CI/CD | No | Sí, integra con GitHub Actions |
| Velocidad de compilación | Lenta | 10–100x más rápida |

Por eso el resto del módulo lo hacemos con Foundry.

---

## Parte 2 — Instalación de Foundry

### 2.1 Bajar el instalador

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Esto baja el "manager" de Foundry (que se llama `foundryup`) y lo agrega a tu `PATH`. Te va a decir algo como:

```
Detected your preferred shell is zsh and added foundryup to PATH.
Run 'source /home/usuario/.zshenv' or start a new terminal session to use foundryup.
```

### 2.2 Recargar el shell

Reabrí la terminal **o** corré (según tu shell):

```bash
source ~/.bashrc      # si usás bash
source ~/.zshenv      # si usás zsh
```

### 2.3 Bajar los binarios reales

```bash
foundryup
```

Esto baja `forge`, `cast`, `anvil` y `chisel` (otra herramienta para sesiones interactivas de Solidity). Tarda menos de un minuto.

### 2.4 Verificar que funciona

```bash
forge --version
cast --version
anvil --version
```

Tienen que devolver algo como:

```
forge Version: 1.5.1-stable
cast Version: 1.5.1-stable
anvil Version: 1.5.1-stable
```

> ⚠️ **Si estás en Windows sin WSL**, esto va a fallar. La solución es instalar [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) y correr todo desde adentro de WSL. Si tenés problemas, postealo en el foro y lo resolvemos.

---

## Parte 3 — Extensión de Solidity en VS Code

La extensión te da resaltado de sintaxis, autocompletado y errores inline:

```bash
code --install-extension juanblanco.solidity
```

> Si `code` no es un comando reconocido, abrí VS Code, ejecutá `Ctrl+Shift+P` (Cmd+Shift+P en Mac), escribí "Shell Command: Install 'code' command in PATH", reabrí la terminal y volvé a probar.

---

## Parte 4 — Clonar el repo y compilar

### 4.1 Clonar

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase2.git
cd diplo-unq-blockchain-clase2
```

Vas a ver esta estructura:

```
.
├── foundry.toml          # configuración del proyecto
├── src/
│   └── SimpleStorage.sol # el contrato
├── test/
│   └── SimpleStorage.t.sol # los tests
└── script/
    └── Deploy.s.sol      # script para deployar (lo usamos en clase 3)
```

| Carpeta | Para qué |
|---|---|
| `src/` | Los contratos que escribís. Es la "fuente" del proyecto. |
| `test/` | Los tests. Foundry te los corre con `forge test`. |
| `script/` | Scripts en Solidity para deployar o automatizar. |
| `foundry.toml` | Configuración: versión de Solidity, optimizador, etc. |

### 4.2 Bajar `forge-std`

`forge-std` es una librería estándar que necesitan los tests de Foundry (te da `Test`, `vm`, `console.log`, etc):

```bash
forge install foundry-rs/forge-std --shallow
```

El flag `--shallow` solo baja el último commit (más rápido).

### 4.3 Compilar

```bash
forge build
```

Output esperado:

```
Compiling 23 files with Solc 0.8.28
Solc 0.8.28 finished in ~900ms
Compiler run successful!
```

Foundry crea una carpeta `out/` con el resultado de la compilación. Adentro vas a encontrar `out/SimpleStorage.sol/SimpleStorage.json`, que tiene el **bytecode** (lo que se sube a la blockchain) y el **ABI** (la "interfaz" para interactuar con el contrato).

> 💡 El bytecode es público y leíble. NO está encriptado — solo está compilado a una representación que entiende la EVM (Ethereum Virtual Machine).

---

## Parte 5 — Tour del contrato `SimpleStorage`

Abrí `src/SimpleStorage.sol` en VS Code. Lo desglosamos:

### 5.1 Licencia + pragma

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
```

- **`SPDX-License-Identifier`**: el compilador pide que declares bajo qué licencia liberás el código. `MIT` es la más permisiva.
- **`pragma solidity ^0.8.19`**: la versión mínima del compilador. El `^` significa "0.8.19 o cualquier 0.8.x posterior, pero NO 0.9.x".

### 5.2 Declaración del contrato

```solidity
contract SimpleStorage {
    // ...
}
```

Un contrato en Solidity es como una clase en lenguajes orientados a objetos: agrupa estado y funciones.

### 5.3 Variable de estado

```solidity
uint256 public favoriteNumber;
```

- **`uint256`**: entero sin signo de 256 bits. Es el tipo "default" en Solidity.
- **`public`**: cualquiera puede leer este valor desde afuera. Solidity te genera **automáticamente** una función `favoriteNumber()` que la devuelve.
- El estado vive **on-chain** y persiste entre transacciones.

### 5.4 Evento

```solidity
event NumberUpdated(
    uint256 oldNumber,
    uint256 newNumber,
    address indexed updatedBy
);
```

Los eventos son "logs" que el contrato emite y que quedan registrados en la blockchain. La palabra `indexed` permite filtrar después: en Etherscan vas a poder buscar todos los `NumberUpdated` emitidos por una address específica.

### 5.5 Función que escribe estado

```solidity
function store(uint256 _number) public {
    uint256 oldNumber = favoriteNumber;
    favoriteNumber = _number;
    emit NumberUpdated(oldNumber, _number, msg.sender);
}
```

- **`public`**: cualquiera puede llamarla.
- **`msg.sender`**: variable global de Solidity que contiene la address que llamó a la función ahora.
- **`emit`**: dispara el evento.
- Como modifica estado, esta función **cuesta gas**.

### 5.6 Función `view`

```solidity
function retrieve() public view returns (uint256) {
    return favoriteNumber;
}
```

- **`view`**: declara que la función solo lee, no modifica estado. Si la llamás desde afuera (sin transacción), **no cuesta gas**.

### 5.7 Función que incrementa

```solidity
function increment() public {
    uint256 oldNumber = favoriteNumber;
    favoriteNumber += 1;
    emit NumberUpdated(oldNumber, favoriteNumber, msg.sender);
}
```

Igual que `store`, pero suma 1 en vez de aceptar un parámetro.

---

## Parte 6 — Tests con Foundry

### 6.1 Correr todos los tests

```bash
forge test
```

Output esperado:

```
Ran 10 tests for test/SimpleStorage.t.sol:SimpleStorageTest
[PASS] testFuzz_IncrementNoOverflow(uint256) (runs: 256, ...)
[PASS] testFuzz_Store(uint256) (runs: 256, ...)
[PASS] test_AnyoneCanStore() ...
[PASS] test_EventRecordsCorrectCaller() ...
[PASS] test_Increment() ...
[PASS] test_IncrementEmitsEvent() ...
[PASS] test_InitialValueIsZero() ...
[PASS] test_RetrieveMatchesFavoriteNumber() ...
[PASS] test_StoreEmitsEvent() ...
[PASS] test_StoreNumber() ...
Suite result: ok. 10 passed; 0 failed; 0 skipped
```

### 6.2 ¿Qué hay adentro de los tests?

Abrí `test/SimpleStorage.t.sol`. Las cosas clave:

- **`setUp()`**: se ejecuta antes de **cada** test. Acá se crea un contrato fresco para que cada test arranque limpio.
- **`assertEq(a, b)`**: la aserción más usada. Si `a != b`, el test falla.
- **`vm.prank(alice)`**: cheatcode mágico de Foundry. La próxima llamada se hace **como si** la hiciera la address `alice`. Sirve para testear que solo el owner puede llamar ciertas funciones.
- **`vm.expectEmit(...)`**: la próxima transacción tiene que emitir el evento exacto que se especifica después.
- **`testFuzz_*`**: tests con fuzzing. Foundry genera 256 valores random para los argumentos y corre el test 256 veces. Encuentra edge cases que no se te ocurrieron.

### 6.3 Más detalle

Para ver el call trace completo de un test específico:

```bash
forge test --match-test test_StoreNumber -vvvv
```

Vas a ver paso a paso qué llamó a qué, qué eventos se emitieron, cuánto gas se gastó.

---

## Parte 7 — ¿Qué viene en clase 3?

En clase 3 vamos a usar todo lo de hoy más:

- **Anvil**: levantar una blockchain local en tu máquina para deployar y testear sin gastar gas real.
- **`cast`**: leer y escribir al contrato desde la terminal (`cast call` y `cast send`).
- **Deploy a Sepolia**: subir el contrato a una blockchain real (testnet) y verlo en [Etherscan](https://sepolia.etherscan.io/).
- **NFTs (ERC-721)**: empezar a construir el contrato de **credenciales académicas** que es la base del trabajo final.

---

## 🏠 Tarea para entregar antes de clase 3 {#tarea}

**Plazo**: lunes 04/05 a las 18:00 (antes de que arranque clase 3).

**Cómo se entrega**: postear en el foro del módulo en el campus.

**Qué tienen que hacer**:

1. **Verificar que `forge test` te devuelve `10 passed; 0 failed`** en tu máquina. Postear una captura del output como respuesta al hilo del módulo en el foro.
2. **Postear en el foro cualquier problema de instalación** que no hayan podido resolver. Mejor que lo mandes hoy mismo así llegamos a clase 3 con todos preparados.
3. **(Opcional, recomendado)** Leer `src/SimpleStorage.sol` y `test/SimpleStorage.t.sol` con calma. Probá modificar algo del contrato (por ejemplo, agregar una función `decrement()`) y ver si los tests siguen pasando.

---

## Si algo falla

| Problema | Solución |
|---|---|
| `foundryup` falla en Windows | Instalar [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) y correr todo desde adentro |
| `forge install` falla por proxy o red | Probar con VPN o desde otra red. Si seguís sin poder, postealo en el foro |
| `forge build` da error de versión de Solidity | Confirmá que `foundry.toml` tiene `solc = "0.8.28"` (no 0.8.19) |
| `code` no es comando reconocido | Abrí VS Code → `Ctrl+Shift+P` → "Shell Command: Install 'code' command in PATH" |
| Algún test falla | Postealo en el foro con el output completo de `forge test -vvv` |

Lo demás, foro del campus.
