/*
 * Relays.cpp — Implementación del módulo de control de relés.
 */
#include "Relays.h"

// Tabla interna de dispositivos registrados.
static DeviceMapping devices[MAX_DEVICES];
static int deviceCount = 0;

void relaysInit() {
  for (int i = 0; i < RELAY_COUNT; i++) {
    pinMode(RELAY_PINS[i], OUTPUT);
    // Estado inicial: apagado.
    relayWrite(RELAY_PINS[i], false);
  }
}

void relayWrite(int gpio, bool encendido) {
  // Traduce el estado lógico (encendido/apagado) al nivel eléctrico según el
  // tipo de módulo de relé (activo en bajo o en alto).
  bool level = RELAY_ACTIVE_LOW ? !encendido : encendido;
  digitalWrite(gpio, level ? HIGH : LOW);
}

void relayRegisterDevice(const String &id, int gpio, bool estado) {
  // ¿Ya existe? -> actualizar.
  for (int i = 0; i < deviceCount; i++) {
    if (devices[i].id == id) {
      devices[i].gpio = gpio;
      devices[i].estado = estado;
      relayWrite(gpio, estado);
      return;
    }
  }
  // Nuevo registro (si hay espacio).
  if (deviceCount < MAX_DEVICES) {
    devices[deviceCount].id = id;
    devices[deviceCount].gpio = gpio;
    devices[deviceCount].estado = estado;
    pinMode(gpio, OUTPUT);
    relayWrite(gpio, estado);
    deviceCount++;
  }
}

int relaySetById(const String &id, bool encendido) {
  for (int i = 0; i < deviceCount; i++) {
    if (devices[i].id == id) {
      devices[i].estado = encendido;
      relayWrite(devices[i].gpio, encendido);
      return devices[i].gpio;
    }
  }
  return -1;
}

int relayDeviceCount() {
  return deviceCount;
}

DeviceMapping relayDeviceAt(int index) {
  if (index >= 0 && index < deviceCount) {
    return devices[index];
  }
  return DeviceMapping{"", -1, false};
}
