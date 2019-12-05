/*********************************************************************
 KINECT Y CARRITO BLUETOOTH
 Noviembre 2019
 
 Usa un RNA para reconocer la orientación de los brazos. Dependiendo 
 de la orientación se envían los siguientes comandos al carrito
 'a': Avanza (brazo apuntando hacia arriba)
 'p': Para (brazo apuntando hacia abajo)
 'i': Gira a la Izquierda (brazo apuntando a la Izq)
 'd': Gira a la Derecha (brazo apuntando a la Der)
 
 Recibe mensajes del carrito para saber si la conexión sigue activa.
 *********************************************************************/

//import processing.video.*; //para usar la cámara, no es necesario cuando se usa Kinect

import processing.serial.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

Serial bt; //objeto serial para comunicar con módulo BT
Kinect kinect; //objeto para manejar Kinect
ArrayList <SkeletonData> bodies;

char mensaje = ' '; //mensaje recibido
char comando = 'p'; //comando para enviar
char comando_nuevo = ' '; //se usa para detectar cambio de comando
 
//Capture cap; //imagen obtenida con la cámara
boolean training; //estado, inicia en modo entrenamiento
ANN ann; //declarar objeto de red neuronal
int w, h; //tamaño de la mini imagen
 
void setup() {
  size(640, 480); //tamaño de la ventana
  background(0); //opcional fondo negro
  textSize(24);
  println("KINECT Y CARRITO BT"); //mensaje inicial
  
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION); //mostrar version de la clase Core de Processing
  
  //cap = new Capture(this, width, height); //parámetros de captura
  //cap.start(); //iniciar cámara
  kinect = new Kinect(this); //iniciar Kinect
  bodies = new ArrayList<SkeletonData>();
  
  training = true; //inicia en modo entrenamiento
  w = 8; //redefine anchura
  h = 6; //redefine altura
  ann = new ANN(w*h, 4); //tamaño de la red neuronal
  
  printArray(Serial.list()); //ver todos los puertos seriales disponibles
  bt = new Serial(this, "COM14", 9600); //iniciar comunicación con módulo BT
  //bt.write("AT+VERSION\r\n");
}
 
void draw() {
  //image(cap, 0, 0); //solo dibuja la captura
  background(0); //Limpiar ventana
  image(kinect.GetDepth(), 0, 0);
  //image(kinect.GetImage(), 0, 0);
  PImage img = new PImage(w, h, ARGB); //crear mini imagen
  img.copy(kinect.GetDepth(), 0, 0, width, height, 0, 0, w, h); //copiar captura en mini imagen
  img.updatePixels(); //dibujar mini imagen
  img.filter(GRAY); //convertir a escala de grises
  float [] grey = getGrey(img); //convertir mini imagen a array
  
  if (bt.available() > 0) {  //Si hay datos disponibles
    mensaje = bt.readChar();
  }
  fill(0, 255, 0);
  text(mensaje, 610, 30); //imprime los datos
  
  if (training == false) { //si no está en modo entrenamiento
    float val = ann.predict(grey); //evaluar (se obtiene valor de probabilidad, pero no se usa)
    print(val); print(" ");
    float [] res = ann.getResult(); //array de resultados (solo un valor por ahora)
    print(res[0]); print(" "); print(res[1]); print(" "); println(res[1]);
    if (val == 0.0) {
      text("Izquierda", 30, 60);
      comando_nuevo = 'i';
    }
    if (val == 1.0) {
      text("Avanza", 30, 60);
      comando_nuevo = 'a';
    }
    if (val == 2.0) {
      text("Derecha", 30, 60);
      comando_nuevo = 'd';
    }
    if (val == 3.0) {
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
 
/*void captureEvent(Capture c) {
  c.read();
}*/

void mousePressed() { //al hacer clic
  PImage img = new PImage(w, h, ARGB); //crear mini imagen
  img.copy(kinect.GetDepth(), 0, 0, width, height, 0, 0, w, h); //copiar captura en mini imagen
  img.updatePixels(); //dibujar mini imagen
  img.filter(GRAY); //convertir a escala de grises
  String fName = "";
  float [] grey = getGrey(img); //convertir mini imagen a array
  if (training) { //si está entrenando
    float [] label = new float[4];
    if (mouseX <= width/4) { //izquierda
      label[0] = 1.0; //activa primera neurona
      label[1] = 0.0;
      label[2] = 0.0;
      label[3] = 0.0;
      println("Entrena izquierda");
      fName = "Izquierda";
    } else if (mouseX > width/4 && mouseX <= width/2){
      label[0] = 0.0; 
      label[1] = 1.0; //activa segunda neurona
      label[2] = 0.0;
      label[3] = 0.0;
      println("Entrena avanza");
      fName = "Avanza";
    } else if (mouseX > width/2 && mouseX < 3*width/4){
      label[0] = 0.0; 
      label[1] = 0.0; 
      label[2] = 1.0; //activa tercera neurona
      label[3] = 0.0;
      println("Entrena derecha");
      fName = "Derecha";
    }else{
      label[0] = 0.0; 
      label[1] = 0.0; 
      label[2] = 0.0;
      label[3] = 1.0; //activa tercera neurona
      println("Entrena para");
      fName = "Para";
    }
    ann.addData(grey, label);
    //fName = (label == 0.0) ? "Izquierda" : "Derecha";
    fName += nf(ann.getCount(), 4) + ".png";
    img.save(dataPath("") + "/" + fName);
  } 
  /*else { //si no está en modo entrenamiento
    float val = ann.predict(grey); //evaluar (se obtiene valor de probabilidad, pero no se usa)
    print(val); print(" ");
    float [] res = ann.getResult(); //array de resultados (solo un valor por ahora)
    print(res[0]); print(" "); print(res[1]); print(" "); println(res[1]);
    if (val == 0.0) {
      text("Izquierda", 30, 60);
      comando_nuevo = 'i';
    }
    if (val == 1.0) {
      text("Para", 30, 60);
      comando_nuevo = 'p';
    }
    if (val == 2.0) {
      text("Derecha", 30, 60);
      comando_nuevo = 'd';
    }
    
    if (comando_nuevo != comando) {
      comando = comando_nuevo;
      bt.write(comando);
      print(comando);
    }
  }*/
}
 
float [] getGrey(PImage m) {
  float [] g = new float[w*h];
  if (m.width != w || m.height != h) 
    return g;
  for (int i=0; i<m.pixels.length; i++) {
    color c = m.pixels[i];
    g[i] = red(c) / 256.0;
  }
  return g;
}
 
void keyPressed() {
  if (keyCode == 32) {
    training = !training;
    if (!training) 
      ann.train();
  }
  println("Training status is " + training);
}
