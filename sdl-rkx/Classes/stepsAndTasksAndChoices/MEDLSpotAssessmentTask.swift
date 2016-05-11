//
//  MEDLSpotAssessmentTask.swift
//  Pods
//
//  Created by James Kizer on 5/6/16.
//
//

import UIKit
import ResearchKit

public class MEDLSpotAssessmentTask: RKXMultipleImageSelectionSurveyTask {

    convenience public init(identifier: String, propertiesFileName: String, itemIdentifiers: [String]? = nil) {
        
        guard let filePath = NSBundle.mainBundle().pathForResource(propertiesFileName, ofType: "json")
            else {
                fatalError("Unable to location file with YADL Spot Assessment Section in main bundle")
        }
        
        guard let fileContent = NSData(contentsOfFile: filePath)
            else {
                fatalError("Unable to create NSData with file content (YADL Spot Assessment data)")
        }
        
        let spotAssessmentParameters = try! NSJSONSerialization.JSONObjectWithData(fileContent, options: NSJSONReadingOptions.MutableContainers)
        
        self.init(identifier: identifier, json: spotAssessmentParameters, itemIdentifiers: itemIdentifiers)
    }
    
    convenience public init(identifier: String, json: AnyObject, itemIdentifiers: [String]? = nil) {
        
        guard let completeJSON = json as? [String: AnyObject],
            let typeJSON = completeJSON["MEDL"] as? [String: AnyObject],
            let assessmentJSON = typeJSON["spot"] as? [String: AnyObject],
            let itemJSONArray = typeJSON["medications"] as? [AnyObject]
            else {
                fatalError("JSON Parse Error")
        }
        
        let items:[RKXCopingMechanismDescriptor] = itemJSONArray.map { (itemJSON: AnyObject) in
            guard let itemDictionary = itemJSON as? [String: AnyObject]
                else
            {
                return nil
            }
            return RKXCopingMechanismDescriptor(itemDictionary: itemDictionary)
            }.flatMap { $0 }
        
        let imageChoices: [ORKImageChoice] = items
            .filter { activity in
                if let identifiers = itemIdentifiers {
                    return identifiers.contains(activity.identifier)
                }
                else {
                    return true
                }
            }
            .map(RKXImageDescriptor.imageChoiceForDescriptor())
            //dont forget to unwrap optionals!!
            .flatMap { $0 }
        
        let assessment = RKXMultipleImageSelectionSurveyDescriptor(assessmentDictionary: assessmentJSON)
        
        let steps: [ORKStep] = {
            if (imageChoices.count == 0) {
                guard let noItemSummary = assessment.noItemsSummary
                    else {
                        fatalError("No items and no item summary")
                }
                let summaryStep = ORKInstructionStep(identifier: noItemSummary.identifier)
                summaryStep.title = noItemSummary.title
                summaryStep.text = noItemSummary.text
                return [summaryStep]
            }
            else {
                
                let answerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(imageChoices)
                
                let spotAssessmentStep = MEDLSpotAssessmentStep(identifier: identifier, title: assessment.prompt, answerFormat: answerFormat)
                
                var steps: [ORKStep] = [spotAssessmentStep]
                
                if let summary = assessment.summary {
                    let summaryStep = ORKInstructionStep(identifier: summary.identifier)
                    summaryStep.title = summary.title
                    summaryStep.text = summary.text
                    steps.append(summaryStep)
                }
                
                return steps
            }
        }()
        
        self.init(identifier: identifier, steps: steps)
        self.options = assessment.options
    }
    
    override init(identifier: String, steps: [ORKStep]?) {
        super.init(identifier: identifier, steps: steps)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}