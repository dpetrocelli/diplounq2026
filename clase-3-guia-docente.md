<head><meta name="robots" content="noindex,nofollow"></head>

# Guía docente — Clase 3 (Credenciales académicas / ERC-721)

> **Audiencia**: Dr. David Petrocelli + Esp. Ciro Romero. Esta guía NO es para los pibes — es el script con el que damos la clase. Página unlisted: no está en el index, no se indexa en buscadores.

> **Duración**: 4 horas (240 min). Hay 25 min de buffer para pausas / preguntas / un alumno trabado.

> **Material del alumno**: [clase-3-clase.html](clase-3-clase.html) + [diagramas-arquitectura.html](diagramas-arquitectura.html). El profe abre AMBAS en pestañas separadas para alternar.

---

## Pre-clase · 15 min antes de empezar

### Setup técnico

- [ ] Verificar conexión a Sepolia: `cast block-number --rpc-url https://ethereum-sepolia-rpc.publicnode.com` (tiene que devolver un número alto y reciente).
- [ ] MetaMask con `0.05+ ETH` en Sepolia (cuenta dedicada `unq-dev-prof`). Si está bajo, ir al [Google Cloud Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia) **antes** de empezar.
- [ ] API key de Etherscan exportada en la terminal: `export ETHERSCAN_API_KEY=...`
- [ ] Repo `diplo-unq-blockchain-clase3` clonado local + `forge install` + `forge build` + `forge test` pasa los 14 tests.
- [ ] Anvil disponible (probar `anvil --help` por si la instalación quedó rota desde clase 2).
- [ ] Pestañas abiertas en el browser:
  - `clase-3-clase.html`
  - `diagramas-arquitectura.html`
  - `https://sepolia.etherscan.io/`
  - MetaMask en Sepolia
- [ ] Terminal en modo "demo" (zoom 130%, fondo negro, tamaño legible para los del fondo del aula).
- [ ] Cerrar Slack, mail, todo lo que tire notificaciones en pantalla.
- [ ] Backup: si Sepolia se cae a mitad de clase, deployamos en Anvil local — tener un script `anvil-fallback.sh` listo.

### Lo que probablemente vamos a romper (anticiparlo)

- ⚠️ Faucet sin ETH → tener un secondary listo (segunda cuenta `unq-dev-prof-2` con balance).
- ⚠️ Sepolia con bloque lento → el `forge create` puede tardar 30-60s, **NO entrar en pánico** ni cancelar la tx, decirles a los alumnos "esperen, esto es normal".
- ⚠️ Algún alumno sin MetaMask configurado → mandarlo a la sección "Pre-requisitos" de [clase-3-clase.html](clase-3-clase.html) y que la haga en vivo mientras seguimos. Si pierde 20 min, la recupera con la tarea.
- ⚠️ `forge install` falla en alguna red corporativa → preparar un tarball `vendored-deps.tar.gz` con `lib/` ya populado, copiar y `tar xzf`.
- ⚠️ `cast wallet import` pide password y nadie lo anota → recordarles ANTES de importar: "elijan un password fácil que se acuerden, no es el de MetaMask, es local".

---

## Apertura · 5 min

Cuando entran al aula y se acomodan:

> "Buenas. La clase pasada terminamos con `SimpleStorage` testeado en sus máquinas. Levantamos la mano: ¿quién logró correr `forge test` y vio los 10 tests pasar en verde?"

(Esperar a ver manos. Si menos de la mitad las levanta, ahí ya hay un problema de prerrequisitos. Si es así, dedicar 3 min extra al final del Bloque 2 para revisar.)

> "Hoy hacemos dos saltos grandes. **Primero**, terminamos lo que quedó pendiente de clase 2: levantamos una blockchain local con Anvil, hablamos con el contrato desde la terminal con `cast`, y después llevamos eso mismo a Sepolia y lo vemos en Etherscan. **Segundo**, pasamos del juguete `SimpleStorage` al contrato real del TP final: un NFT ERC-721 que representa un título universitario."

> "Al final de hoy van a tener un contrato suyo, deployado en una blockchain pública, emitiéndoles un título académico que pueden ver en MetaMask. Eso es la **base** del TP final — todo lo que viene después es extender esto."

> "Antes de tirar comandos, vamos a pasar 20 minutos en una página de diagramas para fijar el modelo mental. Si entendemos el mapa primero, después escribir código es solo seguir el mapa."

(Cambiar de pestaña a `diagramas-arquitectura.html`.)

---

## Bloque 1 · Diagramas para fijar el mental model · 20 min

> **Por qué arrancar acá**: si vamos directo al código, los pibes mueven líneas pero no saben qué están deployando "dónde". Los 4 minutos por diagrama son el seguro pedagógico contra eso.

> **Cómo presentarlo**: abrir [diagramas-arquitectura.html](diagramas-arquitectura.html), hacer scroll desde arriba, parar en cada uno, narrar. NO leer el texto al pie del diagrama — eso lo leen ellos en casa. Acá narramos.

### Diagrama 1 — El ciclo del contrato · 4 min

**Mostrar**: scroll al diagrama #1 ("El ciclo de un smart contract").

**Decir** (apuntando con el cursor):

> "Tres carriles de natación. **Tu máquina** a la izquierda — donde escribís el `.sol`, donde corre `forge build`, donde testeás. **Blockchain** en el medio — Sepolia, mainnet, Base, da igual. Es donde el contrato vive una vez deployado. **Etherscan** a la derecha — es solo un *visor* de la blockchain, no es la blockchain."

