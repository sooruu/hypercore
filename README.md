# HyperCore v6.0 — Balanced Edition

Smart and balanced performance/low-latency optimization for Xiaomi 14 Civi (chenfeng, SM8635 / Snapdragon 7+ Gen 3).

## Philosophy (The v6.0 Fix)
Earlier versions pushed maximum frequencies always-on, which resulted in excellent gaming scores but severe battery drain and significant heating issues for casual users.
**This v6.0 release is the "Balanced Edition"** — it explicitly prioritizes ultra-fast touch response and UI fluidity while restoring the CPU/GPU thermal management systems. The device is allowed to enter deep sleep during idle, cutting down the heat without ever sacrificing interface snappy-ness.

## Core Adjustments
- **Touch & Display First:** Goodix Game Mode is still completely forced, 240Hz input polling is maintained, and touch-handling interrupts are prioritized above all other tasks.
- **Cooler CPU:** Deep sleep states are fully allowed. Governor scale-down thresholds have been accelerated so that when a burst completes, the processor cools down instantly.
- **Dynamic GPU:** Removed Adreno clock enforcement. Let the GPU sleep between frames. Maintains UI fluidity but prevents gaming sessions from melting the battery.
- **Stealth Module:** All vendor alterations are handled purely by Magisk/KernelSU's native magic mount functionality, evading Play Integrity and banking app detection. 

## Optimizations Packed
1. **Qualcomm Feature Unlocks:** SilkyScrolls, ML-based App Launch (AdaptLaunch/Lightning), PreKill, and PrefApps.
2. **Scheduler & Render Boost:** `top-app` gets unrestricted cluster access, `stune.boost` applied modestly to maintain smooth animations, and `SurfaceFlinger` runs at top RT priority. 
3. **IRQ Affinity:** Display rendering and Touch polling interrupts are pinned individually to specific big performance cores to prevent CPU thread congestion. 
4. **Network Buffers:** Optimized TCP/UDP configurations (critical for lowering ping in games like BGMI) are fully enabled without hurting standby battery.
5. **Debloat:** Built-in Xiaomi telemetry services (Analytics, Daemon, Joyose) get killed passively right after the system successfully boots up.

## Installation
1. Flash via Magisk or KernelSU.
2. Reboot your device.
3. Enjoy a fast, smooth, and much cooler experience!
