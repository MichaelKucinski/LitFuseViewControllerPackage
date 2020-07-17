//
//  LitFuseViewController.swift
//  LitFuse
//
//  Created by Michael Kucinski on 7/13/20.
//  Copyright © 2020 Michael Kucinski. All rights reserved.
//
//

// mgk

import Foundation
import UIKit

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageHere = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageHere!
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}


public class LitFuseViewController: UIViewController, UITextViewDelegate {
    
    var poolOfEmittersAlreadyCreated = false
    public var arrayOfEmitters = [CAEmitterLayer]()
    var arrayOfCells = [CAEmitterCell]()
    
    let emojiLengthPerSide : Int = 100
    
    var lastChosenBirthRate : Float = 40
    var lastChosenLifetime : Float = 0.5
    var lastChosenLifetimeRange : Float = 0
    var lastChosenEmissionLongitude : CGFloat = 2 * CGFloat.pi
    var lastChosenEmissionLatitude : CGFloat = 2 * CGFloat.pi
    var lastChosenEmissionRange : CGFloat = 2 * CGFloat.pi
    var lastChosenSpin : CGFloat = 0
    var lastChosenSpinRange : CGFloat = 0
    var lastChosenScale : CGFloat = 1
    var lastChosenScaleRange : CGFloat = 0
    var lastChosenScaleSpeed : CGFloat = 0
    var lastChosenAlphaSpeed : CGFloat = 0
    var lastChosenAlphaRange : CGFloat = 0
    var lastChosenAutoReverses : Bool = false
    var lastChosenIsEnabled : Bool = true
    var continuoslyBurnFuseEnable : Bool = false
    var lastChosenVelocity : CGFloat = 0
    var lastChosenVelocityRange : CGFloat = 0
    var lastChosen_X_Acceleration : CGFloat = 0
    var lastChosen_Y_Acceleration : CGFloat = 0
    var totalFramesSinceStarting = 0
    var indexIntoLitFuse : Int = 0
    var secondIndexIntoLitFuseForContinuousDisplay : Int = 0
    var frameWhenWeChangeCellImages = 0
    var changeCellImagesEnabled = false
    var litFuseEffectEnabled = false
    var singlePassInUseAndValid = false
    var continuousFuseEffectEnabled = false
    var indexIntoArrayOfStrings = 0
    var arrayOfStringsForCycling = [String]()
    var cycleTime : CGFloat = 0
    var framesBetweenCycles : Int = 1
    var startIndexForCycling = 0
    var endIndexForCycling = 0
    var desiredFuseBurningVelocity : CGFloat = 0
    var desiredFuseEndingVelocity : CGFloat = 0
    var savedFuseBurningScale : CGFloat = 1
    var savedFuseFinalScale : CGFloat = 0
    var savedFuseStartIndex : Int = 0
    var savedFuseEndIndex : Int = 0
    var savedFuseStepsPerFrame : Int = 1
    var savedBurningBirthRate : CGFloat = 100
    var savedEndingBirthRate : CGFloat = 1
    var repeatingLastLitFuseEnabled = false
    var numberOfFramesBetweenRepeatedLitFuseDisplays = 2
    var countDownForRepeatingLitFuse = 2
    var scaleSyncedToLifetime : Bool = false
    var lastStartIndexForVisibleEmitters = 0
    var lastEndIndexForVisibleEmitters = 0
    
    // saved parameters from last call to createLitFuseEffectForDesiredRangeOfEmitters
    
    var prior_startIndex : Int = 1
    var prior_endIndex : Int = 2
    var prior_fuseVelocity : CGFloat = 1.0
    var prior_initialVelocity : CGFloat = 0
    var prior_endingVelocity : CGFloat = 0
    var prior_cellInitialScale : CGFloat = 0
    var prior_cellFuseBurningScale : CGFloat = 1
    var prior_cellFinalScale : CGFloat = 0
    var prior_stepsPerFrame : Int = 1
    var prior_initialBirthRate : CGFloat = 1
    var prior_fuseBurningBirthRate : CGFloat = 100
    var prior_endingBirthRate : CGFloat = 1
    var prior_cellLifetime : CGFloat = 2
    var prior_continuousFuseDesired : Bool = false
    var prior_repeatingFuseDesired : Bool = false
    var prior_repeatingFuseFramesBetween : Int = 30
    var transitionToFuseBurningVelocityIndex = 0
    var transitionToEndingVelocityIndex = 0
    var transitionToEndingVelocityIndexHasBegun : Bool = false
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var localTimer = Timer()
        