**Apuntar al `forge create`**:

> "Esta flecha — `forge create` — es la bisagra. A la izquierda escribiste código humano. A la derecha hay bytecode corriendo en una EVM. Esa flecha es el momento donde tu código sale de tu disco y entra a la red pública."

**Preguntar al aula** (para verificar comprensión):

> "¿Etherscan **es** la blockchain o **lee** la blockchain?"

(Respuesta esperada: la lee. Si alguien dice "es", aclarar: Etherscan es una empresa privada que indexa datos públicos. Si Etherscan se cae, la blockchain sigue. Hay alternativas: Blockscout, Tenderly, etc.)

**Anticipación de confusión**: alguno seguro pregunta "¿el contrato está en mi máquina o en Etherscan?". Respuesta: ni uno ni otro — está en **miles de nodos** que corren la red. Tu máquina y Etherscan solo son **clientes** que le hablan.

### Diagrama 2 — Las 3 capas — mapa global · 5 min

**Mostrar**: diagrama #2 ("Las 3 capas").

**Decir**:

> "Este es el mapa más importante de toda la diplomatura. Tres capas de arriba para abajo: **edge** — lo que ve el usuario (browser, wallet, frontend). **Web2** — la app de toda la vida (Next.js, FastAPI, Postgres, IPFS). **On-chain** — el contrato. Lo único de lo tres que **no controlamos** una vez deployado."

**Apuntar a la línea naranja arriba**:

> "Acá viven los decanos, los estudiantes, los empleadores. No saben Solidity. Solo abren un navegador."

**Apuntar a la capa azul (web2)**:

> "Esto es lo que ya saben hacer. Un Next.js, un Postgres. NO desaparece porque uses blockchain. La blockchain *no reemplaza* a la web — la **complementa**."

**Apuntar a la verde (on-chain)**:

> "Acá vive el contrato. Una sola pieza, chiquita comparada con todo lo demás. Pero es la única **inmutable** — la que no se puede borrar ni alterar."

**Regla práctica que tienen que llevarse**:

> "Si necesitan **firma + gas** → es on-chain. Si no → es web2. Esa es la regla. Cuando estén diseñando el TP final, cada vez que se pregunten '¿esto va al contrato?' — háganse esa pregunta."

**Preguntar**:

> "Login con email y password — ¿en qué capa va?" → web2. "Emisión de un título" → on-chain (firma + gas). "Mostrar la lista de títulos emitidos en una página" → mixto: el dato vive on-chain, pero el frontend lo lee y lo renderiza.

### Diagrama 3 — Arquitectura real del sistema · 6 min

**Mostrar**: diagrama #3 ("Arquitectura del sistema de credenciales").

**Decir** (con énfasis):

> "Este es el sistema completo que vamos a construir entre clase 3, clase 4 y el TP final. Frontend en Vercel, backend opcional, contrato `AcademicCredentials` en Sepolia primero y Base Sepolia para el TP final, IPFS para los PDFs y las fotos, indexer para queries rápidas, observabilidad."

**⚠️ Aclarar fuerte para que no entren en pánico**:

> "**No necesitan TODO esto para el TP**. Esto es la versión **producción aspiracional**. Lo mínimo del TP es: frontend + contrato + IPFS. The Graph, Tenderly, Sentry, Cloudflare — todo eso es enchufable después y suma como bonus, pero no aprueba ni desaprueba."

**Apuntar al contrato en el diagrama**:

> "Vean el tamaño relativo del contrato vs todo lo demás. Es **una pieza** del sistema. La gente cree que blockchain reemplaza la app entera y no — el contrato es el equivalente al microservicio de credenciales en una app tradicional. Todo lo demás sigue siendo lo de siempre."

**Mencionar el split issuer/verifier** (apuntando):

> "Vean cómo el frontend tiene **dos modos**: el del decano que emite títulos (necesita wallet con `ISSUER_ROLE`) y el del verificador público que entra desde afuera y solo lee. Esto es lo que les vamos a pedir en el TP final, parte 4."

### Diagrama 4 — Read vs Write (cast call vs cast send) · 3 min

**Mostrar**: diagrama #4.

**Decir**:

> "Esta es la **confusión #1** de todo principiante en Ethereum. Mismo prefijo `cast`, comportamiento radicalmente distinto."

**Mnemonic device**:

> "Si la función Solidity dice `view` o `pure` → `cast call`. **Lectura, gratis, instantánea, no firma nada.** Cualquier otra cosa → `cast send`. **Modifica state, gasta gas, firma con la wallet, espera un bloque.**"

**Quiz al aula**:

> "Si la función es `view returns (uint256)` — ¿`call` o `send`?" → call.
>
> "Si la función modifica un mapping — ¿qué uso?" → send.
>
> "Si llamo a `ownerOf(tokenId)` — ¿qué uso?" → call (es view).
>
> "Si llamo a `issueCredential(...)` — ¿qué uso?" → send (mintea).

**Anticipación**: alguno va a hacer `cast call` cuando debería hacer `cast send`, no va a ver error pero tampoco va a ver cambio en la blockchain. Avisar:

> "Si hacen `cast call` a una función que escribe, **simula la ejecución localmente**. Les devuelve el resultado pero NO lo manda a la red. Es un error silencioso muy común. Si después ven que `ownerOf` devuelve `0x0`, revisen si usaron `send` o `call`."

