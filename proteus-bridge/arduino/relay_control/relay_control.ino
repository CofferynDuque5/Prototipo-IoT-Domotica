/*
 * ===========================================================================
 *  relay_control.ino  —  Control del relé por puerto Serial (Proteus)
 * ===========================================================================
 *  Lee caracteres del puerto Serial (que en Proteus llega vía COMPIM desde el
 *  puente Node.js) y controla el PIN 2, conectado a la base del transistor
 *  2N2222 (a través de R2). El transistor acciona la bobina del relé RL1, que
 *  a su vez conmuta la carga de 120 V AC (lámpara L1).
 *
 *  Protocolo:
 *    '1'  -> PIN 2 en ALTO  -> transistor satura -> relé ON  -> lámpara ON
 *    '0'  -> PIN 2 en BAJO  -> transistor corta  -> relé OFF -> lámpara OFF
 *  (se ignoran otros caracteres, p. ej. saltos de línea)
 *
 *  Velocidad: 9600 baudios (debe coincidir con COMPIM y con el puente).
 * ===========================================================================
 */

const uint8_t PIN_RELE = 2;   // Pin conectado a R2 -> base de Q1 (2N2222)
const uint8_t PIN_LED  = 13;  // LED integrado: refleja el estado (diagnóstico)

void setState(bool encendido) {
  digitalWrite(PIN_RELE, encendido ? HIGH : LOW);
  digitalWrite(PIN_LED, encendido ? HIGH : LOW);
  // Eco de confirmación (útil para depurar en el Terminal de Proteus).
  Serial.println(encendido ? "RELE:ON" : "RELE:OFF");
}

void setup() {
  pinMode(PIN_RELE, OUTPUT);
  pinMode(PIN_LED, OUTPUT);
  setState(false);          // arranque seguro: relé apagado

  Serial.begin(9600);
  Serial.println("Arduino listo. Esperando comandos ('1'/'0')...");
}

void loop() {
  if (Serial.available() > 0) {
    char comando = Serial.read();

    switch (comando) {
      case '1':
        setState(true);
        break;
      case '0':
        setState(false);
        break;
      default:
        // Ignora '\r', '\n' y cualquier otro carácter no reconocido.
        break;
    }
  }
}
