#!/system/bin/sh
# ============================================================
# HyperCore v5.0 — Maximum Performance Edition
# Device: Xiaomi 14 Civi (chenfeng) — SM8635 (cliffs)
# SoC: Qualcomm Snapdragon 7+ Gen 3
# CPU: 3x A520 @2016MHz (little, policy0)
#      4x A720 @2803MHz (big, policy4)
#      1x X4   @3014MHz (prime, policy7)
# GPU: Adreno 735
# Touch: Goodix 240Hz
# Display: 120Hz AMOLED
# ============================================================
# NO daemon. NO game monitor. NO profile switching.
# Pure boot-time tuning — set once, run forever.
# ============================================================

MODDIR=${0%/*}

# Wait for boot
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    /system/bin/sleep 1
done
/system/bin/sleep 3

# Helper: write only if path exists
w() { [ -f "$1" ] && echo "$2" > "$1" 2>/dev/null; }

# ============================================================
# 1. QUALCOMM FEATURE UNLOCKS (resetprop)
#    Stock ROM disables these on cliffs — massive wins
# ============================================================

# SilkyScrolls — ML-based scroll smoothness (IPC/freq boost during scrolls)
resetprop ro.vendor.perf.ss true
resetprop ro.vendor.perf.ssv2 true

# Scroll Performance Load Hint
resetprop ro.vendor.perf.splh scroll

# AdaptLaunch — ML-based adaptive app launch boost
resetprop ro.vendor.perf.lal true

# Lightning Game Launch
resetprop ro.vendor.perf.lgl true

# TopApp Render Thread Boost — boost render thread of foreground app
resetprop vendor.perf.topAppRenderThreadBoost.enable true

# PreKill — proactive memory management
resetprop ro.vendor.perf.enable.prekill true

# PrefApps — preferred apps kept in memory longer
resetprop ro.vendor.perf.enable.prefapps true

# Gesture fling boost — smoother fling scrolls
resetprop vendor.perf.gestureflingboost.enable true

# Background app limit (stock: 60 for 8GB)
resetprop ro.vendor.qti.sys.fw.bg_apps_limit 96

# ============================================================
# 2. CPU GOVERNOR — ZERO LATENCY RAMP-UP
#    schedutil/walt: instant up, controlled down
# ============================================================

# Policy 0: Little cores (A520, cpu0-2) — fast response for UI thread
w /sys/devices/system/cpu/cpufreq/policy0/schedutil/rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us 4000
w /sys/devices/system/cpu/cpufreq/policy0/schedutil/pl 1

# Policy 4: Big cores (A720, cpu3-6) — gaming workhorses
w /sys/devices/system/cpu/cpufreq/policy4/schedutil/rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us 4000
w /sys/devices/system/cpu/cpufreq/policy4/schedutil/pl 1

# Policy 7: Prime core (X4, cpu7) — burst performance
w /sys/devices/system/cpu/cpufreq/policy7/schedutil/rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy7/schedutil/up_rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy7/schedutil/down_rate_limit_us 2000
w /sys/devices/system/cpu/cpufreq/policy7/schedutil/pl 1

# Set hispeed freq floors — prevents governor from idling too low
# Little: 1344MHz floor (stock ~614MHz) — keeps UI thread snappy
w /sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq 1344000
# Big: 1190MHz floor — ready for game thread bursts
w /sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_freq 1190400
# Prime: 1209MHz floor — instant burst capability
w /sys/devices/system/cpu/cpufreq/policy7/schedutil/hispeed_freq 1209600

# ============================================================
# 3. KERNEL SCHEDULER — AGGRESSIVE TASK PLACEMENT
#    Tuned for SM8635 big.LITTLE.prime topology
# ============================================================

# Migration cost: lower = faster migration between cores
# Stock 500000ns is too conservative — tasks stick on wrong core
w /proc/sys/kernel/sched_migration_cost_ns 100000

# Disable tunable scaling — we set absolute values
w /proc/sys/kernel/sched_tunable_scaling 0

# Scheduler latency: total time slice budget for all runnable tasks
# Lower = more responsive preemption, less throughput
w /proc/sys/kernel/sched_latency_ns 3000000

# Min granularity: minimum time slice per task
# Lower = faster context switches = more responsive touch
w /proc/sys/kernel/sched_min_granularity_ns 300000

# Wakeup granularity: how easily a waking task preempts current
# Lower = touch/input events preempt rendering faster
w /proc/sys/kernel/sched_wakeup_granularity_ns 500000

# Child runs first after fork — better for app launch
w /proc/sys/kernel/sched_child_runs_first 1

# Nr_migrate: max tasks migrated per balance — higher = faster rebalance
w /proc/sys/kernel/sched_nr_migrate 64

# ============================================================
# 4. WALT SCHEDULER — SM8635 SPECIFIC
#    Qualcomm's Window-Assisted Load Tracking
# ============================================================

# Colocation: group related threads on same cluster
# Lower threshold = more aggressive colocation (game threads stay together)
w /proc/sys/walt/sched_min_task_util_for_colocation 0
w /proc/sys/walt/sched_min_task_util_for_boost 0

# Colocation hysteresis: how fast threads get colocated
# Stock 80ms → 20ms — game render+logic threads colocate instantly
w /proc/sys/walt/sched_hyst_min_coloc_ns 20000000

# Downmigrate delay: when load drops, how fast tasks move to little cores
# Faster downmigrate = save thermal budget for next burst
w /proc/sys/walt/sched_coloc_downmigrate_ns 5000000

# Task util boost: bias task util estimation upward
# Makes scheduler pick higher frequencies sooner
w /proc/sys/walt/sched_task_util_boost 15

# Ravg window: WALT load tracking window (ms)
# Shorter window = more reactive to load changes
w /proc/sys/walt/sched_ravg_window_nr_ticks 3

# Frequency aggregation: use max of all tasks on a CPU for freq selection
# Prevents frequency drops when multiple light tasks share a core
w /proc/sys/walt/sched_freq_aggregate 1

# Upmigrate/downmigrate thresholds for big cores
# Lower upmigrate = tasks move to big cores sooner
w /proc/sys/walt/sched_upmigrate "60 85"
w /proc/sys/walt/sched_downmigrate "30 60"

# Group upmigrate/downmigrate — for task groups (cgroups)
w /proc/sys/walt/sched_group_upmigrate 85
w /proc/sys/walt/sched_group_downmigrate 55

# ============================================================
# 5. CPU IDLE STATE CONTROL
#    Disable deep sleep on performance cores for instant wakeup
# ============================================================

# Big cores (cpu3-6) + Prime (cpu7): disable deep C-states
# C3/C4/rail-pc add 100-500us wakeup latency — kills touch response
for cpu in 3 4 5 6 7; do
    for state in /sys/devices/system/cpu/cpu${cpu}/cpuidle/state*/disable; do
        state_dir=$(dirname "$state")
        state_name=$(cat "${state_dir}/name" 2>/dev/null)
        case "$state_name" in
            *C3*|*C4*|*rail*|*pc*|*Rail*|*Power*)
                echo 1 > "$state" 2>/dev/null
                ;;
        esac
    done
