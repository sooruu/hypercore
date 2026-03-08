#!/system/bin/sh
# ============================================================
# HyperCore v6.0 — Balanced Edition (Cooler + Smooth)
# Device: Xiaomi 14 Civi (chenfeng) — SM8635 (cliffs)
# ============================================================
# Maximum touch response and smoothness, but with proper 
# thermal management and deep sleep enabled for battery life.
# We no longer force maximum CPU/GPU floors. Say goodbye to overheating.
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
resetprop ro.vendor.perf.ss true
resetprop ro.vendor.perf.ssv2 true
resetprop ro.vendor.perf.splh scroll
resetprop ro.vendor.perf.lal true
resetprop ro.vendor.perf.lgl true
resetprop vendor.perf.topAppRenderThreadBoost.enable true
resetprop ro.vendor.perf.enable.prekill true
resetprop ro.vendor.perf.enable.prefapps true
resetprop vendor.perf.gestureflingboost.enable true
resetprop ro.vendor.qti.sys.fw.bg_apps_limit 96

# ============================================================
# 2. CPU GOVERNOR — RESPONSIVE BUT COOL
#    Instant up limits, but allow fast downscaling for cooling
# ============================================================
w /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us 1000
w /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us 1000
w /sys/devices/system/cpu/cpufreq/policy7/schedutil/up_rate_limit_us 0
w /sys/devices/system/cpu/cpufreq/policy7/schedutil/down_rate_limit_us 500

# ============================================================
# 3. KERNEL SCHEDULER — SMOOTH UI
# ============================================================
w /proc/sys/kernel/sched_migration_cost_ns 100000
w /proc/sys/kernel/sched_tunable_scaling 0
w /proc/sys/kernel/sched_child_runs_first 1
w /proc/sys/kernel/sched_nr_migrate 64
w /proc/sys/walt/sched_hyst_min_coloc_ns 20000000
w /proc/sys/walt/sched_upmigrate "70 90"
w /proc/sys/walt/sched_downmigrate "40 70"

# Note: Deep C-states (Sleep) are INTENTIONALLY LEFT ENABLED 
# to save battery and prevent overheating. We no longer lock cores awake.

# ============================================================
# 4. CPUSET / STUNE
# ============================================================
w /dev/cpuset/top-app/cpus 0-7
w /dev/cpuset/foreground/cpus 0-7
w /dev/cpuset/background/cpus 0-2
w /dev/cpuset/system-background/cpus 0-2
w /dev/cpuset/restricted/cpus 0-2

if [ -f /dev/stune/top-app/schedtune.boost ]; then
    w /dev/stune/top-app/schedtune.boost 1
    w /dev/stune/top-app/schedtune.prefer_idle 1
fi
if [ -f /dev/stune/foreground/schedtune.boost ]; then
    w /dev/stune/foreground/schedtune.boost 1
    w /dev/stune/foreground/schedtune.prefer_idle 1
fi
w /proc/sys/kernel/sched_util_clamp_min 10

# ============================================================
# 5. GPU TUNING — BALANCED
# ============================================================
GPU="/sys/class/kgsl/kgsl-3d0"
if [ -d "$GPU" ]; then
    w "$GPU/force_clk_on" 0
    w "$GPU/force_bus_on" 0
    w "$GPU/force_rail_on" 0
    w "$GPU/force_no_nap" 0
    w "$GPU/throttling" 1
    w "$GPU/devfreq/adrenoboost" 1
    w "$GPU/default_pwrlevel" 3
fi
GPU_GOV="$GPU/devfreq"
if [ -d "$GPU_GOV" ]; then
    w "$GPU_GOV/polling_interval" 20
    w "$GPU_GOV/upthreshold" 65
fi

# ============================================================
# 6. I/O SCHEDULER
# ============================================================
for block in /sys/block/sda /sys/block/sdb /sys/block/dm-*; do
    if [ -d "$block/queue" ]; then
        w "$block/queue/read_ahead_kb" 128
        w "$block/queue/iostats" 0
        w "$block/queue/add_random" 0
        w "$block/queue/nomerges" 2
        w "$block/queue/rq_affinity" 2
    fi
