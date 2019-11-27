/*
  IMPORTANTE
  Usar NewLine y CarriageReturn al enviar comandos desde el moitor serial.
*/
#include <SoftwareSerial.h>
SoftwareSerial bt(10, 11); // RX, TX
//RX (10) se conecta a TX del módulo BT
//TX (11) se conecta a RX del módulo BT

void setup()
{
  Serial.begin(9600); //Serial.begin(38400);
  Serial.println("Goodnight moon!");
  bt.begin(9600);
}

void loop() // run over and over
{
  if (bt.available())
    Serial.write(bt.read());
  if (Serial.available())
    bt.write(Serial.read());
}