done

# Little cores (cpu0-2): allow C2 but disable deepest states
# Keeps little cores responsive for UI while saving some power
for cpu in 0 1 2; do
    for state in /sys/devices/system/cpu/cpu${cpu}/cpuidle/state*/disable; do
        state_dir=$(dirname "$state")
        state_name=$(cat "${state_dir}/name" 2>/dev/null)
        case "$state_name" in
            *rail*|*pc*|*Rail*|*Power*)
                echo 1 > "$state" 2>/dev/null
                ;;
        esac
    done
done

# ============================================================
# 6. CPUSET / STUNE — THREAD PLACEMENT
# ============================================================

# Top-app gets ALL cores — game threads can use any core
w /dev/cpuset/top-app/cpus 0-7

# Foreground: big + prime (no little core penalty for visible apps)
w /dev/cpuset/foreground/cpus 0-7

# Background: little cores only — don't steal from games
w /dev/cpuset/background/cpus 0-2
w /dev/cpuset/system-background/cpus 0-2
w /dev/cpuset/restricted/cpus 0-2

# Stune boost for top-app — bias frequency selection upward
if [ -f /dev/stune/top-app/schedtune.boost ]; then
    w /dev/stune/top-app/schedtune.boost 10
    w /dev/stune/top-app/schedtune.prefer_idle 1
fi
if [ -f /dev/stune/foreground/schedtune.boost ]; then
    w /dev/stune/foreground/schedtune.boost 5
    w /dev/stune/foreground/schedtune.prefer_idle 1
fi

# Uclamp: set minimum utilization for top-app tasks
# Forces scheduler to keep frequency above a floor for foreground
w /proc/sys/kernel/sched_util_clamp_min 20
w /proc/sys/kernel/sched_util_clamp_min_rt_default 50

