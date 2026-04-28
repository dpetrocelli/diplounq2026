# Clase 4 — Frontend NFT + Seguridad

> **Objetivo de hoy**: convertir el contrato `AcademicCredentials` que deployaron en clase 3 en una **DApp** — una aplicación web que cualquiera pueda usar desde el browser sin conocer Solidity ni `cast`. Y entender el bug más famoso de la historia de Ethereum (reentrancy) y cómo prevenirlo.

## ¿Qué vamos a hacer?

### 🏫 En clase (en vivo con David + Ciro) {#en-clase}

1. **Construir un frontend** en Next.js que se conecte al contrato `AcademicCredentials`.
2. **Conectar MetaMask** desde una webapp con RainbowKit + wagmi.
3. **Leer datos del contrato** desde React (balance, tokenURI, isValid).
4. **Escribir transacciones** desde el browser (emitir un título).
5. **Estudiar el bug de reentrancy**: cómo funciona el ataque y dos formas de defenderse.
6. **Correr Slither** — análisis estático automático de vulnerabilidades.

### 🏠 Tarea

La tarea va en una página aparte: [ver tarea de clase 4](clase-4-tarea.html).

---

## Parte 1 — ¿Qué es una DApp?

**DApp** = Decentralized Application = aplicación descentralizada.

A diferencia de una webapp tradicional (frontend + backend + base de datos), una DApp tiene:

| Capa | Web tradicional | DApp |
|---|---|---|
| Frontend | React, Vue, Next.js | Igual (React, Next.js) |
| Backend | Node.js / Django / Rails | **Smart contract** en blockchain |
| Base de datos | PostgreSQL / MongoDB | **Estado del contrato** (on-chain) |
| Auth | Email + password / OAuth | **Wallet** (MetaMask) |

La pieza nueva que aprendemos hoy es la **conexión entre el frontend y el contrato**. Para eso usamos:

- **wagmi** — librería de React hooks para Ethereum (`useReadContract`, `useWriteContract`, `useAccount`).
- **viem** — la librería de bajo nivel que usa wagmi por debajo (encoding/decoding de calldata, ABIs, etc).
- **RainbowKit** — UI lista para "Connect Wallet" (botón + modal con todas las wallets soportadas).

---

## Parte 2 — Setup

### 2.1 Clonar el repo

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase4.git
cd diplo-unq-blockchain-clase4
```

El repo tiene **dos** subdirectorios:

```
diplo-unq-blockchain-clase4/
├── frontend/        # Next.js DApp
└── security-lab/    # Foundry — laboratorio de reentrancy
```

### 2.2 Instalar dependencias del frontend

```bash
cd frontend
npm install
```

Esto baja:
- `next` — framework de React.
- `react` y `react-dom`
- `wagmi` y `viem` — conexión blockchain.
- `@rainbow-me/rainbowkit` — UI de Connect Wallet.
- `@tanstack/react-query` — cache y refetching (lo usa wagmi internamente).

> Si esto falla con un error de Node, verificá que tengas Node.js 18+ con `node --version`. Si es más viejo, instalá [nvm](https://github.com/nvm-sh/nvm) y corré `nvm install 20`.

---

## Parte 3 — WalletConnect Project ID

WalletConnect es el protocolo que conecta una DApp con la wallet del usuario (especialmente con wallets móviles). Necesitás un **Project ID** gratis para identificar tu app.

### 3.1 Conseguir el Project ID

1. Ir a [https://cloud.walletconnect.com/](https://cloud.walletconnect.com/) (ahora se llama "Reown Cloud").
2. Crear cuenta (con Google o email).
3. Click en "Create Project".
4. Nombre: lo que quieras (ej: "UNQ Credentials").
5. Tipo: "AppKit" o "Browser App".
6. Copiar el **Project ID** (un string como `a1b2c3d4e5f6...`).

### 3.2 Pegarlo en `wagmi.ts`

Abrí `frontend/wagmi.ts`:

```ts
const projectId = 'YOUR_WALLETCONNECT_PROJECT_ID';
```

Reemplazá ese string por tu Project ID.

---

## Parte 4 — Pegar la dirección del contrato

En clase 3 deployaste tu contrato `AcademicCredentials` en Sepolia. Necesitás esa address para que el frontend sepa con qué contrato hablar.

Abrí `frontend/contracts/credentials.ts`:

```ts
export const CREDENTIALS_ADDRESS = '0x0000000000000000000000000000000000000000' as const;
```

Reemplazá ese cero-address por la address que te devolvió `forge create` en clase 3.

> Si no llegaste a deployar en clase 3, podés usar la del docente para seguir la práctica. Pero lo ideal es que cada uno deploye el suyo.

---

## Parte 5 — Tour del frontend

### 5.1 `app/providers.tsx` — los 3 providers

```tsx
<WagmiProvider config={config}>
  <QueryClientProvider client={queryClient}>
    <RainbowKitProvider>
      {children}
    </RainbowKitProvider>
  </QueryClientProvider>
