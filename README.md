# Proyecto 6 — Crowdfunding (Proyecto Final)

> **Módulo 5, Proyecto Final** · Dificultad: Avanzado · Tiempo: 120 min

## Descripción

Sistema de crowdfunding multi-contrato con patrón Factory. Incluye dos contratos: `Campaign.sol` (campaña individual con pledge, refund y claim) y `CrowdfundingFactory.sol` (fábrica que crea y registra campañas). Integra todos los conceptos del curso en un proyecto final completo.

## 🌍 Contexto del Mundo Real

El crowdfunding descentralizado resuelve problemas reales que las plataformas tradicionales no pueden — principalmente la confianza y las comisiones:

- **Kickstarter descentralizado**: Plataformas como Gitcoin Grants y Mirror.xyz permiten financiar proyectos de software de código abierto sin intermediario. El contrato guarantee que los fondos solo se liberan si se alcanza la meta — exactamente nuestro sistema de `reclamar()` / `reembolsar()`.
- **Microfinanzas comunitarias**: En economías emergentes, comunidades usan DAOs de ahorro (ROSCAs digitales) para juntar capital colectivamente y prestarlo a sus miembros. El patrón de contribuciones + condición de liberación es idéntico a nuestro Campaign.
- **Financiamiento de películas independientes**: Proyectos en blockchain permiten a fans financiar producciones y recibir tokens de participación. Si el proyecto no se financia, recuperan su inversión automáticamente — sin necesidad de confiar en el creador.
- **Uniswap v3 liquidity positions**: El patrón Factory (un contrato que despliega muchos contratos) es exactamente cómo Uniswap crea un nuevo pool de liquidez para cada par de tokens. Cada Pool es un contrato independiente creado por la UniswapV3Factory.

> 💡 **Takeaway**: El patrón Factory + condiciones de liberación de fondos es uno de los más usados en DeFi. CrowdfundingFactory demuestra exactamente cómo funciona en producción.

## Configuración

1. Consulta la [Guía de Remix IDE](../../docs/remix-guide.md) para configurar tu entorno.
2. Crea los archivos `Campaign.sol` y `CrowdfundingFactory.sol` en Remix IDE.
3. Copia el código de `contracts/Campaign.student.sol` y `contracts/CrowdfundingFactory.student.sol` en el editor.

## Pruebas en Remix VM

> ⚠️ Este proyecto requiere **múltiples cuentas** para simular un crowdfunding real.

### Flujo de Campaign (solo Campaign.sol)

1. Despliega `Campaign` con: `Cuenta1`, `"Mi Proyecto"`, `"Un proyecto innovador"`, `1000000000000000000` (1 ETH), `7` (7 días).
2. Desde **Cuenta 2**: `contribuir()` enviando `0.5 ETH`.
3. Desde **Cuenta 3**: `contribuir()` enviando `0.6 ETH`.
4. Llama a `obtenerEstado()` → debería mostrar `Exitosa` (0.5 + 0.6 = 1.1 ETH > 1 ETH meta).
5. Espera al deadline.
6. Desde **Cuenta 1** (creador): `reclamar()` para retirar los fondos.

### Flujo Completo (con Factory)

1. Despliega `CrowdfundingFactory`.
2. Llama a `crearCampana("Proyecto Alpha", "Descripcion del proyecto", 1000000000000000000, 7)`.
3. Llama a `obtenerCampanas()` para ver la dirección del nuevo contrato Campaign.
4. Interactúa con la Campaign desplegada usando "At Address" en Remix.
5. Prueba pledge, refund y claim desde diferentes cuentas.

## Despliegue en Sepolia

Sigue las instrucciones de la [Guía de Remix IDE](../../docs/remix-guide.md#-desplegar-en-sepolia-testnet-con-metamask) para desplegar y verificar en Etherscan.

## Checklist

- [ ] Ambos contratos compilan sin errores.
- [ ] `CrowdfundingFactory.crearCampana()` crea nuevas campañas correctamente.
- [ ] `contribuir()` acepta contribuciones y actualiza el total.
- [ ] `reembolsar()` devuelve la contribución si la campaña falla (no alcanzó la meta).
- [ ] `reclamar()` permite al creador retirar fondos de campañas exitosas.
- [ ] `obtenerEstado()` refleja el estado correcto en cada fase.
- [ ] No se puede hacer pledge después del deadline.
- [ ] No se puede hacer claim si la meta no se alcanzó.
- [ ] Los eventos se emiten correctamente.
- [ ] Desplegado en Sepolia y verificado en Etherscan.

## Guía Completa

Para la guía paso a paso con explicaciones detalladas, consulta el [documento de proyecto completo](../../project6_Crowdfunding.md).
