<p align="center">
  <img src="https://static.wixstatic.com/media/029b8f_24382ea7f2214725a05730f20133895a~mv2.png/v1/fill/w_720,h_720,al_c,usm_0.66_1.00_0.01/roundedRecPeanut.png" alt="logo" width="20%"/>
</p>
<h1 align="center">
  Peanut
</h1>
</p>
<p align="center">
        <img src="https://img.shields.io/badge/iOS-15.0+-important.svg" />
    <a href="https://swift.org/download/">
        <img src="https://img.shields.io/badge/swift-5.5-orange.svg?style=flat" alt="Language Swift 5.5" />
    <a href="https://twitter.com/dimerabbits">
        <img src="https://img.shields.io/badge/Contact-@dimerabbits-lightgrey.svg?style=flat" alt="Twitter: @dimerabbits" />
    </a>
</p>
<p align="center">
  Peanut is an organizational application focusing on user customization within a simple interface.
</p>


## Table of Contents

- [Featuring](#featuring)
- [Architecture](#architecture)
- [System Integrations](#system-integrations)
- [Additional Coaching Points](#additional-coaching-points)
- [Taking it further…](#taking-it-further)
- [Credits](#credits)
- [License](#license)


## Featuring

- Dynamic Organization: An organized, customizable approach for your projects. Create reminders to enable optimal prioritization to meet timelines.
- Tracking Productivity: Never miss an important timeline and ensure information doesn’t get lost in the shuffle.
- Sharing: Internal chat tool enabling teams and individuals to share updates.
- Accessible: VoiceOver, Haptics, Local notifications.


## Architecture

- Modeled with Core Data using an inverse relationship with parent/child entities "To Many".
- Integrating CloudKit to enable sharing functionality.
- Primarily composed without UIKit except for bridging shortcut(Quick Action) capabilities and resigning the First Responder in order to dismiss the keyboard in TextEditor.
- Pragmatically utilizing MVVM where necessary.


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

- FocusState - keyboard label, prioritization.
- Custom TextField (clear functionality)
- Markdown with String interpolation.
- "note" data model attribute (TextEditor)
- CKQueryOperation deprecated fix (recordsMatchedBlock, queryResultBlock, 
- Rendering Markdown content within text.
- Navigating ProjectSummary
- List/ForEach from bindings
- enabling text selection
- Adjusting list row seperator, visibility, and color.
- WelcomeView - Features, About Peanut & Privacy, json decodable.
- AboutView - Insettable Edge. Scrollable with formatting and confirmation.
- ProgressTiled - Project Summary on TodayView using guage meter.
- Shadows and glows (inner, raised)
- NotesHeader - dismissing TextEditor
- DatePicker - graphical
- onDelete, task
- result in, switch…  
- Dismissing keyboard in TextEditor


## Credits

Learning from [Paul Hudson](https://www.hackingwithswift.com).


## License

Peanut is MIT licensed, as found in the [LICENSE](/LICENSE) file.
