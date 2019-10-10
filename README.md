# Makes Copy Xcode Issue Description Easy, Support Finding Answers in Google or StackOverflow Directly

The plugin is useful when you want to search for solutions for any Xcode issues e.g. `error` or `warning`.

It can copy the full issue description or it can automatically open your default browser and search Google (default shortcut ⇧⌥G) or Stackoverflow (default shortcut ⇧⌥S) for the selected issue.


## What's the Difference


- If you use the standard "Copy" (⌘C) to copy `error` or `warning` in the `Issue Navigator`, you will get "Issue Position + Issue Description":

`/Users/Hanton/GitHub/HTYCopyIssue/HTYCopyIssue/HTYCopyIssue.m:21:7: Use of undeclared identifier 'sharedPlugin'`

- But if you use the "Copy Issue" (⇧⌘V), you will only get the "Issue Description":

`Use of undeclared identifier 'sharedPlugin'`


Then, you can paste it directly to the search engine for finding the solution. Or select an entry in the “ASK THE INTERNET” menu to open your default browser with a Google or Stackoverflow search.

![](screenshots/ScreenShot.png?raw=true)

![](screenshots/Screenshot_Menu.png?raw=true)

#### Strip content inside quotation marks

Per default, everything inside `'` and `"` is removed from the search query. Typically this includes local variable or method names.


## How to Use
1. Select the `error` or `warning` in the Issue Navigator;                      
![Step1](screenshots/Step1.png?raw=true)

2. Use shortcut `⌘⇧C`, or click the "Copy Issue" menu item in the Edit Menu;
![Step2](screenshots/Step2.png?raw=true)

Alternatively, click the Copy Issue menu item in the context menu;
![Step2Alternate](screenshots/Step2Alternate.png?raw=true)

3. Paste the Issue Description to the search engine.
![Step3](screenshots/Step3.png?raw=true)

## Install

Install via [Alcatraz](http://alcatraz.io/)

OR

Clone and build the project, then restart Xcode.

## Uninstall

Uninstall via [Alcatraz](http://alcatraz.io/)

OR

`rm -r ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/HTYCopyIssue.xcplugin/`

## Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/hanton/CopyIssue-Xcode-Plugin/graphs/contributors"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Become a financial contributor and help us sustain our community. [[Contribute](https://opencollective.com/CopyIssue-Xcode-Plugin/contribute)]

#### Individuals

<a href="https://opencollective.com/CopyIssue-Xcode-Plugin"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/individuals.svg?width=890"></a>

#### Organizations

Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/CopyIssue-Xcode-Plugin/contribute)]

<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/0/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/0/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/1/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/1/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/2/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/2/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/3/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/3/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/4/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/4/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/5/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/5/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/6/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/6/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/7/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/7/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/8/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/8/avatar.svg"></a>
<a href="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/9/website"><img src="https://opencollective.com/CopyIssue-Xcode-Plugin/organization/9/avatar.svg"></a>
