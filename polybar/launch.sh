#!/bin/bash

# Terminar instancias de polybar que estén ejecutándose
killall -q polybar

# Esperar hasta que los procesos se hayan cerrado
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar Polybar
polybar main 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar lanzada..."
