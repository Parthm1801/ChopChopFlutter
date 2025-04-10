//
//  IOS_WidgetBundle.swift
//  IOS_Widget
//
//  Created by Parth Maheshwari on 07/04/25.
//

import WidgetKit
import SwiftUI

@main
struct IOS_WidgetBundle: WidgetBundle {
    var body: some Widget {
        IOS_Widget()
        IOS_WidgetControl()
        IOS_WidgetLiveActivity()
    }
}
