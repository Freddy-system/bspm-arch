#!/bin/bash

# Terminar instancias previas de polybar
killall -q polybar

# Esperar a que los procesos terminen
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

# Detectar monitores
if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main &
  done
else
  # Si xrandr no está disponible, lanzar en el monitor principal
  polybar --reload main &
fi

echo "Polybar iniciada correctamente"
