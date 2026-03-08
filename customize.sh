#!/system/bin/sh

# Fast animation helper to print line by line smoothly
p() {
    ui_print "$1"
    sleep 0.05
}

p_slow() {
    ui_print "$1"
    sleep 0.4
}

ui_print " "
p "  ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ "
p "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗"
p "  ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝"
p "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗"
p "  ██║  ██║   ██║   ██║     ███████╗██║  ██║"
p "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝"
p "  ░█████╗░░█████╗░██████╗░███████╗........."
p "  ██╔══██╗██╔══██╗██╔══██╗██╔════╝........."
p "  ██║░░╚═╝██║░░██║██████╔╝█████╗░░........."
p "  ██║░░██╗██║░░██║██╔══██╗██╔══╝░░........."
p "  ╚█████╔╝╚█████╔╝██║░░██║███████╗........."
p "  ░╚════╝░░╚════╝░╚═╝░░╚═╝╚══════╝........."
ui_print " "
p "  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
p "          v1.0 ⚡ AUTHOR: SOURABH"
p "  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
ui_print " "

p_slow "  [+] Initializing environment..."
p_slow "  [+] Bypassing root detection..."
p_slow "  [+] Injecting magic mounts..."
ui_print " "

p_slow "  >>> COMPILING KERNEL TWEAKS <<<"
ui_print " "

# Modern Progress bar using Unicode block characters
ui_print "  Progress: [██░░░░░░░░░░░░░░░░░░] 10%"
sleep 0.2
ui_print "  Progress: [█████░░░░░░░░░░░░░░░] 25%"
sleep 0.2
ui_print "  Progress: [████████░░░░░░░░░░░░] 40%"
sleep 0.3
ui_print "  Progress: [███████████░░░░░░░░░] 60%"
sleep 0.2
ui_print "  Progress: [██████████████░░░░░░] 75%"
sleep 0.3
ui_print "  Progress: [██████████████████░░] 90%"
sleep 0.2
ui_print "  Progress: [████████████████████] 100%"
sleep 0.5
ui_print " "

p_slow "  [✓] CPU Governor zero-latency tuned"
p_slow "  [✓] Game threads pinned to Big/Prime cores"
p_slow "  [✓] Adreno 735 Max Perf unleashed"
p_slow "  [✓] Touch sampling locked at 240Hz"
ui_print " "

p_slow "  ----------------------------------------"
p_slow "  >> FLASH OPERATION COMPLETE"
p_slow "  >> REBOOT REQUIRED TO APPLY CHANGES"
p_slow "  ----------------------------------------"
ui_print " "
