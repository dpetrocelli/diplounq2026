# Clase 1 — Fundamentos de blockchain + tu primer contrato en Remix

## 🏠 Tarea para entregar antes de clase 2 {#tarea}

**Plazo**: lunes 27/04 18:00 (antes de que arranque clase 2).

**Cómo se entrega**: postear en el foro del módulo en el campus.

**Qué tienen que hacer**:

1. **Instalar Metamask** como extensión del navegador, crear una cuenta nueva y **anotar la frase semilla en papel** (no en formato digital, no compartirla con nadie). Activar la red de prueba **Sepolia** desde Settings → Advanced → "Show test networks".

2. **Pedir ETH de prueba a una faucet de Sepolia** (al menos 0.05 ETH). Si una faucet no anda, probá con otra:
   - [sepoliafaucet.com](https://sepoliafaucet.com) (Alchemy)
   - [cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
   - [sepolia-faucet.pk910.de](https://sepolia-faucet.pk910.de)

3. **Verificar la transacción en [sepolia.etherscan.io](https://sepolia.etherscan.io)**: pegá tu address y comprobá que ves el balance y la transacción de la faucet. Postear en el foro una captura del Etherscan mostrando tu address con balance > 0.

4. **Experimentar con Remix**: abrir [remix.ethereum.org](https://remix.ethereum.org), copiar el contrato `SimpleStorage` que vimos en [clase-1-clase.html#parte-11-remix-tu-primer-contrato](clase-1-clase.html), compilarlo, deployarlo **primero en la Remix VM** y después **en Sepolia con Metamask**. Probar las funciones (`set` / `get`). Postear en el foro la address del contrato deployado en Sepolia para poder verlo en Etherscan.

5. **(Opcional, recomendado)** Si te quedó tiempo, instalar [Foundry](https://book.getfoundry.sh/getting-started/installation) siguiendo la documentación oficial — vamos a usarlo desde clase 2.

---

## Volver

[← Volver al menú principal](index.html) · [→ Clase 2](clase-2-clase.html)

## Si algo falla

| Problema | Solución |
|---|---|
| Metamask no muestra Sepolia | Settings → Advanced → activar "Show test networks" |
| La faucet pide cuenta o no acepta mi address | Probá con otra faucet (la lista de arriba). Algunas tienen rate limit por IP. |
| No me llega el ETH | Esperá 5-10 minutos. Si no llega, probá otra faucet. |
| Etherscan dice "no transactions" | Verificá que estés en `sepolia.etherscan.io` (no en `etherscan.io`, que es mainnet). |
| Remix no se conecta a Metamask | Desbloqueá Metamask antes de elegir "Injected Provider - MetaMask" en Remix. |
| Deploy a Sepolia falla por gas | Pedile más ETH a la faucet (un deploy consume más que una transferencia). |
| Perdí la frase semilla | Si nunca te conectaste a mainnet, no es grave: creá una wallet nueva y empezá de cero. **Lección aprendida**: la próxima, anotala en papel. |

Lo demás, foro del campus.