# ============================================================
# 7. GPU TUNING — ADRENO 735 MAXIMUM PERFORMANCE
# ============================================================
GPU="/sys/class/kgsl/kgsl-3d0"
if [ -d "$GPU" ]; then
    # Force GPU clocks on — prevents clock gating latency
    w "$GPU/force_clk_on" 1
    # Force bus on — VRAM bandwidth always available
    w "$GPU/force_bus_on" 1
    # Disable bus split — unified memory bandwidth
    w "$GPU/bus_split" 0
    # Keep GPU rail powered — eliminates power-on latency (~2ms)
    w "$GPU/force_rail_on" 1
    # Disable nap — GPU stays awake between frames
    w "$GPU/force_no_nap" 1
    # Idle timer: how long GPU stays at current freq after going idle
    # Higher = less freq thrashing during frame gaps
    w "$GPU/idle_timer" 96
    # Disable throttling — let thermal management handle it
    w "$GPU/throttling" 0
    # Adreno boost level: 0=off, 1=low, 2=medium, 3=high
    w "$GPU/devfreq/adrenoboost" 3
    # GPU governor: msm-adreno-tz is Qualcomm's adaptive governor
    # Set min pwrlevel closer to max (0=max, higher=lower freq)
    w "$GPU/min_pwrlevel" 2
    w "$GPU/max_pwrlevel" 0
    # Default power level — start at high performance
    w "$GPU/default_pwrlevel" 1
    # Thermal throttle level — allow GPU to run hotter before throttling
    w "$GPU/thermal_pwrlevel" 0
    # Popp (power of performance predictor) — disable to prevent freq drops
    w "$GPU/popp" 0
fi

# GPU devfreq governor tuning
GPU_GOV="$GPU/devfreq"
if [ -d "$GPU_GOV" ]; then
    # Polling interval: how often governor checks GPU load (ms)
    # Lower = more responsive to load changes
    w "$GPU_GOV/polling_interval" 10
    # Up threshold: GPU load % to trigger frequency increase
    # Lower = more aggressive upscaling
    w "$GPU_GOV/upthreshold" 45
    # Down differential: hysteresis for downscaling
    w "$GPU_GOV/downdifferential" 10
fi

# ============================================================
# 8. DRAM + L3 CACHE — MEMORY BANDWIDTH FLOORS
#    Higher floors = less latency when CPU/GPU burst
# ============================================================

# LLCC-DDR bandwidth floor — keeps DRAM responsive
for bw in /sys/class/devfreq/*cpu-llcc-ddr-bw*; do
    w "$bw/min_freq" 762000
    # Polling interval for bandwidth governor
    w "$bw/polling_interval" 10
done

# L3 cache frequency floor — critical for cache-heavy game workloads
for l3 in /sys/class/devfreq/*cpu-l3-lat*; do
    w "$l3/min_freq" 768000
done

# CPU-LLCC bandwidth — higher floor for sustained throughput
for llcc in /sys/class/devfreq/*cpu-llcc-lat*; do
    w "$llcc/min_freq" 614400
done

# ============================================================
# 9. I/O SCHEDULER — LOW LATENCY STORAGE
# ============================================================
for block in /sys/block/sda /sys/block/sdb /sys/block/dm-*; do
    if [ -d "$block/queue" ]; then
        # Read-ahead: 128KB is optimal for UFS 4.0 sequential reads
        w "$block/queue/read_ahead_kb" 128
        # Disable I/O stats — saves CPU cycles per I/O op
        w "$block/queue/iostats" 0
        # Don't contribute to entropy pool — saves cycles
        w "$block/queue/add_random" 0
        # Queue depth: higher = more concurrent I/O
        w "$block/queue/nr_requests" 128
        # Disable I/O merging for lower latency (UFS handles this in HW)
        w "$block/queue/nomerges" 2
        # RQ affinity: complete I/O on the CPU that submitted it
        w "$block/queue/rq_affinity" 2
    fi
done

# UFS: disable auto hibernate — eliminates 5-10ms wakeup penalty
for ufs in /sys/class/scsi_host/host*/auto_hibern8; do
    echo 0 > "$ufs" 2>/dev/null
done

# ============================================================
# 10. MEMORY / VM — OPTIMIZED FOR 8GB + GAMING
# ============================================================

# Swappiness: moderate — keep game textures in RAM
w /proc/sys/vm/swappiness 60

