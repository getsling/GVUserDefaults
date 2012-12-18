# GVUserDefaults - NSUserDefaults access via properties

Tired of writing all that code to get and set defaults in NSUserDefaults? Want to have code completion and compiler checks by using properties instead?

## Usage
Create a category on `GVUserDefaults`, add some properties in the .h file and make them `@dynamic` in the .m file.

    // .h
    @interface GVUserDefaults (Properties)
    @property NSString *userName;
    @property NSNumber *userId;
    @end

    // .m
    @implementation GVUserDefaults (Properties)
    @dynamic userName;
    @dynamic userId;
    @end

Now, instead of using `[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]`, you can simply use `[GVUserDefaults standardUserDefaults].userName`.

You can even save defaults by setting the property:

    [GVUserDefaults standardUserDefaults].userName = @"myusername";

### Key prefix
The keys in NSUserDefaults are the same name as your properties. If you'd like to prefix them, add a `prefix` method to your category:

    - (NSString *)prefix {
        return @"NSUSerDefault:";
    }

### Registering defaults
Registering defaults is done as usual, on NSUserDefaults directly (use the same prefix, if any!).

    NSDictionary *defaults = @{
        @"NSUSerDefault:userName": @"default",
        @"NSUSerDefault:userId": @1
    };

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];


## Install
Install via [CocoaPods](http://cocoapods.org) (`pod 'GVUserDefaults'`) or drag the code in GVUserDefaults to your project.


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
