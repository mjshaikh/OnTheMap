//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-04-30.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}