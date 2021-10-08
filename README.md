# Peanut

</p>

<p align="center">
        <img src="https://img.shields.io/badge/iOS-15.0+-important.svg" />
    <a href="https://swift.org/download/">
        <img src="https://img.shields.io/badge/swift-5.5-orange.svg?style=flat" alt="Language Swift 5.5" />
    <a href="https://twitter.com/dimerabbits">
        <img src="https://img.shields.io/badge/Contact-@dimerabbits-lightgrey.svg?style=flat" alt="Twitter: @dimerabbits" />
    </a>
</p>


## Usage

- Dynamic Organization: An organized, customizable approach for your projects. Create reminders to enable optimal prioritization to meet timelines.
- Tracking Productivity: Never miss an important timeline and ensure information doesn’t get lost in the shuffle.
- Sharing: Internal chat tool enabling teams and individuals to share updates.
- Accessible: VoiceOver, Haptics, Local notifications.


## Architecture

- Modeled with Core Data using an inverse relationship with parent/child entities "to many".
- Integrating CloudKit to enable sharing functionality.
- Primarily composed without UIKit except for bridging shortcut(Quick Action) capabilities and resigning the First Responder in order to dismiss the keyboard in TextEditor.
- Pragmatically utilizing MVVM where necessary.


## Frameworks

SwiftUI | CoreData | CloudKit | StoreKit | WidgetKit | Spotlight | CoreHaptics |  XCTest


## System Integrations

- Haptics
- Spotlight
- Notifications
- StoreKit (In-app purchasing)
- Shortcuts
- Widgets
- Storing data in iCloud
- Querying data from iCloud
- Posting Comments through iCloud
- Sign in with Apple


## Additional Coaching Points

- Core sample data for Canvas previews. - optimizing with previewLayout, preferredColorScheme, etc…
- SwiftLint - Working off Command Line and implementing as a build phase. Adjusting .yml arguments.
- Documenting Code - Documentation Comments, MARKS, FIXME, TODO, Orphaned explanation.
- Testing (Unit & UI) - Measuring performance, setting benchmarks.


## Taking it further…

- WelcomeView - Features, About Peanut & Privacy, json decodable.
- AboutView - Insettable Edges. Scrollable with formatting and confirmation.
- ProgressTiled - Project Summary on TodayView using guage.
- Shadows and glows (inner, raised)
- NotesHeader - dismissing TextEditor
- Datepicker - graphical
- onDelete, task, 
- Dismissing keyboard in TextEditor


## Credits

Learning from [Paul Hudson](https://www.hackingwithswift.com).