</WagmiProvider>
```

Tres "providers" envuelven toda la app:

| Provider | Para qué |
|---|---|
| `WagmiProvider` | Configura las redes y la conexión a la blockchain |
| `QueryClientProvider` | Cache, refetching, loading states (de TanStack Query) |
| `RainbowKitProvider` | Provee el UI de "Connect Wallet" |

### 5.2 `wagmi.ts` — configuración de redes

```ts
export const config = getDefaultConfig({
  appName: 'MyToken DApp',
  projectId,
  chains: [sepolia],
  ssr: true,
});
```

Soporta solo Sepolia (chain ID `11155111`). Si quisieras agregar Base Sepolia, importás `baseSepolia` de `wagmi/chains` y lo agregás al array.

### 5.3 `app/components/MyCredential.tsx` — leer del contrato

```tsx
const { data: balance } = useReadContract({
  address: CREDENTIALS_ADDRESS,
  abi: CREDENTIALS_ABI,
  functionName: 'balanceOf',
  args: address ? [address] : undefined,
});
```

Eso es **lectura**: lee `balanceOf(address)` del contrato. Wagmi maneja el cache, refetching, loading states. Es como un `useState` pero conectado a la blockchain.

Otros ejemplos de `useReadContract` en el archivo: `tokenURI`, `isValid`. Pattern: address + abi + functionName + args.

### 5.4 `app/components/IssueCredential.tsx` — escribir al contrato

```tsx
const { writeContract, data: hash, isPending } = useWriteContract();
const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

function handleSubmit(e) {
  e.preventDefault();
  writeContract({
    address: CREDENTIALS_ADDRESS,
    abi: CREDENTIALS_ABI,
    functionName: 'issueCredential',
    args: [studentAddress, BigInt(tokenId), metadataURI],
  });
}
```

Estado de la transacción:

| Estado | Significado | Qué mostrar al usuario |
|---|---|---|
| `isPending = true` | El usuario tiene que confirmar en MetaMask | "Confirmá en la wallet…" |
| `isConfirming = true` | La transacción se mandó, esperando que se mine | "Esperando confirmación…" |
| `isSuccess = true` | Confirmada en un bloque | "✅ Listo, link a Etherscan" |
| `error` | Falló (revert, sin gas, usuario rechazó) | Mensaje de error |

### 5.5 `app/page.tsx` — UI condicional según rol

```tsx
const { data: contractOwner } = useReadContract({
  address: CREDENTIALS_ADDRESS,
  abi: CREDENTIALS_ABI,
  functionName: 'owner',
});

const isIssuer = address?.toLowerCase() === contractOwner?.toLowerCase();

