# Clase 1 — Fundamentos de blockchain + tu primer contrato en Remix

> **Objetivo de hoy**: arrancar de cero con los fundamentos de blockchain (hash, bloques, consenso, nodos), entender qué es Ethereum y un smart contract, y deployar un contrato simple en la testnet Sepolia usando Remix + Metamask.

## ¿Qué vamos a hacer?

### 🏫 En clase (en vivo con Ciro) {#en-clase}

1. **Repasar los fundamentos teóricos**: qué problema viene a resolver blockchain, funciones hash, cadena de bloques, inmutabilidad y descentralización.
2. **Ubicar a Ethereum en el mapa**: diferencias con Bitcoin, qué es la EVM, qué es un smart contract y por qué nos importa.
3. **Instalar Metamask** como extensión del navegador y configurarla para usar la red de prueba **Sepolia**.
4. **Pedir ETH de prueba a una faucet** y verificar la transacción en el explorador de bloques (Etherscan de Sepolia).
5. **Conocer Remix**, la IDE online de Ethereum, y compilar un contrato Solidity de ejemplo.
6. **Deployar el contrato a Sepolia** desde Remix conectado a Metamask, e interactuar con sus funciones.

### 🏠 Tarea

La tarea va en una página aparte: [ver tarea de clase 1](clase-1-tarea.html).

---

## Parte 1 — ¿Qué problema viene a resolver blockchain?

Arranquemos por el principio. El problema fundamental: ¿cómo hacemos para que dos partes que **no se conocen y no confían entre sí** puedan transaccionar **sin un intermediario**?

Hoy ese rol lo cumplen bancos, notarios, escribanos, el Estado. Validan, certifican y garantizan confianza — pero cobran por hacerlo y son un punto único de control.

En 2008, alguien (o un grupo) bajo el seudónimo de **Satoshi Nakamoto** publicó un paper proponiendo algo distinto: reemplazar la confianza en instituciones por **criptografía + consenso distribuido + inmutabilidad**. Esa es la base de todo lo que vamos a ver en la diplomatura.

### Web 1, Web 2, Web 3

Para entender dónde encaja blockchain, sirve pensar la evolución de la web:

| Etapa | Cuándo | Característica |
|---|---|---|
| Web 1 | 90s | Páginas estáticas, solo lectura |
| Web 2 | 2000s | Plataformas dinámicas, los usuarios producen contenido pero las plataformas se quedan con la propiedad |
| Web 3 | desde ~2015 | Los usuarios son dueños de la información que producen — propiedad digital |

Blockchain es uno de los pilares técnicos de la Web 3. No es una utopía: tiene limitaciones reales de usabilidad y escalabilidad que vamos a ir viendo. Por ahora quedémonos con la idea de **propiedad digital**.

---

## Parte 2 — Funciones hash

Una función hash toma una entrada de cualquier tamaño (texto, archivo, número) y produce una salida de **tamaño fijo**. En blockchain se usan hashes de 256 bits, representados en hexadecimal.

Propiedades clave:

- **Determinista**: misma entrada → misma salida, siempre.
- **Efecto avalancha**: el más mínimo cambio en la entrada cambia la salida por completo.
- **Resistente a colisiones**: es computacionalmente imposible encontrar dos entradas distintas que produzcan el mismo hash.
- **Unidireccional**: dado un hash, no se puede reconstruir la entrada original.

Dos hashes que vas a escuchar nombrar todo el tiempo:

| Algoritmo | Lo usa |
|---|---|
| SHA-256 | Bitcoin |
| Keccak-256 | Ethereum |

Hacen conceptualmente lo mismo, pero son algoritmos distintos.

---

## Parte 3 — De hashes a cadena de bloques

Una blockchain es, literalmente, una cadena de bloques. Cada bloque contiene:

- Transacciones.
- Un timestamp.
- Un nonce.
- **El hash del bloque anterior**.

La cadena empieza con el **bloque génesis** y cada bloque nuevo apunta al anterior por su hash. ¿Qué pasa si alguien modifica un bloque del medio? Por el efecto avalancha, su hash cambia, y eso rompe la referencia del siguiente, y del siguiente, y así hasta el final. La cadena queda **inconsistente** y cualquier nodo lo detecta.