### Diagrama 5 — Qué vive dónde · 2 min

**Mostrar**: diagrama #5.

**Decir** (corto, ya lo saben de clase 1):

> "Repaso rápido — esto ya lo cubrimos en clase 1, pero lo refrescamos porque hoy van a estar exportando private keys de MetaMask y la pueden cagar."

**Apuntar al lado rojo**:

> "Rojo = secreto. Private key, frase BIP-39 de 12 palabras, archivo `.env`. **NUNCA** va a git, NUNCA a Slack, NUNCA a un screenshot en un chat con un LLM."

**Apuntar al lado verde**:

> "Verde = público por diseño. Address, txs, bytecode, storage del contrato. Cualquiera lo lee. NO intenten 'esconder' algo poniéndolo on-chain pensando que es privado — es lo opuesto."

### Cierre del bloque · 1 min

> "Listo. Tenemos el mapa. Ahora bajamos al teclado."

(Cambiar de pestaña a `clase-3-clase.html`.)

---

## Bloque 2 · Cierre de clase 2 — Anvil + cast + Sepolia · 30 min

> **Cómo dictar este bloque**: el profe tipea en su terminal proyectada, los alumnos tipean en la suya. Cada subsección termina con un punto de sincronización: "esperen 30 segundos a que todos lleguen acá".

### 2.1 ¿Qué es Anvil? · 3 min

