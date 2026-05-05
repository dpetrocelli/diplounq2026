<head><meta name="robots" content="noindex,nofollow"></head>

# Trabajo Final · V2 — Diploma NFT UNQ (alcance acotado)

> **Audiencia**: alumnos de la cohorte 2026 que necesitan un alcance más manejable que la versión completa. La V1 sigue disponible en [tp-final.html](tp-final.html) — esta V2 reemplaza esa entrega para quien la elija.
>
> **Página unlisted**: no está enlazada desde el índice del sitio ni indexada en buscadores. Se comparte por mensaje directo del docente.

---

## Filosofía de esta V2

A diferencia del TP original, donde tenían que construir todo el sistema desde cero, acá les damos **el MVP cocinado y funcionando**. Su trabajo consiste en:

1. **Entender** el código del template (contrato, API, front).
2. **Desplegar** la versión base a Sepolia y verificarla en Etherscan.
3. **Extender** con **al menos 3 de las 4 features** del bloque "Extensiones obligatorias".
4. **Demostrar** que funciona end-to-end con un video o una URL pública.

No se trata de escribir menos código, sino de **modificar código que ya funciona** — que es lo que van a hacer en cualquier laburo real.

---

## Punto de partida — ¿Por qué un sistema así?

Esta sección es la misma que la V1 porque el problema **no se simplifica**. Lo que se simplifica es la solución.

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

## Stack del MVP (lo que les damos cocinado)

Repositorio template:

> **`dpetrocelli/diplo-unq-blockchain-tp-v2-starter`**

Lo clonan, leen, ejecutan, lo entienden. Después extienden.

### Contratos (`contracts/`)

- **Foundry** (Forge + Anvil + Cast) — ya lo dominan desde clase 2.
- `Diploma.sol` — ERC-721 con `ERC721URIStorage` y `Ownable` de OpenZeppelin.
- Una sola función relevante: `mint(address student, string uri)` con `onlyOwner`.
- 3 tests en `test/Diploma.t.sol`: mint feliz, mint sin permiso revierte, balance correcto.
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
- Metadata harcodeada en `/public/metadata/N.json` (a propósito: para que la mejoren ustedes).

### Red

- **Sepolia ETH** para el MVP. Faucet recomendado: [Google Cloud Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia).

---

## Parte 1 — Entender y desplegar el MVP (30%)

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

### 1.3 Documentación inicial (10%)

README en la raíz del repo con:

- Instrucciones de setup local copiadas y verificadas.
- Dirección del contrato + link a Etherscan verificado.
- Las 3 transacciones de mint con sus hashes.
- **Qué extensiones eligieron** (de las 4 disponibles) y por qué.

---

## Parte 2 — Extensiones obligatorias (50%)

Eligen **al menos 3 de estas 4**. Cada una vale **17 puntos**. Si hacen las 4, los 51 puntos se redistribuyen como 50 + 1 de bonus.

### Extensión A — Soulbound Token (SBT)

**Capas que tocan**: Contrato + Foundry.

**Qué hacer**:

1. Override `_update` en `Diploma.sol` para que **revierta cualquier transferencia entre direcciones** (mint y burn siguen funcionando: `from == address(0)` o `to == address(0)`).
2. Definir un custom error `DiplomaSoulbound()` y revertir con él.
3. Agregar 2 tests en `Diploma.t.sol`:
   - `test_RevertWhen_TransferFrom`: que `transferFrom` revierta.
   - `test_BurnAllowed`: que `burn` (si lo exponen) o el flujo de mint sigan funcionando.
4. Redesplegar el contrato actualizado a Sepolia y verificarlo.

**Por qué importa**:

Un diploma **no se transfiere**. No se vende en OpenSea, no se regala. La no-transferibilidad del token = la no-transferibilidad de la credencial académica. Sin esto, el sistema **no funciona conceptualmente**.

El paper de referencia es **Ohlhaver, Weyl & Buterin (2022)** — *Decentralized Society: Finding Web3's Soul* ([SSRN 4105763](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763)) — que introduce el concepto de **Soulbound Tokens (SBTs)**. Citenlo en el README.

**Conceptos que aprenden**:

- Hooks de OpenZeppelin v5 (`_update` reemplaza a `_beforeTokenTransfer` de v4).
- `virtual` y `override` en Solidity.
- Custom errors vs `require` con string.
- Que las "extensiones" del estándar ERC-721 se hacen **overrideando hooks**, no agregando funciones nuevas.

---

### Extensión B — Verificación pública sin wallet

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
   - Muestra: estado válido/inválido, dirección del egresado abreviada, fecha de emisión, link a Etherscan.