De ahí salen las tres propiedades clave del sistema:

- **Inmutabilidad**: lo escrito no se puede modificar sin romper la cadena.
- **Transparencia**: cualquiera puede verificar la cadena entera.
- **Descentralización**: no hay un actor único que controle las reglas — muchos nodos independientes mantienen una copia válida.

### Árboles de Merkle

Estructura jerárquica de hashes que sirve para **verificar si una transacción está incluida en un bloque sin recorrer todas las transacciones**. Las hojas son los hashes de cada transacción, cada nodo padre es el hash de sus dos hijos, y arriba de todo hay un **root hash** que representa al bloque entero. Es lo que permite a los light nodes (los que viven en wallets de celular) operar sin descargarse la blockchain completa.

---

## Parte 4 — Tipos de blockchain y tipos de nodos

### Tipos de blockchain

| Tipo | Descripción | Ejemplo |
|---|---|---|
| Pública | Cualquiera puede leer, escribir y validar. Máxima descentralización, menor velocidad | Bitcoin, Ethereum |
| Privada | Acceso restringido, controlada por una organización. Rápida pero centralizada | Hyperledger en una empresa |
| Consorcio | Un grupo de organizaciones comparte el control. Balance entre velocidad y descentralización | Cadenas de banca / supply chain |

En esta diplomatura vamos a trabajar sobre **Ethereum** (pública, semi-permisionada, soporta smart contracts).

### Tipos de nodos

| Nodo | Para qué |
|---|---|
| Full node | Almacena la blockchain completa. Verifica todas las reglas. Pesado. |
| Archive node | Full node + estado histórico de cada bloque. Pesa terabytes. Lo usan exploradores de bloques. |
| Light node | Solo guarda los headers. Verifica con árboles de Merkle. Lo usan wallets en celular. |
| Validador | Propone y valida nuevos bloques. Requiere poner ETH como garantía (staking). |

---

## Parte 5 — Bitcoin vs Ethereum

| | Bitcoin | Ethereum |
|---|---|---|
| Lanzamiento | 2009, Satoshi Nakamoto | 2015, Vitalik Buterin |
| Idea | Oro digital, reserva de valor | Computadora mundial |
| Supply | Fijo, 21 millones | No fijo, con mecanismo de quema (deflacionario en la práctica) |
| Consenso | Proof of Work | Proof of Stake (desde sept. 2022) |
| Lenguaje | Limitado (no Turing completo) | EVM, Turing completa, soporta smart contracts |

Una frase que ayuda: **Bitcoin es una calculadora, Ethereum es una computadora**.

### El Merge (septiembre 2022)

Ethereum migró de Proof of Work a Proof of Stake. Resultados:

- Reducción de casi 100% del consumo energético.
- Los mineros se convirtieron en validadores (staking de 32 ETH como garantía).
- La EVM y Solidity **no cambiaron** — todas las dApps existentes siguieron funcionando sin tocar nada.

---

## Parte 6 — Algoritmos de consenso

¿Cómo se ponen de acuerdo miles de nodos que no se conocen?

| Algoritmo | Cómo funciona | Quién lo usa |
|---|---|---|
| Proof of Work (PoW) | Mineros compiten resolviendo puzles criptográficos. Mucho hardware, mucha energía. | Bitcoin, Ethereum (hasta 2022) |
| Proof of Stake (PoS) | Validadores ponen cripto como garantía. Selección pseudo-aleatoria pesada por stake. Mucho menos consumo. | Ethereum (hoy) |
| Delegated PoS | Los holders votan por delegados que validan en su nombre. Rápido, menos descentralizado. | EOS, Tron |
| Proof of Authority | Validadores con identidad conocida y de confianza. Muy rápido pero centralizado. | Redes privadas y testnets |

---

## Parte 7 — Ciclo de vida de una transacción

Desde que firmás una transacción hasta que queda escrita en la blockchain, son **siete pasos**:

