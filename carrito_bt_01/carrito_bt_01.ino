/************************************************************************
  CARRITO BLUETOOTH
  Noviembre 2019

  El módulo BT recibe instrucciones de un solo caracter
  'a' avanza
  'p' para
  'i' izquierda
  'd' derecha

  Envia un mensaje cada segundo para indicar que la conexión sigue activa
************************************************************************/

// Terminales para conectar a los motores (usan PWM)
#define MOTOR_A 3
#define MOTOR_B 5
#define MOTOR_C 6
#define MOTOR_D 9
#define PWM_BASE 128

void motor(uint8_t a, uint8_t b, uint8_t c, uint8_t d) {
  analogWrite(MOTOR_A, a);
  analogWrite(MOTOR_B, b);
  analogWrite(MOTOR_C, c);
  analogWrite(MOTOR_D, d);
}

// Biblioteca para conectar el módulo BT
#include <SoftwareSerial.h>
SoftwareSerial bt(10, 11);
//RX (10) se conecta a TX del módulo BT
//TX (11) se conecta a RX del módulo BT

uint32_t t_msj = 0; //momento de enviar mensaje
uint32_t T = 1000; //intervalo entre mensajes
char msj[] = {'O', 'W'}; //caracteres que se envian como mensaje
uint8_t j = 0; //indice dentro del array anterior

void setup() {
  Serial.begin(9600); //se usa hardware serial para depurar
  Serial.println("CARRITO BLUETOOTH"); //mensaje inicial
  bt.begin(9600); //iniciar comunicación con módulo BT
  
  //for (int i = 2; i <= 9; i++) pinMode(i, OUTPUT); //salidas
  motor(PWM_BASE, 0, PWM_BASE, 0); //avanzar
}

void loop() {
  if (millis() >= t_msj) {// momento de enviar mensaje
    t_msj += T; //esperar antes de enviar siguiente mensaje
    bt.write(msj[j]); //enviar mensaje por BT
    //Serial.write(msj[j]); //opcional
    j = (j + 1) % 2; //incrementar indice
  }

  if (bt.available()) {// recibir comando
    char comando = bt.read(); //un caracter
    Serial.write(comando);
    switch (comando) {
      case 'i': //girar a la izquierda
        motor(0, 0, PWM_BASE, 0);
        break;
      case 'd': //girar a la derecha
        motor(PWM_BASE, 0, 0, 0);
        break;
      case 'p': //parar
        motor(0, 0, 0, 0);
        break;
      case 'a': //avanzar
        motor(PWM_BASE, 0, PWM_BASE, 0);
        break;
    }
  }

  if (Serial.available()) {//opcional
    bt.write(Serial.read());
  }
}
