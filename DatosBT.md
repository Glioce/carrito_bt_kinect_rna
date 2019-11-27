# Datos de los módulos Bluetooth

## Esclavo

AT+NAME=E //esclavo

AT+PSWD?
+PSWD:1234

AT+UART?
+UART:9600,0,0

AT+ROLE?
+ROLE:0 //esclavo

AT+CMODE?
+CMOD:1 //conexion con cualquier dispositivo, si está en modo maestro

AT+BIND?
+BIND:98d3:31:300e42

AT+VERSION?
+VERSION:2.0-20100601

AT+ADDR? //dirección de este módulo
+ADDR:21:13:5de70

AT+RESET

## Maestro

AT+NAME=M //maestro

AT+PSWD?
+PSWD:1234 //igual que el esclavo

AT+UART?
+UART:9600,0,0

AT+ROLE=1
AT+ROLE?
+ROLE:1 //maestro

AT+CMODE?
+CMOD:1 //conexion con cualquier dispositivo, si está en modo maestro

AT+BIND?
+BIND:98d3:31:300e42
AT+BIND=21,13,5de70

AT+VERSION?
+VERSION:2.0-20100601

AT+ADDR? //dirección de este módulo
+ADDR:21:13:5e31a

AT+RESET