3. Probarlo desde un browser **sin MetaMask instalado** (ej. Firefox limpio o modo incógnito).

**Por qué importa**:

La blockchain es **pública por diseño**. Leerla no requiere wallet ni gas ni firma. El empleador que recibe un CV con un `tokenId` no va a instalar MetaMask. Pega la URL `unq-diplomas.app/verify/42` y ve el resultado en 3 segundos.

Esa separación entre **rol emisor** (decano con wallet) y **rol verificador** (cualquiera con un browser) es **el insight de DApps reales**.

**Conceptos que aprenden**:

- `createPublicClient` de **viem** vs `useReadContract` de wagmi.
- Server Components de Next.js 14 (App Router) — fetch desde el server.
- Diferencia entre `view`/`pure` (gratis, sin wallet) y funciones que mutan estado.

---

### Extensión C — Cache de eventos en la API

**Capas que tocan**: API + (opcional) Frontend.

**Qué hacer**:

1. Elegir storage: **SQLite** (recomendado, cero infra) o **PostgreSQL** (si quieren practicar Docker).
2. Agregar un **worker** en la API que:
   - Lee los eventos `DiplomaIssued` desde el bloque del despliegue hasta el actual.
   - Los persiste en una tabla `events(token_id, student, uri, block_number, tx_hash, created_at)`.
   - Continúa escuchando nuevos eventos en tiempo real (polling cada N segundos o `eth_subscribe` si se animan a WebSockets).
3. Agregar endpoints:
   - `GET /credentials/owner/:address` — lista de tokens emitidos a esa wallet, **leído del cache** (no del RPC).
   - `GET /events/recent?limit=10` — últimos N eventos.
4. Documentar en el README **cuántos hits al RPC se ahorraron** (medir antes y después).

**Por qué importa**:

Pegarle al RPC en cada request **no escala**. Cada llamada cuesta latencia (200-500ms) y, en Alchemy/Infura free tier, te quedás sin créditos rápido. La **separación entre indexación y consulta** es lo que hace **The Graph** en producción — ustedes están armando una versión chiquita.

**Conceptos que aprenden**:

- Por qué existe **The Graph** (lo que están haciendo a mano es lo que The Graph hace generalizado).
- Filtrar eventos con `eth_getLogs` y rangos de bloques.
- Idempotencia: que el worker no inserte el mismo evento dos veces si se reinicia.
- Trade-off **RPC directo vs cache local**.

---

### Extensión D — Migración a Base Sepolia (L2)

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

Migrar entre redes EVM-compatibles es una operación de **producción real**. Una empresa empieza en una testnet y termina en mainnet, o cambia de L1 a L2 para bajar costos. Aprender que **el bytecode no cambia** y que toda la fricción está en config + verificación es la lección.

**Conceptos que aprenden**:

- Qué es un L2 (Base es un Optimistic Rollup).
- ChainId, RPC, explorer, faucet — qué es propio de cada red y qué es universal.
- Multi-chain en wagmi (`chains: [sepolia, baseSepolia]`).
- Que la EVM es **portable** entre redes compatibles.

---

## Parte 3 — Demo + Entrega final (20%)

### 3.1 Demo (10%)

**Opción A** — Video de 3 a 5 minutos, sin cortes, mostrando:

1. La página principal del front conectando wallet.
2. Mint de una credencial nueva (firmando en MetaMask).
3. La transacción aparece en Etherscan/Basescan.
4. **Las extensiones que eligieron en acción**:
   - Si hicieron Soulbound: intentar transferir → ver el revert.
   - Si hicieron `/verify`: abrir la URL en otro browser sin wallet.
   - Si hicieron Cache: mostrar que un `GET /credentials/owner/:address` devuelve sin pegar al RPC.
   - Si hicieron Base Sepolia: cambiar de red en RainbowKit y mintear en la otra red.
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
5. **Mapeo a la rúbrica** abajo de todo: "Parte 1.1 → tal commit", etc. **Esto les ahorra puntos perdidos** porque les marcamos qué buscar.

---

## Rúbrica resumen

