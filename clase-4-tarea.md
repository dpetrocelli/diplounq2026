# Clase 4 — Frontend NFT + Seguridad

> **Objetivo de hoy**: convertir el contrato `AcademicCredentials` que deployaron en clase 3 en una **DApp** — una aplicación web que cualquiera pueda usar desde el browser sin conocer Solidity ni `cast`. Y entender el bug más famoso de la historia de Ethereum (reentrancy) y cómo prevenirlo.

## 🏠 Tarea para esta semana {#tarea}

**Plazo**: a definir con la coordinación (antes de la entrega del TP final).

**Cómo se entrega**: postear en el foro del módulo en el campus.

**Qué tienen que hacer**:

1. **Completar el frontend**: agregar un botón "Revocar credencial" visible solo para el issuer.
2. **Listar todas las credenciales del usuario**, no solo el `tokenId 1`. Pista: leer eventos `CredentialIssued` filtrando por `student`.
3. **Correr Slither** sobre `AcademicCredentials.sol` (de clase 3) y postear el output en el foro.
4. **Empezar a leer** el spec del TP final cuando se publique.

---


---

## Volver

- [Material de la clase 4](clase-4-clase.html)
- [Volver al índice](index.html)

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