return (
  <main>
    <ConnectButton />
    {isConnected && (
      <>
        <MyCredential />
        {isIssuer && <IssueCredential />}
      </>
    )}
  </main>
);
```

Si la wallet conectada es el `owner` del contrato → ve el panel de emisión. Si no, solo ve la lectura.

> ⚠️ Eso es solo un **filtro de UI**. La seguridad real está en el contrato (`onlyOwner`). Si alguien manda la transacción directamente sin pasar por el frontend, igual va a revertir on-chain.

---

## Parte 6 — Correr la DApp

```bash
npm run dev
```

Abrí [http://localhost:3000](http://localhost:3000):

1. Click en "Connect Wallet" → seleccioná MetaMask.
2. MetaMask te pide aprobar la conexión.
3. Asegurate de estar en **Sepolia**.
4. Vas a ver tu balance de credenciales (debería ser `1` si te emitiste un título en clase 3).
5. Si tu wallet es la del owner del contrato, vas a ver el formulario "Emitir credencial".

### Probá emitir un título a un compañero

1. Pedile a alguien su address de MetaMask.
2. En el formulario:
   - Address del estudiante: la del compañero.
   - Token ID: `2` (o cualquier número que no usaste antes).
   - Metadata URI: `ipfs://bafy.../titulo.json` (placeholder).
3. Click en "Emitir credencial".
4. Confirmá en MetaMask.
5. Esperá ~12 segundos.
6. Aparece el ✅ con link a Etherscan.

El compañero importa el NFT en su MetaMask (Tab NFTs → Import NFT → address + tokenId 2) y ve el título emitido.

---

## Parte 7 — Reentrancy: el bug más famoso de Ethereum

En **2016**, alguien drenó **$60 millones de dólares** del proyecto "The DAO" usando un bug llamado **reentrancy**. Fue tan grave que Ethereum tuvo que hacer un hard fork (que dio origen a Ethereum Classic). Vamos a entender cómo funciona y cómo prevenirlo.

### 7.1 Setup del laboratorio

```bash
cd ../security-lab
forge install foundry-rs/forge-std --shallow
forge install OpenZeppelin/openzeppelin-contracts --shallow
forge build
forge test -vvv
```

Tienen que ver `8 passed; 0 failed`.

### 7.2 El contrato vulnerable

Abrí `src/VulnerableVault.sol`. Es un "vault" simple donde la gente deposita ETH y lo retira:

```solidity
contract VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // BUG: manda el ETH ANTES de actualizar el balance
        (bool ok,) = msg.sender.call{value: balance}("");
        require(ok, "Transfer failed");

        balances[msg.sender] = 0;
    }
}
```

¿Cuál es el bug?

**El orden**: manda el ETH primero, actualiza el balance después.

Si `msg.sender` es un **contrato**, su función `receive()` se ejecuta durante el `.call`. Y desde ese `receive()` puede llamar `withdraw()` **otra vez**. Como `balances[msg.sender]` todavía no fue puesto en `0`, la segunda llamada también pasa el `require`. Y la tercera. Y la cuarta. Hasta vaciar el vault.

### 7.3 El atacante

En el mismo archivo, el contrato `Attacker`:

```solidity
contract Attacker {
    VulnerableVault public vault;
    uint256 public attackCount;

    constructor(address _vault) {
        vault = VulnerableVault(_vault);
    }

    function attack() external payable {
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        attackCount++;
        if (address(vault).balance >= 1 ether) {
            vault.withdraw();  // ← REENTRADA
        }
    }
}
```

Cuando el atacante recibe ETH (en `receive()`), llama `withdraw()` del vault otra vez. Y otra. Y otra. Drena todo.

### 7.4 Ver el ataque

```bash
forge test --match-test test_ReentrancyAttack -vvv
```

Output esperado:

```
=== BEFORE THE ATTACK ===
Vault balance: 10000000000000000000  (10 ETH de Alice + Bob)
=== AFTER THE ATTACK ===
Vault balance: 0
Stolen balance in attacker: ~10 ETH
Times receive() was called: 10+
ETH stolen by Eve: ~10 ETH
```

Eve invirtió **1 ETH**, drenó **10 ETH**, ganancia **9 ETH**.

---

## Parte 8 — Cómo defenderse

Hay dos patrones estándar.

### 8.1 Defensa #1: Checks-Effects-Interactions (CEI)

Abrí `src/SecureVault.sol`. La versión `SecureVaultCEI`:

```solidity
function withdraw() public {
    uint256 balance = balances[msg.sender];
    require(balance > 0, "No balance");          // 1. CHECK

    balances[msg.sender] = 0;                    // 2. EFFECT (¡antes!)

    (bool ok,) = msg.sender.call{value: balance}(""); // 3. INTERACTION
    require(ok, "Transfer failed");
}
```

