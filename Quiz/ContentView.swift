//
//  ContentView.swift
//  Quiz
//
//  Created by Robert Wiebe on 10.05.21.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

class quiz: ObservableObject {
    @Published var questions = ["Was sollte man in der sechsten Klasse beherrschen?", "Wie viele Google-Konten hat Ulrich Wiebe?"]
    @Published var answers = [["Afrika", "den Weitsprung", "what the hell", "such impressed"], ["4", "5", "6", "7"]]
    @Published var solutions: [Int] = [3, 1]
    @Published var currentQuestion: Int = 0
    @Published var editIsPresented: Bool = false
    @Published var editOffset = CGFloat(707)
    @Published var backgroundBlurry: Bool = false
    
}

struct ContentView: View {
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .green
        UIView.appearance().isMultipleTouchEnabled = false
        UIView.appearance().isExclusiveTouch = true
    }
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    let questionColor = Color(red: 29/255, green: 70/255, blue: 173/255)
    let answerColor = Color(red: 173/255, green: 127/255, blue: 12/255)
    
    @State private var anscolors: [Color] = [.blue, .blue, .blue, .blue]
//    @State private var currentQuestion: Int = 0
    @State private var points: Int = 0
//    @State public var questions = ["Was sollte man in der sechsten Klasse beherrschen?", "Wie viele Google-Konten hat Ulrich Wiebe?"]
//    @State public var answers = [["Afrika", "den Weitsprung", "what the hell", "such impressed"], ["4", "5", "6", "7"]]
//    @State public var solutions: [Int] = [3, 1]
//    @State private var editIsPresented = false
    @State private var reachedEnd = false
    @State private var takingInput = true
    @State private var checkPlaying = false
//    @ObservedObject var quizControl: quiz
    @StateObject var quizControl = quiz()
    //@State var barState: CGFloat = .zero
    
    
    var body: some View {
//        NavigationView {
            ZStack {
                
                Image("gold")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: quizControl.backgroundBlurry ? 10 : 0)
                    .edgesIgnoringSafeArea(.all)
                
                
                
                
                VStack(spacing:30){
                    ZStack {
                        Circle()
                            .foregroundColor(questionColor)
                            .frame(width: 90, height:90)
                            .padding(.bottom, -25)
                            .padding(.top, 20)
                            .overlay(
                                Text("?")
                                    .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.blue)
                                    .padding(.top, 40)
                            )
                        Circle()
                            .trim(from: 0.0, to: CGFloat(reachedEnd ? 1 : Double(quizControl.currentQuestion+1)*1/3))
                            .stroke(Color.green, style:StrokeStyle(lineWidth: reachedEnd ? 2 : 10, lineCap: .round))
                            .frame(width: 100, height: 100)
                            .scaleEffect(reachedEnd ? 1.42 : 1)
                            .rotationEffect(.degrees(-90))
                            .padding(.bottom, -25)
                            .padding(.top, 20)
                            .offset(x: reachedEnd ? 500 : 0, y: reachedEnd ? 268 : 0)
                    }
                        
                        
                    
                    
                    Text("Frage " + String(quizControl.currentQuestion + 1))
                        .font(.system(size: 55, weight: .heavy, design: .default))
                        .foregroundColor(questionColor)
                        .shadow(radius: 30)
                        .transition(.opacity)
                        .id("Frage" + String(quizControl.currentQuestion))
                        
                        
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height:150)
                        .foregroundColor(questionColor)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .overlay(
                            Text(quizControl.questions[quizControl.currentQuestion])
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .transition(.opacity)
                                .id("question" + quizControl.questions[quizControl.currentQuestion])
                                .multilineTextAlignment(.center)
                        )
                        
                    VStack(spacing:10){
                        ForEach((0...3), id: \.self) { i in
                            Button(action: {
                                self.takingInput = false
                                playFeedbackHaptic(hapticStyle)
                                anscolors[i] = (quizControl.solutions[quizControl.currentQuestion] == i) ? .green : .red
                                points += (quizControl.solutions[quizControl.currentQuestion] == i) ? 1 : 0
                                playSound(sound: (quizControl.solutions[quizControl.currentQuestion] == i) ? "correct" : "incorrect", type: "mp3")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation(.easeInOut) {
                                        nextQuestion()
                                    }
                                }
                            }, label: {
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(height:70)
                                    .foregroundColor(anscolors[i])
                                    .overlay(Text(quizControl.answers[quizControl.currentQuestion][i])
                                                .font(.title)
                                                .foregroundColor(.black)
                                                .transition(.opacity)
                                                .id("answer" + quizControl.answers[quizControl.currentQuestion][i])
                                    )
                                    //.animation(.default)
                            }).disabled(!takingInput)
                        }
                    }
                }.padding(.horizontal, 30)
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                .offset(x: reachedEnd ? -500 : 0, y: -50)
                
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                //End Screen
                VStack(spacing: 5) {
                    if checkPlaying {
                        CheckView()
                    }
                    Text("\(points) von \(quizControl.questions.count) Punkten!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("Herzlichen Glückwunsch!")
                        .foregroundColor(.white)
                    
                    Button(action: {
                        playFeedbackHaptic(.rigid)
                        quizControl.currentQuestion = 0
                        anscolors = [.blue, .blue, .blue, .blue]
                        takingInput = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            withAnimation {
                                reachedEnd = false

                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                checkPlaying = false
                                points = 0
                            }
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width:200, height:50)
                            .foregroundColor(questionColor.opacity(0.8))
                            .overlay(
                                Text("Neustart")
                                    .foregroundColor(Color.white)
                            )
                            .padding(.top, 15)
                    })
                }
                .shadow(radius: 10)
                .offset(x: reachedEnd ? 0 : 500)
                
                editView(quizControl: self.quizControl)
                    .offset(y: quizControl.editOffset)
                
            }
        
            //.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//            .navigationTitle("Mini-Quiz")
