# Clase 2 — Setup

## Repo del ejercicio

```bash
git clone https://github.com/dpetrocelli/diplo-unq-blockchain-clase2.git
cd diplo-unq-blockchain-clase2
```

## Instalar Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Reabrir terminal o:

```bash
source ~/.bashrc      # bash
source ~/.zshenv      # zsh
foundryup
```

Verificar:

```bash
forge --version
cast --version
anvil --version
```

## Instalar la extensión Solidity en VS Code

```bash
code --install-extension juanblanco.solidity
```

## Correr el proyecto

```bash
forge install foundry-rs/forge-std --shallow
forge build
forge test
```

Tienen que ver `10 passed; 0 failed`.
