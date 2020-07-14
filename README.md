# LitFuseViewControllerPackage


Lit Fuse Effects can be used to provide uniquely artistic and highly tailorable animation effects that your users will enjoy.  These effects can be used to provide eye catching animations to help your users notice a certain area of the screen.  These effect might be used in gaming, social media, or advertising.

See https://drive.google.com/file/d/1h3Q4yGh4pJvbF6thSQFS-txZAJITXCKy/view to view some sample fuse effects.

A variety of lit fuse effects are supported where the fuse particles are any sized emoji, or even short text.   You can control the emoji size.  Very small emoji look like colorful sparks.  Large emoji will show as much emoji detail as desired such that the fuse effects are a form of emoji art.

Lit fuses can burn and leave a burnt trail behind.  Or they can burn and leave no trail behind.

The initial fuse path itself can be either visible or invisible.

There are 3 stages where you can control the size of the fuse particles.  Size can be specified for the initial fuse path placement, while the fuse is actually burning, and a final size for the emitter particles after the fuse has burnt. 

If the initial size is zero, the fuse itself is invisible prior to burning.
While burning, the size needs to be greater than zero to see the burning action.  If the final size of the emitters after the burn is specified to be non zero, then the burnt path will remain on the screen.

It should be noted that the burnt path that remains on the screen still consists of emitters that  constantly emit cells at the last specified birthrate.  Those cells can be made to look stationary if the final cell velocity is zero.  There is a subtlety in that the final cell birthrate multiplied by the final cell lifetime needs to be greater than 1 for there to be no flicker or strobing effect.

You can specify the final cell birthrate and the lifetime in the API that creates the lit fuse effect.

Lit fuse effects can be commanded to run continuously, or to run repetively with a time gap between burns, or run as a one shot one time display of the desired animation.

You can specify how quickly the fuse burns.

Note that you may need to consider whether your app runs on older and slower devices or faster and newer devices, and how many other animations are being drawn to the screen at the same time.   Emitter animations can use a lot of CPU and GPU processing.   The larger your specified pool is and your chosen fuse parameters may effect performance and produce lag.   At first try using these effects with screens that are mostly static.  A design that shows a fuse effect, then hide the emitters for a short time period can allow all the prior emitted cells to reach the end of their lifetimes, and improve fuse performance. Hiding the emitters helps when used in a design that calls for repeated fuse effects. 

To create a lit fuse effect, you must  create a pool of emitters that will handle the largest numbers of emitters that you intend on using on a path. We suggest anywhere from 50 to 1000 emitters, depending on your path complexity and the desired density.

Below are code snippets that you can use to quickly get the Lit Fuse Effect working in your project.  First import the LitFuseViewControllerPackage

import LitFuseViewControllerPackage

Declare a LitFuseViewController object  

let litFuse = LitFuseViewController()

Make sure you call the litFuse.viewDidLoad() from the viewDidLoad of your parent view.  Create your pool of emitters right afterwards in the viewDidLoad.  Don't worry about the default emoji character passed to someEmojiCharacter.  You can specify and change it on the fly.  But if your design always uses the same emoji character then specify it in the call.  Note the emoji character is specified as a string.  We take care of converting that string into an image under the covers.

litFuse.viewDidLoad()

litFuse.createPoolOfEmitters(maxCountOfEmitters : 400, someEmojiCharacter: "🧠")

In the viewDidLoad, you will also need to add a sublayer for each element in the pool of emitters.

for thisEmitter in litFuse.arrayOfEmitters {
view.layer.addSublayer(thisEmitter)
}

And finally, we recommend hiding all the emitters in the viewDidLoad too.   The lit fuse emitters are now ready to be shown at will.

litFuse.hideAllEmitters()

To display a lit fuse effect, you may want to set an emoji pattern first.

litFuse.setCellImageFromTextStringForDesiredRangeOfEmitters(desiredImageAsText: "🟡", startIndex: 1, endIndex: 300)
litFuse.setCellImageFromTextStringForDesiredRangeOfEmitters(desiredImageAsText: "🔵", startIndex: 301, endIndex: 400)

Next, specify where your emitters are to be placed on the screen.  Here is an example that builds two rectangles, and uses them as the fuse path.  

var tempRect : CGRect = CGRect(x: 100, y: 300, width: 300, height: 300)

litFuse.placeEmittersOnSpecifiedRectangle(thisRectangle: tempRect, startIndex: 1, endIndex: 200)

tempRect = CGRect(x: 500, y: 300, width: 300, height: 300)

