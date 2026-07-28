# 🗣️ Guión sencillo para la defensa

> Léelo con calma y con tus palabras. Está pensado para durar unos **5–6 minutos**.
> Autores: Valeryn Duque & Juan Vrasmatas.

---

## 1. Presentación (qué es)

«Buenas tardes. Nuestro proyecto es un **sistema de domótica**, es decir, un
sistema para **controlar aparatos eléctricos del hogar desde el celular**.
Por ejemplo, encender o apagar una luz, un ventilador o un tomacorriente,
estemos donde estemos, y que la respuesta sea **inmediata**.»

---

## 2. El problema (para qué sirve)

«Hoy, controlar los aparatos de una casa a distancia normalmente requiere
sistemas caros o cerrados. Nosotros quisimos construir una solución **propia,
económica y en tiempo real**, que uniera tres mundos: la **aplicación móvil**,
un **servidor en la nube** y el **hardware** que enciende la carga.»

---

## 3. Cómo lo hicimos (las partes)

«El sistema tiene **cuatro partes** que trabajan juntas:

**Primero, la aplicación móvil.** La hicimos en **Flutter**, que permite crear
una sola app para Android, iPhone y web. En la app el usuario se registra,
inicia sesión y ve un panel con tarjetas: cada tarjeta es un dispositivo con su
interruptor.

**Segundo, el servidor (el backend).** Lo programamos en **Node.js**. Es el
"cerebro": recibe las órdenes de la app, las guarda y avisa a todos los demás.

**Tercero, la base de datos.** Usamos **PostgreSQL**, donde se guarda el estado
de cada dispositivo (encendido o apagado), los usuarios y el historial de lo que
va pasando. Es la **fuente de verdad** del sistema.

**Y cuarto, el hardware.** Un microcontrolador **ESP8266** recibe la orden por
internet y activa un **relé**, que es como un interruptor automático que deja
pasar o corta la corriente de 120 voltios de la lámpara. Y para poder mostrarlo
sin montar todo el circuito físico, lo **simulamos en Proteus** con un Arduino.»

---

## 4. Cómo funciona (el recorrido de una orden)

«Voy a explicar qué pasa cuando alguien toca el interruptor en la app:

1. El usuario **pulsa el botón** de "Luz Sala" en el celular.
2. La app le avisa al **servidor**, que **guarda el cambio en la base de datos**.
3. El servidor **avisa al instante** a todo el sistema usando una tecnología
   llamada **WebSocket**, que mantiene una conexión abierta para que no haya
   retraso.
4. El **microcontrolador** recibe el cambio, activa el **relé** y la **lámpara
   se enciende**.

Todo esto ocurre en **milisegundos**. Y lo importante: la app y el hardware
**siempre leen el mismo estado** en la base de datos, así que nunca se
desincronizan.»

---

## 5. Qué hicimos para que fuera profesional

«No queríamos solo una demostración, sino un proyecto **bien hecho**:

- Organizamos el código en **capas separadas** (arquitectura limpia), para que
  sea ordenado y fácil de mantener.
- Protegimos las cuentas: las **contraseñas se guardan cifradas** y las sesiones
  usan un token de seguridad.
- Escribimos **32 pruebas automáticas** que revisan que el servidor funcione
  bien, y se ejecutan solas cada vez que cambiamos algo.
- Documentamos todo: guías para instalar, configurar Proteus y conectar el
  hardware.»

---

## 6. Qué logramos (resultados)

«Como resultado tenemos:

- La **app funcionando** en el celular.
- El **servidor y la base de datos** guardando y sincronizando todo en tiempo
  real.
- El **circuito** (real o simulado en Proteus) encendiendo la carga cuando lo
  ordenamos desde la app, **incluso usando datos móviles**, como si
  estuviéramos fuera de casa.»

---

## 7. Cierre

«En resumen, construimos un **ecosistema completo de domótica**: una app, un
servidor con base de datos y el hardware, comunicándose en tiempo real. Con
gusto respondemos sus preguntas y hacemos la demostración en vivo. Muchas
gracias.»

---

## 🔑 Palabras clave (por si te preguntan qué significan)

| Palabra | Explicación en una frase |
|---|---|
| **Flutter** | Herramienta para hacer la app para varios celulares con un solo código. |
| **Backend / Node.js** | El servidor, el "cerebro" que coordina todo. |
| **PostgreSQL** | La base de datos donde se guarda el estado de los aparatos. |
| **WebSocket** | Una conexión abierta que envía los cambios al instante, sin retraso. |
| **ESP8266** | El microcontrolador con Wi-Fi que enciende el relé. |
| **Relé** | Un interruptor automático que maneja la corriente de 120 V. |
| **Transistor 2N2222** | Amplifica la señal del microcontrolador para poder activar el relé. |
| **Proteus / COMPIM** | Programa para **simular** el circuito y conectarlo al sistema real. |

> 💡 Consejo: habla despacio, señala el **diagrama de arquitectura** mientras
> explicas el punto 4, y termina siempre invitando a la **demo en vivo**.
