import SwiftUI

struct StatusBar: View {
    let isOnline: Bool
    @State private var isVisible = false
    
    var body: some View {
        HStack {
            Image(systemName: isOnline ? "wifi" : "wifi.slash")
                .foregroundColor(isOnline ? .green : .red)
                .font(.system(size: 16, weight: .medium))
            Text(isOnline ? "Connected" : "Offline")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(isOnline ? .green : .red)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground).opacity(0.8))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .offset(y: isVisible ? 0 : -100)
        .animation(.easeInOut(duration: 0.5), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct ColorCard: View {
    let hexCode: String
    let timestamp: Date
    @State private var isTapped = false
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color(hex: hexCode))
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(hexCode.uppercased())
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                Text(timestamp, style: .date)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                .shadow(color: Color.white.opacity(0.7), radius: 5, x: -5, y: -5)
        )
        .scaleEffect(isTapped ? 0.95 : isHovered ? 1.02 : 1.0)
        .rotationEffect(.degrees(isTapped ? 2 : 0))
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isTapped)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onTapGesture {
            withAnimation {
                isTapped = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isTapped = false
                }
            }
        }
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.indigo, Color.pink]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ColorViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color.indigo.opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    StatusBar(isOnline: viewModel.isOnline)
                    
                    Button("Generate Color") {
                        withAnimation(.spring()) {
                            viewModel.generateColor()
                        }
                    }
                    .buttonStyle(CustomButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    List {
                        ForEach(viewModel.colors) { color in
                            ColorCard(
                                hexCode: color.hexCode ?? "",
                                timestamp: color.timestamp ?? Date()
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
                .navigationTitle("HueVault")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
