# Clase 1 — Fundamentos + tu primer contrato en Remix

> **Objetivo de hoy**: salir de la clase con **Metamask instalado**, **ETH de testnet en Sepolia** y un **contrato deployado** en la red de prueba. La teoría va en los videos del campus — acá nos enfocamos en la parte práctica.

## ¿Qué vamos a hacer?

### 🏫 En clase (en vivo con Ciro) {#en-clase}

1. **Instalar Metamask** y configurar la red de prueba **Sepolia**.
2. **Pedir ETH de prueba** a una faucet y verificar el saldo en Etherscan.
3. **Conocer Remix**, la IDE online de Ethereum.
4. **Compilar y deployar** un contrato `SimpleStorage` — primero en la VM de Remix, después en Sepolia.
5. **Verlo on-chain** en `sepolia.etherscan.io`.

### 🏠 Tarea

La tarea va en una página aparte: [ver tarea de clase 1](clase-1-tarea.html).

### 🎥 La teoría

Los conceptos (qué es blockchain, hash, bloques, EVM, gas, consenso, L1/L2) están explicados **en los videos del campus**. Esta página es solo el paso a paso de lo que hacemos en vivo.

---

## Parte 1 — Instalar Metamask

1. Ir a [metamask.io](https://metamask.io) e instalar la **extensión de navegador** (Chrome / Firefox / Brave). Para esta diplomatura usamos la extensión, no la app móvil — más cómoda para conectarse a Remix.
2. Crear una cuenta nueva y **anotar la frase semilla en papel**.
3. La cuenta arranca en mainnet. **No vamos a usar mainnet** — usamos Sepolia (testnet, sin plata real).

> ⚠️ **Tres reglas de la frase semilla**: nunca digital, nunca en la nube, nunca compartida. Si la perdés y tenías plata real, no se recupera.

---

## Parte 2 — Activar Sepolia

1. En Metamask, abrir el menú de redes (arriba a la izquierda).
2. Settings → Advanced → activar **"Show test networks"**.
3. Volver al selector y elegir **Sepolia**.
4. El balance va a estar en 0 — es esperable.

---

## Parte 3 — Pedir ETH a una faucet

Una **faucet** es un servicio gratis que tira ETH de testnet para experimentar.

1. Copiar la address de tu wallet (en Metamask, click en el nombre de la cuenta — se copia automáticamente). Es un hash que arranca con `0x...`.
2. Ir a una faucet de Sepolia. Si una falla, probá otra:
   - [sepoliafaucet.com](https://sepoliafaucet.com) (Alchemy)
   - [cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
   - [sepolia-faucet.pk910.de](https://sepolia-faucet.pk910.de) (PoW — minás un poco antes de recibir)
3. Pegar la address, resolver el captcha y pedir.
4. Esperar (instantáneo o unos minutos según la faucet).
5. Verificar el saldo en Metamask.

> 💡 Las faucets tiran cantidades chicas (0.05 a 0.5 ETH) para evitar abuso. Con eso te alcanza para deployar varios contratos.

---

## Parte 4 — Verificar tu address en Etherscan

1. Ir a [sepolia.etherscan.io](https://sepolia.etherscan.io).
2. Pegar tu address en el buscador.
3. Vas a ver: balance, transacciones, hashes, números de bloque, gas consumido.

Esto demuestra el punto de transparencia de blockchain: **cualquiera con tu address puede ver tus transacciones**. Tenelo presente cuando trabajes con direcciones reales.

---

## Parte 5 — Remix: tu primer contrato

[Remix](https://remix.ethereum.org) es la IDE online oficial del ecosistema Ethereum. Sirve para escribir, compilar, deployar y testear smart contracts sin instalar nada.

> 💡 A partir de **clase 2** pasamos a **Foundry** (toolkit profesional, terminal + VS Code). Para arrancar, Remix es perfecto porque ya viene todo configurado.

### 5.1 La interfaz

Cuatro paneles en la barra lateral izquierda:

| Panel | Para qué |
|---|---|
| **File explorer** | Crear / organizar archivos `.sol` |
| **Solidity compiler** | Compilar el código (tiene auto-compile) |
| **Deploy & run transactions** | Deployar y llamar funciones |
| **Plugins / debugger** | Herramientas extra |

### 5.2 El contrato `SimpleStorage`

Crear un archivo nuevo (`File explorers → contracts → New File → SimpleStorage.sol`) y pegar:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 public storedNumber;

    function set(uint256 _number) public {
        storedNumber = _number;
    }

    function get() public view returns (uint256) {
        return storedNumber;
    }
}
```

Cosas a notar de la sintaxis (lo vamos a ver en detalle en clase 2):

- `contract SimpleStorage { ... }` — todo se agrupa adentro de un contrato, parecido a una clase en POO.
- `uint256 public storedNumber;` — variable de estado pública. Solidity le genera un getter automático.
- `function set(...)` modifica estado → cuesta gas.
- `function get(...) view` solo lee → no cuesta gas si la llamás desde afuera.

> 💡 **Hilo conductor**: este mismo `SimpleStorage` lo retomamos en **clase 2** corriéndolo localmente con Foundry en vez de en el browser.

### 5.3 Compilar

1. Click en el panel **Solidity compiler**.
2. Verificar que la versión coincida con el `pragma` del archivo.
3. Click en **"Compile"**. Si todo va bien, el botón se pone verde.
4. Si hay errores, Remix los muestra inline.

### 5.4 Deployar — primero en Remix VM

**Remix VM** = blockchain virtual local. No toca testnet, no usa Metamask, no consume nada. Sirve para probar antes de gastar gas de testnet.

1. Panel **Deploy & run transactions**.
2. **Environment**: dejar `Remix VM (Cancun)` (o la versión que aparezca por default).
3. **Account**: viene precargada con 100 ETH de juguete.
4. Seleccionar `SimpleStorage` en el dropdown.
5. Click en **Deploy**.
6. El contrato aparece abajo en "Deployed contracts". Expandirlo: ves los botones (`set`, `get`, `storedNumber`).
7. Probar: poner un número en `set`, click. Después click en `get`. Tiene que devolver lo que guardaste.

### 5.5 Deployar — ahora en Sepolia real

1. **Environment**: cambiar a `Injected Provider - MetaMask`.
2. Metamask pide autorización. Confirmar.
3. **Confirmar que la red en Metamask es Sepolia** (crítico — si fuera mainnet pagás gas real).
4. Click en **Deploy**.
5. Metamask abre un popup con el costo de gas. Confirmar.
6. Esperar la confirmación on-chain (segundos).
7. Copiar la address del contrato (queda abajo en "Deployed contracts").
8. Pegarla en [sepolia.etherscan.io](https://sepolia.etherscan.io) — vas a ver tu contrato deployado.

### 5.6 ¿Y si re-deployás?

Modificar el contrato (aunque sea un comentario) y volver a Deploy → **se crea un contrato nuevo** con otra address. El anterior sigue ahí, inmutable. La blockchain no edita, solo agrega.

Los contratos se identifican por su **address**: cada deploy es un contrato distinto, aunque el código sea idéntico.

---

## Parte 6 — ¿Qué viene en clase 2?

- Pasar de Remix a **Foundry** (terminal + VS Code).
- Mismo `SimpleStorage`, pero compilando con `forge build`.
- **Tests automatizados** (`forge test`) — el primer paso para escribir contratos serios.
- Control de versiones con Git.

---

## Después de clase

La tarea de la semana → [tarea de clase 1](clase-1-tarea.html).

## Si algo falla

| Problema | Solución |
|---|---|
| Metamask no muestra Sepolia | Settings → Advanced → activar "Show test networks" |
| La faucet pide cuenta o no acepta mi address | Probá otra faucet de la lista. Algunas tienen rate limit por IP. |
| No me llega el ETH | Esperá 5-10 min. Si no llega, otra faucet. |
| Etherscan dice "no transactions" | Verificá que estás en `sepolia.etherscan.io`, no en `etherscan.io` (mainnet). |
| Remix no se conecta a Metamask | Desbloqueá Metamask antes de elegir "Injected Provider - MetaMask". |
| Deploy a Sepolia falla por gas | Pedí más ETH a la faucet (un deploy consume más que una transferencia). |

Lo demás, foro del campus.
