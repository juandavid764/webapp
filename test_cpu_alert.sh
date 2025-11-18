#!/bin/bash

# Script para generar carga de CPU y probar alertas de Prometheus
# ADVERTENCIA: Este script consumirá CPU. Presiona Ctrl+C para detenerlo.

echo "================================================================"
echo "Script de Prueba de Alerta de CPU para Prometheus"
echo "================================================================"
echo ""
echo "Este script generará carga en la CPU para que puedas ver"
echo "la alerta HighCPUUsage activarse en Prometheus."
echo ""
echo "Para ver las alertas:"
echo "  1. Abre http://localhost:9090/alerts en tu navegador"
echo "  2. Ejecuta este script"
echo "  3. Espera ~2 minutos para que la alerta se active"
echo ""
echo "Presiona Ctrl+C para detener la carga de CPU"
echo "================================================================"
echo ""

# Número de procesos a crear (uno por CPU)
NUM_CPUS=$(nproc)
echo "Generando carga en $NUM_CPUS CPUs..."
echo ""

# Función para generar carga de CPU
generate_load() {
    while true; do
        echo "scale=10000; 4*a(1)" | bc -l >/dev/null 2>&1
    done
}

# Iniciar procesos de carga
for i in $(seq 1 $NUM_CPUS); do
    generate_load &
    pids[${i}]=$!
done

echo "Procesos de carga iniciados (PIDs: ${pids[@]})"
echo "Monitorea la alerta en: http://localhost:9090/alerts"
echo ""
echo "Presiona Ctrl+C para detener..."

# Esperar señal de interrupción
trap "echo ''; echo 'Deteniendo carga de CPU...'; kill ${pids[@]} 2>/dev/null; echo 'Procesos detenidos.'; exit 0" SIGINT SIGTERM

# Mantener el script corriendo
wait
