# Trabajo Final — Sistema de Verificación de Credenciales Académicas (UNQ)

> **Objetivo**: construir un sistema que permita a la UNQ emitir títulos universitarios verificables on-chain, sin pasar por la oficina de alumnos y sin depender de servidores centralizados. Es el TP final de la diplomatura.

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
| **Defensa oral** | Semana del **15/06/2026** (15 min por grupo) |
| **Grupos** | Individual o **pareja** (máximo 2 personas) |
| **Alcance** | Solo **títulos finales** (Licenciatura, Tecnicatura, Profesorado). No incluye certificados de cursos / diplomas intermedios |
| **Datos** | **Caso ficticio** — UNQ "Demo". Inventar 3-5 personas con DNI ficticios. **No usar datos reales de alumnos**. |
| **Nota mínima** | 60 / 100 |
| **Cómo se entrega** | Repositorio Git (público o privado con permisos a los docentes) + video demo + URL pública del frontend deployado |

---

## Parte 0 — Hook UNQ + Modelado de datos (10%)

> Esto va al **principio del README**, antes que cualquier otra cosa. Es lo primero que vamos a leer al evaluar.

### 0.1 Hook UNQ (5%)

En 1-2 párrafos, contestar:

- **¿Qué área de UNQ usaría este sistema?** (rectorado, secretaría académica, oficina de alumnos, decanato de una facultad, etc.)
- **¿Cómo encajaría en el flujo actual?** (¿reemplaza un proceso existente? ¿se suma como capa sobre lo que ya hay?)
- **¿Quién es el usuario?** (¿el egresado? ¿un empleador que verifica? ¿la propia universidad?)

> No tiene que ser perfecto, pero sí mostrar que pensaron el sistema **integrado a la institución real**, no como ejercicio aislado.

### 0.2 Modelado de datos / arquitectura (5%)

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

## Parte 2 — Testing (20%)

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

### Criterios

- [ ] Slither corrió y todos los findings están documentados en `SECURITY.md`
- [ ] El checklist está 100% cumplido
- [ ] No hay High/Medium severity sin justificar

---

## Parte 4 — Frontend + Deploy a L2 (20%)

### 4.1 Frontend (10%)

Tres modos según el rol del que está conectado:

#### Modo público — verificador (cualquiera, sin login)
- Form para ingresar `tokenId`
- Muestra: ¿existe?, ¿está activo?, nombre del título, fecha de emisión, address del estudiante (corta), link al PDF (resuelto desde IPFS), `documentHash` para cotejar con el PDF físico

#### Modo issuer (`ISSUER_ROLE`)
- Form para emitir credencial:
  - Address del estudiante
  - tokenId (auto-incremental ideal, manual está OK)
  - Nombre del título (dropdown con las opciones de la facultad)
  - Datos del estudiante → el frontend hashea y manda solo el hash
  - Upload PDF a IPFS (Pinata) → el frontend hashea el PDF y manda hash + CID como `metadataURI`
- Form para revocar credencial (con razón)

#### Modo super-admin (`DEFAULT_ADMIN_ROLE`)
- Form para agregar/quitar issuers

### Stack obligatorio

- Next.js 14 (App Router)
- wagmi v2 + viem
- RainbowKit para conexión de wallet
- (Bonus) Pinata SDK para subir a IPFS desde el navegador

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
7. La página pública del verificador tiene que estar **deployada también** (Vercel free tier o GitHub Pages) para que cualquiera pueda probarla con una URL.

### Criterios de la parte 4

- [ ] La DApp anda en `localhost:3000` después de un `npm install + npm run dev`
- [ ] Conecta wallet (MetaMask) en Base Sepolia
- [ ] La UI cambia según el rol del usuario conectado
- [ ] Verificación pública anda (modo lectura sin login)
- [ ] Emisión anda con el `ISSUER_ROLE`
- [ ] Maneja loading + errores con mensajes claros
- [ ] Diseño responsive (funciona en mobile)
- [ ] Contrato deployado en Base Sepolia y **verificado en Basescan**
- [ ] Frontend deployado online (URL pública)
- [ ] **3 credenciales emitidas reales** en la DApp deployada

---

## Parte 5 — Video demo + entregables finales (5%)

### Video demo (3-5 min)

Tiene que mostrar **en este orden** (sin cortes ni post-producción rara):

1. La URL del verificador público funcionando (verificar 1-2 títulos).
2. Login con la wallet del rector → agregar un issuer en vivo.
3. Login con la wallet del decano → emitir un título a una wallet → mostrar el evento en Basescan.
4. Login con la wallet del egresado → mostrar el NFT en MetaMask.
5. Intento de transfer en MetaMask → falla (soulbound).
6. Decano revoca el título → la verificación pública pasa de ✅ a ❌.

> Subir a YouTube unlisted, Google Drive con link, o adjuntar al campus.

### README

El README del repo tiene que tener:

1. **Hook UNQ** + **diagramas de arquitectura** (parte 0).
2. **Cómo correr local** (`forge install`, `forge test`, `npm install`, `npm run dev`).
3. **Direcciones deployadas**:
   - Address del contrato en Base Sepolia.
   - Link a Basescan verificado.
   - URL del frontend deployado.
4. **Cómo se evalúa la rúbrica** (linkear a esta página).

---

## Resumen de la rúbrica

| Parte | Pts | Qué se evalúa |
|---|---|---|
| 0 — Hook UNQ + modelado | 10 | README arranca con contexto institucional + diagramas claros |
| 1 — Smart contract | 35 | AccessControl + soulbound + struct + eventos + funciones obligatorias |
| 2 — Testing | 20 | Coverage ≥ 80% + soulbound + fuzz + casos error |
| 3 — Seguridad | 10 | Slither documentado + checklist completo |
| 4 — Frontend + Deploy L2 | 20 | 3 modos + Base Sepolia verificado + frontend online |
| 5 — Video demo + README | 5 | Demo end-to-end de 3-5 min + README completo |
| **Total** | **100** | |

**Aprueba con 60 puntos.**

### Bonus (suman pero no son obligatorios)

- **+10**: Multi-firma (un título solo se emite si firma decano + secretario, vía Gnosis Safe).
- **+10**: QR code en el frontend que abre la verificación.
- **+5**: ZK proof "tengo título de UNQ sin revelar cuál" (Noir o Circom).
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
