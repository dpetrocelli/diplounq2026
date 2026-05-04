# Diagramas de arquitectura — del ciclo del contrato al sistema de credenciales

> **Para qué sirve esta página**: tener visualizaciones polidas que cubren todo el camino conceptual de la diplomatura — desde "qué es un smart contract" hasta "cómo se construye el sistema de credenciales académicas UNQ".

---

## 1 · El ciclo de un smart contract

Lo más fundamental: del archivo `.sol` que escribís en tu disco, al contrato deployado en la chain, al usuario final que lo usa desde el browser. Tres swim-lanes (tu máquina, blockchain, Etherscan) muestran qué pieza vive dónde y qué herramienta hace de bisagra entre ellas.

![Ciclo completo](assets/diagramas/01-ciclo-completo.png)

---

## 2 · Read vs Write — la distinción crítica

La confusión #1 de todo principiante. `cast call` y `cast send` se ven idénticos en el código pero hacen cosas radicalmente distintas. **Regla mnemotécnica**: si la función Solidity dice `view` o `pure` → `cast call`. Cualquier otra cosa → `cast send`.

![Read vs Write](assets/diagramas/02-read-vs-write.png)

---

## 3 · Qué vive dónde — público vs privado

Mapa mental para saber qué se puede compartir y qué nunca. Todo lo que está del lado rojo (private key, frase BIP-39, `.env`) es secreto. Todo lo del lado verde (address, txs, bytecode, storage, source verificado) es **público por diseño** — cualquiera lo lee.

![Qué vive dónde](assets/diagramas/03-que-vive-donde.png)

---

## 4 · Arquitectura real del sistema de credenciales

**El sistema completo**: Frontend (Vercel) + Backend Web2 (k3s) + `AcademicCredentials.sol` (Sepolia → más adelante Base/Polygon) + IPFS para PDFs y fotos + indexer The Graph + observabilidad (Tenderly + Sentry).

> **El contrato es UNA pieza** del sistema, no es todo. Es el "servicio de credenciales" en una app tradicional. El resto (UI, API, BD, login admin, monitoreo) sigue siendo lo de siempre.

![Arquitectura del sistema](assets/diagramas/04-sistema-real.png)

---

## 5 · Las 3 capas — mapa global del sistema

El mapa mental de más alto nivel sobre el que se apoya todo el sistema: **edge / cliente** (browser del decano/estudiante/verificador + frontend en Vercel + MetaMask) · **web2 infra** (backend, indexer, Postgres, IPFS, observabilidad — la app web tradicional) · **on-chain** (`AcademicCredentials.sol` + roles + state inmutable de las credenciales en Sepolia).

![Las 3 capas](assets/diagramas/05-tres-capas.png)

> **Regla práctica**: si lo pueden romper sin pedirle permiso a nadie → es suyo (web2). Si necesitan firma + gas → es on-chain.

> **Cómo leer este diagrama**: lo de arriba (naranja) es lo que ve y toca el usuario. Lo del medio (azul) es la app web "de toda la vida" — un Next.js, un FastAPI, un Postgres. Lo de abajo (verde) es el contrato — la única pieza que **no controlan** una vez deployada.

---

## Material relacionado

- [Clase 3 — Cierre de Clase 2 + Credenciales académicas](clase-3-clase.html) — la clase donde se introducen estos conceptos
- [Clase 4 — Frontend NFT + Seguridad](clase-4-clase.html)
- [Trabajo Final — Verificación de credenciales académicas UNQ](tp-final.html) — el TP de la diplomatura
