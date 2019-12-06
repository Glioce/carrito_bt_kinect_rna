/**************************************************
 Clase personalizada de Artificial Neural Networks
 **************************************************/

import org.opencv.core.Core; //Contiene muchas funciones para operaciones de matrices
import org.opencv.core.Mat; //Clase matriz
import org.opencv.core.MatOfInt; //Hereda de Mat
import org.opencv.core.MatOfFloat; //Hereda de Mat
import org.opencv.core.CvType; //Define varios tipos de datos
import org.opencv.ml.Ml; //Define algunas constantes utilizadas en Machine Learning
import org.opencv.ml.ANN_MLP; //Artificial Neural Networks - Multi-Layer Perceptrons

// La clase ANN_MLP permite definir la topología de un red neuronal.
// Cuando se crea, todos los pesos valen cero. Después se entrena con
// vectores de entrada y salida. El proceso de entrenamiento se puede
// repetir varias veces para ajustar los pesos con nuevos datos.  

public class ANN {
  final int MAX_DATA = 1000;
  ANN_MLP mlp; //objeto multi-layer perceptron
  int input; //tamaño de la entrada
  int output; //tamaño de la salida
  ArrayList<float []>train; //lista de arrays (los arrays son imágenes)
  ArrayList<Float>label; //lista de etiquetas
  MatOfFloat result; //el resultado es un vector de flotantes
  String model; //¿para qué se usa? Creo  que por ahora no sirve

  // Constructor
  public ANN(int i, int o) {
    input = i; //se especifica el tamaño de la entrada
    output = o; //por ahora solo hay una neurona de salida

    // Esta es la topología de la red neuronal. Tiene 3 capas:
    // La primera capa tiene un número de neuronas igual al
    // número de pixels de las imágenes de entrenamiento.
    // La capa intermendia tiene la mitad de neuronas que la primera capa.
    // La capa de salida tiene una neurona.
    mlp = ANN_MLP.create(); //pointer 
    MatOfInt m1 = new MatOfInt(input, input/2, output);
    mlp.setLayerSizes(m1);

    // A continuación se indica la función de activación y el
    // método de entrenamiento: Función sigmoidal y Propagación.
    mlp.setActivationFunction(ANN_MLP.SIGMOID_SYM);
    mlp.setTrainMethod(ANN_MLP.RPROP);

    // Se inicializa el vector de salida 'result' y las listas de entrenamiento y etiquetas
    // 'model' no sirve para nada
    result = new MatOfFloat();
    train = new ArrayList<float[]>();
    label = new ArrayList<Float>();
    model = dataPath("trainModel.xml");
  }

  // Agregar datos
  // t: "train" imagen de entrada como vector
  // l: "label" etiqueta como valor con punto flotante
  void addData(float [] t, float [] l) {
    if (t.length != input) // si el tamaño del vector es diferente al tamaño de la entrada
      return; //no agregar datos
    if (train.size() >= MAX_DATA) //si se ha alcanzado el número máximo de datos
      return; //tampoco agregar datos
    train.add(t); //se agrega el vector a la lista
    for (int k=0; k<output; k++) {
      label.add(l[k]); //se agregan las etiquetas a la lista
    }
  }

  /*void saveData() {
  }*/

  // Ver cuantas imágenes se han agregado
  int getCount() {
    return train.size();
  }

  // Entrenar
  void train() {
    // Copiar toda la información de 'train' a una matriz simple 'tr'
    float [][] tr = new float[train.size()][input];
    for (int i=0; i<train.size(); i++) {
      for (int j=0; j<train.get(i).length; j++) {
        tr[i][j] = train.get(i)[j];
      }
    }
    float [] trf = flatten(tr); //toda la información se vuelve a aplanar
    Mat trainData = new Mat(train.size(), input, CvType.CV_32FC1);
    trainData.put(0, 0, trf); //guardar último aplanado en matriz

    print("trainData "); 
    print(trainData.rows()); 
    print(" "); 
    println(trainData.cols());

    // La lista de etiquetas se copia a una matriz 1D (vector)
    //MatOfFloat response = new MatOfFloat();
    //response.fromList(label);
    Mat response = new Mat(train.size(), output, CvType.CV_32FC1);
    int index = 0;
    for (int i=0; i<train.size(); i++) {
      for (int j=0; j<output; j++) {
        //tr[i][j] = train.get(i)[j];
        //println(label.get(index));
        response.put(i, j, label.get(index));
        index ++;
      }
    }

    print("response "); 
    print(response.rows()); 
    print(" "); 
    println(response.cols());

    // Entrenar (samples, layout, responses)
    mlp.train(trainData, Ml.ROW_SAMPLE, response);

    trainData.release(); //borrar matriz
    response.release(); //borrar matriz
    train.clear(); //limpiar lista
    label.clear(); //limpiar lista
  }

  // Evaluar imagen
  float predict(float [] i) {
    if (i.length != input) //si el tamaño de del vector es diferente al tamaño de entrada 
      return -1; //no evaluar
    Mat test = new Mat(1, input, CvType.CV_32FC1);
    test.put(0, 0, i); //copiar en matriz
    float val = mlp.predict(test, result, 0); //(samples, results, flags)
    return val; //¿qué devuelve? Tal vez es el valor de probabilidad
  }

  // Convertir 'result' a array
  float [] getResult() {
    float [] r = result.toArray();
    return r;
  }

  // Aplanar. Se obtiene un array 1D de un array 2D
  float [] flatten(float [][] a) {
    if (a.length == 0) 
      return new float[]{};
    int rCnt = a.length;
    int cCnt = a[0].length;
    float [] res = new float[rCnt*cCnt];
    int idx = 0;
    for (int r=0; r<rCnt; r++) {
      for (int c=0; c<cCnt; c++) {
        res[idx] = a[r][c];
        idx++;
      }
    }
    return res;
  }
}
