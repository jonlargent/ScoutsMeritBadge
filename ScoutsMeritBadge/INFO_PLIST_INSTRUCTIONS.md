# Info.plist Configuration

To enable web scraping, you need to add the following to your Info.plist file:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>scouting.org</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

## How to add this:

1. In Xcode, click on your project in the navigator
2. Select your app target
3. Go to the "Info" tab
4. Right-click in the list and select "Add Row"
5. Add "App Transport Security Settings" (NSAppTransportSecurity)
6. Expand it and configure as shown above

Alternatively, you can edit the Info.plist file directly if it exists as a separate file.
