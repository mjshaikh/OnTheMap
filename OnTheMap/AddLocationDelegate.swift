//
//  AddLocationDelegate.swift
//  OnTheMap
//
//  Created by Mohammed Javeed Shaikh on 2016-05-06.
//  Copyright © 2016 Mohammed Javeed Shaikh. All rights reserved.
//

import Foundation

/* AddLocationDelegate protocol that will implemented by Table and Map View Controllers to update data */

protocol AddLocationDelegate {
    
    func refreshLocations()
}