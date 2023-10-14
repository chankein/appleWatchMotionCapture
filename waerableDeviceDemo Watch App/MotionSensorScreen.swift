//
//  MotionSensorScreen.swift
//  waerableDeviceDemo Watch App
//
//  Created by kein chan on 2023/10/09.
//

import SwiftUI
import Foundation


struct MotionSensorScreen: View {
    @ObservedObject var sensor = MotionSensor()
    
    var body: some View {
        
            VStack(spacing: 0){
                HStack {
                    Image(systemName: "figure.walk")
                    Text("\(sensor.stepCount)")
                    Spacer()
                }
                .offset(x: 0,y: -25)
                Button(action: {
                    sensor.isStarted ? sensor.stop() : sensor.start()
                }) {
                    ZStack() {
                        StartBottunBackGround()
                        Text(sensor.isStarted ? "終了" : "開始")
                            .font(Font.custom("Manrope", size: 24).weight(.bold))
                            .foregroundColor(Color(red: 0.97, green: 0.97, blue: 0.97))
                    }
                    
                    //Text(sensor.isStarted ? "記録停止" : "記録開始")
                    
                }
                .offset(x: 0,y: -10)
                .frame(width: 100, height: 100)
                .buttonStyle(PlainButtonStyle())
                .onReceive(sensor.$stepCount, perform: { newValue in
                    print("View received stepCount: \(newValue)")
                })
                
                HStack{
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().frame(width: 24).foregroundColor(Color("DarkGray")))
                    
                    Text("\(sensor.elapsedTimeString)")
                    
                    Image(systemName: "square.and.arrow.up.fill").font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().frame(width: 24).foregroundColor(Color("DarkGray")))
                }
                HStack {
                    Image(systemName: "heart")
                    Text("\(sensor.heartRate) BPM")
                    Spacer()
                    Image(systemName: "flame")
                    Text("\(sensor.calories) kcal")
                }
                .foregroundColor(.accentColor)
                //.offset(x: 0,y: 15)
            }
            //.sheet(isPresented: sensor.isStarted) {
            //}

          
    }
}

struct TimingView: View {
    @ObservedObject var sensor = MotionSensor()
  var body: some View {
      VStack {
          HStack{
              Spacer()
              VStack {
              Text("加速度")
                .font(.system(size: 14))
                .foregroundColor(Color(.white))
              Text("x: \(sensor.acceX) \ny: \(sensor.acceY) \nz: \(sensor.acceZ)")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.79, green: 0.79, blue: 0.79))
                .multilineTextAlignment(.leading)
          }.frame(width: 70, height: 70)
                  .overlay(
                    RoundedRectangle(cornerRadius: 10)
                      .inset(by: 1)
                      .stroke(Color(red: 1, green: 0.56, blue: 0.24), lineWidth: 1)
                  )
              Spacer()
              VStack {
                  Text("回転速度")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.white))
                  Text("x: \(sensor.rotX) \ny: \(sensor.rotY) \nz: \(sensor.rotZ)")
                    .font(Font.custom("Manrope", size: 12))
                    .foregroundColor(Color(red: 0.79, green: 0.79, blue: 0.79))
                    .multilineTextAlignment(.leading)
              }
              .frame(width: 70, height: 70)
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .inset(by: 1)
                  .stroke(Color(red: 1, green: 0.56, blue: 0.24), lineWidth: 1)
              )
              Spacer()
            }
          HStack{ZStack() {
              Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 85, height: 30)
                  .background(Color(red: 1, green: 0.56, blue: 0.24))
                  .cornerRadius(25)
                  .offset(x: 0, y: 0)
              Text(sensor.isStarted ? "終了" : "開始")
                  .font(.system(size: 20))
                  .foregroundColor(.white)
          }
          //.frame(width: 125, height: 52)
          }
          HStack{
              Image(systemName: "figure.walk")
              Text("\(sensor.stepCount)")
              Spacer()
              Image(systemName: "clock")
              Text("Time: \(sensor.elapsedTimeString)")
          }
          .overlay(
            Divider()
            .background(.white)
            .offset(y: 10)
          )
          .frame(width: .infinity)
          
          HStack {
              Image(systemName: "heart")
              Text("\(sensor.heartRate) BPM")
              Spacer()
              Image(systemName: "flame")
              Text("\(sensor.calories) kcal")
          }
          .foregroundColor(.accentColor)
          .frame(width: .infinity)
      }
  }
}


struct StartBottunBackGround: View {
    var body: some View {
        ZStack {
            Circle().foregroundColor(Color("DarkRed")).frame(width: 105)
            Circle().foregroundColor(Color("MiddleRed")).frame(width: 85)
            Circle()
                .foregroundColor(.accentColor).frame(width: 70)
        }
    }
}

#Preview {
    MotionSensorScreen()
    //TimingView()
}
