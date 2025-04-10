import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FlutterEntry {
        FlutterEntry(date: Date(), widgetData: WidgetData(text: "Flutter iOS widget!"))
    }

    func getSnapshot(in context: Context, completion: @escaping (FlutterEntry) -> ()) {
        let entry = FlutterEntry(date: Date(), widgetData: WidgetData(text: "Flutter iOS widget!"))
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

struct FlutterIOSWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                ZStack {
                    Text(entry.widgetData?.text ?? "Tap to set message.")
                        .padding()
                }
                .containerBackground(for: .widget) {
                    Color.clear
                }
            } else {
                ZStack {
                    Text(entry.widgetData?.text ?? "Tap to set message.")
                        .padding()
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
        .configurationDisplayName("Flutter iOS Widget")
        .description("This is an example Flutter iOS widget.")
    }
}
