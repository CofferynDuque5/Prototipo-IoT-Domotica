const uint8_t PIN_RELE_SALA = 2;    // Pin 32 del ATmega (PD2)
const uint8_t PIN_RELE_COCINA = 3;  // Pin 33 del ATmega (PD3)

void setup() {
  Serial.begin(9600);

  pinMode(PIN_RELE_SALA, OUTPUT);
  pinMode(PIN_RELE_COCINA, OUTPUT);

  digitalWrite(PIN_RELE_SALA, LOW);
  digitalWrite(PIN_RELE_COCINA, LOW);

  Serial.println("Arduino listo con 2 dispositivos.");
}

void loop() {
  if (Serial.available() > 0) {
    char comando = Serial.read();

    switch (comando) {
      // --- Foco Sala ---
      case '1':
        digitalWrite(PIN_RELE_SALA, HIGH);
        Serial.println("SALA:ON");
        break;
      case '0':
        digitalWrite(PIN_RELE_SALA, LOW);
        Serial.println("SALA:OFF");
        break;

      // --- Foco Cocina ---
      case '2':
        digitalWrite(PIN_RELE_COCINA, HIGH);
        Serial.println("COCINA:ON");
        break;
      case '3':
        digitalWrite(PIN_RELE_COCINA, LOW);
        Serial.println("COCINA:OFF");
        break;
    }
  }
}