//
//  TimecodeTests.swift
//  Slider ControlTests
//
//  Created by Franek on 28/03/2020.
//  Copyright © 2020 Frankie. All rights reserved.
//

import XCTest
@testable import Slider_Control

class TimecodeTests: XCTestCase {

    var sut: Timecode!
    
    override func setUp() {
        super.setUp()
        
        
    }

    override func tearDown() {
        super.tearDown()
        
    }
    
    func testInitFrames(){
        sut = Timecode(frames: 1465)
        
        // Check minutes
        XCTAssertEqual(sut.min, 1, "Minutes are not equal")
        
        // Check seconds
        XCTAssertEqual(sut.sec, 1, "Seconds are not equal")
        
        // Check frames
        XCTAssertEqual(sut.frame, 1, "Frames are not equal")
    }
    
    func testTotalFrames(){
        sut = Timecode(frames: 1465)
        
        // Check total frames
        XCTAssertEqual(sut.totalFrames, 1465, "Total frames are not equal")
    }
    
    func testChangingFPS(){
        Timecode.FPS = 25
        sut = Timecode(min: 1, sec: 1, frame: 1)
        XCTAssertEqual(sut.totalFrames, 1526, "Total frames not eqaul after changing FPS")
    }
    
    //func test
    

  

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
