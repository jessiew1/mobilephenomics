import SwiftUI

struct ContentView: View {
    @ObservedObject var controller: MonitoringController
    @Binding var isRunning: Bool

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Circle()
                        .fill(controller.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(controller.isConnected ? "MQTT Connected" : "MQTT Disconnected")
                        .font(.headline)
                }
                HStack {
                    Text("Sent: \(controller.sentCount)")
                    Text("Queued: \(controller.queuedCount)")
                }
                Toggle(isOn: $isRunning) {
                    Text(isRunning ? "Monitoring active" : "Monitoring stopped")
                }
                .onChange(of: isRunning) { _, newValue in
                    if newValue {
                        controller.start()
                    } else {
                        controller.stop()
                    }
                }
                .onAppear {
                    controller.start()
                }
                List(controller.recentEvents, id: \.id) { event in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(event.category.rawValue.uppercased()).font(.caption).bold()
                            Text(event.severity.rawValue.capitalized)
                                .font(.caption)
                                .foregroundColor(event.severity == .critical ? .red : .primary)
                        }
                        Text(event.message).font(.body)
                        Text(event.timestamp, style: .time).font(.caption)
                    }
                }
            }
            .padding()
            .navigationTitle("Base44 EFB IDS")
        }
    }
}
