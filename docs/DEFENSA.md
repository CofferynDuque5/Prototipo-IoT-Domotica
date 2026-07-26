# 🎓 Guión de Defensa — Prototipo de Sistema IoT para Domótica

**Autores:** Valeryn Duque & Juan Vrasmatas · Ingeniería de Sistemas
**Duración objetivo:** ~12 min de exposición + ~3–5 min de demo y preguntas.

Presentación: [`docs/defensa.pptx`](defensa.pptx) · Diagrama: [`docs/arquitectura.svg`](arquitectura.svg)

---

## ⏱️ Tiempos por diapositiva

| # | Diapositiva | Tiempo | Idea que debe quedar |
|---|---|---|---|
| 1 | Portada | 0:30 | Qué es y quiénes lo hicieron. |
| 2 | El problema | 1:00 | Control accesible, en tiempo real y multiplataforma. |
| 3 | Objetivos | 1:00 | General + hardware + software/cloud. |
| 4 | Arquitectura | 2:00 | **La diapositiva clave**: el flujo de extremo a extremo. |
| 5 | Tecnologías | 1:00 | Stack moderno y justificado. |
| 6 | Flujo de comunicación | 1:30 | 3 pasos + por qué WebSockets. |
| 7 | La app Flutter | 1:00 | Funcionalidades para el usuario. |
| 8 | Hardware & Simulación | 1:30 | Del bit al relé de 120 V; COMPIM. |
| 9 | Calidad e ingeniería | 1:00 | 32 pruebas, CI, Clean Architecture. |
| 10 | Resultados | 0:45 | Entregables concretos. |
| 11 | Conclusiones | 1:00 | Logros + trabajo futuro. |
| 12 | Demo + preguntas | 3:00+ | Demostración en vivo. |

---

## 🗣️ Qué decir en cada diapositiva

**1. Portada.** «Buenas tardes. Presentamos el Prototipo de Sistema IoT para Domótica: un sistema que permite encender y apagar cargas eléctricas del hogar en tiempo real desde una app móvil, integrando hardware, nube y aplicación.»

**2. El problema.** Controlar dispositivos suele requerir presencia física o sistemas propietarios caros. Nuestra meta: una solución accesible, multiplataforma y con **latencia imperceptible**. Menciona la idea clave: mantener una conexión abierta (WebSockets).

**3. Objetivos.** Lee los tres: (a) prototipo funcional con app móvil y latencia mínima; (b) nodo físico con microcontrolador Wi-Fi que actúa sobre la corriente; (c) backend con datos en tiempo real + interfaz intuitiva.

**4. Arquitectura (la más importante).** Recorre el flujo con el dedo: **App Flutter → API (REST + WebSocket) → PostgreSQL**, y de ahí dos rutas de hardware: el **ESP8266** por Wi-Fi y la **simulación en Proteus** (puente serial → COMPIM → Arduino). Remata: «Ambas rutas comparten el mismo estado del relé en PostgreSQL: una sola fuente de verdad, dos caminos de hardware.»

**5. Tecnologías.** Justifica brevemente cada elección (ver Q&A). Enfatiza que es un stack estándar de la industria.

**6. Flujo de comunicación.** Los 3 pasos: Interacción → Sincronización → Ejecución. Cierra con la caja azul: WebSockets mantienen un túnel abierto → la latencia entre tocar el botón y encender la carga es imperceptible.

**7. La app Flutter.** Muestra las funcionalidades: autenticación, dashboard en tiempo real, control por habitaciones, estado del sistema (RSSI, uptime), historial de eventos y modo claro/oscuro. (Si puedes, salta a la app real.)

**8. Hardware & Simulación.** Explica la **cadena de actuación**: el comando `1/0` llega al Pin 2, que por una resistencia excita la base del **2N2222**; el transistor energiza la **bobina del relé** (con diodo de protección) y el relé conmuta la **lámpara de 120 V**. Aclara qué es COMPIM: un puerto serial **virtual** que conecta la simulación con software real, sin hardware físico.

**9. Calidad e ingeniería.** Este es tu diferenciador: **32 pruebas automatizadas** (Jest + Supertest) en 6 suites, integración continua, Clean Architecture y seguridad (JWT + bcrypt). Menciona `pg-mem`: se prueba sin base de datos externa.

**10. Resultados.** Los tres entregables: prototipo de hardware, app instalada y funcionando, y la demostración de telemetría (operar por internet, incluso con datos móviles).

**11. Conclusiones.** Resume logros y sé honesto con el trabajo futuro (SMTP, HTTPS/despliegue, más dispositivos).

**12. Cierre.** Lanza la **demo en vivo** y abre a preguntas.

---

## 🧪 Checklist de la demostración en vivo

### Antes de entrar (pre-vuelo)
- [ ] `.hex` del Arduino cargado en Proteus (Program File).
- [ ] Par de puertos virtuales creado (VSPD/com0com): **COM1 ⇄ COM2**.
- [ ] Mismos baudios en todo: **9600** (COMPIM = Arduino = puente).
- [ ] `DEVICE_API_KEY` idéntica en el backend y en el puente.
- [ ] Teléfono/PC en la **misma red Wi-Fi**; ten a mano la **IP LAN** de tu PC.
- [ ] **Video de respaldo** grabado de la demo funcionando (plan B).

### Orden de arranque
1. **Backend + BD:** `cd backend && docker compose up` → verifica `http://localhost:3000/health`.
2. **Proteus:** inicia la simulación (COMPIM toma COM1).
3. **Puente serial:** `cd proteus-bridge && npm start` → debe decir «Puerto COM2 abierto».
4. **App Flutter:** `flutter run --dart-define=API_HOST=<IP-de-tu-PC>` e inicia sesión.

