# Trabajo Final — Sistema de Verificación de Credenciales Académicas (UNQ)

> **Objetivo**: construir un sistema que permita a la UNQ emitir títulos universitarios verificables on-chain, sin pasar por la oficina de alumnos y sin depender de servidores centralizados. Es el **TP final de la materia Desarrollo de Smart Contracts y DApps** (una de las materias de la diplomatura).

## ¿Por qué este TP?

Las otras materias de la diplomatura están orientando sus trabajos finales a **resolver problemas reales de la UNQ**. La pieza que armamos acá es **la base técnica del sistema**; otras materias pueden encargarse de la integración administrativa, la UX, el modelo de datos pedagógico, etc.

| Problema clásico | Cómo lo resuelve blockchain |
|---|---|
| El servidor de la universidad se rompe / se borra / lo hackean | El estado vive replicado en miles de nodos, inmutable |
| Un certificado en PDF se puede falsificar | El emisor (UNQ) firma criptográficamente, cualquiera verifica |
| Verificar un título requiere llamar a la universidad y esperar días | Cualquiera con la dirección del contrato y el `tokenId` verifica en segundos |
| El egresado depende de la universidad para "demostrar" su título | Lo tiene en su wallet — nadie se lo puede sacar (salvo revocación) |

## Punto de partida

Lo que escribieron en clase 3 (`AcademicCredentials`) es el **esqueleto** del TP. Lo que hacen acá es **extenderlo** con todo lo que hace falta para un sistema productivo.

---

## Reglas

| | |
|---|---|
| **Plazo de entrega** | Lunes **08/06/2026 · 18:00** |
| **Grupos** | Individual o **pareja** (máximo 2 personas) |
| **Alcance** | Solo **títulos finales** (Licenciatura, Tecnicatura, Profesorado). No incluye certificados de cursos / diplomas intermedios |
| **Datos** | **Caso ficticio** — UNQ "Demo". Inventar 3-5 personas con DNI ficticios. **No usar datos reales de alumnos**. |
| **Nota mínima** | 60 / 100 |
| **Cómo se entrega** | Repositorio Git (público o privado con permisos a los docentes) + video demo **o** URL pública de la aplicación funcional |

---

## Parte 0 — Hook UNQ + Modelado de datos (20%)

> Esto va al **principio del README**, antes que cualquier otra cosa. Es lo primero que vamos a leer al evaluar.

### 0.1 Hook UNQ (5%) — por qué este TP

#### El problema real

