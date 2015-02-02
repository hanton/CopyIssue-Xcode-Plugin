## Makes Copy Xcode Issue Description Easily

- The plugin is useful when you want to google solutions for Xcode `error` or `warning`.

If you use the standard "Copy"(command+c) to copy `error` or `warning` in the `Issue Navigator`, you will get "Issue Position + Issue Description" - `/Users/Hanton/GitHub/HTYCopyIssue/HTYCopyIssue/HTYCopyIssue.m:21:7: Use of undeclared identifier 'sharedPlugin'`.

But if you use the "Copy Issue"(command+shift+v), you will only get the "Issue Description" - `Use of undeclared identifier 'sharedPlugin'`.

Then, you can paste the `error` or `warning` description directly to the search engine for finding the solution. 

![ScreenShoot](https://github.com/hanton/CopyIssue-Xcode-Plugin/blob/master/ScreenShot.png)


## Install

Install via [Alcatraz](http://alcatraz.io/)

OR

Clone and build the project, then restart Xcode.

## Uninstall

Uninstall via [Alcatraz](http://alcatraz.io/)

OR

Run `rm -r ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/HTYCopyIssue.xcplugin/`


## TODO
- Add 'Copy Issue' to right click's context menu
