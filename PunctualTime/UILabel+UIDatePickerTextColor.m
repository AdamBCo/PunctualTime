#import <objc/runtime.h>
#import "UILabel+UIDatePickerTextColor.h"


static void swizzle(Class klass, SEL from, SEL to) {
    Method method1 = class_getInstanceMethod(klass, from);
    Method method2 = class_getInstanceMethod(klass, to);
    method_exchangeImplementations(method1, method2);
}


@implementation UILabel (TextColor)

+ (void)load {
    swizzle(self, @selector(setTextColor:), @selector(swizzledSetTextColor:));
}

- (BOOL)shouldBeSwizzled {
    NSArray *classes = @[@"UIDatePicker", @"UIDatePickerWeekMonthDayView", @"UIDatePickerContentView"];

    UIView *view = [self superview];
    while (view) {
        id klass = NSStringFromClass(view.class);
        if ([classes containsObject:klass])
            return YES;
        view = view.superview;
    }

    return NO;
}

- (void)swizzledSetTextColor:(UIColor *)newTextColor {
    [self swizzledSetTextColor:self.shouldBeSwizzled ? [UIColor blackColor] : newTextColor];
}

@end