| Parte | Puntos | ¿Qué evaluamos? |
|---|---|---|
| 1.1 — Setup local | 10 | Los 4 comandos funcionan en una máquina limpia |
| 1.2 — Despliegue Sepolia | 10 | Contrato verificado + 3 mints reales |
| 1.3 — Documentación inicial | 10 | README claro con setup, dirección, decisiones |
| 2.A — Soulbound *(opcional)* | 17 | Override + 2 tests + redespliegue |
| 2.B — Verify público *(opcional)* | 17 | Endpoint + ruta SSR sin wallet |
| 2.C — Cache de eventos *(opcional)* | 17 | Worker + endpoints + medición de hits ahorrados |
| 2.D — Base Sepolia *(opcional)* | 17 | Despliegue verificado + multi-chain en front + doc |
| 3.1 — Demo | 10 | Video o app desplegada cubriendo el flujo |
| 3.2 — README final | 10 | Mapeo a rúbrica + decisiones documentadas |
| **TOTAL** | **100** | **Pasa con 60+. Pareja: ambos defienden ambas partes.** |

> Si hacen las **4 extensiones** (no 3), suman **+1 de bonus** sobre los 100. No es mucho — el incentivo real es aprender más, no la décima.

---

## Lo que NO les pedimos en esta V2 (vs. V1)

Para que quede claro qué se simplifica respecto del [TP final original](tp-final.html):

| Tema | V1 | V2 |
|---|---|---|
| Roles (`AccessControl`) | Obligatorio (ISSUER + ADMIN) | Solo `Ownable` |
| Soulbound | Obligatorio | Extensión A (opcional) |
| Struct extendida con hashes | Obligatorio | Solo `tokenURI` |
| Eventos custom (4 distintos) | Obligatorio | Solo `DiplomaIssued` |
| Coverage 80% + fuzz tests | Obligatorio | 3 tests funcionales |
| Slither + SECURITY.md | Obligatorio | No requerido |
| IPFS (Pinata) | Bonus | Pueden agregarlo si quieren (no puntúa) |
| Multi-sig / Chainlink / DID | Bonus | Fuera de alcance |
| Frontend con dual-mode (verify + issuer) | Obligatorio | El verify queda en Extensión B |
| Base Sepolia | Obligatorio | Extensión D (opcional) |

Si después de hacer la V2 quieren ir por más, la V1 sigue ahí. Lo recomendamos especialmente para quienes apunten a defender el TP en una entrevista laboral.

---

## Preguntas frecuentes

**¿Puedo hacer la V1 directamente?**
Sí. La V2 es una opción para quienes prefieren un alcance más manejable. La V1 da más puntos máximos posibles porque tiene más bonus, pero ambas se aprueban con 60+.

**¿Las 3 extensiones tienen que ser un combo específico?**
No. Cualquier combinación de 3 de las 4. Si tienen dudas de qué combo elegir, vengan a una clase de consulta — los orientamos según el perfil de cada uno.

**¿Puedo entregar individual y que mi compañero entregue otro TP por su cuenta?**
Sí. Pero si entregan en pareja, **ambos tienen que poder defender ambas partes**. Si uno hizo solo el front y no entiende el contrato, baja la nota de los dos.

**¿Qué pasa si solo hago 2 extensiones bien hechas en lugar de 3 a medias?**
Se evalúa lo entregado. Dos extensiones perfectas a 17 puntos cada una son 34. Falta llegar a 60. Mejor 3 razonables que 2 perfectas.

**¿Puedo cambiar de stack (ej. Vue, Express, Hardhat)?**
No. La consigna es modificar el template, no reescribirlo. Foundry + Next.js + FastAPI es lo que evaluamos.

---

## Referencias

- **Ohlhaver, Weyl & Buterin (2022)**. *Decentralized Society: Finding Web3's Soul*. SSRN [4105763](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763). Paper que define **Soulbound Tokens** — el concepto detrás de la Extensión A.
- **Grech & Camilleri (2017)**. *Blockchain in Education*. JRC, Comisión Europea. EUR 28778 EN, doi:[10.2760/60649](https://publications.jrc.ec.europa.eu/repository/handle/JRC108255). Reporte fundacional sobre adopción de blockchain en educación.
- **Universidad Nacional de Córdoba (2025)**. [Premio MetaRed TIC](https://www.unc.edu.ar/inform%C3%A1tica/blockchain-y-educaci%C3%B3n-la-unc-premiada-por-su-innovaci%C3%B3n-en-gesti%C3%B3n-acad%C3%A9mica). Caso argentino de referencia.
- [Foundry Book](https://book.getfoundry.sh/) · [wagmi v2 docs](https://wagmi.sh/) · [viem](https://viem.sh/) · [RainbowKit](https://www.rainbowkit.com/) · [FastAPI](https://fastapi.tiangolo.com/) · [Base Sepolia docs](https://docs.base.org/chain/network-information).

---

> **Cualquier duda**: clases de consulta los lunes 18:00, o por mensaje directo. **No usen el foro general** para esta V2 — la consigna oficial sigue siendo la V1.
