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
    @State private var showTimePicker = false
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60*60)
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 0){
            if !sensor.isStarted {
                steps
            } else {
                accAndRot
            }
            
            startAndStop.animation(.easeInOut)
                
            if !sensor.isStarted {
                settingAndUpload
            } else{
                stepsAndTiming
            }
            GradientDivider()
            heartRateAndCalories
            GradientDivider()
        }.animation(.easeInOut, value: sensor.isStarted)
    }
}

extension MotionSensorScreen {
    private var steps: some View {
        HStack {
            Image(systemName: "figure.walk")
            Text("\(sensor.stepCount)")
            Spacer()
        }
        .offset(x: 10,y: -27)
    }
    
    private var accAndRot: some View {
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
            }
            .frame(width: 70, height: 70)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .inset(by: 1)
                .stroke(Color.accentColor, lineWidth: 1)
            )
            Spacer()
            VStack {
                Text("回転速度")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.white))
                Text("x: \(sensor.rotX) \ny: \(sensor.rotY) \nz: \(sensor.rotZ)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.79, green: 0.79, blue: 0.79))
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 70, height: 70)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .inset(by: 1)
                .stroke(Color.accentColor, lineWidth: 1)
            )
            Spacer()
          }
    }
    
    private var startAndStop: some View {
        Group {
            if sensor.isStarted {
                // 当已开始，显示这个按钮样式
                Button(action: {
                    sensor.stop()
                }) {
                    HStack{
                        ZStack {
                            Rectangle()
                                .foregroundColor(.accentColor)
                                .frame(width: 85, height: 30)
                                .cornerRadius(25)
                            Text("終了")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }.frame(width: 100, height: 45)
                            .offset(y: 10)
                    }
                }
            } else {
                // 当未开始，显示这个按钮样式
                Button(action: {
                    sensor.start()
                }) {
                    ZStack {
                        StartBottunBackGround()
                        Text("開始")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                    }
                    .frame(width: 100, height: 100)
                }
            }
        }
        .offset(x: 0, y: -10)
        .buttonStyle(PlainButtonStyle())
    }

    
    private var settingAndUpload: some View {
        HStack{
            Button(action: {
                showTimePicker = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().frame(width: 28).foregroundColor(Color("DarkGray")))
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showTimePicker) {
                TimePickerView(showPicker: $showTimePicker, startDate: $startDate, endDate: $endDate)
            }
            
            Text("\(sensor.elapsedTimeString)")
            
            Button(action: handleUploadAction) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().frame(width: 28).foregroundColor(Color("DarkGray")))
            }
            .buttonStyle(PlainButtonStyle())
            .alert(isPresented: $showAlert) {
                Alert(title: Text("alart"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }


        }
    }
    
    private var stepsAndTiming: some View {
        HStack{
            Image(systemName: "figure.walk")
            Text("\(sensor.stepCount)")
            Spacer()
            Image(systemName: "clock")
            Text("\(sensor.elapsedTimeString)")
        }
        .padding(.vertical, 3)
        /*
        .overlay(
          Divider()
          .background(.white)
          .offset(y: 14)
        )
        .frame(width: .infinity)*/
    }
    
    private var heartRateAndCalories: some View {
        HStack {
            Image(systemName: "heart")
            Text("\(sensor.heartRate) BPM")
            Spacer()
            Image(systemName: "flame")
            Text("\(sensor.calories) kcal")
        }
        .padding(.vertical, 3)
        .foregroundColor(.accentColor)
        
    }
    
    func handleUploadAction() {
            sensor.uploadDataToAPI { (success, error) in
                if success {
                    showAlert = true
                    alertMessage = "アップロード成功!"
                } else if let error = error {
                    showAlert = true
                    alertMessage = "アップロード失敗: \(error.localizedDescription)"
                }
            }
        }
}

struct StartBottunBackGround: View {
    var body: some View {
        ZStack {
            Circle().foregroundColor(Color("DarkRed")).frame(width: 105)
            Circle().foregroundColor(Color("MiddleRed")).frame(width: 85)
            Circle().foregroundColor(.accentColor).frame(width: 70)
        }
    }
}

struct TimePickerView: View {
    @Binding var showPicker: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack() {
            DatePicker("开始时间", selection: $startDate, displayedComponents: .hourAndMinute)
            DatePicker("结束时间", selection: $endDate, displayedComponents: .hourAndMinute)
            Button("完成") {
                showPicker = false
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 100,height: 40)
        }
        .padding()
    }
}

struct GradientDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .darkGray,
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}


#Preview {
    MotionSensorScreen()
}
