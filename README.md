# GVUserDefaults - NSUserDefaults access via properties


## Usage
Create a category on `GVUserDefaults`, add some properties in the .h file and make them `@dynamic` in the .m file.

    // .h
    @interface GVUserDefaults (Mine)
    @property NSString *userName;
    @property NSNumber *userId;
    @end

    // .m
    @implementation GVUserDefaults (Mine)
    @dynamic userName;
    @dynamic userId;
    @end

Now, instead of using `[[NSUserDefaults standardUserDefaults] objectForKey:@"NSUSerDefault:userName"]`, you can simply use `[GVUserDefaults standardUserDefaults].userName`.

You can even save defaults by setting the property:

    [GVUserDefaults standardUserDefaults].userName = @"myusername";


## Install
Install via [CocoaPods](http://cocoapods.org) (`pod GVUserDefaults`) or drag the code in GVUserDefaults to your project.


## Issues and questions
Have a bug? Please [create an issue on GitHub](https://github.com/gangverk/GVUserDefaults/issues)!


## Contributing
GVUserDefaults is an open source project and your contribution is very much appreciated.

1. Check for [open issues](https://github.com/gangverk/GVUserDefaults/issues) or [open a fresh issue](https://github.com/gangverk/GVUserDefaults/issues/new) to start a discussion around a feature idea or a bug.
2. Fork the [repository on Github](https://github.com/gangverk/GVUserDefaults) and make your changes on the **develop** branch (or branch off of it).
3. Write tests, make sure everything passes.
4. Make sure to add yourself to AUTHORS and send a pull request.


## License
GVUserDefaults is available under the MIT license. See the LICENSE file for more info.
