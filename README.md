# GVUserDefaults - NSUserDefaults access via properties

Tired of writing all that code to get and set defaults in NSUserDefaults? Want to have code completion and compiler checks by using properties instead?

## Usage
Create a category on `GVUserDefaults`, add some properties in the .h file and make them `@dynamic` in the .m file.

    // .h
    @interface GVUserDefaults (Properties)
    @property (nonatomic, weak) NSString *userName;
    @property (nonatomic, weak) NSNumber *userId;
    @end

    // .m
    @implementation GVUserDefaults (Properties)
    @dynamic userName;
    @dynamic userId;
    @end

Now, instead of using `[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]`, you can simply use `[GVUserDefaults standardUserDefaults].userName`.

You can even save defaults by setting the property:

    [GVUserDefaults standardUserDefaults].userName = @"myusername";

### Objects only
At this moment only objects can be stored, so no integers or booleans. Just wrap them in an NSNumber.

### Key prefix
The keys in NSUserDefaults are the same name as your properties. If you'd like to prefix or alter them, add a `transformKey:` method to your category. For example, to turn "userName" into "NSUserDefaultUserName":

    - (NSString *)transformKey:(NSString *)key {
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
        return [NSString stringWithFormat:@"NSUserDefault%@", key];
    }

### Registering defaults
Registering defaults is done as usual, on NSUserDefaults directly (use the same prefix, if any!).

    NSDictionary *defaults = @{
        @"NSUserDefaultUserName": @"default",
        @"NSUserDefaultUserId": @1
    };

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];


### Performance
The getter is about 3 times as slow as directly using NSUserDefaults, but we're talking about fractions of a millisecond (0.22 ms vs 0.65 ms on an iPod Touch 4th gen). The setter is about 3 times as slow as well (0.20 ms vs 0.61 ms). 
The numbers vary a bit from device to device and from run to run, but it always seems to be about 1.5 to 3 times as slow. For example on an iPhone 4 the setter takes 0.77 ms vs 0.5 ms when you do it natively.


## Install
Install via [CocoaPods](http://cocoapods.org) (`pod 'GVUserDefaults'`) or drag the code in the GVUserDefaults subfolder to your project.


## Issues and questions
Have a bug? Please [create an issue on GitHub](https://github.com/gangverk/GVUserDefaults/issues)!


## Contributing
GVUserDefaults is an open source project and your contribution is very much appreciated.

1. Check for [open issues](https://github.com/gangverk/GVUserDefaults/issues) or [open a fresh issue](https://github.com/gangverk/GVUserDefaults/issues/new) to start a discussion around a feature idea or a bug.
2. Fork the [repository on Github](https://github.com/gangverk/GVUserDefaults) and make your changes on the **develop** branch (or branch off of it). Please retain the code style that is used in the project.
3. Write tests, make sure everything passes.
4. Make sure to add yourself to AUTHORS and send a pull request.


## License
GVUserDefaults is available under the MIT license. See the LICENSE file for more info.
