//
//  MyWidget.swift
//  MyWidget
//
//  Created by Paul Jaime Felix Flores on 25/04/23.
//

import WidgetKit
import SwiftUI
//El widget se compone de 4 estructuras (Modelo,Provider,Diseño,Configuracion)

/*-------------------------------------------------------------------------------------------------------*/
/*
  V-140.Paso 1.0 MODELO VAR
  Es el tipo de datos que usaremos en el widget
  El TimeLineEntry siemre va este protocolo ,osea que los datos y el protocolo que
   se usara en Widget
*/
struct Modelo : TimelineEntry {
    //paso 1.0,El date siempre viene afuerzas
    var date: Date
    //var mensaje: String
    //Paso 1.14 cambiamos el modelo y le diremos que usaremos el modelo de Json de la API
    var widgetData : [JsonData]
    
}

//V-141,paso 1.13,modelo para nuestro Json y traer datos de una API
struct JsonData: Decodable {
    var id : Int
    var name : String
    var email : String
}

/*-------------------------------------------------------------------------------------------------------*/
// PROVIDER
/* El proveedor inicializa el widget ,el tipo de datos que traera el widget y la logica principal*/

//Paso 1.1,Nos retorna el propio modelo
/* Necesita de afuerzas del protocolo: TimelineProvider */
struct Provider: TimelineProvider {
    //Paso 1.2,debemos adjuntar estos 3 métodos

    /* Paso 1.3 ,El placeholder nos retorna el propio modelo, cual es el modelo
       que usaremos de nuestro widget ?
    */
    func placeholder(in context: Context) -> Modelo {
        //Retornamos nuestro modelo
        //Paso 1.15,llenamos nuestro data con el array
        return Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 2))
        // return Modelo(date: Date() , mensaje:"")
    }
    
    /* Paso 1.4,Nos da el tipo de dato que nos dará el widget */
    func getSnapshot(in context: Context, completion: @escaping (Modelo) -> Void) {
        //Vid 143
        completion(Modelo(date: Date(), widgetData: Array(repeating: JsonData(id: 0, name: "", email: ""), count: 2)))
        //completion (Modelo(date: Date(), mensaje:""))
    }
    
    //Aqui es donde va la lógica de nuestro widget
    /* Paso 1.5,Este es el más importante , ya que van los datos que llenaremos que van en el widget */
    func getTimeline(in context: Context, completion: @escaping (Timeline<Modelo>) -> Void) {
        
        //Paso 1.6,Policy es la forma que se actualizara el widget
        //completion (Timeline(entries: [entry], policy: .never))
        
        //Paso 1.17
        //En model data viene todo lo que en el comletation estamos arrojando que viene en el json
        getJson { (modelData) in
            let data = Modelo(date: Date(), widgetData: modelData)
            /*
              Paso 1.18,Para actualizar nuestro widget, cambiara cada 30 min
              by adding le decimos cada cuanto que cambie
            */
            guard let update = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) else { return }
            let timeline = Timeline(entries: [data], policy: .after(update))
            //El cpmpletation es como un return por eso le ponemos timeline
            completion(timeline)
        }
        
        /*
          Paso 1.7
          Es una conexcion entre el modelo y la vista y la parte de configuración
          es el puente entre las diferentes estructuras
        */
        typealias Entry = Modelo
        
    }
    
    //Paso 1.16, función para traer nuestro json
    func getJson(completion: @escaping ([JsonData]) -> ()){
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments?postId=1") else { return  }
        
        URLSession.shared.dataTask(with: url){data,_,_ in
            
            guard let data = data else { return }
            
            do{
                let json = try JSONDecoder().decode([JsonData].self, from: data)
                DispatchQueue.main.async {
                    //Enviamos el completation
                    completion(json)
                }
            }catch let error as NSError {
                print("fallo", error.localizedDescription)
            }
            
        }.resume()
    }
    
    /*-------------------------------------------------------------------------------------------------------*/
    //DISEÑO - VISTA
    
    struct vista: View {
        //Hacemos la conexion con el entry para poder acceder a los datos del modelo
        let entry : Provider.Entry
        //V-142,paso 2.1,mandamos a llamar los diferentes tamaños
        @Environment(\.widgetFamily) var family
        
        //Para que nos agarre los 3 tamaños diferentes
        @ViewBuilder
        var body: some View{
            //Paso 1.8
            //Text(entry.mensaje)
            //Paso 1.19,creamos una lista ysaldra un circulo amarillo de que no se puede,list no es soportado
            /*List (entry.widgetData, id: \.id){ item in
             Text(item.name)
             Text(item.email)
             }*/
            /*
             //Paso 1.19
             VStack(alignment: .center){
             Text("Mi Lista").font(.title).bold()
             ForEach(entry.widgetData, id:\.id){ item in
             Text(item.name).bold()
             Text(item.email)
             }
             }*/
            
            //paso 2.2, un switch para que nos salga los 3 tipos de widgets
            switch family {
                //V-143,Paso 2.3,Para tener los 3 tamaños
            case .systemSmall:
                //Paso 2.4
                VStack(alignment: .center){
                    Text("Mi Lista")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                    Spacer()
                    Text(String(entry.widgetData.count)).font(.custom("Arial", size: 80)).bold()
                    Spacer()
                }
                //Paso 2.5
            case .systemMedium:
                VStack(alignment: .center){
                    Text("Mi Lista")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                    Spacer()
                    VStack(alignment: .leading){
                        //traeremos los dos primeros registros
                        Text(entry.widgetData[0].name).bold()
                        Text(entry.widgetData[0].email)
                        Text(entry.widgetData[1].name).bold()
                        Text(entry.widgetData[1].email)
                    }.padding(.leading)
                    Spacer()
                }
            default:
                VStack(alignment: .center){
                    Text("Mi Lista")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                    Spacer()
                    VStack(alignment: .leading){
                        ForEach(entry.widgetData, id:\.id){ item in
                            Text(item.name).bold()
                            Text(item.email)
                        }
                    }.padding(.leading)
                    Spacer()
                }
            }
            
        }
    }
    /*-------------------------------------------------------------------------------------------------------*/
    
    //CONFIGURACION
    /* Paso 1.9,Aqui vemos el diseño */
    //Main es lo primeto que debe ejecutar
    @main
    struct HelloWidget: Widget {
        
        var body: some WidgetConfiguration{
            //Paso 1.10 ,kind es el identificador de nuestro widget y el provider es el que definimos nosotros
            StaticConfiguration(kind: "widget", provider: Provider()) { entry in
                //Paso 1.11,traemos la vista
                vista(entry: entry)
                    
            }
            .description("descripcion del widget")
            .configurationDisplayName("nombre widget")
            //Paso 1.12,tamaño del widget , los 3 tamaños
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
            //.supportedFamilies([.systemLarge])
        }
    }
}

