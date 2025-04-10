import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FlutterEntry {
        FlutterEntry(date: Date(), widgetData: WidgetData(text: "ChopChop Pardner!"))
    }

    func getSnapshot(in context: Context, completion: @escaping (FlutterEntry) -> ()) {
        let entry = FlutterEntry(date: Date(), widgetData: WidgetData(text: "ChopChop Pardner!"))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FlutterEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.parth.flutterWidgetTest")
        print("📢 Widget timeline requested at \(Date())")
        var widgetData: WidgetData? = nil
        if let jsonString = sharedDefaults?.string(forKey: "widgetData") {
            print("✅ Widget received raw JSON: \(jsonString)")
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    widgetData = try JSONDecoder().decode(WidgetData.self, from: jsonData)
                    print("✅ Widget decoded text: \(widgetData!.text)")
                } catch {
                    print("❌ Widget failed to decode: \(error)")
                }
            }
        } else {
            print("❌ No data found in UserDefaults")
        }

        let entry = FlutterEntry(date: Date(), widgetData: widgetData)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct WidgetData: Decodable, Hashable {
    let text: String
}

struct FlutterEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData?
}

struct GradientText: View {
    let text: String

    var body: some View {
        LinearGradient(
            colors: [Color(red: 138/255, green: 79/255, blue: 255/255), Color(red: 255/255, green: 143/255, blue: 113/255)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(
            Text(text)
                // .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                // .lineLimit(3)
                // .padding(.horizontal)
        )
    }
}

struct FlutterIOSWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                // Full size container
                VStack {
                    Spacer(minLength: 0)

                    GradientText(text: entry.widgetData?.text ?? "Tap to set message.")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        // .multilineTextAlignment(.center)
                        // .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: false)
                        .layoutPriority(1)
                        // .minimumScaleFactor(0.5)s
                        // .padding(.horizontal, 12)

                    Spacer(minLength: 0)
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // 🔄 Refresh Button
                Link(destination: URL(string: "chopchopai://refresh")!) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 138/255, green: 79/255, blue: 255/255),
                                             Color(red: 255/255, green: 143/255, blue: 113/255)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 16, height: 15)

                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(8)
                }
            }
        }
    }
}




struct FlutterIOSWidget: Widget {
    let kind: String = "FlutterIOSWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlutterIOSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ChopChop Pardner!")
        .description("Tap refresh to stay motivated!")
    }
}