**Misma cantidad de líneas**, solo cambia el orden:

1. **Checks**: validar (`require`).
2. **Effects**: actualizar estado del contrato.
3. **Interactions**: llamar a contratos externos.

Cuando el atacante reentra, su balance ya está en `0` → `require(balance > 0)` falla → revierte.

> 💡 **Regla mnemotécnica**: "actualizá tu estado **antes** de llamar a alguien afuera, porque ese alguien puede llamarte a vos otra vez".

### 8.2 Defensa #2: ReentrancyGuard

OpenZeppelin trae un modifier `nonReentrant`:

```solidity
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SecureVaultGuard is ReentrancyGuard {
    function withdraw() public nonReentrant {
        // ... cualquier orden interno
    }
}
```

Cómo funciona internamente: pone una variable de estado `_status = ENTERED` al entrar, revierte si ya está entrada, y la pone en `NOT_ENTERED` al salir. Es un mutex.

### 8.3 ¿Cuándo usar cuál?

| Patrón | Cuándo |
|---|---|
| **CEI** | Funciones simples con un solo external call |
| **ReentrancyGuard** | Funciones con múltiples external calls o lógica compleja |
| **Ambos** | Funciones críticas que mueven mucho dinero |

---

## Parte 9 — Slither: análisis estático

Slither es una herramienta que **lee tu código sin ejecutarlo** y te marca vulnerabilidades automáticamente.

### Instalación

```bash
pip install slither-analyzer
```

(Necesitás Python 3.8+)

### Correrlo

```bash
cd security-lab
slither .
```

Output esperado:

```
Reentrancy in VulnerableVault.withdraw() (src/VulnerableVault.sol#15-25):
    External calls:
    - (success, ) = msg.sender.call{value: balance}() (src/VulnerableVault.sol#19)
    State variables written after the call(s):
    - balances[msg.sender] = 0 (src/VulnerableVault.sol#22)
Severity: HIGH
```

Slither **detectó automáticamente** la vulnerabilidad. Cuando corrés Slither sobre `SecureVaultCEI` y `SecureVaultGuard`, no marca nada — porque el orden está bien.

### Otros detectores comunes

| Detector | Qué busca |
|---|---|
| `reentrancy-eth` | Reentrancy que drena ETH |
| `arbitrary-send-eth` | ETH enviado a address arbitraria |
| `unchecked-lowlevel` | `.call()` sin chequear el return value |
| `tx-origin` | Uso de `tx.origin` para auth (vulnerable a phishing) |
| `uninitialized-state` | Variables no inicializadas |

---

## Parte 10 — Trabajo final

A partir del jueves se publica en el campus el **spec del trabajo final**: extender `AcademicCredentials` a un sistema completo de certificación de títulos UNQ. Va a incluir:

1. **Smart contract** con `AccessControl` (roles ISSUER + ADMIN), soulbound (no transferible), estructura de datos completa.
2. **Tests** con coverage >= 80% + fuzz + un test que valide soulbound.
3. **`SECURITY.md`** con análisis de Slither + checklist completo.
4. **Frontend** con dos modos: panel admin (issuer) + verificador público.
5. **Deploy** en Sepolia + verificación en Etherscan.
6. **Demo en video** de 5–10 min.

**Plazo**: a definir con la coordinación de la diplomatura.

---


---

## Después de clase

La tarea de la semana → [tarea de clase 4](clase-4-tarea.html).

## Si algo falla

| Problema | Solución |
|---|---|
| `npm install` lento | Esperá. La primera vez tarda. |
| `npm install` falla | Verificá `node --version >= 18`, si no `nvm install 20` |
| El frontend no conecta | Verificá que MetaMask esté en Sepolia (chain ID `11155111`) |
| `WalletConnect Project ID is not valid` | Confirmá que copiaste el Project ID correcto en `wagmi.ts` |
| MetaMask no muestra el NFT | "Import NFT" manualmente con address + tokenId |
| Slither no compila el proyecto | Necesitás `solc` instalado: `pip install solc-select && solc-select install 0.8.28 && solc-select use 0.8.28` |

Lo demás, foro del campus.