En mayo de 2023, la Policía Federal desbarata la **"Operación Alejo"**: una red que había vendido más de **500 títulos secundarios y universitarios truchos**, principalmente para ejercer en **medicina y educación** ([Infobae, 2023](https://www.infobae.com/sociedad/2023/05/04/una-banda-de-falsificadores-vendio-titulos-secundarios-y-universitarios-truchos-a-mas-de-500-clientes/)). Dos años antes, en Río Cuarto, **un chico de 19 años se hizo pasar por médico durante la pandemia** usando una matrícula ajena, coordinó hisopados y reemplazó a profesionales en dispensarios ([La Nación, 2021](https://www.lanacion.com.ar/sociedad/escandalo-en-cordoba-el-medico-trucho-suma-antecedentes-y-hasta-lo-investigan-por-homicidio-nid10022021/)). En 2025, la Cámara Federal sigue procesando casos similares.

El problema no es que falten sistemas — es que los que hay **no permiten verificar al instante** quién emitió el título, ni con qué autoridad. Hoy en Argentina:

- **SIDCER** (Ministerio de Educación) digitalizó los diplomas, pero es **centralizado**: si el sistema cae o un dato se altera internamente, no hay verificación independiente.
- **Apostillar un título argentino** para usarlo afuera cuesta **USD 30-40 y 20-30 días corridos** ([Cancillería, TAD](https://www.cancilleria.gob.ar/es/servicios/apostilla-legalizacion-con-validez-internacional-tad)).
- En Argentina hay un precedente: la **[Universidad Nacional de Córdoba](https://www.unc.edu.ar/inform%C3%A1tica/blockchain-y-educaci%C3%B3n-la-unc-premiada-por-su-innovaci%C3%B3n-en-gesti%C3%B3n-acad%C3%A9mica)** implementó un Sistema de Validación Académica con smart contracts sobre blockchain, integrado a SIU Guaraní. Redujo el trámite de **4 meses a 2 semanas** y ganó el **Premio Internacional MetaRed TIC 2025** (categoría Tecnología para la Gestión Universitaria). El resto del sistema universitario nacional (UBA, UNLP, UTN, ITBA, UNQ) todavía no tiene nada institucional — UNC es el caso a estudiar y a emular.

#### Lo que ya hicieron otras universidades

| Año | Institución | Stack | Volumen |
|---|---|---|---|
| 2014 | **Universidad de Nicosia** (Chipre) | Bitcoin | Primera del mundo en emitir certificados blockchain |
| 2017 | **MIT** | Blockcerts (BTC) | ~600 graduados en el primer año ([MIT News](https://news.mit.edu/2017/mit-debuts-secure-digital-diploma-using-bitcoin-blockchain-technology-1017)) |
| 2018-19 | **Malta** | Blockcerts (BTC) | **País entero** — todas las instituciones educativas |
| 2018 | **UE — EBSI** | Verifiable Credentials W3C | 25+ proyectos activos, diplomas transfronterizos |
| 2018 | **Tec de Monterrey** (México) | IBM blockchain | 5.000-10.000 certificados/año |
| 2019 | **Univ. Nacional de Colombia** | eTítulo | Primera pública latinoamericana |
| 2025 | **W3C** | — | **Verifiable Credentials 2.0** [es estándar oficial](https://www.w3.org/press-releases/2025/verifiable-credentials-2-0/) |

#### Por qué este TP importa

UNQ tiene ~11.000 estudiantes activos, 18 carreras de grado, modalidad virtual desde 1999 (pionera nacional). El sistema que ustedes están armando, si funciona, **resuelve un problema real**: que cualquier RRHH del mundo pueda verificar un título de UNQ en 3 segundos pegando un `tokenId` en una web pública, en vez de esperar 30 días por una apostilla.

Y el modelo es replicable. Argentina tiene **60+ universidades nacionales**, ~140.000 egresados/año (CONEAU/SPU). Existe infraestructura pública sin uso ([Blockchain Federal Argentina](https://bfa.ar/blockchain/casos-de-uso/titulos-academicos)) — falta el sistema que la consuma. **No están haciendo un toy project. Están prototipando una pieza de infraestructura.**

#### Referencias académicas

Si en su README quieren citar literatura para defender decisiones de diseño (lo que un buen TP hace), estas son las fuentes más citadas y aplicables al TP:

##### Fundacionales / conceptuales

- **Grech, A. & Camilleri, A. F. (2017)**. *Blockchain in Education*. Joint Research Centre, European Commission. Luxembourg: Publications Office of the EU. EUR 28778 EN, doi:[10.2760/60649](https://publications.jrc.ec.europa.eu/repository/handle/JRC108255). Reporte fundacional del JRC sobre adopción de blockchain en educación. Propone **8 escenarios de uso** y discute privacidad y gobernanza. ~180 citas Scholar.

- **Ohlhaver, P., Weyl, E. G. & Buterin, V. (2022)**. *Decentralized Society: Finding Web3's Soul*. SSRN [4105763](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763). **Paper que define el concepto de Soulbound Tokens (SBTs)** — credenciales no transferibles atadas a una identidad. Es exactamente el diseño que ustedes están implementando con el override de `_update`. Si alguien pregunta "¿por qué no transferible?" en la defensa, este es el paper a citar. Uno de los más descargados de SSRN.

##### Diseño / arquitectura

- **Turkanović, M., Hölbl, M., Košič, K., Heričko, M. & Kamišalić, A. (2018)**. *EduCTX: A Blockchain-Based Higher Education Credit Platform*. IEEE Access, 6, 5112-5127. doi:[10.1109/ACCESS.2018.2789929](https://ieeexplore.ieee.org/document/8247166). Diseño de referencia para credenciales académicas distribuidas inspirado en ECTS europeo. Patrón **token por crédito** + trade-offs on-chain vs off-chain — directamente aplicable al modelado del struct `Credential`.

##### Implementación reciente

- **Tiwari, A. et al. (2025)**. *Blockchain ensuring academic integrity with a degree verification prototype*. **Scientific Reports** (Nature), 15, 7943. doi:[10.1038/s41598-025-93913-6](https://www.nature.com/articles/s41598-025-93913-6). Prototipo de verificación de **títulos universitarios** con red blockchain híbrida y nodos Docker. **Nature, 2025** — el más reciente y el de stack más cercano al que van a usar (Ethereum-like + Docker).

##### Estado del arte

- **Nasir, A., Rasheed, M. et al. (2025)**. *A Systematic Review of Blockchain-Based Initiatives in Comparison to Best Practices Used in Higher Education Institutions*. Computers (MDPI), 14(4), 141. doi:[10.3390/computers14040141](https://www.mdpi.com/2073-431X/14/4/141). Revisión sistemática reciente — best practices y gaps. Menciona Blockcerts y EBSI como benchmarks.

> Si justifican una decisión técnica con un paper (ej. "elegimos soulbound siguiendo Ohlhaver, Weyl & Buterin 2022" o "el patrón hash on-chain + PDF off-chain está validado en Tiwari et al. 2025"), suma puntos en la rúbrica de modelado (parte 0.2).

#### Lo que les pedimos en esta sección

En 2-3 párrafos en el README, justificar:

- **¿Qué área de UNQ operaría el sistema?** (rectorado, secretaría académica, decanato de facultad)
- **¿Cómo encaja en el flujo actual?** (¿reemplaza SIDCER? ¿corre en paralelo? ¿es una capa de verificación pública sobre lo que ya hay?)
- **¿Quién es el usuario que se beneficia?** (egresado que aplica afuera, empleador que verifica, la propia universidad)
- **¿Por qué blockchain y no una base de datos firmada?** (defender la elección — si una BD centralizada alcanza, decirlo)

> Si no logran enmarcar el "para qué", pierden estos 5 puntos enteros. La parte técnica sin contexto vale poco.

### 0.2 Modelado de datos / arquitectura (15%)

Diagrama + texto explicando:

1. **Diagrama de componentes**: qué piezas hay (smart contract, IPFS, frontend, wallet del rector, wallet del decano, browser del verificador) y cómo se conectan.
2. **Modelado del struct `Credential`**: qué campos guarda y por qué cada uno está on-chain o off-chain. Justificar:
   - ¿Por qué `studentNameHash` y no `studentName` en clear?
   - ¿Por qué `documentHash` separado del `metadataURI`?
   - ¿Qué pasa si la universidad pierde el JSON de IPFS?
3. **Diagrama de flujo de emisión**: rector da rol a decano → decano firma transacción → contrato emite → evento → frontend lo ve.
4. **Diagrama de flujo de verificación pública**: empleador entra a `/verify/<tokenId>` → frontend lee del contrato → muestra datos.

> Aceptamos diagramas en draw.io, Excalidraw, Mermaid (en el README), o foto de papel/pizarra si está prolijo.

---

## Parte 1 — Smart contract (35%)

### Lo que ya tienen

De clase 3: ERC-721 con URIStorage + Ownable + `issueCredential` + `revoke` + `isValid`.

### Lo que tienen que agregar

#### 1. Roles con `AccessControl`

Reemplazar `Ownable` por `AccessControl` con dos roles:

- `ISSUER_ROLE` — quien puede emitir y revocar credenciales (decanos, secretarías).
- `DEFAULT_ADMIN_ROLE` — quien puede agregar/quitar issuers (rector).

```solidity
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
```

#### 2. Soulbound (no transferible)

Los títulos NO se pueden transferir. Sobrescribir `_update` para revertir cualquier transfer (mintear y quemar siguen funcionando):

```solidity
function _update(address to, uint256 tokenId, address auth)
    internal override returns (address)
{
    address from = _ownerOf(tokenId);
    if (from != address(0) && to != address(0)) {
        revert("Soulbound: non-transferable");
    }
    return super._update(to, tokenId, auth);
}
```

#### 3. Struct `Credential` extendido

```solidity
struct Credential {
    string degreeName;       // "Licenciatura en Sistemas de Información"
    bytes32 studentNameHash; // keccak256(nombre completo + DNI) — privacidad
    uint256 issueDate;       // timestamp de emisión
    bytes32 documentHash;    // keccak256 del PDF original del título
    bool active;             // false si fue revocado
}

mapping(uint256 => Credential) public credentials;
```

> **¿Por qué hashear el nombre?** El ledger es público. Si guardás `"Juan Pérez DNI 12345678"` en clear, cualquiera lo lee. Guardando el hash, **solo quien ya conoce los datos** puede verificar la coincidencia. Es un *commitment scheme*.

#### 4. Eventos

```solidity
event CredentialIssued(address indexed student, uint256 indexed tokenId, string degreeName, bytes32 studentNameHash);
event CredentialRevoked(uint256 indexed tokenId, address indexed by, string reason);
event IssuerGranted(address indexed account, address indexed by);
event IssuerRevoked(address indexed account, address indexed by);
```

### Funciones obligatorias

| Función | Quién | Qué hace |
|---|---|---|
| `grantIssuer(address)` | `DEFAULT_ADMIN_ROLE` | Agrega un nuevo emisor |
| `revokeIssuer(address)` | `DEFAULT_ADMIN_ROLE` | Quita un emisor |
| `issueCredential(student, tokenId, degreeName, studentNameHash, documentHash, metadataURI)` | `ISSUER_ROLE` | Emite y guarda los datos |
| `revoke(tokenId, reason)` | `ISSUER_ROLE` | Revoca con motivo |
| `verify(tokenId)` returns `(Credential, bool isValid)` | Cualquiera | Devuelve datos + estado |

### Criterios de aprobación

- [ ] Compila sin warnings
- [ ] Roles funcionan: solo `ISSUER_ROLE` emite/revoca, solo `DEFAULT_ADMIN_ROLE` agrega/quita issuers
- [ ] Soulbound: mintear y quemar OK, transferir falla
- [ ] Cada credencial guarda los 5 campos del struct
- [ ] Los 4 eventos se emiten correctamente con sus `indexed`

---

## Parte 2 — Testing (10%)

### Tests obligatorios

#### Camino feliz
1. Admin agrega un issuer y se verifica con `hasRole(ISSUER_ROLE, addr)`
2. Issuer emite una credencial y todos los campos se guardan
3. `verify()` devuelve los datos correctos
4. Issuer revoca y `verify()` devuelve `isValid = false`

#### Casos de error
5. Una address sin `ISSUER_ROLE` no puede emitir (revierte)
6. **Transferir una credencial entre dos addresses revierte** (soulbound)
7. Emitir con `tokenId` duplicado revierte
8. Revocar un `tokenId` inexistente revierte
9. Una address sin `DEFAULT_ADMIN_ROLE` no puede agregar issuers

#### Fuzz
10. `fuzz_issueCredential(address student, uint256 tokenId)` — verificar que `ownerOf(tokenId) == student` para cualquier `student != address(0)`

### Coverage

```bash
forge coverage --report lcov
```

Mínimo **80%** en `AcademicCredentials.sol`.

### Criterios

- [ ] Todos los tests pasan
- [ ] Coverage ≥ 80%
- [ ] Al menos 1 fuzz test
- [ ] Test que valida soulbound (transfer revierte)

---

## Parte 3 — Seguridad (10%)

### Slither

```bash
pip install slither-analyzer
slither .
```

Documentar **cada finding** en un archivo `SECURITY.md`:

| Finding | Severidad | ¿Real? | Cómo lo arreglé / por qué es false positive |
|---|---|---|---|
| ... | ... | ... | ... |

### Checklist obligatorio

- [ ] Solidity 0.8.20+ (overflow protection nativa)
- [ ] `AccessControl` correctamente aplicado
- [ ] Eventos en TODA mutación de estado
- [ ] Validación de inputs (no permitir `address(0)`, `tokenId` duplicado, hash vacío)
- [ ] Soulbound implementado correctamente
- [ ] No hay `selfdestruct`, `delegatecall` a addresses arbitrarias, ni `tx.origin` en checks de auth
- [ ] El `documentHash` es `bytes32` (no `string` — gas + integridad)

### Análisis propio (sección obligatoria del `SECURITY.md`)

Slither detecta lo conocido. Lo más interesante es **lo que pensaste vos**. Agreguen una sección **"Análisis propio"** con 3-5 párrafos respondiendo:

- **¿Qué pasa si el rector pierde la wallet del `DEFAULT_ADMIN_ROLE`?** ¿Cómo se recupera el sistema?
- **¿Qué pasa si una wallet con `ISSUER_ROLE` se compromete?** ¿Cuántos títulos truchos se pueden emitir antes de detectarlo?
- **¿Qué pasa si emiten una credencial por error** (al alumno equivocado, con datos errados)? ¿Cómo se corrige sin perder trazabilidad?
- **¿Qué riesgo hay en el front-running** (alguien ve la tx en la mempool y…)?
- **Privacidad**: el `studentNameHash` es público. ¿Se puede hacer ataque de diccionario contra él?

No hace falta resolver todo — sí pensarlo. Una credencial buena viene con un análisis de amenazas honesto, no con "todo bien".

### Criterios

- [ ] Slither corrió y todos los findings están documentados en `SECURITY.md`
- [ ] El checklist está 100% cumplido
- [ ] No hay High/Medium severity sin justificar
- [ ] Sección **"Análisis propio"** completada en `SECURITY.md`

---

## Parte 4 — Frontend + Deploy a L2 (20%)

> 🎁 **Starter repo**: les dejamos un frontend de partida ya cableado con wagmi + RainbowKit en <https://github.com/dpetrocelli/diplo-unq-blockchain-tp-final-starter>. Forkean, cambian la `CREDENTIALS_ADDRESS` y el ABI con el que generaron al deployar el contrato, y arrancan. **No tienen que armar el frontend desde cero** — el foco está en cablear los modos correctamente y entender qué hace cada llamada.

### 4.1 Frontend (10%)

**Obligatorio** — dos modos:

#### Modo público — verificador (cualquiera, sin login)
- Form para ingresar `tokenId`
- Muestra: ¿existe?, ¿está activo?, nombre del título, fecha de emisión, address del estudiante (corta), `documentHash` para cotejar con el PDF físico

#### Modo issuer (`ISSUER_ROLE`)
- Form para emitir credencial:
  - Address del estudiante
  - tokenId (auto-incremental ideal, manual está OK)
  - Nombre del título (dropdown con las opciones de la facultad)
  - Datos del estudiante → el frontend hashea y manda solo el hash
  - `metadataURI` puede ser un string placeholder (ej. `ipfs://demo/cred-001.json`) — la integración real con IPFS es **opcional** (ver bonus)
- Form para revocar credencial (con razón)

**Opcional** — suma puntos como bonus:

#### Modo super-admin (`DEFAULT_ADMIN_ROLE`) — **+5 bonus**
- Form para agregar/quitar issuers

#### Integración real con IPFS (Pinata) — **+5 bonus**
- Upload PDF a IPFS desde el navegador
- El frontend hashea el PDF y manda hash + CID real como `metadataURI`

### Stack obligatorio (ya cableado en el starter)

- Next.js 14 (App Router)
- wagmi v2 + viem
- RainbowKit para conexión de wallet

### 4.2 Deploy a L2 (10%) — **OBLIGATORIO**

El sistema tiene que estar deployado en una **L2** (Layer 2). Recomendamos **Base Sepolia** porque:

- Tiene los costos más bajos del ecosistema (~$0.005/tx).
- Misma EVM que Ethereum, mismo Solidity.
- Tiene Etherscan compatible (`sepolia.basescan.org`).

Pasos:

1. Agregar Base Sepolia a MetaMask (chain ID `84532`).
2. Conseguir ETH de testnet en Base Sepolia ([Coinbase Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet) o [Alchemy](https://www.alchemy.com/faucets/base-sepolia)).
3. `forge create` con `--rpc-url https://sepolia.base.org`.
4. `forge verify-contract` para que aparezca el código fuente en Basescan.
5. Cambiar el frontend de Sepolia → Base Sepolia (`wagmi.ts`).
6. Emitir 3 credenciales de prueba reales en Base Sepolia.
7. **(Opcional, recomendado)** Deployar el frontend del verificador online (Vercel free tier o GitHub Pages) para que cualquiera pueda probarlo con una URL. Si no logran deployarlo, el video demo cumple la misma función — pero la URL pública suma puntos.

### Criterios de la parte 4

- [ ] La DApp anda en `localhost:3000` después de un `npm install + npm run dev`
- [ ] Conecta wallet (MetaMask) en Base Sepolia
- [ ] La UI cambia según el rol del usuario conectado
- [ ] Verificación pública anda (modo lectura sin login)
- [ ] Emisión anda con el `ISSUER_ROLE`
- [ ] Maneja loading + errores con mensajes claros
- [ ] Contrato deployado en Base Sepolia y **verificado en Basescan**
- [ ] **Video demo** mostrando la app funcionando **o** frontend deployado online
- [ ] **3 credenciales emitidas reales** en Base Sepolia (visibles en Basescan)

---

## Parte 5 — Demo + entregables finales (5%)

### Demo end-to-end

Pueden entregar **una de las dos opciones**:

#### Opción A — Video demo (3-5 min)

Sin cortes ni post-producción rara. Subir a YouTube unlisted, Google Drive con link público, o adjuntar al campus.

#### Opción B — App deployada (URL pública)

El frontend online + el contrato en Base Sepolia con 3 credenciales reales emitidas, listas para verificar. Se evalúa probando la URL.

#### Cubrir este flujo (en cualquiera de las dos opciones)

1. Verificación pública de un título (`tokenId` → muestra los datos).
2. Wallet con `DEFAULT_ADMIN_ROLE` agrega un issuer.
3. Wallet con `ISSUER_ROLE` emite un título → evento en Basescan.
4. El egresado ve el NFT en MetaMask.
5. Intento de transfer → falla (soulbound).
6. El issuer revoca el título → la verificación pública pasa de ✅ a ❌.

> Si eligen video y se animan, lo pueden hacer también en vivo el día de la corrección — pero el TP entregable formal es uno de los dos de arriba.

### README

El README del repo tiene que tener:

1. **Hook UNQ** + **diagramas de arquitectura** (parte 0).
2. **Cómo correr local** (`forge install`, `forge test`, `npm install`, `npm run dev`).
3. **Direcciones deployadas**:
   - Address del contrato en Base Sepolia.
   - Link a Basescan verificado.
   - URL del frontend deployado (si lo deployaron) **o** link al video demo.
4. **Cómo se evalúa la rúbrica** (linkear a esta página).

---

## Resumen de la rúbrica

| Parte | Pts | Qué se evalúa |
|---|---|---|
| 0 — Hook UNQ + modelado | 20 | README arranca con contexto institucional + diagramas claros |
| 1 — Smart contract | 35 | AccessControl + soulbound + struct + eventos + funciones obligatorias |
| 2 — Testing | 10 | Coverage ≥ 80% + soulbound + fuzz + casos error |
| 3 — Seguridad | 10 | Slither documentado + checklist completo |
| 4 — Frontend + Deploy L2 | 20 | Verifier + issuer + Base Sepolia verificado + frontend online |
| 5 — Demo + README | 5 | Video demo (3-5 min) **o** app deployada con flujo end-to-end + README completo |
| **Total** | **100** | |

**Aprueba con 60 puntos.**

### Bonus (suman pero no son obligatorios)

- **+5**: Modo super-admin en el frontend (`DEFAULT_ADMIN_ROLE`) — agregar/quitar issuers vía UI.
- **+5**: Integración real con **Pinata/IPFS** — upload de PDF al emitir + hash on-chain.
- **+10**: Multi-firma (un título solo se emite si firma decano + secretario, vía Gnosis Safe).
- **+10**: QR code en el frontend que abre la verificación.
- **+5**: Indexer con The Graph.
- **+5**: Integración con DID (W3C Decentralized Identifiers).
- **+5**: Notificación on-chain → email/Slack vía Chainlink Functions.

---

## Recursos

| Recurso | URL |
|---|---|
| Repo de partida (clase 3) | <https://github.com/dpetrocelli/diplo-unq-blockchain-clase3> |
| Frontend de referencia (clase 4) | <https://github.com/dpetrocelli/diplo-unq-blockchain-clase4> |
| OpenZeppelin AccessControl | <https://docs.openzeppelin.com/contracts/access-control> |
| OpenZeppelin ERC-721 | <https://docs.openzeppelin.com/contracts/erc721> |
| Pinata IPFS | <https://www.pinata.cloud/> |
| Slither | <https://github.com/crytic/slither> |
| Base Docs (L2) | <https://docs.base.org/> |
| Base Sepolia Faucet | <https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet> |

---

## Origen

Esta consigna surge de una conversación entre la cátedra (Petrocelli + Romero) y los alumnos, donde varios trabajos finales en otras materias de la diplomatura están apuntando a resolver problemas de gestión universitaria (certificación, identidad, autenticación). Esta versión del TP les da **una pieza técnica concreta y reutilizable** que puede integrarse con esos otros trabajos.
