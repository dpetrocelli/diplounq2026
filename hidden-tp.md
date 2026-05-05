<head><meta name="robots" content="noindex,nofollow"></head>

# Trabajo Final — Diploma NFT UNQ

## Cómo se trabaja este TP

Les damos un **template funcionando end-to-end** (contrato + API + front) y su trabajo es:

1. **Entender** el código del template y cómo se conectan las tres capas.
2. **Desplegar** la versión base a Sepolia y verificarla en Etherscan.
3. **Extender** con la **Extensión A obligatoria** más **2 de las 3 extensiones opcionales** del bloque "Extensiones".
4. **Demostrar** que funciona end-to-end con un video o una URL pública.

No se trata de escribir desde cero, sino de **modificar código que ya funciona** — que es lo que ocurre en cualquier proceso de desarrollo profesional. La complejidad está en comprender la base existente y extenderla con criterio, no en partir de un editor en blanco.

---

## ¿Por qué este TP?

En mayo de 2023, la Policía Federal desbarata la **"Operación Alejo"**: una red que vendió más de **500 títulos secundarios y universitarios truchos**, principalmente para ejercer en medicina y educación ([Infobae, 2023](https://www.infobae.com/sociedad/2023/05/04/una-banda-de-falsificadores-vendio-titulos-secundarios-y-universitarios-truchos-a-mas-de-500-clientes/)).

En 2025, la **[Universidad Nacional de Córdoba](https://www.unc.edu.ar/inform%C3%A1tica/blockchain-y-educaci%C3%B3n-la-unc-premiada-por-su-innovaci%C3%B3n-en-gesti%C3%B3n-acad%C3%A9mica)** ganó el Premio MetaRed TIC con un sistema de validación académica con smart contracts integrado a SIU Guaraní. Redujo el trámite de **4 meses a 2 semanas**.

| Problema | Cómo lo resuelve blockchain |
|---|---|
| El servidor central se rompe / se hackea / se borra | Estado replicado en miles de nodos, inmutable |
| Un PDF se puede falsificar | El emisor firma criptográficamente, cualquiera verifica |
| Verificar un título = llamar y esperar días | `tokenId` en una URL pública = 3 segundos |
| El egresado depende de la universidad para "demostrar" su título | Lo tiene en su wallet, nadie se lo puede sacar |

UNQ tiene ~11.000 estudiantes activos y 18 carreras. **No están haciendo un toy project. Están prototipando una pieza de infraestructura real.**

---

## Reglas

| | |
|---|---|
| **Plazo de entrega** | Lunes **08/06/2026 · 18:00** |
| **Grupos** | Individual o **pareja** (máximo 2 personas) |
| **Alcance** | Solo títulos finales (Licenciatura, Tecnicatura, Profesorado) |
| **Datos** | Caso ficticio. Inventar 3-5 personas. **No usar datos reales de alumnos** |
| **Nota mínima** | 60 / 100 |
| **Cómo se entrega** | Repositorio Git + video demo (3-5 min) **o** URL pública desplegada |

---

## Stack del MVP (template provisto)

Repositorio base que se entrega como punto de partida:

> **`dpetrocelli/diplo-unq-blockchain-tp-starter`**

Se clona, se lee, se ejecuta, se comprende. Recién después se extiende.

### Contratos (`contracts/`)

- **Foundry** (Forge + Anvil + Cast) — herramienta ya trabajada en clase 2.
- `Diploma.sol` — ERC-721 con `ERC721URIStorage` y `Ownable` de OpenZeppelin.
- Una sola función relevante: `mint(address student, string uri)` con `onlyOwner`.
- 3 tests en `test/Diploma.t.sol`: mint exitoso, mint sin permisos (revierte), balance correcto post-mint.
- Script `script/Deploy.s.sol` para desplegar a Sepolia.
- `forge test` pasa, `forge coverage` reporta el baseline.

### API (`api/`)

- **FastAPI + web3.py**, stateless, sin base de datos.
- Endpoint `GET /credentials/:tokenId` que llama `ownerOf` y `tokenURI` al RPC y devuelve JSON.
- Endpoint `GET /health` para verificar conexión al RPC.
- CORS abierto (es prototipo).

### Frontend (`web/`)

- **Next.js 14 (App Router) + wagmi v2 + viem + RainbowKit**.
- `ConnectButton` de RainbowKit.
- Form de mint protegido por owner.
- Lista de NFTs del wallet conectado leyendo eventos `DiplomaIssued` con `useWatchContractEvent`.
- Metadata hardcodeada en `/public/metadata/N.json` (intencional: queda como punto de extensión hacia IPFS).

### Red

- **Sepolia ETH** para el MVP. Faucet recomendado: [Google Cloud Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia).

---

## Parte 1 — Entender y desplegar el MVP (20%)

### 1.1 Setup local (10%)

Que funcione en su máquina. La rúbrica es binaria:

| Comando | Resultado esperado |
|---|---|
| `forge build` en `contracts/` | Compila sin warnings |
| `forge test` en `contracts/` | 3 tests pasan |
| `uvicorn main:app --reload` en `api/` | `GET /health` responde `{"status":"ok"}` |
| `npm run dev` en `web/` | `localhost:3000` muestra el ConnectButton |

### 1.2 Despliegue a Sepolia (10%)

- Desplegar `Diploma.sol` a Sepolia con el script de Foundry.
- **Verificar el código fuente en Etherscan** (`forge verify-contract`).
- Configurar la dirección del contrato en `web/.env.local` y `api/.env`.
- Mintear **3 credenciales reales** a 3 wallets distintos (pueden ser sus propios wallets de prueba).

---

## Parte 2 — Extensiones (60%)

La **Extensión A es obligatoria para todos los grupos**. Las extensiones **B, C y D son opcionales**: cada grupo elige **2 de las 3**. Cada extensión vale **20 puntos** (Parte 2 = 60 puntos). Implementar la tercera de las opcionales (B + C + D completas) suma **+20 de bonus** sobre los 100.

### Extensión A — Migración a Base Sepolia (L2) · OBLIGATORIA

**Capas que tocan**: Foundry + Frontend + API.

**Qué hacer**:

1. **Contrato**:
   - Conseguir testnet ETH en [Coinbase Faucet de Base Sepolia](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet).
   - Desplegar el contrato a **Base Sepolia** (chainId `84532`, RPC `https://sepolia.base.org`).
   - Verificar el código en **Basescan** (`forge verify-contract --verifier-url https://api-sepolia.basescan.org/api`).
2. **Frontend**:
   - Actualizar `web/src/lib/wagmi.ts` para soportar Sepolia **y** Base Sepolia (ambas redes en el connector).
   - El `ConnectButton` de RainbowKit debe permitir cambiar de red.
   - La dirección del contrato se resuelve según la red activa.
3. **API**:
   - Variable de entorno `CHAIN` (`sepolia` o `base-sepolia`) que selecciona el RPC y la dirección del contrato.
4. **Documentar en el README**:
   - Diferencia entre L1 (Sepolia ETH) y L2 (Base Sepolia).
   - Costo de gas comparado (mismo mint, capturas en Etherscan vs Basescan).
   - Qué cambió **en el código** (poco) y qué cambió **en la config** (todo).

**Por qué importa**:

Migrar entre redes EVM-compatibles es una operación de **producción real**. Una empresa empieza en una testnet y termina en mainnet, o cambia de L1 a L2 para reducir costos de gas. La lección es que **el bytecode no cambia** y que toda la fricción está en la configuración y la verificación.

**Conceptos que aprenden**:

- Qué es un L2 (Base es un Optimistic Rollup).
- ChainId, RPC, explorer, faucet — qué es propio de cada red y qué es universal.
- Multi-chain en wagmi (`chains: [sepolia, baseSepolia]`).
- Que la EVM es **portable** entre redes compatibles.

---

### Extensión B — Soulbound Token (SBT) · *opcional (elegir 2 de 3)*

**Capas que tocan**: Contrato + Foundry.

**Qué hacer**:

1. Override `_update` en `Diploma.sol` para que **revierta cualquier transferencia entre direcciones** (mint y burn siguen funcionando: `from == address(0)` o `to == address(0)`).
2. Definir un custom error `DiplomaSoulbound()` y revertir con él.
3. Agregar 2 tests en `Diploma.t.sol`:
   - `test_RevertWhen_TransferFrom`: que `transferFrom` revierta.
   - `test_BurnAllowed`: que `burn` (si lo exponen) o el flujo de mint sigan funcionando.
4. Redesplegar el contrato actualizado y verificarlo.

**Por qué importa**:

Un diploma **no se transfiere**. No se vende en OpenSea, no se regala. La no-transferibilidad del token = la no-transferibilidad de la credencial académica. Sin esto, el sistema **no funciona conceptualmente**.

El paper de referencia es **Ohlhaver, Weyl & Buterin (2022)** — *Decentralized Society: Finding Web3's Soul* ([SSRN 4105763](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763)) — que introduce el concepto de **Soulbound Tokens (SBTs)**. Citarlo en el README.

**Conceptos que aprenden**:

- Hooks de OpenZeppelin v5 (`_update` reemplaza a `_beforeTokenTransfer` de v4).
- `virtual` y `override` en Solidity.
- Custom errors vs `require` con string.
- Que las "extensiones" del estándar ERC-721 se hacen **overrideando hooks**, no agregando funciones nuevas.

---

### Extensión C — Verificación pública sin wallet · *opcional (elegir 2 de 3)*

**Capas que tocan**: API + Frontend.

**Qué hacer**:

1. **API**: agregar `GET /verify/:tokenId` que devuelva:
   ```json
   {
     "tokenId": 1,
     "owner": "0x...",
     "tokenURI": "ipfs://...",
     "exists": true,
     "metadata": { ... }
   }
   ```
   Si el `tokenId` no existe, responder `404` con `{"exists": false}`.

2. **Frontend**: agregar la ruta `/verify/[tokenId]/page.tsx` (Server Component de Next.js):
   - Llama a la API desde el server (no desde el client).
   - **No usa wagmi ni RainbowKit**: no requiere wallet.
   - Muestra: estado válido/inválido, dirección del egresado abreviada, fecha de emisión, link a Etherscan/Basescan.

3. Probarlo desde un browser **sin MetaMask instalado** (ej. Firefox limpio o modo incógnito).

**Por qué importa**:

La blockchain es **pública por diseño**. Leerla no requiere wallet, ni gas, ni firma. Un empleador que recibe un CV con un `tokenId` no va a instalar MetaMask: abre la URL `unq-diplomas.app/verify/42` y obtiene el resultado en segundos.

Esa separación entre **rol emisor** (decano con wallet) y **rol verificador** (cualquiera con un browser) es el insight central de las DApps reales.

**Conceptos que aprenden**:

- `createPublicClient` de **viem** vs `useReadContract` de wagmi.
- Server Components de Next.js 14 (App Router) — fetch desde el server.
- Diferencia entre `view`/`pure` (gratis, sin wallet) y funciones que mutan estado.

---

### Extensión D — Cache de eventos en la API · *opcional (elegir 2 de 3)*

**Capas que tocan**: API + (opcional) Frontend.

**Qué hacer**:

1. Elegir storage: **SQLite** (recomendado, cero infra) o **PostgreSQL** (si quieren practicar Docker).
2. Agregar un **worker** en la API que:
   - Lee los eventos `DiplomaIssued` desde el bloque del despliegue hasta el actual.
   - Los persiste en una tabla `events(token_id, student, uri, block_number, tx_hash, created_at)`.
   - Continúa escuchando nuevos eventos en tiempo real (polling cada N segundos o `eth_subscribe` si optan por WebSockets).
3. Agregar endpoints:
   - `GET /credentials/owner/:address` — lista de tokens emitidos a esa wallet, **leído del cache** (no del RPC).
   - `GET /events/recent?limit=10` — últimos N eventos.
4. Documentar en el README **cuántas llamadas al RPC se ahorraron** (medir antes y después).

**Por qué importa**:

Llamar al RPC en cada request **no escala**. Cada invocación implica latencia (200-500ms) y, en los planes gratuitos de Alchemy / Infura, los créditos se agotan rápidamente. La **separación entre indexación y consulta** es lo que resuelve **The Graph** en producción — esta extensión implementa una versión reducida del mismo patrón.

**Conceptos que aprenden**:

- Por qué existe **The Graph** (lo que se implementa a mano acá es lo que The Graph generaliza).
- Filtrar eventos con `eth_getLogs` y rangos de bloques.
- Idempotencia: que el worker no inserte el mismo evento dos veces si se reinicia.
- Trade-off **RPC directo vs cache local**.

---

## Parte 3 — Demo + Entrega final (20%)

### 3.1 Demo (10%)

**Opción A** — Video de 3 a 5 minutos, sin cortes, mostrando:

1. La página principal del front conectando wallet.
2. Mint de una credencial nueva (firmando en MetaMask).
3. La transacción aparece en Etherscan/Basescan.
4. **Extensiones en acción**:
   - **Extensión A (Base Sepolia, obligatoria)**: cambiar de red en RainbowKit y mintear sobre Base Sepolia; mostrar la transacción en Basescan.
   - Si implementaron **Soulbound**: intentar transferir → ver el revert con el custom error.
   - Si implementaron **`/verify` público**: abrir la URL en otro browser sin wallet.
   - Si implementaron **Cache de eventos**: mostrar que un `GET /credentials/owner/:address` resuelve sin invocar al RPC.
5. Mostrar el README explicando el por qué.

Subir a YouTube (unlisted), Drive (link público) o adjuntar al campus.

**Opción B** — Aplicación desplegada en URL pública:

- Frontend en Vercel / GitHub Pages / Netlify.
- API en Railway / Fly.io / Render free tier.
- Contrato verificado en Etherscan o Basescan.
- 3 credenciales emitidas reales.

### 3.2 README final (10%)

Tiene que cubrir, en orden:

1. **Hook UNQ** breve (3-5 líneas, ¿por qué este TP?).
2. **Setup local** verificable (`forge test`, `npm run dev`, etc.).
3. **Direcciones de despliegue**: contrato + Etherscan/Basescan + URL del front (si aplica).
4. **Las extensiones que eligieron**, con un párrafo cada una explicando:
   - Qué hicieron.
   - Qué archivos tocaron.
   - Qué aprendieron.
5. **Mapeo a la rúbrica** al final del documento: "Parte 1.1 → commit X", "Extensión A → archivo Y", etc. **Permite ubicar la evidencia de cada criterio durante la corrección** y evita que se descuenten puntos por ítems que sí están entregados.

---

## Rúbrica resumen

| Parte | Puntos | ¿Qué evaluamos? |
|---|---|---|
| 1.1 — Setup local | 10 | Los 4 comandos funcionan en una máquina limpia |
| 1.2 — Despliegue Sepolia | 10 | Contrato verificado + 3 mints reales |
| 2.A — Base Sepolia *(obligatoria)* | 20 | Despliegue verificado + multi-chain en front + doc |
| 2.B — Soulbound *(elegir 2 de 3)* | 20 | Override + 2 tests + redespliegue |
| 2.C — Verify público *(elegir 2 de 3)* | 20 | Endpoint + ruta SSR sin wallet |
| 2.D — Cache de eventos *(elegir 2 de 3)* | 20 | Worker + endpoints + medición de llamadas ahorradas |
| 3.1 — Demo | 10 | Video o app desplegada cubriendo el flujo |
| 3.2 — README final | 10 | Setup, direcciones, decisiones, mapeo a rúbrica |
| **TOTAL** | **100** | **Pasa con 60+. Pareja: ambos defienden ambas partes.** |

> **Bonus**: implementar **las tres extensiones opcionales** (B + C + D, además de la A obligatoria) suma **+20 puntos** sobre los 100. La nota máxima alcanzable es **120**.

---

## Fuera de alcance

Para que quede claro qué **no** se evalúa en este TP (pueden hacerlo igual si quieren, pero no suma puntos):

- Roles complejos con `AccessControl` (con `Ownable` alcanza).
- Struct on-chain con hashes de DNI / nombre del estudiante.
- Slither + análisis estático formal.
- Coverage > 80% + fuzz tests.
- IPFS + Pinata para metadata.
- Multi-sig (Gnosis Safe), Chainlink Functions, W3C DID.
- Indexadores externos como The Graph (la Extensión C cubre el insight con SQLite local).

Si terminan temprano y quieren ir por más, agréguenlo y mencionenlo en el README — lo vamos a leer y comentar, pero no afecta la nota.

---

## Preguntas frecuentes

**¿Puedo elegir qué extensiones implementar?**
La **Extensión A (Base Sepolia)** es obligatoria para todos los grupos. De las opcionales (B, C, D) eligen **2 de las 3**. Cualquier combinación es válida. Ante dudas sobre qué elegir, pueden consultarlo en las clases de consulta y se orienta según el perfil del grupo.

**¿Puedo entregar individual y que mi compañero entregue otro TP por su cuenta?**
Sí. Pero si entregan en pareja, **ambos tienen que poder defender ambas partes**. Si uno hizo solo el front y no entiende el contrato, baja la nota de los dos.

**¿Qué pasa si entrego solo la Extensión A más una opcional?**
Se evalúa lo entregado, pero la consigna queda incompleta: faltaría una de las dos opcionales requeridas. La cobertura sería A + 1 opcional = 40 sobre los 60 posibles de la Parte 2, y se pierden 20 puntos del bloque. Es preferible entregar las 3 extensiones requeridas (A + 2 opcionales) razonablemente bien antes que 2 perfectas: la consistencia entre las capas (contrato, API, front) se evalúa mejor cuando hay más superficie funcional cubierta.

**¿Puedo cambiar de stack (ej. Vue, Express, Hardhat)?**
Sí, queda a criterio del grupo. El template oficial usa Foundry + Next.js + FastAPI y la corrección se realiza sobre esa base; cualquier reemplazo de stack debe cumplir los mismos requisitos funcionales (mismas extensiones, misma rúbrica, mismo flujo demo) y la responsabilidad de que el resultado sea evaluable queda a cargo del grupo.

---

## Referencias

- **Ohlhaver, Weyl & Buterin (2022)**. *Decentralized Society: Finding Web3's Soul*. SSRN [4105763](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763). Paper que define **Soulbound Tokens** — el concepto detrás de la Extensión A.
- **Grech & Camilleri (2017)**. *Blockchain in Education*. JRC, Comisión Europea. EUR 28778 EN, doi:[10.2760/60649](https://publications.jrc.ec.europa.eu/repository/handle/JRC108255). Reporte fundacional sobre adopción de blockchain en educación.
- **Universidad Nacional de Córdoba (2025)**. [Premio MetaRed TIC](https://www.unc.edu.ar/inform%C3%A1tica/blockchain-y-educaci%C3%B3n-la-unc-premiada-por-su-innovaci%C3%B3n-en-gesti%C3%B3n-acad%C3%A9mica). Caso argentino de referencia.
- [Foundry Book](https://book.getfoundry.sh/) · [wagmi v2 docs](https://wagmi.sh/) · [viem](https://viem.sh/) · [RainbowKit](https://www.rainbowkit.com/) · [FastAPI](https://fastapi.tiangolo.com/) · [Base Sepolia docs](https://docs.base.org/chain/network-information).

---

> **Cualquier duda**: clases de consulta los lunes 18:00, foro del campus, o mensaje directo a los docentes.