//        }
    }
    
    func playFeedbackHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    
    func nextQuestion() {
        if quizControl.currentQuestion < quizControl.questions.count - 1 {
            withAnimation {
                quizControl.currentQuestion += 1
                anscolors = [.blue, .blue, .blue, .blue]
            }
            self.takingInput = true
        }
        
        else {
            self.checkPlaying = true
            playSound(sound: "success", type: "mp3")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                withAnimation {
                    self.reachedEnd = true
                }
            })
            
        }
    }
    
    
    
}


struct editView: View {
    
    @ObservedObject var quizControl: quiz
    let questionColor = Color(red: 29/255, green: 70/255, blue: 173/255)
    
    var body: some View {
//        NavigationView {
        VStack(spacing: 0) {
                VisualEffectView(style: .systemUltraThinMaterialLight)
                    .frame(height: 90)
                    .cornerRadius(5)
                    .overlay(
                        HStack{
                            RoundedRectangle(cornerRadius: 5)
                                .aspectRatio(1, contentMode: .fit)
                                .padding(8)
                                .foregroundColor(questionColor)
                                .overlay(Text("?").font(.largeTitle).bold().foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/))
                            VStack(alignment: .leading) {
                                Text("Standard-Quiz")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                                Text("Frage \(quizControl.currentQuestion + 1) von \(quizControl.questions.count)")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                            Spacer()
                            
//                            Button(action: {withAnimation(Animation.spring()){quizControl.editIsPresented.toggle()}}, label: {
//                                Image(systemName: "square.and.pencil")
//                                    .font(.title)
//                                    .foregroundColor(questionColor)
//                            })
                        }.padding(.bottom)
                        .padding(.horizontal, 38)
                    )
                    .if(!quizControl.editIsPresented) { view in
                        view.onTapGesture {
                            quizControl.editIsPresented = true
                            withAnimation(Animation.spring(blendDuration: 0.5)){
                                                            quizControl.editOffset = 10
                                quizControl.backgroundBlurry = true
                                                        
                                                        print("Button pressed")
                                                    }
                        }
                    }
                    .if(quizControl.editIsPresented) { view in
                        view.gesture(
                            DragGesture()
                                .onChanged { amount in
                                    if quizControl.editIsPresented {
                                        withAnimation(.spring()) {
                                            quizControl.editOffset = CGFloat(10) + amount.translation.height
                                        }
                                    }
                                }
                                .onEnded{ amount in
                                    print("Gesture ended!")
                                    if quizControl.editOffset > 100 {
                                        quizControl.editIsPresented = false
                                        print("was bigger than")
                                        withAnimation(.spring()) {
                                            quizControl.editOffset = CGFloat(707)
                                            quizControl.backgroundBlurry = false
                                        }
                                        
                                        
                                    }
                                    else {
                                        print("was smaller than")
                                        withAnimation(.spring()) {
                                            quizControl.editOffset = CGFloat(10)
                                        }
                                    }
                                }
                        )
                    }
                List {
                    ForEach(0...quizControl.questions.count-1, id: \.self) { i in
                        GroupBox {
                            TextField("Frage " + String(i+1), text: $quizControl.questions[i])
                                .keyboardType(/*@START_MENU_TOKEN@*/.default/*@END_MENU_TOKEN@*/)
                            ForEach(0...3, id: \.self) { j in
                                TextField("Möglichkeit " + String(j+1), text: $quizControl.answers[i][j])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            Picker(selection: $quizControl.solutions[i], label: Text("Richtige Antwort festlegen"), content: {
                                createLabel(i: i, j: 3)
                                createLabel(i: i, j: 2)
                                createLabel(i: i, j: 1)
                                createLabel(i: i, j: 0)
                                }).pickerStyle(MenuPickerStyle()
                            )
                            

                        }.padding(.horizontal)
                    }.onDelete(perform: removeRows)
                    
                    
                    Button(action: {
                        quizControl.questions.append("")
                        quizControl.answers.append(["", "", "", ""])
                        quizControl.solutions.append(0)
    //                    print(questions, answers)
                    }, label: {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(height: 50)
                            .padding(.horizontal, 50)
                            .foregroundColor(.blue)
                            .overlay(
                                Label("Frage hinzufügen", systemImage: "plus.app.fill")
                                    .foregroundColor(.white)
                            )
                    })
                }
//                .frame(height:690)
//                .navigationTitle("Quiz bearbeiten")
//                .navigationBarItems(leading: EditButton())
                
                
                
        }.frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 400, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 700, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
//        }.navigationBarTitleDisplayMode(.inline)
    }
    
    func removeRows(at offsets: IndexSet) {
        quizControl.questions.remove(atOffsets: offsets)
        quizControl.answers.remove(atOffsets: offsets)
        quizControl.solutions.remove(atOffsets: offsets)
        print(quizControl.questions, quizControl.answers, quizControl.solutions)
    }
    
    func createLabel(i: Int, j: Int) -> some View {
        let letters = ["A: ", "B: ", "C: ", "D: "]
        let answer = quizControl.answers[i][j]
        let combined = letters[j] + answer
        return Text(combined).tag(j)
    }
    
}


struct VisualEffectView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