1. **Firma**: el usuario firma con su clave privada. Sin firma no hay transacción.
2. **Envío al nodo**: la transacción viaja por una llamada RPC al nodo, que es el puente entre la app y la red.
3. **Mempool**: queda en una "sala de espera" pública con todas las transacciones pendientes. (Acá nace el concepto de **MEV — Maximal Extractable Value**, que vamos a ver más adelante).
4. **Block builder**: un agente especializado selecciona y ordena transacciones para armar un bloque. Las que pagan más fee suelen ir primero.
5. **Validador**: un validador (seleccionado por la red) propone el bloque.
6. **Ejecución en la EVM**: la transacción se ejecuta, modifica el estado.
7. **Inserción**: el bloque queda escrito de manera inmutable.

El validador cobra el **gas** que se consumió. Si la transacción **falla**, el gas igual se cobra hasta el punto de fallo — no hay reembolso.

Tiempos típicos:
- Capa 1 de Ethereum (mainnet): ~12-13 segundos por bloque.
- Capa 2 (Base, Arbitrum, etc.): 2-3 segundos.

---

## Parte 8 — Smart contracts y cuentas

En Ethereum hay dos tipos de cuentas:

| Tipo | Controlada por | Usa |
|---|---|---|
| **Externally Owned Account (EOA)** | Clave privada del usuario | Lo que tenés en Metamask. Inicia transacciones. No tiene código. |
| **Contract account** | Código (bytecode en la EVM) | No puede iniciar transacciones por sí sola — alguien tiene que llamarla. Tiene almacenamiento propio. |

### Frase semilla — las tres reglas absolutas

La frase semilla son 12 o 24 palabras que generan toda la jerarquía de claves de la cuenta. Quien tiene la frase, tiene todo.

1. **Nunca** la guardes en formato digital (ni screenshot, ni nota en el celular, ni archivo de texto).
2. **Nunca** se la compartas a nadie. Sin excepción.
3. Quien tiene la frase semilla tiene control total sobre los fondos.

### ¿Qué es un smart contract?

Es un programa almacenado en la blockchain que se ejecuta automáticamente cuando se cumplen ciertas condiciones que vos definiste. Comparte las propiedades de la blockchain:

- **Inmutable**: una vez deployado, el código no se puede modificar. Si querés cambiarlo, deployás un contrato nuevo (con otra address).
- **Determinista**: misma entrada → misma salida. Todos los nodos llegan al mismo resultado.
- **Transparente**: el código (bytecode) es público. Lo podés verificar en Etherscan.
- **Sin permisos**: cualquiera puede interactuar con el contrato — eso lo hace abierto pero también vulnerable a ataques.

### Estándares de tokens

Sobre la base de los smart contracts, la comunidad armó estándares:

| Estándar | Para qué | Ejemplos |
|---|---|---|
| ERC-20 | Tokens fungibles (criptomonedas). Funciones clave: `transfer`, `approve`, `transferFrom`, `balanceOf` | USDC, DAI, LINK, UNI |
| ERC-721 | Tokens **no** fungibles (NFTs). Cada token tiene ID único. | CryptoKitties, BoredApe Yacht Club |
| ERC-1155 | Multi-token: maneja fungibles y no fungibles en un solo contrato | Juegos play-to-earn |

---

## Parte 9 — Gas y capa 2

Todo en Ethereum cuesta **gas**. Sirve para:

- Pagar a los validadores por el cómputo.
- Evitar spam y prevenir loops infinitos en contratos.

Fórmula básica: `costo = gas usado × (base fee + priority fee)`. La unidad práctica es el **wei**, que es 10⁻¹⁸ de un ether. Una transacción simple cuesta como mínimo 21.000 de gas.

| Red | Costo aproximado de una transacción simple |
|---|---|
| Capa 1 (mainnet) | ~50 centavos de dólar (puede subir mucho más con congestión) |
| Capa 2 (Base, Arbitrum) | menos de un centavo |

### El trilema de blockchain

Dice que una blockchain de capa 1 solo puede optimizar **dos** de estas tres cosas: seguridad, descentralización, escalabilidad. Ethereum priorizó las dos primeras y eso hizo que originalmente las transacciones fueran caras y lentas.

### Capa 2: la solución a la escalabilidad

