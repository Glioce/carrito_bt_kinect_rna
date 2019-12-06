/*********************************************************************
 KINECT-BT-RNA Y CARRITO-BT
 Noviembre 2019
 
 Usa una RNA para reconocer la posición de los brazos. Dependiendo 
 de la posición se envían los siguientes comandos al carrito
 
 'a': Avanza (brazo apuntando hacia arriba)
 'p': Para (brazo apuntando hacia abajo)
 'i': Gira a la Izquierda (brazo apuntando a la Izq)
 'd': Gira a la Derecha (brazo apuntando a la Der)
 
 El programa inicia en modo entrenamiento. En este modo se pueden
 tomar imágenes para entrenar o se puede cargar datos previos.
 
 Recibe mensajes del carrito para saber si la conexión sigue activa.
 *********************************************************************/

//import processing.video.*; //para usar webcam, no es necesario cuando se usa Kinect
import processing.serial.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

Serial bt; //objeto serial para comunicar con módulo BT
Kinect kinect; //objeto para manejar Kinect
ArrayList <SkeletonData> bodies;

char mensaje = ' '; //mensaje recibido
char comando = 'p'; //comando para enviar
char comando_nuevo = ' '; //se usa para detectar cambio de comando

boolean training; //estado, inicia en modo entrenamiento
boolean kolor; //indica si se captura imagen a color
ANN ann; //declarar objeto de red neuronal
int w, h; //tamaño de la mini imagen
PImage img; //mini imagen
PImage cap; //captura de Kinect
//Capture cap; //captura de Webcam
float [] grey; //array donde se copia la mini imagen

void setup() {
  size(640, 480); //tamaño de la ventana
  background(0); //opcional fondo negro
  textSize(24); //se dibujará texto de 24 px de alto
  println("KINECT-BT-RNA Y CARRITO-BT"); //mensaje inicial

  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION); //mostrar version de la clase Core de Processing

  //cap = new Capture(this, width, height); //parámetros de captura
  //cap.start(); //iniciar cámara
  kinect = new Kinect(this); //iniciar Kinect
  bodies = new ArrayList<SkeletonData>();

  training = true; //inicia en modo entrenamiento
  kolor = true;
  w = 16; //define anchura
  h = 12; //define altura
  ann = new ANN(w*h, 4); //tamaño de la red neuronal
  img = new PImage(w, h, ARGB); //crear mini imagen
  cap = new PImage(640, 480); //crear imagen de captura

  printArray(Serial.list()); //ver todos los puertos seriales disponibles
  bt = new Serial(this, Serial.list()[0], 9600); //iniciar comunicación con módulo BT
  //bt.write("AT+VERSION\r\n");
}

void draw() {
  background(0); //Limpiar ventana
  if (kolor) cap = kinect.GetImage();
  else cap = kinect.GetDepth(); 
  image(cap, 0, 0); //dibuja la captura

  img.copy(cap, 0, 0, width, height, 0, 0, w, h); //copiar captura en mini imagen
  img.updatePixels(); //actualizar mini imagen
  img.filter(GRAY); //convertir a escala de grises
  grey = getGrey(img); //convertir mini imagen a array
  image(img, 500, 380, w*8, h*8);

  if (bt.available() > 0) {  //Si hay datos disponibles
    mensaje = bt.readChar();
  }
  fill(0, 255, 0);
  text(mensaje, 610, 30); //imprime los datos

  if (training) {
    text("Modo entrenamiento", 30, 30);
    text("i", 160, 80);
    text("d", 480, 80);
    text("a", 160, 240);
    text("p", 480, 240);
    //text("Guardar", 160, 400);
    //text("Cargar", 480, 400);
  } else { //si no está en modo entrenamiento
    float val = ann.predict(grey); //evaluar
    //float [] res = ann.getResult(); //array de resultados
    //print(val," ",res);
    print(val);

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
  String fName = "";  

  if (training) { //si está entrenando
    float [] label = new float[4];
    if (mouseX > 0 && mouseX <= 320 && mouseY > 0 && mouseY <= 160) { //izquierda
      fName = "Izquierda";
      label[0] = 1.0; //activa primera neurona
      label[1] = 0.0;
      label[2] = 0.0;
      label[3] = 0.0;
    } else if (mouseX > 0 && mouseX <= 320 && mouseY > 160 && mouseY <= 320) {
      fName = "Avanza";
      label[0] = 0.0; 
      label[1] = 1.0; //activa segunda neurona
      label[2] = 0.0;
      label[3] = 0.0;
    } else if (mouseX > 320 && mouseX <= 640 && mouseY > 0 && mouseY <= 160) {
      fName = "Derecha";
      label[0] = 0.0; 
      label[1] = 0.0; 
      label[2] = 1.0; //activa tercera neurona
      label[3] = 0.0;
    } else if (mouseX > 320 && mouseX <= 640 && mouseY > 160 && mouseY <= 320) {
      fName = "Para";
      label[0] = 0.0; 
      label[1] = 0.0; 
      label[2] = 0.0;
      label[3] = 1.0; //activa cuarta neurona
    } /*else if (mouseX > 320 && mouseX <= 640 && mouseY > 160 && mouseY <= 320) {
      ann.saveData();
    }*/

    if (fName != "") {
      ann.addData(grey, label);
      fName += nf(ann.getCount(), 4) + ".png";
      img.save(dataPath("") + "/" + fName);
      println("Entrena ", fName);
    }
  }
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