# Dirty ratios: flush writes sooner to prevent I/O stalls
w /proc/sys/vm/dirty_ratio 10
w /proc/sys/vm/dirty_background_ratio 3
w /proc/sys/vm/dirty_expire_centisecs 1000
w /proc/sys/vm/dirty_writeback_centisecs 300

# VFS cache pressure: lower = keep dentries/inodes cached longer
# Game assets = lots of file opens, cached metadata = faster
w /proc/sys/vm/vfs_cache_pressure 60

# Disable proactive compaction — saves CPU during gaming
w /proc/sys/vm/compaction_proactiveness 0

# Disable watermark boost — prevents unnecessary reclaim
w /proc/sys/vm/watermark_boost_factor 0

# Page cluster: readahead for swap (2^3 = 8 pages)
w /proc/sys/vm/page-cluster 3

# Extra free kbytes: keep more memory free to avoid direct reclaim stalls
w /proc/sys/vm/extra_free_kbytes 32768

# Min free kbytes: higher = less chance of direct reclaim during gaming
w /proc/sys/vm/min_free_kbytes 16384

# Disable zone reclaim — let memory be used globally
w /proc/sys/vm/zone_reclaim_mode 0

# Overcommit: allow aggressive memory allocation (games allocate big)
w /proc/sys/vm/overcommit_memory 1

# ============================================================
# 11. TOUCH INPUT — MAXIMUM RESPONSIVENESS
#     Goodix controller on chenfeng: 240Hz native
# ============================================================

# Enable touch game mode — raw input, less filtering/smoothing
for gts in /sys/devices/platform/goodix_ts.0; do
    w "$gts/game_mode" 1
    # Disable touch idle — prevents controller entering low-power
    w "$gts/idle_enable" 0
    # Keep default 240Hz report rate (switch_report_rate=0)
    w "$gts/switch_report_rate" 0
done

# Touch boost via msm_performance
for tb in /sys/module/msm_performance/parameters/touchboost; do
    echo 1 > "$tb" 2>/dev/null
done

# Touch props — lower pressure threshold for faster registration
resetprop persist.sys.scrollingcache 3
resetprop touch.pressure.scale 0.001
resetprop persist.sys.touch.pressure true
resetprop ro.surface_flinger.set_touch_timer_ms 0

# Input device boost — tell perf HAL to boost on any input event
resetprop persist.vendor.qti.inputopts.enable true
resetprop persist.vendor.qti.inputopts.movetouchslop 0.6

