/*********************************************************************
 KINECT Y CARRITO BLUETOOTH
 Noviembre 2019
 
 Obtiene información de esqueleto a través de Kinect y calcula la
 orientación del brazo derecho. Dependiendo de la orientación se
 envían los siguientes comandos al carrito
 'a': Avanza (brazo apuntando hacia arriba)
 'p': Para (brazo apuntando hacia abajo)
 'i': Gira a la Izquierda (brazo apuntando a la Izq)
 'd': Gira a la Derecha (brazo apuntando a la Der)
 
 Recibe mensajes del carrito para saber si la conexión sigue activa.
 *********************************************************************/

import processing.serial.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

Serial bt; //objeto serial para comunicar con módulo BT
Kinect kinect; //objeto para manejar Kinect
ArrayList <SkeletonData> bodies;

char mensaje = ' '; //mensaje recibido
char comando = 'p'; //comando para enviar
char comando_nuevo = ' '; //se usa para detectar cambio de comando

void setup() {
  size(640, 480); //ventana
  background(0); //fondo negro
  textSize(24);
  println("KINECT Y CARRITO BT"); //mensaje inicial

  kinect = new Kinect(this); //iniciar Kinect
  bodies = new ArrayList<SkeletonData>();

  printArray(Serial.list()); //ver todos los puertos seriales disponibles
  bt = new Serial(this, "COM13", 9600); //iniciar comunicación con módulo BT
  //bt.write("AT+VERSION\r\n");
}

void draw() {
  background(0); //Limpiar ventana
  image(kinect.GetDepth(), 0, 0);
  for (int i=0; i<bodies.size(); i++) 
  {
    drawSkeleton(bodies.get(i));
    drawPosition(bodies.get(i));
    medirHueso(bodies.get(i), 
      Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
      Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
  }
  if (bt.available() > 0) {  //Si hay datos disponibles
    mensaje = bt.readChar();
  }
  fill(0, 255, 0);
  text(mensaje, 610, 30); //imprime los datos
}

void medirHueso(SkeletonData _s, int _j1, int _j2) 
{
  if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
    _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    float angulo = degrees(atan2(
      _s.skeletonPositions[_j1].x - _s.skeletonPositions[_j2].x, 
      _s.skeletonPositions[_j1].y - _s.skeletonPositions[_j2].y 
      ));
    text(angulo, 30, 30);
    if (angulo > -45 && angulo < 45) {
      text("Avanza", 30, 60);
      comando_nuevo = 'a';
    }
    if (angulo > 45 && angulo < 135) {
      text("Izquierda", 30, 60);
      comando_nuevo = 'i';
    }
    if (angulo > -135 && angulo < -45) {
      text("Derecha", 30, 60);
      comando_nuevo = 'd';
    }
    if (angulo > 135 || angulo < -135) {
      text("Para", 30, 60);
      comando_nuevo = 'p';
    }
    
    if (comando_nuevo != comando) {
      comando = comando_nuevo;
      bt.write(comando);
      print(comando);
    }
  }
}
