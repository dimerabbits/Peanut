<p align="center">
  <img src="https://static.wixstatic.com/media/029b8f_24382ea7f2214725a05730f20133895a~mv2.png/v1/fill/w_720,h_720,al_c,usm_0.66_1.00_0.01/roundedRecPeanut.png" alt="logo" width="20%"/>
</p>
<h1 align="center">
  Peanut
</h1>
</p>
<p align="center">
    <a href="https://www.apple.com/ios/ios-15/">
        <img src="https://img.shields.io/badge/iOS-15.0+-important.svg" />
    <a href="https://swift.org/download/">
        <img src="https://img.shields.io/badge/swift-5.5+-orange.svg?style=flat" alt="Language Swift 5.5" />
    <a href="https://twitter.com/dimerabbits">
        <img src="https://img.shields.io/badge/Contact-@dimerabbits-lightgrey.svg?style=flat" alt="Twitter: @dimerabbits" />
    </a>
</p>
<p align="center">
  Peanut is an organizational application focusing on user customization within a simple interface.
</p>


## Table of Contents

- [User Features](#user-features)
- [Architecture](#architecture)
- [System Integrations](#system-integrations)
- [Additional Coaching Points](#additional-coaching-points)
- [Taking it Further…](#taking-it-further)
- [Credits](#credits)
- [License](#license)


## User Features

- Dynamic Organization: Handle multiple projects at once by setting reminders, prioritization, sorting, and your choice of color scheme.
- Tracking Productivity: Keep a close eye on your progress to ensure there is never a deadline missed. Utilize Peanut to meet the goals specific to your work.
- Sharing: Post comments to share updates and engage with team members to inspire new ideas.


## Architecture

- Modeled with Core Data using an inverse relationship with parent/child entities "To Many".
- Integrated with CloudKit to enable sharing functionality. 
- Composed primarily without UIKit except for bridging Quick Actions capability and dismissing the keyboard in TextEditor.
- Pragmatically utilized MVVM where necessary.
- Built with Accessibility in mind: VoiceOver, grouping data, adding traits and additional labels.


## System Integrations

- Haptics
- Spotlight
- Local Notifications
- StoreKit (In-app purchasing)
- Shortcuts
- Home Screen Quick Actions
- Widgets
- Storing data in iCloud
- Querying data from iCloud
- Posting Comments through iCloud
- Ratings and Review Request
- Sign in with Apple


## Additional Coaching Points

- Core sample data for Canvas previews. - optimizing with previewLayout, preferredColorScheme, etc…
- Extending 'Error' to handle CloudKit errors.
- SwiftLint - Working off Command Line and implementing as a build phase. Adjusting .yml arguments.
- Documenting Code - Documentation Comments, MARKS, FIXME, TODO, Orphaned explanation.
- Testing (Unit & UI) - Measuring performance, setting benchmarks.
- Internationalization(i18n) and localization(l10n) - genstrings, handling plurals, structuring interpolated data, and completely localized to English and Spanish.
- State Restoration - @AppStorage / @SceneStorage and attaching tag to the Hashable protocol.


## Taking it Further…

- WelcomeView
- AboutView
- Completely localized to Spanish
- Custom TextField (includes clearing text functionality)
- Custom Progress View
- Custom Color Picker LazyHGrid
- String Interpolation and Rendering Markdown content in text
- Adjusting List row seperator visibility and color
- Creating a List / ForEach from a binding
- additional data model attribute - "note" (TextEditor)
- CKQueryOperation deprecation fix (recordsMatchedBlock, queryResultBlock) 
- Adding additional NavigationLinks to ProjectSummaryView
- Adjusting list row seperator, visibility, and color
- ProgressTiled - Project Summary on TodayView using guage meter
- Shadows and glows (inner, raised)
- @FocusState - reading and writing the current focus position in view hierarchy. Dismissing the keyboard
- NotesHeader - Resigning First Responder using UIApplicationDelegateAdaptor to dismiss the keyboard of TextEditor
- SwiftUI for iOS 15 - confirmationDialog, withAnimation, Button roles, submitLabel, textSelection, symbolRenderingMode, Visual Effect Blurs using Material, focusable, alert, onSubmit, foregroundStyle(semantic colors, gradients, glows, shadows)
- Incorporating a multitude of Swift 5.5 API’s and Adhering to the latest Apple Interface Guidelines.


## Credits

Learning from [Paul Hudson](https://www.hackingwithswift.com).


## License

Peanut is MIT licensed, as found in the [LICENSE](/LICENSE) file.
