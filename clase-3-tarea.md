# Clase 3 — Cierre clase 2 + Credenciales académicas (ERC-721)

> **Objetivo de hoy**: pasar de "tengo un contrato testeado en mi máquina" a "tengo un contrato deployado en una blockchain real, lo veo en un explorador, y emito un primer título universitario verificable on-chain". Esto es la base del trabajo final de la diplomatura.

## 🏠 Tarea para entregar antes de clase 4 {#tarea}

**Plazo**: lunes 11/05 a las 18:00 (antes de que arranque la clase siguiente).

**Cómo se entrega**: postear en el foro del módulo en el campus.

**Qué tienen que hacer**:

1. **Deployar tu propio `AcademicCredentials`** en Sepolia (vos sos el issuer).
2. **Emitirte un título a vos mismo** con un `tokenURI` placeholder.
3. **Postear en el foro** del campus:
   - La address de tu contrato.
   - El `tokenId` del título emitido.
   - El hash de la transacción de emisión.
4. **(Opcional, suma puntos)** Subir un JSON real a [Pinata](https://www.pinata.cloud/) (cuenta gratis), copiar el CID, y usarlo como `tokenURI`. La metadata queda como:

```json
{
  "name": "Licenciatura en Sistemas de Información",
  "description": "Título emitido por la Universidad Nacional de Quilmes",
  "issueDate": "2026-04-27",
  "studentName": "Tu Nombre",
  "image": "ipfs://bafy.../tu-foto.png"
}
```

---


---

## Volver

- [Material de la clase 3](clase-3-clase.html)
- [Volver al índice](index.html)

## Si algo falla

| Problema | Solución |
|---|---|
| `forge install` lento o falla | Probá con VPN o desde otra red |
| Faucet de Sepolia no manda tokens | Probar [Google Cloud Web3 Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia) |
| RPC público lento | Cambiar a `https://rpc.sepolia.org` o `https://sepolia.gateway.tenderly.co` |
| `forge create` tarda > 30 seg | Normal por congestión. Si pasan 60s, revisar con `cast tx <hash>` |
| MetaMask no muestra mi NFT | Verificá que estés en Sepolia y que la address del contrato esté bien |

Lo demás lo resolvemos en el foro del campus.
