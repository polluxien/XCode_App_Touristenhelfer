//
//  ContentView.swift
//  Touristenhelfer
//
//  Created by Bennet Panzek on 13.01.24.
//

import SwiftUI
import MapKit
import CoreLocation
import AVFoundation

struct eventButtoons {
    var name: String
    var icon: String
    var pressed: Bool
    
    init(_ name: String, _ icon: String, _ pressed: Bool) {
        self.name = name
        self.icon = icon
        self.pressed = pressed
    }
}


struct ContentView: View {
    
    @State var catLocations: [MKPointAnnotation] = []
    @ObservedObject var locationService = LocationService.shared
    @State var aktuelleSuche: eventButtoons?
    
    @State var buttonIdPressed: Int = -1;
    @State var buttonArr = [
        eventButtoons("Park", "tree.fill", false),
        eventButtoons("Geldautomat", "creditcard.fill", false),
        eventButtoons("Shoping", "bag.fill", false),
        eventButtoons("Museum", "fossil.shell.fill", false)]
    
    var greenColor = Color(red: 0.5, green: 0.8, blue: 0.4)
    
    func getThemSpots(suchWort: String){
        let suchRadius = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let suchRegion = MKCoordinateRegion(center: getUserLocation(), span: suchRadius)
        
        let suchAnfrage = MKLocalSearch.Request()
        suchAnfrage.region = suchRegion
        suchAnfrage.resultTypes = .pointOfInterest
        suchAnfrage.naturalLanguageQuery = suchWort
        
        let suche = MKLocalSearch(request: suchAnfrage)
        
        suche.start { antwort,error  in
            print(antwort ?? "Fehler")
            if let antwort = antwort{
                self.catLocations = antwort.mapItems.map { location in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.placemark.coordinate
                    annotation.title = location.name
                    return annotation
                }
            }
        }
    }
    
    func getUserLocation() -> CLLocationCoordinate2D{
        if let lastLocation = locationService.locationManager.location?.coordinate {
            let latitude = lastLocation.latitude
            let longitude = lastLocation.longitude
            print("Latitude: \(latitude), Longitude: \(longitude)")
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        print("Default Standort: Berlin, App muss beim ersten mal neu gestartet werden")
        return CLLocationCoordinate2D(latitude: 52.503472, longitude: 13.348305)
    }
    
    func darstellendeFarbe(_ button: eventButtoons) -> Color{
        if(button.pressed){
            return greenColor
        }
        return Color(.white)
    }
    
    var body: some View {
            ZStack{
                Map(){
                    Annotation("Mein Standort", coordinate: getUserLocation(), anchor: .bottom){
                        ZStack{
                            Circle()
                                .foregroundColor(.orange)
                                .frame(width: 40)
                            Image(systemName: "car")
                                .padding(5)
                                .foregroundColor(.white)
                        }
                    }
                    
                    //Hier werden die Parks angezeigt
                    
                    ForEach(catLocations.indices, id: \.self) { locationIndex in
                        Annotation(aktuelleSuche?.name ?? "nothing", coordinate: catLocations[locationIndex].coordinate, anchor: .bottom){
                            ZStack{
                                Circle()
                                    .foregroundColor(greenColor)
                                    .frame(width: 40)
                                Image(systemName: aktuelleSuche?.icon ?? "nothing")
                                    .padding(5)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        
                    }
                }
                .onAppear {
                    locationService.requestPermissionToAcessLocation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapScaleView()
                    MapCompass()
                        .mapControlVisibility(.visible)
                }
                .mapStyle(.hybrid)
                .tabViewStyle(.page)
                .background(.white)
                
            VStack{
                Text("Kategorien")
                    .font(.headline)
                    
                    .padding()
                HStack {
                    ForEach(0..<buttonArr.count, id: \.self) { i in
                        Button(action: {
                            print("Action vom button wird asugeführt")
                            if(buttonIdPressed != -1) {
                                buttonArr[buttonIdPressed].pressed.toggle()
                            }
                            if(buttonIdPressed != i){
                                if(!catLocations.isEmpty){
                                    catLocations.removeAll()
                                }
                                aktuelleSuche = buttonArr[i]
                                getThemSpots(suchWort: buttonArr[i].name)
                            }
                            buttonArr[i].pressed.toggle()
                            buttonIdPressed = i
                        }) {
                            Image(systemName: buttonArr[i].icon)
                                .padding(.horizontal)
                                .padding(.vertical)
                        }
                        .frame(width: 50, height: 50)
                        .padding(.horizontal)
                        .padding(.vertical)
                        .foregroundColor(darstellendeFarbe(buttonArr[i]))
               //         .background(darstellendeFarbe(buttonArr[i]))
                        .border(darstellendeFarbe(buttonArr[i]), width: 5)
                    }
                }
            }
            .frame(width: 800, height: 150)
            .foregroundColor(.white)
            .background(Color(red: 0.45 ,green: 0.5, blue: 0.5) .opacity(0.65))
            .offset(y: 320)
        }
    }
}

#Preview {
    ContentView()
}
