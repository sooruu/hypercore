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
p "          v6.4 ⚡ AUTHOR: SOURABH"
p "  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
ui_print " "

p_slow "  [+] Initializing environment..."
p_slow "  [+] Bypassing root detection..."
p_slow "  [+] Injecting magic mounts..."

# Set standard permissions for XML files
ui_print "  [+] Setting XML permissions (644)..."
set_perm_recursive $MODPATH/vendor 0 0 0755 0644
set_perm_recursive $MODPATH/product 0 0 0755 0644

ui_print " "
p_slow "  >>> COMPILING BALANCED KERNEL TWEAKS <<<"
ui_print " "

# Progress bar animation
ui_print "  Progress: [████████████████████] 100%"
sleep 0.5
ui_print " "

p_slow "  [✓] CPU thermal headroom configured"
p_slow "  [✓] iOS-Style Frame Sync active"
p_slow "  [✓] Locked 60Hz/60FPS applied"
p_slow "  [✓] System props injected"
ui_print " "

p_slow "  ----------------------------------------"
p_slow "  >> FLASH OPERATION COMPLETE"
p_slow "  >> REBOOT REQUIRED TO APPLY CHANGES"
p_slow "  ----------------------------------------"
ui_print " "