**Demo en pantalla**: solo abrir [clase-3-clase.html#11-qué-es-anvil-y-para-qué-sirve](clase-3-clase.html) y leer la tabla de "Velocidad / Costo / Iteración".

**Decir**:

> "Piensen en Anvil como `localhost:3000` para Ethereum. Es una blockchain de juguete que corre en su máquina, sin minería, sin gas real. La usamos para iterar rápido. Cuando ya funciona, recién ahí vamos a Sepolia."

**No tipear nada todavía** — es conceptual.

### 2.2 Levantar Anvil · 5 min

**Demo en pantalla**:

```bash
cd diplo-unq-blockchain-clase2
anvil
```

**Decir** mientras se llena la pantalla:

> "Vean las 10 cuentas, cada una con 10.000 ETH falsos. Las private keys están **publicadas** en el output — es a propósito. Estas keys son conocidas por todo el mundo, **NUNCA las usen en una red real**."

⚠️ **Pausa de sincronización**:

> "Esperen, no cierren esa terminal. Anvil tiene que seguir corriendo. Abran una **segunda terminal** y vengan al mismo directorio."

(Esperar 30s. Mirar al aula. Preguntar: "¿todos tienen Anvil corriendo en una terminal y otra terminal lista?". Si alguien levanta la mano, ayudarlo.)

### 2.3 Deploy local con `forge create` · 5 min

**Demo en pantalla** — copiar y pegar el comando completo de [clase-3-clase.html#13-deploy-local-con-forge-create](clase-3-clase.html):

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

**Decir** mientras corre:

> "Cuatro flags: qué deployar, contra qué RPC, con qué cuenta firma, y `--broadcast` que dice 'mandalo de verdad, no simules'. Sin `--broadcast` es un dry-run."

> "La address que les devuelve — `0x5FbDB...0aa3` — es **determinística** en Anvil. Si reinician Anvil y hacen el primer deploy, les va a dar siempre la misma. Eso facilita iterar."

**Demo**: exportar la variable y mostrarla:

```bash
export ADDR=0x5FbDB2315678afecb367f032d93F642f64180aa3
echo $ADDR
```

⚠️ **Pausa**: "¿todos tienen una address deployada?" Esperar.

### 2.4 Interactuar con `cast` · 7 min

**Aquí aplica el diagrama #4 que vimos antes**. Avisar:

> "Volvemos al diagrama de read vs write. Vamos a hacer las dos."

**Demo lectura** (call):

```bash
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

**Decir**:

> "Devolvió `0`. Recién deployamos, valor inicial. **No firmamos nada, no gastamos gas.** Esto es `view`."

**Demo escritura** (send):

```bash
cast send $ADDR "store(uint256)" 42 \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

**Decir** mostrando el receipt:

> "Vean: `status: 1`, `gasUsed: 45277`. Ese es el costo en gas de modificar storage. Y vean el campo `logs` — ahí está el evento `NumberUpdated` que emitió el contrato. **Eso es lo que vamos a aprovechar después con Etherscan.**"

**Demo confirmación**:

```bash
cast call $ADDR "favoriteNumber()" --rpc-url http://localhost:8545 | cast --to-dec
```

> "Ahora dice `42`. Se modificó. Cerramos el loop."

**Pregunta al aula**:

> "Si quiero leer un mapping con `cast call`, ¿qué le paso?" (Respuesta: `cast call $ADDR "miMapping(uint256)" 5` — la firma se pasa con tipos, los argumentos después.)

⚠️ **Pausa de 1 min**: "todos hagan los tres comandos. Si les funciona, miran al pizarrón. Si no, levantan la mano."

### 2.5 Deploy a Sepolia · 7 min

> **El primer momento crítico de la clase**. Si Sepolia anda lenta, esto puede tirar 5 min más.

**Decir antes de tipear**:

> "Ahora pasamos a la blockchain real. Sepolia. Chain ID `11155111`. Las transacciones tardan ~12 segundos cada una. **Sin pánico** si parece colgado."

**Demo importar wallet** (proyectar):

```bash
cast wallet import dev-wallet --interactive
```

> "Les va a pedir DOS cosas: la private key (la sacan de MetaMask: ⋮ → Account details → Show private key) y un password local. **El password lo eligen ustedes y lo van a tener que tipear cada vez que firmen algo.** No es el password de MetaMask."

⚠️ **Pausa larga** (2 min): este paso es donde todos se quedan atorados. Caminar entre las filas, ver pantallas, ayudar al que no encuentra "Show private key" en MetaMask.

**Demo deploy** a Sepolia:

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```

> "Va a pedir el password. Después tarda ~12 segundos. **Esperen**, no cancelen. Si pasan 60s sin respuesta, *ahí* sí me llaman."

(Mientras corre, contar: "esto está construyendo la transacción, firmándola con tu private key encriptada, mandándola al nodo público de Sepolia, y esperando que entre en un bloque.")

**Cuando vuelve**:

> "Esa address — diferente a la de Anvil — es ahora **única en Sepolia**. Existe en una blockchain pública. Pueden mandarle el link a su mamá y verlo desde otra computadora."

**Exportar**:

```bash
export ADDR_SEPOLIA=0x...
```

### 2.6 Verlo en Etherscan · 3 min

**Demo en browser**: abrir `https://sepolia.etherscan.io/address/$ADDR_SEPOLIA`.

**Mostrar**:

- La transacción de creación (tab "Transactions").
- El bytecode (tab "Contract" → "Source code not verified" — apuntar: "esto lo arreglamos al final de clase con `forge verify-contract`").
- El campo "Logs" → "no hay logs todavía porque no llamamos `store`".

**Decir**:

> "Cierra el loop completo: del `.sol` que escribieron en su disco al log decodificado en el explorador público. Son las 3 capas del diagrama #1 conectadas."

⚠️ **Pausa**: "¿todos tienen address en Etherscan? Foto a la pantalla, lo van a necesitar para la tarea de clase 2."

---

## Bloque 3 · ERC-721 conceptual · 15 min

> **Aquí baja la intensidad de tipeo**. Más pizarrón, menos teclado. Si hay pizarra física, dibujar. Si no, podés compartir un Excalidraw o dibujar en el iPad y compartir.

### Parte 2 — Qué es un NFT · 8 min

**Decir** (con whiteboard):

> "Hasta ahora trabajamos con `uint256 favoriteNumber`. Una variable. Un número. Si yo y otra persona ponemos `42`, el state es **el mismo número**. No tiene identidad."

**Dibujar**:

```
ERC-20 (fungible)             ERC-721 (no fungible)
┌─────────────┐               ┌─────────────────────┐
│ alice: 100  │               │ tokenId 1 → alice   │
│ bob:    50  │               │ tokenId 2 → bob     │
│ carol:   3  │               │ tokenId 3 → alice   │
└─────────────┘               └─────────────────────┘
balances → cantidad           ownerOf → identidad
```

**Decir**:

> "Un USDC es igual a otro USDC. Eso es ERC-20. Pero un título de Lic en Sistemas de Juan no es igual al de María — tienen DNIs distintos, fechas distintas, foto distinta. Cada uno es **único e identificable**. Eso es ERC-721."

**Pregunta al aula**:

> "¿Un dólar es fungible o no fungible?" (Fungible.) "¿Una entrada al Lollapalooza con butaca asignada?" (No fungible — cada una tiene un asiento.)

**Tres campos** que tiene todo NFT:

> "`tokenId` — el número único. `ownerOf(tokenId)` — quién es dueño hoy. `tokenURI(tokenId)` — link a la metadata: nombre, foto, atributos. Esa metadata vive **fuera** de la chain, normalmente en IPFS, porque guardar JSON on-chain es carísimo."

> "Para un título universitario: `tokenId = 12345`, `ownerOf(12345) = address de Juan Pérez`, `tokenURI(12345) = ipfs://bafy.../titulo-juan.json`."

### Parte 3 — OpenZeppelin · 7 min

**Decir**:

> "Si tuviéramos que escribir un ERC-721 desde cero, son ~400 líneas de Solidity con un montón de edge cases. Mintear, transferir, aprobar, balance tracking, token URIs... Y cada línea es una oportunidad de bug que cuesta dinero real."

> "OpenZeppelin es una librería de contratos **auditados, usados en producción por Coinbase, Uniswap, Aave**. Heredamos de ellos en lugar de reescribir."

**Mostrar la tabla** de [clase-3-clase.html#parte-3—openzeppelin](clase-3-clase.html):

| Contrato | Qué da |
|---|---|
| `ERC721` | El estándar base |
| `ERC721URIStorage` | Permite URI distinta por tokenId |
| `Ownable` | Control de acceso simple — `onlyOwner` |

**Decir**:

> "Heredamos de los **dos primeros** para tener el NFT con metadata por token. Y de `Ownable` para que solo la wallet del 'rector' pueda emitir títulos."

> "En el TP final van a cambiar `Ownable` por `AccessControl` — porque queremos múltiples emisores (varios decanos), no uno solo. Pero para hoy, `Ownable` alcanza."

---

## Bloque 4 · Setup + tour del contrato · 25 min

### Parte 4 — Setup del repo · 5 min

**Demo en pantalla** — comandos de [clase-3-clase.html#parte-4—setup-del-repo-de-clase-3](clase-3-clase.html):

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase3.git
cd diplo-unq-blockchain-clase3
forge install foundry-rs/forge-std --shallow
forge install OpenZeppelin/openzeppelin-contracts --shallow
forge build
forge test
```

**Decir**:

> "El `--shallow` baja solo el último commit, no toda la historia git. Para una librería que solo consumimos, es mucho más rápido."

⚠️ **Pausa de 2 min** mientras todos clonan e instalan. Esto es donde se cae la red corporativa de la sede. Si alguien falla `forge install`, ofrecer el tarball de fallback.

**Esperar** que todos vean `14 passed; 0 failed`. Esto es el go/no-go del bloque siguiente.

### Parte 5 — Tour de `AcademicCredentials` · 20 min

**Abrir** `src/AcademicCredentials.sol` en VS Code y proyectarlo.

**Recorrer en orden** ([clase-3-clase.html#parte-5—tour-del-contrato-academiccredentials](clase-3-clase.html)):

#### 5.1 Imports · 3 min

> "Tres imports. `ERC721`, `ERC721URIStorage` y `Ownable` — los tres de OpenZeppelin. La sintaxis `@openzeppelin/...` viene del archivo `remappings.txt` que mapea ese alias a `lib/openzeppelin-contracts/...`."

**Pregunta**:

> "¿Por qué importan `ERC721URIStorage` y no `ERC721` solo?" (Respuesta: porque queremos **distinta URI por tokenId**, no una URI base. Cada título tiene su JSON propio.)

#### 5.2 Herencia múltiple · 3 min

```solidity
contract AcademicCredentials is ERC721URIStorage, Ownable {
```

**Decir**:

> "Solidity permite herencia múltiple. Acá heredamos `ERC721URIStorage` (que ya hereda de `ERC721`) y `Ownable`. Si después en el TP cambian `Ownable` por `AccessControl`, solo cambian esa palabra y se trae todo el sistema de roles."

#### 5.3 Constructor · 3 min

```solidity
constructor()
    ERC721("UNQ Academic Credential", "UNQ-CRED")
    Ownable(msg.sender)
{}
```

**Decir**:

> "Le pasamos argumentos a los constructores de los padres. `ERC721` quiere name y symbol — eso es lo que va a aparecer en MetaMask cuando importen el NFT. `Ownable(msg.sender)` deja como dueño a la wallet que deployó."

**Pregunta**:

> "Si yo deployo este contrato desde mi wallet — ¿quién es el `owner`?" (Yo, el que firmó el deploy.)

#### 5.4 issueCredential · 4 min

```solidity
function issueCredential(address student, uint256 tokenId, string memory metadataURI)
    public onlyOwner
{
    _mint(student, tokenId);
    _setTokenURI(tokenId, metadataURI);
    emit CredentialIssued(student, tokenId, metadataURI);
}
```

**Decir línea por línea**:

> "`onlyOwner` — modifier de `Ownable`. Si llamás esta función desde una wallet que no es el owner, **revierte**. Esa es la primera capa de seguridad."

> "`_mint(student, tokenId)` — guion bajo adelante = función interna heredada de `ERC721`. Crea el NFT y lo asigna a la address `student`."

> "`_setTokenURI(...)` — guarda la URI con la metadata. Eso lo trae `ERC721URIStorage`."

> "`emit CredentialIssued(...)` — un log on-chain que el frontend va a usar para enterarse que pasó algo. **Sin emit, el frontend no sabe que hubo un mint** — tendría que estar haciendo polling, que es ineficiente y caro."

**Pregunta**:

> "¿Por qué `_mint` y no `_safeMint`?" (Respuesta corta: para el TP, `_mint` evita un edge case del fuzzer. En producción usarían `_safeMint`. Es una decisión deliberada de este repo, no un bug.)

#### 5.5 revoke · 3 min

```solidity
function revoke(uint256 tokenId) public onlyOwner {
    _burn(tokenId);
    emit CredentialRevoked(tokenId);
}
```

**Decir**:

> "Si la universidad detecta fraude o emisión por error, **quema** el token. Después de esto, `ownerOf(tokenId)` revierte y `isValid` devuelve `false`."

**Pregunta importante** (filosófica):

> "¿Por qué la universidad puede revocar? ¿No se supone que blockchain es 'inmutable'?"

(Respuesta: blockchain hace que **cualquier mutación quede registrada y firmada** — eso es lo inmutable. Pero si el contrato dice "el owner puede burnear", el owner puede burnear. La inmutabilidad es del **registro de las acciones**, no de las acciones en sí. Esto va a ser tema de discusión en el TP final.)

#### 5.6 isValid · 2 min

```solidity
function isValid(uint256 tokenId) public view returns (bool) {
    return _ownerOf(tokenId) != address(0);
}
```

**Decir**:

> "Helper de verificación pública. Cualquiera, sin gas, sin login, puede llamar esto y saber si el título existe. Esa es la magia: **la universidad no media en la verificación**."

#### 5.7 Cierre del tour · 2 min

> "Ese es todo el contrato. ~50 líneas. La razón por la que es tan corto es porque OpenZeppelin nos dio el 95% del código gratis. Nosotros solo escribimos las funciones específicas del dominio: emitir, revocar, verificar."

> "En el TP final esto se va a triplicar — agregando `AccessControl`, struct `Credential` con metadata estructurada, soulbound (no transferible). Pero el esqueleto es éste."

---

## Pausa · 10 min

> "Vuelvan a las **XX:XX**" (calcular en vivo: hora actual + 10 min). "**No más**, sino no llegamos al deploy a Sepolia y se quedan sin la parte buena."

(Aprovechar para tomar agua, revisar Sepolia, refrescar Etherscan, mirar el balance de la wallet.)

---

## Bloque 5 · Tests + Coverage · 25 min

### Parte 6 — Tests con Foundry · 15 min

**Demo en pantalla**:

```bash
forge test
```

**Mostrar el output** y comentar:

> "14 tests pasan. Cubren: el camino feliz (issuer mintea, verify devuelve true), casos de error (no-issuer no puede mintear, tokenId duplicado falla), eventos (`vm.expectEmit`), y fuzz tests (256 casos random)."

**Demo con verbose** ([clase-3-clase.html#parte-6—tests-con-foundry](clase-3-clase.html)):

```bash
forge test --match-test test_IssuerCanIssue -vvvv
```

**Decir** mostrando el call trace:

> "Vean el árbol completo: el `setUp` deploya un contrato fresco, después `prank` cambia el msg.sender, después `issueCredential`, después emit del evento. Cada línea con su gas. Si quieren entender qué está haciendo un test, este es el comando."

**Demo de un fuzz test**:

```bash
forge test --match-test testFuzz -vv
```

> "Vean `runs: 256`. Foundry generó 256 valores random para los argumentos y los corrió todos. Si **uno solo** falla, te muestra el counterexample y podés reproducir el bug exacto."

**Pregunta**:

> "¿Cuál es la diferencia entre `vm.prank(alice)` y `vm.startPrank(alice) ... vm.stopPrank()`?" (`prank` solo aplica a la siguiente call. `startPrank/stopPrank` aplica a todas hasta el stop.)

### Parte 6.5 — Coverage · 10 min

**Demo**:

```bash
forge coverage --report summary
```

**Mostrar** la tabla con porcentajes por archivo.

**Decir**:

> "Coverage = qué porcentaje de líneas / branches / funciones del contrato están **ejecutadas por al menos un test**. No mide calidad de los tests — mide superficie cubierta."

> "**Para el TP final pedimos ≥ 80%**. No 100% — porque buscar el último 20% lleva a tests vacíos que no agregan valor. 80% es un piso razonable que asegura que las funciones críticas están cubiertas."

**Demo lcov**:

```bash
forge coverage --report lcov
ls lcov.info
```

> "Si suben el repo a GitHub, este `lcov.info` lo pueden subir a Codecov o Coveralls y les muestra heatmaps de qué líneas están cubiertas. No es obligatorio para el TP, pero queda lindo en el README."

**Pregunta**:

> "Si yo tengo una función `revoke()` y NO le escribo ningún test — ¿qué pasa con coverage?" (Baja. Específicamente: las líneas de `revoke` aparecen en rojo.)

> "Si después de agregar funciones nuevas el coverage baja, la solución es **agregar tests**, no quitar la función."

---

## Bloque 6 · Deploy a Sepolia + Verify · 30 min

> **El momento de la verdad**. Acá se cae todo si la red está congestionada. Tener Plan B (Anvil) listo. Antes de empezar, hacer `cast block-number` para confirmar que Sepolia responde.

### Parte 7 — Deploy del contrato · 12 min

**Decir** antes de tipear:

> "Ya importaron `dev-wallet` en clase 2 (o al principio de hoy). Si no, tienen 2 minutos para hacerlo ahora — `cast wallet import dev-wallet --interactive`. Si ya está, esperan."

**Demo** ([clase-3-clase.html#deploy](clase-3-clase.html)):

```bash
forge create src/AcademicCredentials.sol:AcademicCredentials \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet \
  --broadcast
```

**Esperar** los ~12 segundos. Mientras tanto, contar:

> "Esto está compilando localmente, generando el bytecode, construyendo la transacción de deploy, firmándola con la private key encriptada, mandándola al RPC público de Sepolia, esperando que un validador la incluya en un bloque."

**Cuando devuelve**:

```bash
export ADDR=0x...   # la address devuelta
```

⚠️ **Pausa de 3 min**: este es el paso que más se cae. Caminar por el aula. Si a alguien le falla:

- Faucet vacío → mandar a Google Cloud faucet.
- RPC timeout → cambiar a `https://rpc.sepolia.org`.
- Tx rechazada por nonce → `cast wallet address --account dev-wallet` y revisar saldo.

### Parte 7.5 — `forge verify-contract` · 8 min

**Decir**:

> "Por defecto Etherscan ve solo el bytecode — ilegible. Para que muestre el código Solidity y permita interactuar desde la web, hay que **verificar**. Esto es **obligatorio para el TP final**."

**Demo** ([clase-3-clase.html#verificar-el-código-fuente-en-etherscan](clase-3-clase.html)):

```bash
forge verify-contract \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  $ADDR \
  src/AcademicCredentials.sol:AcademicCredentials
```

> "Tarda 30-90 segundos. Detrás de escena: Foundry sube el código fuente a Etherscan, Etherscan lo recompila y compara el bytecode con el deployado. Si coincide → ✅ verificado."

**Mostrar en browser**: refrescar la página de Etherscan del contrato. La tab "Contract" ahora tiene el código fuente y dos sub-tabs: "Read Contract" y "Write Contract".

**Decir**:

> "Vean los tabs: **Read** muestra todas las funciones `view` con un botón para llamarlas sin gas. **Write** muestra las que modifican state, conecta MetaMask, y firma desde el browser. **Esto es lo que su frontend del TP va a hacer** — pero hecho a mano por Etherscan."

**Mencionar el truco**:

> "La misma API key de Etherscan sirve para Basescan, Polygonscan, Arbiscan — todos son del mismo grupo. Solo cambia `--chain`."

### Emitirse un título · 7 min

**Demo** ([clase-3-clase.html#emitirte-un-título-a-vos-mismo](clase-3-clase.html)):

```bash
export YOU=$(cast wallet address --account dev-wallet)
echo $YOU

cast send $ADDR \
  "issueCredential(address,uint256,string)" \
  $YOU 1 "ipfs://bafybeigdyrztktc.../titulo-prof.json" \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --account dev-wallet
```

**Decir**:

> "Le emito el `tokenId 1` a mí mismo. La URI es placeholder — para el TP la van a generar real con Pinata."

**Verificar** (volver a usar el diagrama de read vs write):

```bash
cast call $ADDR "ownerOf(uint256)" 1 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
cast call $ADDR "tokenURI(uint256)" 1 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
cast call $ADDR "isValid(uint256)" 1 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

**Decir**:

> "`ownerOf` devuelve mi address. `tokenURI` devuelve la URI. `isValid` devuelve `true`. **El título existe on-chain.**"

### Verlo en Etherscan · 3 min

**Browser**: refrescar Etherscan, tab "Logs".

**Mostrar** el evento `CredentialIssued` decodificado:

> "Vean: `student`, `tokenId`, `metadataURI`. Todos los campos del evento decodificados porque el contrato está verificado. Si no estuviera verificado, verían solo el hex crudo. **Por eso verificar es importante.**"

**Mostrar** también el tab "Contract → Read":

> "Apreten 'Read Contract' → `ownerOf` → ingresen `1` → click. Devuelve mi address. **Cualquiera en el mundo puede hacer esto.** Eso es la verificación pública."

⚠️ **Pausa**: "tomen captura de la página de Etherscan con su address y su título. Eso lo van a postear en el foro como tarea."

---

## Bloque 7 · Verlo como NFT en MetaMask · 10 min

> **El momento mágico**. Pausen. Dejen que lo vean. Es el primer "wow" de la diplomatura.

**Decir**:

> "Última cosa antes del cierre. Vamos a importar el NFT en MetaMask para que aparezca **como un NFT real**, igual que un Bored Ape o un CryptoKitty."

**Demo en browser** (MetaMask abierto, Sepolia activa):

1. Click en tab **"NFTs"**.
2. **"Import NFT"**.
3. Address: pegar `$ADDR`.
4. Token ID: `1`.
5. Click "Import".

**Esperar** unos segundos. MetaMask muestra:

- Nombre: `UNQ Academic Credential #1`.
- Symbol: `UNQ-CRED`.
- Si la metadata estuviera real en IPFS, mostraría también la imagen y el JSON.

**Decir**:

> "**Eso es un título universitario en su wallet.** No vive en un servidor de la UNQ. Si la UNQ se cae mañana, el título sigue existiendo. Cualquier RRHH del mundo, pegando `address + tokenId` en una página web pública, lo verifica en 3 segundos."

**Pausa para asimilar** (1 min). Dejarlos jugar — refrescar, mirar.

**Pregunta filosófica**:

> "¿Quién es el dueño de tu título universitario hoy, en el mundo real?" (La universidad guarda el registro maestro, vos tenés el papel — pero la fuente de verdad es la oficina de alumnos.)
>
> "¿Y con esto?" (El estudiante. Vos tenés el NFT en tu wallet. La universidad emitió, pero no controla el record — todos los nodos de Ethereum lo controlan.)

---

## Bloque 8 · TP final + cierre · 15 min

### Parte 9 — Y para el TP final · 8 min

**Cambiar de pestaña** a [tp-final.html](tp-final.html).

**Mostrar la rúbrica** (parte 5 — tabla de puntos).

**Decir**:

> "Lo que escribimos hoy es el **20% del TP final**. La parte 1 (smart contract, 35 puntos) extiende esto con:"

- `AccessControl` con dos roles → quitamos `Ownable`.
- **Soulbound** — los títulos NO se pueden transferir. Override `_update` para revertir transfers.
- **Struct `Credential`** completo con `degreeName`, `studentNameHash`, `documentHash`, `issueDate`, `active`.
- **4 eventos indexados** (no 2).
- **5 funciones obligatorias**: `grantIssuer`, `revokeIssuer`, `issueCredential` extendido, `revoke` con razón, `verify` que devuelve struct + bool.

**Mencionar también las otras partes**:

> "Parte 2 — testing 80% coverage. Parte 3 — Slither + análisis propio en `SECURITY.md`. Parte 4 — frontend con dos modos (issuer + verifier público) y deploy a **Base Sepolia** (no a Sepolia — costos más bajos)."

**Mencionar el starter**:

> "Para el frontend les dejamos un repo starter con wagmi + RainbowKit ya cableado. Forkean, cambian la address y el ABI, y arrancan. **No tienen que armar el frontend desde cero.**"

**Plazo y modalidad**:

> "Plazo: **lunes 08/06/2026 a las 18:00**. Pueden trabajar **individual o en pareja** (máx 2). Aprueban con 60/100."

### Parte 10 — Repaso diagramas y Q&A · 5 min

**Volver a `diagramas-arquitectura.html`**, scrollear rápido por los 5 diagramas:

> "Tres capas, ciclo del contrato, sistema real, read vs write, qué vive dónde. Estos cinco diagramas son la cheat sheet conceptual de toda la diplomatura. **Vuelvan a esta página cada vez que dudan dónde poner algo.**"

**Q&A abierto** (~3 min). Anticipar:

- "¿Pinata es obligatorio?" → No, es opcional/bonus. Para hoy, URI placeholder está bien.
- "¿Por qué Base Sepolia y no mainnet?" → Costos. Mainnet cuesta dólares reales por tx.
- "¿Puedo usar Polygon en vez de Base?" → Sí, EVM-compatible, mismo Solidity, solo cambia chain ID y RPC.
- "¿Y si pierdo la private key?" → Se pierde el contrato (ya no podés llamar `onlyOwner`). En el TP con `AccessControl` hay un admin que puede regenerar issuers.

### Tarea + cierre · 2 min

**Mostrar** [clase-3-tarea.html](clase-3-tarea.html).

**Decir**:

> "La tarea para entregar antes de clase 4 (lunes 11/05 a las 18:00):"

1. Deployar tu propio `AcademicCredentials` en Sepolia.
2. Emitirte un título.
3. Postear en el foro: address del contrato, tokenId, hash de la tx.
4. Bonus: subir un JSON real a Pinata como `tokenURI`.

> "El próximo jueves arrancamos clase 4 con frontend + seguridad. Van a conectar lo de hoy a una página web. Suerte."

(Cierre. No hace falta despedida elaborada — ellos ya están guardando MetaMask y Etherscan.)

---

## Tabla de tiempos (consolidada)

| Bloque | Min | Acumulado |
|---|---|---|
| Apertura | 5 | 5 |
| Diagramas | 20 | 25 |
| Cierre clase 2 + Anvil + cast + Sepolia | 30 | 55 |
| ERC-721 conceptual | 15 | 70 |
| Setup + tour contrato | 25 | 95 |
| Pausa | 10 | 105 |
| Tests + Coverage | 25 | 130 |
| Deploy Sepolia + Verify | 30 | 160 |
| NFT en MetaMask | 10 | 170 |
| TP final + cierre | 15 | 185 |
| **Buffer / preguntas** | **55** | **240** |

> El buffer de 55 min se reparte: ~15 min para preguntas distribuidas, ~20 min para alumnos trabados en setup, ~20 min de margen para la parte de Sepolia que es la más impredecible.

---

## Si algo se rompe — playbook

| Problema | Plan B en clase |
|---|---|
| Sepolia no responde | Demo en Anvil. Deploy en Sepolia se hace de tarea. Mostrar nuestro contrato del prof ya deployado en Etherscan para cerrar el loop visualmente. |
| Faucet sin ETH | Mandar al [Google Cloud faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia). Si falla, transferir 0.01 ETH desde la wallet del prof a la del alumno (`cast send <addr> --value 0.01ether --account dev-wallet --rpc-url ...`). |
| Etherscan verify falla | Skipear `--verify` y verificar standalone con `forge verify-contract` después de clase. Mostrar uno ya verificado del prof. |
| Un alumno sin MetaMask | Lo derivamos a la sección "Pre-requisitos" de [clase-3-clase.html](clase-3-clase.html) mientras seguimos. Que se ponga al día durante la pausa. |
| Internet de la sede caído | Demo todo en Anvil, screenshots de Sepolia desde mi máquina con tethering 4G. Plan C: cancelar la parte de Sepolia y empujarla a clase 4. |
| `forge install` falla por proxy corporativo | Tarball `vendored-deps.tar.gz` listo en USB / Drive. `tar xzf` adentro del repo. |
| `cast wallet import` no encuentra el comando | Versión vieja de Foundry. `foundryup` para actualizar. Si no hay tiempo, deployar con `--private-key` directo (peor, pero funciona en testnet). |
| Algún alumno olvidó el password de `dev-wallet` | Re-importar con otro nombre: `cast wallet import dev-wallet-2 --interactive`. |
| RPC público lento (>60s para deploy) | Cambiar a `https://rpc.sepolia.org` o `https://sepolia.gateway.tenderly.co`. |
| Coverage tira error raro | `forge clean && forge build && forge coverage`. Si sigue, pasar el ejercicio de coverage como demo del prof. |

---

## Después de clase

- [ ] Confirmar que la tarea de clase 3 quedó publicada (`clase-3-tarea.html` accesible).
- [ ] Postear en el foro: address del contrato del profe (referencia para los alumnos).
- [ ] Postear screenshot del contrato verificado en Etherscan como "así tiene que verse el suyo".
- [ ] Revisar respuestas en el foro durante la semana — al menos 2 pasadas (martes + viernes).
- [ ] Preparar clase 4: revisar `clase-4-clase.md` un par de días antes. Confirmar que el frontend starter compila.
- [ ] Si hubo más de 2 alumnos trabados en algo específico (ej. import de wallet), agregar nota a la apertura de clase 4 para repasarlo.
- [ ] Si Sepolia se cayó durante clase, postear instrucciones específicas en el foro para que terminen la parte de Sepolia en casa.
- [ ] Anotar en `~/.claude/projects/diplomatura-blockchain/memory/learnings.md` qué cosas funcionaron y qué no para la próxima edición.
