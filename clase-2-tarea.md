# Clase 2 — Foundry + tu primer smart contract

> **Objetivo de hoy**: pasar de "instalé Remix en clase 1 y deployé un contrato con la GUI" a "tengo el toolkit profesional instalado, escribo y testeo contratos desde la terminal, y entiendo el flujo de desarrollo que se usa en la industria".

## 🏠 Tarea para entregar antes de clase 3 {#tarea}

**Plazo**: lunes 04/05 a las 18:00 (antes de que arranque clase 3).

**Cómo se entrega**: postear en el foro del módulo en el campus.

**Qué tienen que hacer**:

1. **Verificar que `forge test` te devuelve `10 passed; 0 failed`** en tu máquina. Postear una captura del output como respuesta al hilo del módulo en el foro.
2. **Postear en el foro cualquier problema de instalación** que no hayan podido resolver. Mejor que lo mandes hoy mismo así llegamos a clase 3 con todos preparados.
3. **(Opcional, recomendado)** Leer `src/SimpleStorage.sol` y `test/SimpleStorage.t.sol` con calma. Probá modificar algo del contrato (por ejemplo, agregar una función `decrement()`) y ver si los tests siguen pasando.

---


---

## Volver

- [Material de la clase 2](clase-2-clase.html)
- [Volver al índice](index.html)

## Si algo falla

| Problema | Solución |
|---|---|
| `foundryup` falla en Windows | Instalar [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) y correr todo desde adentro |
| `forge install` falla por proxy o red | Probar con VPN o desde otra red. Si seguís sin poder, postealo en el foro |
| `forge build` da error de versión de Solidity | Confirmá que `foundry.toml` tiene `solc = "0.8.28"` (no 0.8.19) |
| `code` no es comando reconocido | Abrí VS Code → `Ctrl+Shift+P` → "Shell Command: Install 'code' command in PATH" |
| Algún test falla | Postealo en el foro con el output completo de `forge test -vvv` |

Lo demás, foro del campus.
