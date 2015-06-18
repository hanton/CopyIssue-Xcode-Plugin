# Makes Copy Xcode Issue Description Easy
## Support Finding Answers in Google or StackOverflow Directly

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

2. Use shortcut `⌘⇧C`, or click the "Copy Issue" menu in the Edit Menu;
![Step2](screenshots/Step2.png?raw=true)

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


## TODO
- Add 'Copy Issue' to right click's context menu