Las redes de capa 2 procesan transacciones **fuera** de la cadena principal y solo publican los resultados consolidados en capa 1. Heredan la seguridad de Ethereum pero bajan los costos a fracciones de centavo y suben el throughput a miles de TPS.

Dos grandes familias:

| Familia | Cómo verifica | Ejemplos |
|---|---|---|
| Optimistic Rollups | Asumen que las transacciones son válidas, dan 7 días para detectar fraude | Base, Arbitrum, Optimism |
| ZK Rollups | Generan una prueba criptográfica de validez (segundos/minutos) | zkSync, Starknet |

En 2026, la mayoría de las dApps productivas viven en capa 2, no en mainnet directamente.

---

## Parte 10 — Manos a la obra: Metamask + Sepolia + Faucet

### 10.1 Instalar Metamask

1. Ir a [metamask.io](https://metamask.io) e instalar la **extensión de navegador** (Chrome / Firefox / Brave). Para esta diplomatura usamos la extensión, no la app móvil — más cómoda para conectarse a Remix.
2. Crear una cuenta nueva y **anotar la frase semilla en papel**. Repasá las tres reglas de la Parte 8.
3. La cuenta arranca en mainnet. **No vamos a usar mainnet** — usamos Sepolia (red de prueba, sin plata real).

### 10.2 Activar Sepolia

1. En Metamask, abrir el menú de redes (arriba a la izquierda).
2. Settings → Advanced → activar **"Show test networks"**.
3. Volver al selector y elegir **Sepolia**.
4. El balance va a estar en 0 — es esperable.

### 10.3 Pedir ETH de prueba a una faucet

Una **faucet** es un servicio gratis que te tira ETH de testnet para que puedas experimentar.

1. Copiar la address de tu wallet (en Metamask, hacer click en el nombre de la cuenta, se copia automáticamente). Es un hash que arranca con `0x...`.
2. Ir a una faucet de Sepolia. Algunas opciones:
   - [sepoliafaucet.com](https://sepoliafaucet.com) (Alchemy)
   - [cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
   - [sepolia-faucet.pk910.de](https://sepolia-faucet.pk910.de) (PoW faucet — necesitás minar un poco)
3. Pegar la address, resolver el captcha y pedir los tokens.
4. Esperar a que llegue (puede ser instantáneo o tardar unos minutos según la faucet).
5. Verificar el saldo en Metamask con Sepolia seleccionada.

> 💡 Si una faucet falla, probá con otra. Tiran cantidades chicas (típicamente 0.05 a 0.5 ETH) para evitar abuso.

### 10.4 Ver la transacción en Etherscan

1. Ir a [sepolia.etherscan.io](https://sepolia.etherscan.io).
2. Pegar la address de tu wallet en el buscador.
3. Vas a ver: balance, transacciones, hashes de cada operación, números de bloque, gas consumido, todo.

Esto demuestra el punto de transparencia: **cualquiera con tu address puede ver tus transacciones y tu saldo**. Tenelo presente cuando trabajes con direcciones reales.

---

## Parte 11 — Remix: tu primer contrato

[Remix](https://remix.ethereum.org) es la IDE online oficial del ecosistema Ethereum. Sirve para escribir, compilar, deployar y testear smart contracts sin instalar nada. Es ideal para esta primera clase porque ya viene todo configurado.

> 💡 A partir de clase 2 vamos a pasar a **Foundry** (toolkit profesional para terminal + VS Code). Pero para arrancar y entender el flujo, Remix es perfecto.

### 11.1 Conocer la interfaz

Remix tiene cuatro paneles principales en la barra lateral izquierda:

| Panel | Para qué |
|---|---|
| **File explorer** | Crear y organizar archivos `.sol`. Podés importar proyectos también. |
| **Solidity compiler** | Compilar el código. Tiene `auto-compile` que te avisa de errores mientras escribís. |
| **Deploy & run transactions** | Deployar el contrato, elegir entorno (Remix VM o Metamask), e interactuar con las funciones. |
| **Plugins / debugger** | Herramientas extra. |

### 11.2 El contrato de ejemplo (`SimpleStorage`)

El contrato que usamos en clase es uno básico que guarda y devuelve un valor. Algo como:

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

> Copialo tal cual y pegalo en un archivo nuevo en Remix (`File explorers → contracts → New File → SimpleStorage.sol`). En **clase 2** vamos a retomar este mismo contrato, pero corriéndolo localmente con Foundry en vez de en el browser.

Cosas a notar de la sintaxis (lo vamos a ver en detalle en clase 2):
- `contract SimpleStorage { ... }` — todo se agrupa adentro de un contrato, parecido a una clase en POO.
- `uint256 public storedNumber;` — variable de estado pública. Solidity le genera un getter automático.
- `function set(...)` modifica estado → cuesta gas.
- `function get(...) view` solo lee → no cuesta gas si la llamás desde afuera.

### 11.3 Compilar

1. Click en el panel **Solidity compiler**.
2. Verificar que la versión coincida con el `pragma` del archivo.
3. Click en **"Compile"**. Si todo está bien, el botón se pone verde.
4. Si hay errores, Remix los muestra inline en el código.

### 11.4 Deployar (primero en Remix VM, después en Sepolia)

**Primero, en la blockchain virtual de Remix** (no toca testnet, no usa Metamask):

1. Panel **Deploy & run transactions**.
2. **Environment**: dejar `Remix VM (Cancun)` (o la versión que aparezca por default).
3. **Account**: viene precargada con 100 ETH de juguete.
4. Seleccionar el contrato `SimpleStorage` en el dropdown.
5. Click en **Deploy**.
6. El contrato aparece abajo en "Deployed contracts". Expandirlo: ves los botones de las funciones (`set`, `get`, `storedNumber`).
7. Probar: poner un número en `set`, click. Después click en `get`. Tiene que devolver el número que guardaste.

**Después, en Sepolia real** (con Metamask):

1. **Environment**: cambiar a `Injected Provider - MetaMask`.
2. Metamask te va a pedir autorización. Confirmá.
3. Confirmar que la red en Metamask es **Sepolia** (no mainnet — esto es crítico, si fuera mainnet pagás gas real).
4. Click en **Deploy**.
5. Metamask abre un popup mostrando el costo de gas de prueba. Confirmar.
6. Esperar la confirmación on-chain (segundos).
7. El contrato queda en Sepolia con su propia address. Copiala.
8. Pegar la address en [sepolia.etherscan.io](https://sepolia.etherscan.io) — vas a ver tu contrato deployado, sus eventos, sus transacciones.

### 11.5 ¿Qué pasa si re-deployás?

Si modificás el contrato (aunque sea un comentario) y volvés a hacer Deploy, **se crea un contrato nuevo** con otra address. El anterior sigue ahí, inmutable. La blockchain no edita — solo agrega.

Por eso los contratos se identifican por su **address**: cada deploy es un contrato distinto, aunque el código sea idéntico.

---

## Después de clase

La tarea de la semana → [tarea de clase 1](clase-1-tarea.html).

En clase 2 pasamos al toolkit profesional: **Foundry** + VS Code, tests automatizados, control de versiones con Git. Remix se queda como herramienta de exploración rápida.

## Si algo falla

| Problema | Solución |
|---|---|
| Metamask no muestra Sepolia | Settings → Advanced → activar "Show test networks" |
| La faucet dice "address inválida" | Verificá que copiaste la address completa (`0x` + 40 caracteres hex). Sin espacios. |
| La faucet pide login con cuenta de Alchemy/Google | Es normal — algunas requieren cuenta para evitar abuso. Probá con otra. |
| No me llega el ETH de la faucet | Esperá 5-10 minutos. Si sigue sin llegar, probá con otra faucet. Algunas tienen colas largas. |
| Etherscan no encuentra mi address | La testnet está en `sepolia.etherscan.io`, **no** en `etherscan.io`. |
| Remix no encuentra Metamask | Asegurate de que Metamask esté **desbloqueada** en el navegador antes de seleccionar "Injected Provider". |
| El deploy en Sepolia falla por "out of gas" | Pedile más ETH a la faucet. El deploy de un contrato usa más gas que una transferencia simple. |
| Re-deployé y el contrato anterior "desapareció" | No desapareció — sigue en su address original. El nuevo deploy genera otra address distinta. |

Lo demás, foro del campus.
