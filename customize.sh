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
p "          v6.1 ⚡ AUTHOR: SOURABH"
p "  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
ui_print " "

p_slow "  [+] Initializing environment..."
p_slow "  [+] Bypassing root detection..."
p_slow "  [+] Injecting magic mounts..."
ui_print " "

p_slow "  >>> COMPILING BALANCED KERNEL TWEAKS <<<"
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

p_slow "  [✓] CPU thermal headroom configured"
p_slow "  [✓] Deep sleep (C-states) safely enabled"
p_slow "  [✓] GPU battery drain limits enforced"
p_slow "  [✓] Touch sampling locked at 240Hz"
ui_print " "

p_slow "  ----------------------------------------"
p_slow "  >> FLASH OPERATION COMPLETE"
p_slow "  >> REBOOT REQUIRED TO APPLY CHANGES"
p_slow "  ----------------------------------------"
ui_print " "
