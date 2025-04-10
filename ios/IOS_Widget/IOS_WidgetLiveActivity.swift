//
//  IOS_WidgetLiveActivity.swift
//  IOS_Widget
//
//  Created by Parth Maheshwari on 07/04/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct IOS_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct IOS_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IOS_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension IOS_WidgetAttributes {
    fileprivate static var preview: IOS_WidgetAttributes {
        IOS_WidgetAttributes(name: "World")
    }
}

extension IOS_WidgetAttributes.ContentState {
    fileprivate static var smiley: IOS_WidgetAttributes.ContentState {
        IOS_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: IOS_WidgetAttributes.ContentState {
         IOS_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: IOS_WidgetAttributes.preview) {
   IOS_WidgetLiveActivity()
} contentStates: {
    IOS_WidgetAttributes.ContentState.smiley
    IOS_WidgetAttributes.ContentState.starEyes
}