# ============================================================
# 12. IRQ AFFINITY — PIN CRITICAL INTERRUPTS TO FAST CORES
# ============================================================
for irq_dir in /proc/irq/*/; do
    irq_name=""
    [ -f "${irq_dir}actions" ] && irq_name=$(cat "${irq_dir}actions" 2>/dev/null)
    case "$irq_name" in
        # GPU interrupts → prime core (cpu7)
        *kgsl*|*adreno*|*gpu*)
            echo 80 > "${irq_dir}smp_affinity" 2>/dev/null
            ;;
        # Display interrupts → big core 6 (next to prime)
        *sde*|*mdss*|*display*|*dsi*)
            echo 40 > "${irq_dir}smp_affinity" 2>/dev/null
            ;;
        # Touch interrupts → big cores (cpu3-6) for lowest latency
        # NOT prime — prime should be free for game render thread
        *touch*|*goodix*|*fts*|*synaptics*|*atmel*|*nvt*|*xiaomi*|*focaltech*|*gtp*|*input*)
            echo 78 > "${irq_dir}smp_affinity" 2>/dev/null
            ;;
        # UFS storage → little cores (don't interrupt game threads)
        *ufs*|*ufshcd*|*scsi*)
            echo 7 > "${irq_dir}smp_affinity" 2>/dev/null
            ;;
        # Network → little cores
        *wlan*|*wifi*|*rmnet*|*ipa*)
            echo 7 > "${irq_dir}smp_affinity" 2>/dev/null
            ;;
    esac
done

# ============================================================
# 13. PROCESS PRIORITY — CRITICAL SYSTEM SERVICES
#     SCHED_FIFO for display pipeline, RT for audio
# ============================================================

# SurfaceFlinger: highest RT priority — never preempted by normal tasks
SF_PID=$(pidof surfaceflinger 2>/dev/null)
[ -n "$SF_PID" ] && chrt -f -p 97 "$SF_PID" 2>/dev/null

# HWC (Hardware Composer): second highest
HWC_PID=$(pidof android.hardware.composer.default 2>/dev/null)
[ -z "$HWC_PID" ] && HWC_PID=$(pidof vendor.qti.hardware.display.composer-service 2>/dev/null)
[ -n "$HWC_PID" ] && chrt -f -p 96 "$HWC_PID" 2>/dev/null

# AudioServer: RT for glitch-free audio
AUDIO_PID=$(pidof audioserver 2>/dev/null)
[ -n "$AUDIO_PID" ] && chrt -f -p 90 "$AUDIO_PID" 2>/dev/null

# CameraServer: RT for viewfinder smoothness
CAM_PID=$(pidof cameraserver 2>/dev/null)
[ -n "$CAM_PID" ] && chrt -f -p 85 "$CAM_PID" 2>/dev/null

# InputDispatcher/Reader — boost the input pipeline
INPUT_PID=$(pidof android.hardware.input.processor-service 2>/dev/null)
[ -n "$INPUT_PID" ] && chrt -f -p 95 "$INPUT_PID" 2>/dev/null

# ============================================================
# 14. NETWORK — LOW LATENCY GAMING
# ============================================================

# BBR congestion control
if grep -q bbr /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null; then
    w /proc/sys/net/ipv4/tcp_congestion_control bbr
fi

# TCP fast open — both directions
w /proc/sys/net/ipv4/tcp_fastopen 3

# Disable slow start after idle — keeps connection warm
w /proc/sys/net/ipv4/tcp_slow_start_after_idle 0

# Smaller TCP buffers — less queuing delay for real-time packets
echo "4096 32768 131072" > /proc/sys/net/ipv4/tcp_rmem 2>/dev/null
echo "4096 32768 131072" > /proc/sys/net/ipv4/tcp_wmem 2>/dev/null

# Disable timestamps — saves 12 bytes/packet, reduces latency
w /proc/sys/net/ipv4/tcp_timestamps 0

# ECN for congestion signaling
w /proc/sys/net/ipv4/tcp_ecn 1

# Keepalive: detect dead connections faster
w /proc/sys/net/ipv4/tcp_keepalive_time 30
w /proc/sys/net/ipv4/tcp_keepalive_intvl 5
w /proc/sys/net/ipv4/tcp_keepalive_probes 3

# UDP buffers — BGMI uses UDP for game state
w /proc/sys/net/core/rmem_default 524288
w /proc/sys/net/core/rmem_max 1048576
w /proc/sys/net/core/wmem_default 524288
w /proc/sys/net/core/wmem_max 1048576

# Netdev budget — process more packets per softirq
w /proc/sys/net/core/netdev_budget 1200
w /proc/sys/net/core/netdev_budget_usecs 8000
w /proc/sys/net/core/netdev_max_backlog 256

# Disable reverse path filtering — faster packet routing
w /proc/sys/net/ipv4/conf/all/rp_filter 0
w /proc/sys/net/ipv4/conf/default/rp_filter 0

# Somaxconn — max pending connections
w /proc/sys/net/core/somaxconn 512

# ============================================================
# 15. RENDERING + DISPLAY PROPS
# ============================================================

# Force SkiaGL threaded rendering — parallel GPU command submission
resetprop persist.sys.ui.hw 1
resetprop debug.hwui.renderer skiagl
resetprop debug.renderengine.backend skiaglthreaded
resetprop debug.hwui.render_thread true

# Triple buffering — prevents frame drops during GPU-heavy scenes
resetprop debug.egl.buffcount 3

# GPU composition for all layers
resetprop debug.sf.hw 1

# Disable GLES error checking — saves 2-3% GPU overhead
resetprop debug.egl.hw 1

# Disable HWUI profiling — saves CPU overhead
resetprop debug.hwui.profile false

# SurfaceFlinger: latch unsignaled buffers — reduces frame latency
resetprop debug.sf.latch_unsignaled 1
resetprop debug.sf.auto_latch_unsignaled 1

# Phase offset for next vsync — tighter deadline
resetprop debug.sf.phase_offset_threshold_for_next_vsync_ns 6000000

# Disable SurfaceFlinger backpressure — prevents frame queuing
resetprop debug.sf.disable_backpressure 1

# Force 4x MSAA — smoother edges (Adreno 735 handles this easily)
resetprop debug.egl.force_msaa true

# ============================================================
# 16. DALVIK/ART VM — OPTIMIZED FOR 8GB
# ============================================================
resetprop dalvik.vm.heapsize 512m
resetprop dalvik.vm.heapgrowthlimit 256m
resetprop dalvik.vm.heapminfree 8m
resetprop dalvik.vm.heapmaxfree 32m
resetprop dalvik.vm.heaptargetutilization 0.75
resetprop dalvik.vm.dex2oat-threads 8
resetprop pm.dexopt.install speed-profile
resetprop pm.dexopt.bg-dexopt speed-profile

# JIT compiler: larger code cache for hot methods
resetprop dalvik.vm.jit.codecachesize 6

# ============================================================
# 17. ZRAM — LZ4 FOR SPEED
# ============================================================
for zram in /sys/block/zram*; do
    if [ -f "$zram/comp_algorithm" ]; then
        grep -q lz4 "$zram/comp_algorithm" 2>/dev/null && \
            echo lz4 > "$zram/comp_algorithm" 2>/dev/null
    fi
done

# ============================================================
# 18. DISABLE KERNEL DEBUG OVERHEAD
# ============================================================
w /proc/sys/kernel/printk "0 0 0 0"
w /proc/sys/kernel/panic_on_oops 0
w /proc/sys/kernel/panic 0
w /sys/kernel/tracing/tracing_on 0
w /sys/kernel/debug/tracing/tracing_on 0

# Disable sched debug
w /proc/sys/kernel/sched_debug 0

# Disable hung task detection — saves timer overhead
w /proc/sys/kernel/hung_task_timeout_secs 0

# Disable softlockup detector
w /proc/sys/kernel/softlockup_panic 0
w /proc/sys/kernel/soft_watchdog 0

# Perf event paranoid — disable perf monitoring overhead
w /proc/sys/kernel/perf_event_paranoid 3
w /proc/sys/kernel/perf_cpu_time_max_percent 0

# Timer migration: allow timers to migrate — reduces wakeups
w /proc/sys/kernel/timer_migration 1

# ============================================================
# 19. THERMAL — HIGHER HEADROOM BEFORE THROTTLING
# ============================================================

# Reduce thermal polling frequency — less CPU overhead
for tz in /sys/class/thermal/thermal_zone*/polling_delay_passive; do
    echo 2000 > "$tz" 2>/dev/null