        if localTimer.isValid
        {
            // This blank if statement gets rid of a nuisance warning about never reading the timer.
        }
        
        // start the timer
        localTimer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(handleTimerEvent), userInfo: nil, repeats: true)
    }
    
    // starts handleTimer...
    @objc func handleTimerEvent()
    {
        totalFramesSinceStarting += 1
        
        if changeCellImagesEnabled
        {
            if totalFramesSinceStarting >= frameWhenWeChangeCellImages
            {
                frameWhenWeChangeCellImages += framesBetweenCycles
                
                // Get next string
                
                let newStringToImage = arrayOfStringsForCycling[indexIntoArrayOfStrings]
                
                setCellImageFromTextStringForDesiredRangeOfEmitters(desiredImageAsText: newStringToImage, startIndex: startIndexForCycling, endIndex: endIndexForCycling)
                
                indexIntoArrayOfStrings += 1
                if indexIntoArrayOfStrings >= arrayOfStringsForCycling.count
                {
                    indexIntoArrayOfStrings = 0
                }
            }
        }
        
        if litFuseEffectEnabled
        {
            var wentThroughTheLoops : Bool = false
            
            if continuousFuseEffectEnabled
            {
                for _ in 1...savedFuseStepsPerFrame
                {
                    wentThroughTheLoops = true
                    
                    // Transition this emitter to fuse burning velocity
                    let thisCell = arrayOfCells[transitionToFuseBurningVelocityIndex]
                    let thisEmitter = arrayOfEmitters[transitionToFuseBurningVelocityIndex]
                    
                    thisCell.velocity = desiredFuseBurningVelocity
                    thisCell.scale = savedFuseBurningScale
                    if scaleSyncedToLifetime
                    {
                        thisCell.scaleSpeed = -1 * thisCell.scale / CGFloat(thisCell.lifetime)
                    }
                    thisCell.birthRate = Float(savedBurningBirthRate)
                    thisEmitter.beginTime = CACurrentMediaTime()
                    
                    let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
                    
                    thisEmitter.emitterCells = [aCell]
                    
                    transitionToFuseBurningVelocityIndex += 1
                    
                    let tempsavedFuseStepsPerFrame : Int = Int(savedFuseStepsPerFrame)
                    
                    if transitionToFuseBurningVelocityIndex >  tempsavedFuseStepsPerFrame
                    {
                        transitionToEndingVelocityIndexHasBegun = true
                    }
                    
                    if transitionToFuseBurningVelocityIndex >= arrayOfEmitters.count
                    {
                        transitionToFuseBurningVelocityIndex = 0
                    }
                }
                if transitionToEndingVelocityIndexHasBegun
                {
                    for _ in 1...savedFuseStepsPerFrame
                    {
                        wentThroughTheLoops = true
                        
                        // Transition this emitter to ending velocity
                        
                        let thisCell = arrayOfCells[transitionToEndingVelocityIndex]
                        let thisEmitter = arrayOfEmitters[transitionToEndingVelocityIndex]
                        
                        thisEmitter.beginTime = CACurrentMediaTime()
                        if scaleSyncedToLifetime
                        {
                            thisCell.scaleSpeed = -1 * savedFuseFinalScale / CGFloat(thisCell.lifetime)
                        }
                        
                        thisCell.velocity = desiredFuseEndingVelocity
                        thisCell.scale = savedFuseFinalScale
                        thisCell.birthRate = Float(savedEndingBirthRate)
                        thisEmitter.beginTime = CACurrentMediaTime()
                        
                        let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
                        
                        thisEmitter.emitterCells = [aCell]
                        
                        transitionToEndingVelocityIndex += 1
                        
                        if transitionToEndingVelocityIndex >= arrayOfEmitters.count
                        {
                            transitionToEndingVelocityIndex = 0
                        }
                    }
                }
            }
            else // continuousFuseEffectEnabled is false
            {
                if singlePassInUseAndValid
                {
                    for _ in 1...savedFuseStepsPerFrame
                    {
                        wentThroughTheLoops = true
                        
                        // Transition this emitter to fuse burning velocity
                        let thisCell = arrayOfCells[transitionToFuseBurningVelocityIndex]
                        let thisEmitter = arrayOfEmitters[transitionToFuseBurningVelocityIndex]
                        
                        thisCell.velocity = desiredFuseBurningVelocity
                        thisCell.scale = savedFuseBurningScale
                        if scaleSyncedToLifetime
                        {
                            thisCell.scaleSpeed = -1 * thisCell.scale / CGFloat(thisCell.lifetime)
                        }
                        thisCell.birthRate = Float(savedBurningBirthRate)
                        thisEmitter.beginTime = CACurrentMediaTime()
                        
                        let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
                        
                        thisEmitter.emitterCells = [aCell]
                        
                        transitionToFuseBurningVelocityIndex += 1
                        
                        let tempsavedFuseStepsPerFrame : Int = Int(savedFuseStepsPerFrame)
                        
                        if transitionToFuseBurningVelocityIndex >  tempsavedFuseStepsPerFrame
                        {
                            transitionToEndingVelocityIndexHasBegun = true
                        }
                        
                        if transitionToFuseBurningVelocityIndex >= arrayOfEmitters.count
                        {
                            // stop the fuse burning
                            singlePassInUseAndValid = false
                            
                            // break out of the loop
                            break
                        }
                    }
                }
                
                if transitionToEndingVelocityIndexHasBegun
                {
                    for _ in 1...savedFuseStepsPerFrame
                    {
                        wentThroughTheLoops = true
                        
                        // Transition this emitter to fuse burning velocity
                        
                        let thisCell = arrayOfCells[transitionToEndingVelocityIndex]
                        let thisEmitter = arrayOfEmitters[transitionToEndingVelocityIndex]
                        
                        thisEmitter.beginTime = CACurrentMediaTime()
                        if scaleSyncedToLifetime
                        {
                            thisCell.scaleSpeed = -1 * savedFuseFinalScale / CGFloat(thisCell.lifetime)
                        }
                        
                        thisCell.velocity = desiredFuseEndingVelocity
                        thisCell.scale = savedFuseFinalScale
                        thisCell.birthRate = Float(savedEndingBirthRate)
                        thisEmitter.beginTime = CACurrentMediaTime()
                        
                        let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
                        
                        thisEmitter.emitterCells = [aCell]
                        
                        transitionToEndingVelocityIndex += 1
                        
                        if transitionToEndingVelocityIndex >= arrayOfEmitters.count
                        {
                            // stop the fuse ending velocity
                            transitionToEndingVelocityIndexHasBegun = false
                            
                            // and start the countdown if needed
                            
                            countDownForRepeatingLitFuse = numberOfFramesBetweenRepeatedLitFuseDisplays
                            
                            // break out of the loop
                            break
                        }
                    }
                }
            }
            
        } // ends if litFuseEffectEnabled
        
        if repeatingLastLitFuseEnabled
        {
            if countDownForRepeatingLitFuse == numberOfFramesBetweenRepeatedLitFuseDisplays / 2
            {
                hideAllEmitters()
            }
            if countDownForRepeatingLitFuse == 0
            {
                createLitFuseEffectForDesiredRangeOfEmitters(
                    startIndex                  : prior_startIndex,
                    endIndex                    : prior_endIndex,
                    initialVelocity             : prior_initialVelocity,
                    fuseBurningVelocity         : prior_fuseVelocity,
                    endingVelocity              : prior_endingVelocity,
                    cellInitialScale            : prior_cellInitialScale,
                    cellFuseBurningScale        : prior_cellFuseBurningScale,
                    cellEndingScale             : prior_cellFinalScale,
                    stepsPerFrame               : prior_stepsPerFrame,
                    initialBirthRate            : prior_initialBirthRate,
                    fuseBurningBirthRate        : prior_fuseBurningBirthRate,
                    endingBirthRate             : prior_endingBirthRate,
                    cellLifetime                : prior_cellLifetime,
                    continuousFuseDesired       : prior_continuousFuseDesired,
                    repeatingFuseDesired        : prior_repeatingFuseDesired,
                    repeatingFuseFramesBetween  : prior_repeatingFuseFramesBetween)
            }
            
        } // ends if repeatingLastLitFuseEnabled
        
        countDownForRepeatingLitFuse -= 1
        
    } // ends handleTimerEvent
    
    public func createPoolOfEmitters(
        maxCountOfEmitters : Int,
        someEmojiCharacter : String)
    {
        if poolOfEmittersAlreadyCreated
        {
            return
        }
        
        var seedCurrent = 0
        
        let emojiString = someEmojiCharacter
        let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textOrEmojiToUIImage.textColor = UIColor.red
        textOrEmojiToUIImage.backgroundColor = UIColor.clear
        
        textOrEmojiToUIImage.text = emojiString
        textOrEmojiToUIImage.sizeToFit()
        
        for _ in 1...maxCountOfEmitters {
            
            let thisEmitter = CAEmitterLayer()
            
            thisEmitter.isHidden = false
            thisEmitter.emitterPosition = CGPoint(x: -1000, y: 0)
            
            thisEmitter.emitterShape = .point
            thisEmitter.emitterSize = CGSize(width: 50, height: 50)
            thisEmitter.renderMode = CAEmitterLayerRenderMode.oldestFirst
            
            let emojiString = someEmojiCharacter
            let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            textOrEmojiToUIImage.text = emojiString
            textOrEmojiToUIImage.sizeToFit()
            
            let tempImageToUseWhenChangingCellImages  =  UIImage.imageWithLabel(label: textOrEmojiToUIImage)
            
            let aCell = makeCell(thisEmitter: thisEmitter, newColor: .white, contentImage: tempImageToUseWhenChangingCellImages)
            
            thisEmitter.emitterCells = [aCell]
            
            seedCurrent += 1
            thisEmitter.seed = UInt32(seedCurrent)
            
            arrayOfEmitters.append(thisEmitter)
            arrayOfCells.append(aCell)
        }
        
        poolOfEmittersAlreadyCreated = true
        
    } // ends createPoolOfEmitters
    
    public func makeCell(
        thisEmitter     : CAEmitterLayer,
        newColor        : UIColor,
        contentImage    : UIImage) -> CAEmitterCell
    {
        let cell = CAEmitterCell()
        
        cell.birthRate          = lastChosenBirthRate
        cell.lifetime           = lastChosenLifetime
        cell.lifetimeRange      = lastChosenLifetimeRange
        cell.color              = newColor.cgColor
        cell.emissionLongitude  = lastChosenEmissionLongitude
        cell.emissionLatitude   = lastChosenEmissionLatitude
        cell.emissionRange      = lastChosenEmissionRange
        cell.spin               = lastChosenSpin
        cell.spinRange          = lastChosenSpinRange
        cell.scale              = lastChosenScale
        cell.scaleRange         = lastChosenScaleRange
        cell.scaleSpeed         = lastChosenScaleSpeed
        cell.alphaSpeed         = Float(lastChosenAlphaSpeed)
        cell.alphaRange         = Float(lastChosenAlphaRange)
        cell.autoreverses       = lastChosenAutoReverses
        cell.isEnabled          = lastChosenIsEnabled
        cell.velocity           = lastChosenVelocity
        cell.velocityRange      = lastChosenVelocityRange
        cell.xAcceleration      = lastChosen_X_Acceleration
        cell.yAcceleration      = lastChosen_Y_Acceleration
        cell.zAcceleration      = 0
        cell.contents           = contentImage.cgImage
        cell.name               = "myCellName"
        
        // cell.beginTime .. https://stackoverflow.com/questions/51271868/what-is-the-proper-way-to-end-a-caemitterlayer-in-swift You can set the emitterLayer.lifetime to something other than 0. You'll also potentially want to set  emitterLayer.beginTime = CACurrentMediaTime() when starting it up again, otherwise sprites may appear where you wouldn't expect them. – Dave Y May 2 at 14:21
        
        return cell
        
    } // ends makeCell
    
    public func makeCellBasedOnPreviousCell(
        thisEmitter : CAEmitterLayer,
        oldCell     : CAEmitterCell) -> CAEmitterCell
    {
        let cell = CAEmitterCell()
        
        cell.birthRate              = oldCell.birthRate
        cell.lifetime               = oldCell.lifetime
        cell.lifetimeRange          = oldCell.lifetimeRange
        cell.color                  = oldCell.color
        cell.emissionLongitude      = oldCell.emissionLongitude
        cell.emissionLatitude       = oldCell.emissionLatitude
        cell.emissionRange          = oldCell.emissionRange
        cell.spin                   = oldCell.spin
        cell.spinRange              = oldCell.spinRange
        cell.scale                  = oldCell.scale
        cell.scaleRange             = oldCell.scaleRange
        cell.scaleSpeed             = oldCell.scaleSpeed
        cell.alphaSpeed             = oldCell.alphaSpeed
        cell.alphaRange             = oldCell.alphaRange
        cell.autoreverses           = oldCell.autoreverses
        cell.isEnabled              = oldCell.isEnabled
        cell.velocity               = oldCell.velocity
        cell.velocityRange          = oldCell.velocityRange
        cell.xAcceleration          = oldCell.xAcceleration
        cell.yAcceleration          = oldCell.yAcceleration
        cell.zAcceleration          = oldCell.zAcceleration
        cell.name                   = oldCell.name
        cell.contents               = oldCell.contents
        
        return cell
        
    } // ends makeCellBasedOnPreviousCell
    
    public func placeEmittersOnSpecifiedCircleOrArc(
        thisCircleCenter        : CGPoint,
        thisCircleRadius        : CGFloat,
        thisCircleArcFactor     : CGFloat = 1.0,
        startIndex              : Int,
        endIndex                : Int,
        offsetAngleInDegrees    : CGFloat = 0,
        scaleFactor             : CGFloat = 1.0)
    {
        let angleBetweenEmitters : CGFloat = 360.0 / CGFloat(endIndex - startIndex + 1) * thisCircleArcFactor
        var currentSumOfAngles : CGFloat = 0
        
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: thisCircleCenter.x + scaleFactor * thisCircleRadius * sin(currentSumOfAngles.degreesToRadians + offsetAngleInDegrees.degreesToRadians), y: thisCircleCenter.y + scaleFactor * thisCircleRadius * cos(currentSumOfAngles.degreesToRadians + offsetAngleInDegrees.degreesToRadians))
            
            currentSumOfAngles += angleBetweenEmitters
        }
        
    } // ends placeEmittersOnSpecifiedCircleOrArc
    
    public func placeEmittersOnSpecifiedLine(
        startingPoint   : CGPoint,
        endingPoint     : CGPoint,
        startIndex      : Int,
        endIndex        : Int)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        var lastPosition_X : CGFloat = startingPoint.x
        var lastPosition_Y : CGFloat = startingPoint.y
        
        let horizontalDistanceToCoverPerPlacement : CGFloat = (endingPoint.x - startingPoint.x) / CGFloat((endIndex - startIndex))
        
        let verticalDistanceToCoverPerPlacement : CGFloat = (endingPoint.y - startingPoint.y) / CGFloat((endIndex - startIndex))
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
            
            lastPosition_X += horizontalDistanceToCoverPerPlacement
            lastPosition_Y += verticalDistanceToCoverPerPlacement
        }
        
    } // ends placeEmittersOnSpecifiedLine
    
    public func placeEmittersOnSpecifiedRectangle(
        thisRectangle   : CGRect,
        startIndex      : Int,
        endIndex        : Int,
        scaleFactor     : CGFloat = 1.0)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        // Rectange must be level with no offsetting angle.
        
        // This version places an equal number of emitters on all 4 sides if possible, but 3 sides may have one less emitter.
        
        // Figure out how many emitters per side
        let emittersPerSide : Int = ((endIndex - startIndex + 1) / 4)
        
        var emittersTopSide : Int = emittersPerSide
        var emittersRightSide : Int = emittersPerSide
        var emittersBottomSide : Int = emittersPerSide
        let emittersLeftSide : Int = emittersPerSide
        
        if (endIndex - startIndex + 1) % 4 != 0
        {
            emittersTopSide += 1
        }
        if (endIndex - startIndex + 1) % 4 == 2
        {
            emittersRightSide += 1
        }
        if (endIndex - startIndex + 1) % 4 == 3
        {
            emittersRightSide += 1
            emittersBottomSide += 1
        }
        
        var countOfEmittersPlacedSoFar : Int = 0
        var countOfHorizontalEmittersPlacedForThisSide : CGFloat = 0
        var countOfVerticalEmittersPlacedForThisSide : CGFloat = 0
        
        var horizontalDistanceToCoverPerPlacement : CGFloat = scaleFactor  * thisRectangle.width / 4
        var verticalDistanceToCoverPerPlacement : CGFloat = scaleFactor * thisRectangle.height / 4
        
        let origin_X_AdjustmentDueToScaleFactor = -(thisRectangle.width * scaleFactor - thisRectangle.width) / 2
        let origin_Y_AdjustmentDueToScaleFactor = -(thisRectangle.height * scaleFactor - thisRectangle.height) / 2
        
        var lastPosition_X : CGFloat = thisRectangle.origin.x + origin_X_AdjustmentDueToScaleFactor
        var lastPosition_Y : CGFloat = thisRectangle.origin.y + origin_Y_AdjustmentDueToScaleFactor
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            if countOfEmittersPlacedSoFar < emittersTopSide
            {
                horizontalDistanceToCoverPerPlacement = scaleFactor * thisRectangle.width /  CGFloat(emittersTopSide)
                
                arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                
                lastPosition_X = lastPosition_X + horizontalDistanceToCoverPerPlacement
                
                
                countOfHorizontalEmittersPlacedForThisSide += 1
            }
            else if countOfEmittersPlacedSoFar < emittersTopSide + emittersRightSide
            {
                verticalDistanceToCoverPerPlacement = thisRectangle.height /  CGFloat(emittersRightSide) * scaleFactor
                
                arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                
                lastPosition_Y = lastPosition_Y + verticalDistanceToCoverPerPlacement
                
                countOfVerticalEmittersPlacedForThisSide += 1
                countOfHorizontalEmittersPlacedForThisSide = 0
            }
            else if countOfEmittersPlacedSoFar < emittersTopSide + emittersRightSide + emittersBottomSide
            {
                horizontalDistanceToCoverPerPlacement = thisRectangle.width /  CGFloat(emittersBottomSide) * scaleFactor
                
                arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                
                lastPosition_X = lastPosition_X - horizontalDistanceToCoverPerPlacement
                
                countOfHorizontalEmittersPlacedForThisSide += 1
                countOfVerticalEmittersPlacedForThisSide = 0
            }
            else
            {
                verticalDistanceToCoverPerPlacement = thisRectangle.height /  CGFloat(emittersLeftSide) * scaleFactor
                
                arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                
                lastPosition_Y = lastPosition_Y - verticalDistanceToCoverPerPlacement
                
                countOfVerticalEmittersPlacedForThisSide += 1
                countOfHorizontalEmittersPlacedForThisSide = 0
            }
            
            countOfEmittersPlacedSoFar += 1
        }
        
    } // ends placeEmittersOnSpecifiedRectangle
    
    public func desiredRangeOfVisibleEmitters(
        startIndex  : Int,
        endIndex    : Int)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        lastStartIndexForVisibleEmitters = startIndex
        lastEndIndexForVisibleEmitters = endIndex
        
        for (thisIndex, _) in arrayOfEmitters.enumerated()
        {
            if thisIndex < adjustedStartIndex || thisIndex > adjustedEndIndex
            {
                arrayOfEmitters[thisIndex].isHidden = true
            }
            else
            {
                arrayOfEmitters[thisIndex].isHidden = false
            }
        }
        
    } // ends desiredRangeOfVisibleEmitters
    
    public func hideAllEmitters()
    {
        litFuseEffectEnabled = false
        
        for (thisIndex, _) in arrayOfEmitters.enumerated()
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            thisCell.lifetime = 0
            thisCell.scale = 0
            
            thisEmitter.beginTime = CACurrentMediaTime()
            thisEmitter.isHidden = true
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]
            
            indexIntoLitFuse = 0
            secondIndexIntoLitFuseForContinuousDisplay = 0
        }
        
    } // ends hideAllEmitters
    
    public func setCellImageFromTextStringForDesiredRangeOfEmitters(
        desiredImageAsText  : String,
        startIndex          : Int,
        endIndex            : Int)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: emojiLengthPerSide, height: emojiLengthPerSide))
        
        textOrEmojiToUIImage.text = desiredImageAsText
        textOrEmojiToUIImage.sizeToFit()
        
        let tempImageToUseWhenChangingCellImages  =  UIImage.imageWithLabel(label: textOrEmojiToUIImage)
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            thisCell.contents = tempImageToUseWhenChangingCellImages.cgImage
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]
        }
        
    } // ends setCellImageFromTextStringForDesiredRangeOfEmitters
    
    public func setEmitterCellDirectionOutwardsForRangeOfEmittersOnCircle(
        offsetAngle         : CGFloat = 0,
        startIndex          : Int,
        endIndex            : Int,
        twistAngleAddition  : CGFloat = 0)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        var currentTwistValue = twistAngleAddition
        
        var cummulativeAngle : CGFloat = -90 + offsetAngle
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            
            thisCell.emissionLongitude = -cummulativeAngle.degreesToRadians
            thisCell.emissionLatitude = 0
            thisCell.emissionRange = 0
            
            cummulativeAngle += currentTwistValue
            
            currentTwistValue += twistAngleAddition
        }
    } // ends setEmitterCellDirectionOutwardsForRangeOfEmittersOnCircle
    
    public func setEmitterCellDirectionRandomForRangeOfEmittersOnCircle(
        startIndex  : Int,
        endIndex    : Int)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            
            thisCell.emissionLongitude = 2 * CGFloat.pi
            thisCell.emissionLatitude = 2 * CGFloat.pi
            thisCell.emissionRange = 2 * CGFloat.pi
        }
    } // ends setEmitterCellDirectionRandomForRangeOfEmittersOnCircle
    
    public func setEmitterCellDirectionToSpecifiedAngle(
        specifiedAngle  : CGFloat,
        startIndex      : Int,
        endIndex        : Int)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            
            thisCell.emissionLongitude = specifiedAngle.degreesToRadians
            thisCell.emissionLatitude = 0
            thisCell.emissionRange = 0
        }
    } // ends setEmitterCellDirectionToSpecifiedAngle
    
    public func cycleToNewCellImageFromTextStringForDesiredRangeOfEmittersAtDesiredRate(
        desiredArrayAsText  : [String],
        startIndex          : Int,
        endIndex            : Int,
        timeBetweenChanges  : CGFloat)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        arrayOfStringsForCycling = desiredArrayAsText
        cycleTime = timeBetweenChanges
        framesBetweenCycles = Int(cycleTime * 60.0)
        frameWhenWeChangeCellImages = totalFramesSinceStarting
        startIndexForCycling = startIndex
        endIndexForCycling = endIndex
        
        indexIntoArrayOfStrings = 0
        
        changeCellImagesEnabled = true
        
    } // ends cycleToNewCellImageFromTextStringForDesiredRangeOfEmittersAtDesiredRate
    
    public func alternateCellImagesWithGivenArrayOfEmojiOrTextForDesiredRangeOfEmitters(
        desiredArrayAsText  : [String],
        startIndex          : Int,
        endIndex            : Int)
    {
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        var indexIntoArray = 0
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            let newStringToImage = desiredArrayAsText[indexIntoArray]
            let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: emojiLengthPerSide, height: emojiLengthPerSide))
            
            textOrEmojiToUIImage.text = newStringToImage
            textOrEmojiToUIImage.sizeToFit()
            
            let tempImageToUseWhenChangingCellImages  =  UIImage.imageWithLabel(label: textOrEmojiToUIImage)
            
            indexIntoArray += 1
            
            if indexIntoArray >= desiredArrayAsText.count
            {
                indexIntoArray = 0
            }
            
            thisCell.contents = tempImageToUseWhenChangingCellImages.cgImage
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]
        }
        
    } // ends alternateCellImagesWithGivenArrayOfEmojiOrTextForDesiredRangeOfEmitters
    
    public func createLitFuseEffectForDesiredRangeOfEmitters(
        startIndex                  : Int,
        endIndex                    : Int,
        initialVelocity             : CGFloat = 0,
        fuseBurningVelocity         : CGFloat,
        endingVelocity              : CGFloat = 0,
        cellInitialScale            : CGFloat = 0,
        cellFuseBurningScale        : CGFloat = 1,
        cellEndingScale             : CGFloat = 0,
        stepsPerFrame               : Int = 1,
        initialBirthRate            : CGFloat = 1,
        fuseBurningBirthRate        : CGFloat = 100,
        endingBirthRate             : CGFloat = 1,
        cellLifetime                : CGFloat = 2,
        continuousFuseDesired       : Bool = false,
        repeatingFuseDesired        : Bool = false,
        repeatingFuseFramesBetween  : Int = 30,
        spin                        : CGFloat = 0,
        spinRange                   : CGFloat = 0,
        scaleSpeed                  : CGFloat = 0,
        alphaSpeed                  : CGFloat = 0)
    {
        prior_startIndex                    = startIndex
        prior_endIndex                      = endIndex
        prior_fuseVelocity                  = fuseBurningVelocity
        prior_initialVelocity               = initialVelocity
        prior_endingVelocity                = endingVelocity
        prior_cellInitialScale              = cellInitialScale
        prior_cellFuseBurningScale          = cellFuseBurningScale
        prior_cellFinalScale                = cellEndingScale
        prior_stepsPerFrame                 = stepsPerFrame
        prior_initialBirthRate              = initialBirthRate
        prior_fuseBurningBirthRate          = fuseBurningBirthRate
        prior_endingBirthRate               = endingBirthRate
        prior_cellLifetime                  = cellLifetime
        prior_continuousFuseDesired         = continuousFuseDesired
        prior_repeatingFuseDesired          = repeatingFuseDesired
        prior_repeatingFuseFramesBetween    = repeatingFuseFramesBetween
        
        if startIndex - 1 < 0
        {
            return
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if endIndex - 1 < 0
        {
            return
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return
        }
        if startIndex > endIndex
        {
            return
        }
        
        desiredRangeOfVisibleEmitters(startIndex: startIndex, endIndex: endIndex)
        
        litFuseEffectEnabled = true
        
        if continuousFuseDesired
        {
            continuousFuseEffectEnabled = true
            repeatingLastLitFuseEnabled = false
            
            indexIntoLitFuse = prior_startIndex - 1
            
            transitionToEndingVelocityIndex = 0
            transitionToEndingVelocityIndexHasBegun = false
            transitionToFuseBurningVelocityIndex = 0
        }
        else if repeatingFuseDesired
        {
            repeatingLastLitFuseEnabled = true
            continuousFuseEffectEnabled = false
            numberOfFramesBetweenRepeatedLitFuseDisplays = repeatingFuseFramesBetween
            singlePassInUseAndValid = true
            transitionToFuseBurningVelocityIndex = 0
            transitionToEndingVelocityIndex = 0
            transitionToEndingVelocityIndexHasBegun = false
        }
        else
        {
            continuousFuseEffectEnabled = false
            repeatingLastLitFuseEnabled = false
            singlePassInUseAndValid = true
            transitionToFuseBurningVelocityIndex = 0
            transitionToEndingVelocityIndex = 0
            transitionToEndingVelocityIndexHasBegun = false
        }
        
        // Save the values for later
        desiredFuseBurningVelocity = fuseBurningVelocity
        desiredFuseEndingVelocity = endingVelocity
        savedFuseStartIndex = startIndex - 1
        savedFuseEndIndex = endIndex - 1
        indexIntoLitFuse = startIndex - 1
        savedFuseBurningScale = cellFuseBurningScale
        savedFuseFinalScale = cellEndingScale
        savedFuseStepsPerFrame = stepsPerFrame
        if savedFuseStepsPerFrame < 1
        {
            savedFuseStepsPerFrame = 1
        }
        if savedFuseStepsPerFrame > 80
        {
            savedFuseStepsPerFrame = 80
        }
        savedEndingBirthRate = endingBirthRate
        savedBurningBirthRate = fuseBurningBirthRate
        
        // set all emitters in the range to the initial velocity
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            thisCell.velocity = initialVelocity
            thisCell.scale = cellInitialScale
            thisCell.spin = spin
            thisCell.spinRange = spinRange
            thisCell.scaleSpeed = scaleSpeed
            thisCell.alphaSpeed = Float(alphaSpeed)
            thisCell.lifetime = Float(cellLifetime)
            thisEmitter.beginTime = CACurrentMediaTime()
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]
        }
        
    } // ends createLitFuseEffectForDesiredRangeOfEmitters
    
    public func repeatLastLitFuseEffectWithSpecifiedNumberOfFramesBetween(
        numberOfFramesBetween : Int)
    {
        repeatingLastLitFuseEnabled = true
        continuousFuseEffectEnabled = false
        numberOfFramesBetweenRepeatedLitFuseDisplays = numberOfFramesBetween
        countDownForRepeatingLitFuse = numberOfFramesBetweenRepeatedLitFuseDisplays
        
    } // ends repeatLastLitFuseEffectWithSpecifiedNumberOfFramesBetween
    
    /*
     public func toggleContinuousFuseEffectEnabled()
     {
     continuousFuseEffectEnabled.toggle()
     repeatingLastLitFuseEnabled = false
     
     if continuousFuseEffectEnabled
     {
     litFuseEffectEnabled = true
     
     indexIntoLitFuse = prior_startIndex - 1
     
     }
     else
     {
     hideAllEmitters()
     }
     
     } // ends toggleContinuousFuseEffectEnabled
     
     public func toggleRepeatingLastLitFuseEnabled()
     {
     repeatingLastLitFuseEnabled.toggle()
     numberOfFramesBetweenRepeatedLitFuseDisplays = 40
     continuousFuseEffectEnabled = false
     litFuseEffectEnabled = true
     
     prior_continuousFuseDesired = false
     prior_repeatingFuseDesired = true
     prior_repeatingFuseFramesBetween = 40
     
     if !repeatingLastLitFuseEnabled
     {
     hideAllEmitters()
     }
     
     } // ends toggleRepeatingLastLitFuseEnabled
     
     var randomState = true
     
     var summingAngle : CGFloat = 0
     
     public func toggleRandomState()
     {
     randomState.toggle()
     if randomState
     {
     setEmitterCellDirectionRandomForRangeOfEmittersOnCircle(startIndex: lastStartIndexForVisibleEmitters, endIndex: lastEndIndexForVisibleEmitters)
     }
     else
     {
     summingAngle += 45
     
     setEmitterCellDirectionOutwardsForRangeOfEmittersOnCircle(offsetAngle: summingAngle, startIndex: lastStartIndexForVisibleEmitters, endIndex: lastEndIndexForVisibleEmitters, twistAngleAddition: 0)
     }
     
     } // ends toggleRandomState
     
     */
    
    
    
} // ends file
