//
//  YADLSpotAssessmentStep.swift
//  Pods
//
//  Created by James Kizer on 5/2/16.
//
//

import UIKit

class YADLSpotAssessmentStep: RKXMultipleImageSelectionSurveyStep {

    override func stepViewControllerClass() -> AnyClass {
        return YADLSpotAssessmentStepViewController.self
    }
    
}