litFuse.placeEmittersOnSpecifiedRectangle(thisRectangle: tempRect, startIndex: 201, endIndex: 400)

Note that it can be so much easier if you already have an object on the screen that has a frame.  That frame is a rectangle and it can be passed.  In our prototype, we have a UITextView called readMeTextView, and below it's frame is passed so that the fuse path will actually trace its border.

litFuse.placeEmittersOnSpecifiedRectangle(thisRectangle: readMeTextView.frame, startIndex: 1, endIndex: 300, scaleFactor: 1.0)

Note the scaleFactor is an optional parameter.   A scaleFactor of 1.0 is right on the border, but if you want a standOff distance so the emitters surround the border with a buffer space, make the scale factor as large as desired, maybe 1.25 or so to get a 25 percent larger fuse path.

Finally, make a call to createLitFuseEffectForDesiredRangeOfEmitters.  Note that there are some optional parameters that this example doesn't use.  This will display the effect one time. 

litFuse.createLitFuseEffectForDesiredRangeOfEmitters(
startIndex              : 1,
endIndex                : 400,
initialVelocity         : 0,
fuseBurningVelocity     : 500,
endingVelocity          : 0,
framesAtHighVelocity    : 18,
cellInitialScale        : 0,
cellFuseBurningScale    : 0.15,
cellEndingScale         : 0.5,
stepsPerFrame           : 1,
initialBirthRate        : 5,
fuseBurningBirthRate    : 800,
endingBirthRate         : 5,
cellLifetime            : 0.2)


If you want your fuse to burn continuously, specify the continuousFuseDesired parameter as being true, as shown below

litFuse.createLitFuseEffectForDesiredRangeOfEmitters(
startIndex              : 1,
endIndex                : 400,
initialVelocity         : 0,
fuseBurningVelocity     : 500,
endingVelocity          : 0,
framesAtHighVelocity    : 18,
cellInitialScale        : 0,
cellFuseBurningScale    : 0.15,
cellEndingScale         : 0.5,
stepsPerFrame           : 1,
initialBirthRate        : 5,
fuseBurningBirthRate    : 800,
endingBirthRate         : 5,
cellLifetime            : 0.2,
continuousFuseDesired   : true)

At some point, you may want to hide the lit fuse effect.  Simply call

litFuse.hideAllEmitters()

You can change the fuse placement whenever you desire, but it may look best to do that while the emitters are hidden.

You can change the emoji whenever you desire, but it may look best to do that while the emitters are hidden.

You can call createLitFuseEffectForDesiredRangeOfEmitters whenever you desire, but it may look best to do that while the emitters are hidden.

The above should get you going.

If you desire to specify a more complex emoji pattern for your fuse effect, you can build an array of emoji.  That pattern will get repeated for the specified range of indices.  Typically, you will let the indices cover your whole pool.

var arrayOfEmoji = [String]()

arrayOfEmoji.removeAll() // removeAll just in case you already built the array with different emoji already

for _ in 1...4 { arrayOfEmoji.append("🦄") }
for _ in 1...3 { arrayOfEmoji.append("🐝") }
for _ in 1...2 { arrayOfEmoji.append("🐞") }
for _ in 1...1 { arrayOfEmoji.append("🦋") }

litFuse.alternateCellImagesWithGivenArrayOfEmojiOrTextForDesiredRangeOfEmitters(desiredArrayAsText: arrayOfEmoji, startIndex: 1, endIndex: 400)

Instead of using emoji, you can specify a short string of text, such as "Hi" but that's a feature that hasn't been thoroughly designed for.  It's one font, and one color, white.



If you want to place your fuse path on a line, here is some sample code :

let pointOne = CGPoint(x: 100, y: 100)
let pointTwo = CGPoint(x: 800, y: 1200)

litFuse.placeEmittersOnSpecifiedLine(
startingPoint: pointOne,
endingPoint: pointTwo,
startIndex: 1,
endIndex: 400)

If you want to place your fuse path on a circle, here is some sample code :

litFuse.placeEmittersOnSpecifiedCircleOrArc(
thisCircleCenter: CGPoint(x: 500, y: 700),
thisCircleRadius: 400,
thisCircleArcFactor: 1.0,
startIndex : 1,
endIndex: 400,
offsetAngleInDegrees: 45)

Note thisCircleArcFactor as 1 drawns a complete circle.   As 0.5 it would draw an arc for half a circle.   The  offsetAngleInDegrees would then control at which angle the half circle is shown.

Using 3 for thisCircleArcFactor would rap the fuse path around the circle 3 times.





