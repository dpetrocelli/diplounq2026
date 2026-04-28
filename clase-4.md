# Clase 4 — Frontend NFT + Seguridad

## Repo del ejercicio

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase4.git
cd diplo-unq-blockchain-clase4
```

## Setup del frontend

```bash
cd frontend
npm install
```

### 1. WalletConnect Project ID

1. Crear cuenta gratis en <https://cloud.walletconnect.com/>
2. Crear proyecto
3. Copiar el Project ID
4. Pegarlo en `frontend/wagmi.ts` reemplazando `YOUR_WALLETCONNECT_PROJECT_ID`

### 2. Address del contrato

Editar `frontend/contracts/credentials.ts` y poner el address del `AcademicCredentials` que deployaron en clase 3.

### 3. Correr

```bash
npm run dev
```

Abrir <http://localhost:3000>. Conectar MetaMask en **Sepolia**.

## Setup del security-lab

```bash
cd security-lab
forge install foundry-rs/forge-std --shallow
forge install OpenZeppelin/openzeppelin-contracts --shallow
forge build
forge test -vvv
```

Tienen que ver `8 passed; 0 failed`.

## Slither (opcional)

```bash
pip install slither-analyzer
cd security-lab
slither .
```
