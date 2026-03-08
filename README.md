# HyperCore — Maximum Performance Edition

Maximum performance and low latency optimization for Xiaomi 14 Civi (chenfeng, SM8635 / Snapdragon 7+ Gen 3).
Designed for pure boot-time tuning — set once, run forever. No daemons, no background game monitors, no profile switching.

## Stealth & Root-Hiding
- **Native Magic Mount:** All vendor configurations are now placed inside the module's `system/` directory. By letting KernelSU / Magisk handle it natively, manual `mount --bind` traces in `/proc/mounts` are eliminated, remaining completely hidden from banking apps and Play Integrity without root access.

## Optimizations Packed

### 1. Qualcomm Feature Unlocks
Stock ROM disables several ML-based features. We explicitly enable them:
- **SilkyScrolls** — ML-based scroll smoothness (IPC/freq boost during scrolls)
- **sPLH** — Scroll Performance Load Hint
- **AdaptLaunch** — ML-based adaptive app launch boost
- **Lightning Game Launch** — Adaptive game launch boost
- **TopApp Render Thread Boost** — Priority boost for foreground app render thread
- **PreKill & PrefApps** — Proactive memory management and keeping preferred apps in memory longer
- **Gesture Fling Boost** — Smoother fling scrolls

### 2. CPU & Scheduler Tuning
- **Zero Latency Ramp-Up:** Instant governor scale-up and controlled ramp-down on schedutil/walt.
- **Kernel Scheduler:** Aggressive task placement with lower migration costs, minimized scheduling latency, and responsive wakeups.
- **WALT enhancements:** Faster thread colocation (reduced hysteresis to 20ms) keeping game render and logic threads together.
- **CPU Idle State Control:** Disabled deep C-states on big and prime cores to eliminate 100-500us wakeup latency, avoiding touch response lag.
- **CPUSET & Stune Boost:** `top-app` gets access to all cores with stune boosting, while background tasks are tightly restricted to little cores.

### 3. GPU (Adreno 735) Tuning
- **Maximum Performance:** Forced GPU clocks/bus on, disabled GPU nap, and disabled thermal throttling.
- **Zero Power-on Latency:** GPU rail forced on to eliminate power-on delays.
- **Adrenoboost Level 3:** Aggressive GPU scaling, with tighter devfreq polling intervals.

### 4. Memory & I/O
- **DRAM & L3 Cache Floors:** Set minimum bandwidth limits to keep DRAM responsive and prevent frame drops during sudden workloads.
- **Storage Latency:** Disabled UFS auto-hibernate to erase the 5-10ms wakeup penalty. Set read-ahead to 128KB, optimized for UFS 4.0.
- **VM Tweaks:** Tuned specifically for 8GB devices. Balanced swappiness, lowered VFS cache pressure, and disabled proactive compaction to save CPU cycles during gaming. ZRAM uses LZ4.
- **Optimized Dalvik/ART:** Adjusted heap limits and increased JIT cache space for hot methods.

### 5. Touch & Display
- **240Hz Native Touch:** Goodix controller game mode directly enabled with deep-idle sleeping disabled. Touch threshold scales modified for ultra-fast registration.
- **Rendering Pipeline:** Skiagl threaded rendering forced, triple buffering enabled, and SurfaceFlinger configured to latch unsignaled buffers for lower frame latency.
- **IRQ Affinity:** GPU and Display interrupts strictly pinned to the prime and dedicated big cores; Touch interrupts pinned to the remaining big cores for minimal latency.
- **Process Priority:** `SurfaceFlinger`, `Hardware Composer`, `AudioServer`, and `CameraServer` are all bumped to high-priority Real-Time (`SCHED_FIFO` / `RT`) scheduling levels.

### 6. Network (Low Latency Gaming)
- **BBR Congestion Control:** Enabled if supported.
- **TCP Fast Open:** Enabled in both directions.
- **Buffer & Connection Tuning:** Optimized UDP buffers (critical for games like BGMI), stripped TCP timestamps to reduce packet overhead, and lowered TCP keepalive intervals.

### 7. Miscellaneous Tweaks
- **Debloat:** Kills predefined Xiaomi telemetry processes (Analytics, Daemon, Joyose) entirely at boot.
- **Kernel Debugging Disabled:** Tracing, sched debug, and printk disabled to clear up CPU overhead.
- **Filesystem & Entropy:** `noatime` and `nodiratime` applied to `/data` and `/cache`, alongside faster entropy thresholds.

## Installation
1. Flash via Magisk or KernelSU.
2. Reboot your device.
3. Enjoy Maximum Performance.

## Compatibility
Targeted specifically for **Xiaomi 14 Civi (chenfeng)** running **SM8635 (Snapdragon 7+ Gen 3)**.
