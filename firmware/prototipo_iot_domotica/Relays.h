/*
 * Relays.h
 * ---------------------------------------------------------------------------
 * Módulo de control de relés (salidas GPIO).
 *
 * Mantiene un mapa dinámico entre el identificador de cada dispositivo de la
 * base de datos y el pin GPIO físico que lo controla. Expone funciones para
 * inicializar los pines y para encender/apagar por GPIO o por id.
 * ---------------------------------------------------------------------------
 */
#ifndef RELAYS_H
#define RELAYS_H

#include <Arduino.h>
#include "Config.h"

// Número máximo de dispositivos que el firmware puede rastrear.
#define MAX_DEVICES 16

// Estructura que asocia un dispositivo lógico con su relé físico.
struct DeviceMapping {
  String id;     // Identificador del nodo en /devices
  int    gpio;   // Pin GPIO asociado
  bool   estado; // Último estado conocido
};

// Inicializa todos los pines de relé como salidas y los deja apagados.
void relaysInit();

// Aplica el nivel eléctrico correcto a un GPIO según RELAY_ACTIVE_LOW.
void relayWrite(int gpio, bool encendido);

// Registra o actualiza el mapeo de un dispositivo (id -> gpio) y su estado.
void relayRegisterDevice(const String &id, int gpio, bool estado);

// Aplica un estado a un dispositivo identificado por su id. Devuelve el GPIO
// afectado, o -1 si el id no está registrado.
int relaySetById(const String &id, bool encendido);

// Devuelve el número de dispositivos registrados.
int relayDeviceCount();

// Acceso de solo lectura al mapeo por índice.
DeviceMapping relayDeviceAt(int index);

#endif  // RELAYS_H