done

# ============================================================
# 7. MEMORY / VM
# ============================================================
w /proc/sys/vm/swappiness 60
w /proc/sys/vm/vfs_cache_pressure 80
w /proc/sys/vm/compaction_proactiveness 0
w /proc/sys/vm/extra_free_kbytes 32768

# ============================================================
# 8. TOUCH INPUT — MAXIMUM RESPONSIVENESS
# ============================================================
for gts in /sys/devices/platform/goodix_ts.0; do
    w "$gts/game_mode" 1
    w "$gts/idle_enable" 0
done

for tb in /sys/module/msm_performance/parameters/touchboost; do
    echo 1 > "$tb" 2>/dev/null
done

resetprop persist.sys.scrollingcache 3
resetprop touch.pressure.scale 0.001
resetprop persist.sys.touch.pressure true
resetprop ro.surface_flinger.set_touch_timer_ms 0
resetprop persist.vendor.qti.inputopts.enable true
resetprop persist.vendor.qti.inputopts.movetouchslop 0.6

# ============================================================
# 9. IRQ AFFINITY
# ============================================================
for irq_dir in /proc/irq/*/; do
    irq_name=""
    [ -f "${irq_dir}actions" ] && irq_name=$(cat "${irq_dir}actions" 2>/dev/null)
    case "$irq_name" in
        *kgsl*|*adreno*|*gpu*) echo 80 > "${irq_dir}smp_affinity" 2>/dev/null ;;
        *sde*|*mdss*|*display*|*dsi*) echo 40 > "${irq_dir}smp_affinity" 2>/dev/null ;;
        *touch*|*goodix*|*fts*|*synaptics*|*input*) echo 78 > "${irq_dir}smp_affinity" 2>/dev/null ;;
    esac
done

# ============================================================
# 10. PROCESS PRIORITY
# ============================================================
SF_PID=$(pidof surfaceflinger 2>/dev/null)
[ -n "$SF_PID" ] && chrt -f -p 97 "$SF_PID" 2>/dev/null
HWC_PID=$(pidof android.hardware.composer.default 2>/dev/null)
[ -z "$HWC_PID" ] && HWC_PID=$(pidof vendor.qti.hardware.display.composer-service 2>/dev/null)
[ -n "$HWC_PID" ] && chrt -f -p 96 "$HWC_PID" 2>/dev/null
AUDIO_PID=$(pidof audioserver 2>/dev/null)
[ -n "$AUDIO_PID" ] && chrt -f -p 90 "$AUDIO_PID" 2>/dev/null
INPUT_PID=$(pidof android.hardware.input.processor-service 2>/dev/null)
[ -n "$INPUT_PID" ] && chrt -f -p 95 "$INPUT_PID" 2>/dev/null

# ============================================================
# 11. NETWORK & DISPLAY PROPS
# ============================================================
w /proc/sys/net/ipv4/tcp_fastopen 3
resetprop debug.hwui.renderer skiagl
resetprop debug.renderengine.backend skiaglthreaded
resetprop debug.hwui.render_thread true
resetprop debug.sf.hw 1
resetprop debug.sf.latch_unsignaled 1

# ============================================================
# 12. DISABLE XIAOMI TELEMETRY
# ============================================================
for proc in com.miui.analytics com.miui.daemon com.xiaomi.joyose; do
    PID=$(pidof "$proc" 2>/dev/null)
    [ -n "$PID" ] && kill -9 "$PID" 2>/dev/null
done

# ============================================================
# 13. ENTROPY
# ============================================================
w /proc/sys/kernel/random/read_wakeup_threshold 64
w /proc/sys/kernel/random/write_wakeup_threshold 128

# ============================================================
# 14. THERMAL THROTTLING HEADROOM
# ============================================================
# Reduce thermal polling frequency so the CPU doesn't aggressively
# micro-throttle over brief temperature spikes (e.g., loading a level).
# Provides sustained burst potential while keeping the device safe.
for tz in /sys/class/thermal/thermal_zone*/polling_delay_passive; do
    w "$tz" 2000
done

# DONE