done

# ============================================================
# 20. BORE SCHEDULER TUNING (if compiled in)
# ============================================================
if [ -f /proc/sys/kernel/sched_bore ]; then
    # Enable BORE
    w /proc/sys/kernel/sched_bore 1

    # Burst offset: how much burst credit a task gets
    # Higher = more burst allowance for interactive tasks (touch, render)
    w /proc/sys/kernel/sched_burst_cache_lifetime 30000000
    w /proc/sys/kernel/sched_burst_penalty_offset 22
    w /proc/sys/kernel/sched_burst_penalty_scale 1280
    w /proc/sys/kernel/sched_burst_smoothness_long 1
    w /proc/sys/kernel/sched_burst_smoothness_short 0
fi

# ============================================================
# 21. DISABLE XIAOMI TELEMETRY
# ============================================================
for proc in com.miui.analytics com.miui.daemon com.xiaomi.joyose; do
    PID=$(pidof "$proc" 2>/dev/null)
    [ -n "$PID" ] && kill -9 "$PID" 2>/dev/null
done

# ============================================================
# 22. POWER MANAGEMENT — KEEP PERFORMANCE CORES ALIVE
# ============================================================

# Disable core hotplug — all cores stay online
w /sys/devices/system/cpu/cpu3/online 1
w /sys/devices/system/cpu/cpu4/online 1
w /sys/devices/system/cpu/cpu5/online 1
w /sys/devices/system/cpu/cpu6/online 1
w /sys/devices/system/cpu/cpu7/online 1

# Disable LPM (Low Power Mode) for big+prime cluster
w /sys/module/lpm_levels/parameters/sleep_disabled 1

# ============================================================
# 23. FILESYSTEM — REDUCE OVERHEAD
# ============================================================

# Disable access time updates — saves I/O on every file read
for mp in /data /cache; do
    mount -o remount,noatime,nodiratime "$mp" 2>/dev/null
done

# ============================================================
# 24. ENTROPY — FASTER RANDOM NUMBER GENERATION
# ============================================================
w /proc/sys/kernel/random/read_wakeup_threshold 64
w /proc/sys/kernel/random/write_wakeup_threshold 128

# ============================================================
# DONE
# ============================================================