### Momento «wow»
- Pulsa **Luz Sala** en la app → en Proteus se acciona el relé y **enciende la lámpara**; aparece el **evento** en el historial y el estado se ve **online**. Si tienes el ESP8266 físico, el LED/relé también responde.

### Plan B (si algo falla)
- Sin app/red: ejecuta el comando y muestra el efecto en Proteus:
  ```bash
  curl -X POST http://localhost:3000/api/estado \
    -H "x-device-key: <TU_KEY>" -H "Content-Type: application/json" \
    -d '{"estado": true}'
  ```
- Sin backend/hardware: muestra las **32 pruebas en verde** (`cd backend && npm test`) y reproduce el **video de respaldo**.

---

## ❓ Preguntas frecuentes del jurado (con respuestas)

**1. ¿Por qué WebSockets y no HTTP tradicional?**
HTTP exige que el cliente pregunte constantemente (polling), lo que añade latencia y carga. WebSocket mantiene un **túnel abierto bidireccional**: el servidor **empuja** el cambio al instante a todas las apps conectadas. En domótica, esa inmediatez es crítica.

**2. ¿Por qué PostgreSQL y no Firebase?**
Empezamos con Firebase, pero migramos a **PostgreSQL** para tener una base de datos **relacional real**, control total del esquema, consultas SQL, y evitar la dependencia de un proveedor (vendor lock-in). Montamos nuestro propio backend (Node.js/Express) que además expone la API que consume el hardware.

**3. ¿Cómo aseguran la aplicación?**
Las contraseñas se guardan con **hash bcrypt** (nunca en texto plano). Las sesiones usan **JWT** firmados. El hardware se autentica con una **clave de dispositivo** (`x-device-key`) separada de las credenciales de usuario. Hay validación de entradas en cada endpoint.

**4. ¿Qué pasa si se cae la red o el microcontrolador?**
Hay **reconexión automática** en tres niveles: Wi-Fi del ESP8266, WebSocket de la app y el puente serial. Además, el ESP se marca **offline** automáticamente si deja de enviar su *heartbeat* (telemetría) durante un umbral configurable.

**5. ¿Cómo saben que el ESP está conectado?**
El ESP publica telemetría periódica (`lastSeen`). El sistema compara la antigüedad de ese último latido contra un umbral (30 s); si se supera, se muestra **offline**, aunque no llegue ningún mensaje nuevo.

**6. ¿Por qué un transistor y un relé, y no conectar el GPIO directo?**
El pin del microcontrolador entrega muy poca corriente y trabaja a 3.3 V; no puede mover la bobina del relé. El **2N2222** actúa como interruptor amplificador. El **relé** aísla eléctricamente y conmuta los 120 V. El **diodo (1N4007)** protege al transistor del pico de tensión de la bobina.

**7. ¿Es seguro trabajar con 120 V?**
En el prototipo priorizamos el aislamiento del relé y, para pruebas, se usan indicadores/LEDs. La manipulación de la carga real se hace con las precauciones eléctricas adecuadas.

**8. ¿Cómo probaron el backend?**
Con **32 pruebas automatizadas** (Jest + Supertest) sobre auth, dispositivos, eventos, telemetría, `/estado` y WebSocket. Usamos **pg-mem** (PostgreSQL en memoria), así que las pruebas corren en cualquier máquina y en **CI (GitHub Actions)** sin base de datos externa.

**9. ¿Escala a más dispositivos o casas?**
Sí: agregar dispositivos es insertar filas en la tabla `devices`. El WebSocket difunde a N clientes. El backend puede desplegarse en la nube y soportar varios nodos ESP simultáneamente.

**10. ¿Cuál es la diferencia entre la ruta del ESP8266 y la de Proteus?**
Ambas leen el **mismo estado** en PostgreSQL. El ESP8266 es la ruta de hardware real; **Proteus + COMPIM** permite demostrar el circuito completo **sin hardware físico**, ideal para la defensa.

**11. ¿Qué es exactamente COMPIM / VSPD?**
COMPIM es un componente de Proteus que conecta la simulación a un **puerto serie** del PC. VSPD/com0com crea un **par de puertos virtuales enlazados** (COM1 ⇄ COM2): lo que escribe nuestro puente en COM2 lo recibe Proteus por COM1. Todo virtual.

**12. ¿Por qué Clean Architecture?**
Separa el código en capas (modelos, servicios, repositorios, controladores) siguiendo **SOLID**. Resultado: es **testeable**, mantenible y permite cambiar una pieza (p. ej. la base de datos) sin reescribir la app — de hecho, así pudimos migrar de Firebase a PostgreSQL.

**13. ¿Cuánta latencia real hay?**
En la red local, la propagación por WebSocket es de milisegundos. El ESP consulta su estado cada ~1.5 s (parametrizable); podría reducirse o migrarse a WebSocket en el propio microcontrolador.

**14. ¿Limitaciones actuales?**
El envío real del correo de recuperación requiere integrar SMTP (queda como punto de extensión). El backend corre en HTTP en la red local; para producción se añadiría HTTPS y despliegue en la nube.

---

## ✅ Frases de cierre útiles
- «Construimos un ecosistema **completo y probado**, no solo una demo: 32 pruebas automatizadas respaldan el backend.»
- «La misma orden viaja de la app a la nube y al hardware en tiempo real: **una sola fuente de verdad, dos rutas de hardware**.»
- «La arquitectura limpia nos permitió incluso **cambiar la base de datos** sin reescribir la aplicación.»
