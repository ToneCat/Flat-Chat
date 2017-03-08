@interface IMItem : NSObject

@property (nonatomic) long long type;
@property (nonatomic) long long messageID;
@property (nonatomic, retain) NSString *unformattedID;
@property (nonatomic, retain) NSString *service;

@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) NSString *accountID;
@property (nonatomic, retain) NSString *handle;
@property (nonatomic, retain) NSString *countryCode;
@property (nonatomic, retain) NSString *guid;

@property (nonatomic, retain) NSString *roomName;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSDictionary *senderInfo;

@property (nonatomic, readonly) BOOL isFromMe;
@property (nonatomic, retain) id context;
@property (nonatomic, retain) NSDate *time;

@end

@interface CKBalloonImageView : UIView
@end

@interface CKTextBalloonView : UIView
-(void)sizeToFit;
@end

@interface CKContactBalloonView

@property (nonatomic, retain) UILabel *nameLabel;

@end

@interface CKAvatarNavigationBar : UINavigationBar
@end

@interface CKColoredBalloonView : UIView
-(void)updateWantsGradient;
@property (nonatomic, retain) CKBalloonImageView *effectViewMask;
@end

@interface NSConcreteAttributedString : NSAttributedString
- (id)attributesAtIndex:(unsigned int)arg1 effectiveRange:(NSRange *)arg2;
- (id)string;
@end

@interface IMChatItem : NSObject
-(IMItem *)_item;
@end

@interface IMTranscriptChatItem : IMChatItem
@end

@interface CKTranscriptCollectionView : UIView
-(void)setBackgroundView:(UIView *)arg1;
@end

@interface CKConversationListCell : UITableViewCell

@end

@interface CKChatItem : NSObject
@property (nonatomic, retain) IMTranscriptChatItem *IMChatItem;
@end

@interface CKGradientView : UIView
- (CALayer*)gradientLayer;
- (void)setGradientLayer:(id)arg1;
@property (nonatomic) CGRect gradientFrame;
@end

@interface UIView (FindUIViewController)
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;
@end

@interface CKTranscriptCollectionViewController : UIViewController
-(IMItem *)_item;
@end

@interface CKTranscriptCell
-(void)sizeToFit;
- (void)layoutSubviews;
- (void)layoutSubviewsForAlignmentContents;
- (void)layoutSubviewsForContents;
- (void)layoutSubviewsForDrawer;
@end

@interface CKAvatarContactNameCollectionReusableView

@property (nonatomic, retain)UILabel *titleLabel;

@end

@interface CKTranscriptLabelCell

@property (nonatomic, retain)UILabel *label;

@end

#define BACKGROUNDCOLOR [UIColor colorWithRed:0.98 green:0.96 blue:0.95 alpha:1.0]
#define IMESSAGEBUBBLE [UIColor colorWithRed:0.49 green:0.73 blue:0.83 alpha:1.0]
#define SMSBUBBLE [UIColor colorWithRed:0.61 green:0.76 blue:0.75 alpha:1.0]
#define BLACKTEXT [UIColor colorWithRed:0.57 green:0.59 blue:0.62 alpha:1.0]

static bool fromMoi;
static bool iMessme;

%hook CKTranscriptCell

-(void)configureForChatItem:(id)arg1
{
	CKChatItem *chatItem = arg1;
	fromMoi = [[[chatItem IMChatItem] _item] isFromMe];
	iMessme = [[[[chatItem IMChatItem] _item] service] isEqualToString:@"SMS"];
	%orig;
}


%end

%hook CKBalloonView

-(BOOL) canUseOpaqueMask
{
	return FALSE;
}

%end


%hook CKColoredBalloonView


-(BOOL) color {
	return TRUE;
}

-(BOOL)wantsGradient{
	return TRUE;
}

-(void)setWantsGradient:(BOOL)arg1{
	%log;
	%orig;
}

-(void)updateWantsGradient{
	%log;
	%orig;
}

-(void)setGradientView:(CKGradientView *)arg1{
	
	%orig;
}

%end


%hook CKGradientView


-(CALayer *)gradientLayer{
	self.layer.masksToBounds = NO;
	CALayer *newLayer = %orig;
	[newLayer setMasksToBounds:NO];
	newLayer.cornerRadius = 0;
	//HBLogDebug(@"Called grad layer");
	

	CAShapeLayer *maskLayer = [CAShapeLayer layer];

	UIBezierPath *maskPath;

	maskPath = [UIBezierPath
	    bezierPathWithRoundedRect:self.bounds
	    byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerTopLeft)
	    cornerRadii:CGSizeMake(10, 10)
	];

	maskLayer.frame = self.bounds;
	maskLayer.path = maskPath.CGPath;
	
	/*
	maskLayer.shadowOffset = CGSizeMake(0, 2);
	maskLayer.shadowRadius = 5.0;
	maskLayer.shadowColor = [UIColor blackColor].CGColor;
	maskLayer.shadowOpacity = 0.8;
	*/
	self.layer.shadowOffset = CGSizeMake(0, 1);
	self.layer.shadowRadius = 2.0;
	self.layer.shadowColor = BLACKTEXT.CGColor;
	self.layer.shadowOpacity = 0.5;


	//[newLayer addSublayer:maskLayer];
	
	newLayer.mask = maskLayer;
	
	return newLayer;
}

-(id)colors
{
	NSMutableArray *arrays = [NSMutableArray array];
	if(fromMoi && !iMessme)
	{
		[arrays addObject:IMESSAGEBUBBLE];
		[arrays addObject:IMESSAGEBUBBLE];
	} else if (fromMoi && iMessme){
		[arrays addObject:SMSBUBBLE];
		[arrays addObject:SMSBUBBLE];
	}
	else
	{
		[arrays addObject:BACKGROUNDCOLOR];
		[arrays addObject:BACKGROUNDCOLOR];
	}
	return arrays;
}


%end

%hook CKAvatarNavigationBar

-(void)layoutSubviews{
	%orig;
	[self setTranslucent:YES];
	[self setBarTintColor:BACKGROUNDCOLOR];
	[self setTintColor:SMSBUBBLE];
	self.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"Futura-Medium" size:15.5f]};
	[self setBarStyle:1];
}

%end

%hook CKTextBalloonView

-(void)layoutSubviews{
	[self sizeToFit];
	%orig;
	if (self.frame.origin.x > 90){
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		CGFloat screenWidth = screenRect.size.width;
		self.frame = CGRectMake(screenWidth-10-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
	}	
}

- (void)setAttributedText:(NSConcreteAttributedString *)arg1
{
	NSConcreteAttributedString *originalText = arg1;
	NSMutableDictionary *mDict = [[originalText attributesAtIndex:0 effectiveRange:nil] mutableCopy];
	if(fromMoi){
		mDict[@"NSColor"] = BACKGROUNDCOLOR;
		mDict[NSFontAttributeName] = [UIFont fontWithName:@"Futura-Medium" size:15.5f];
	}
	else{
		mDict[@"NSColor"] = BLACKTEXT;
		mDict[NSFontAttributeName] = [UIFont fontWithName:@"Futura-Medium" size:15.5f];
	}

	arg1 = [[NSConcreteAttributedString alloc] initWithString:[originalText string] attributes:mDict];
	%orig;

	//return newText;
	
}

%end


%hook CKTranscriptCollectionView

-(void)setBackgroundColor:(UIColor *)color
{
	color = BACKGROUNDCOLOR;
	%orig;
}



%end

%hook CKMessageEntryView

-(void)setShouldHideBackgroundView:(BOOL)arg1{
	arg1=true;
	%orig;
}

%end

%hook CKConversationListCell

-(void)setBackgroundColor:(UIColor *)arg1{
	arg1 = BACKGROUNDCOLOR;
	%orig;
}

-(void)layoutSubviews{
	%orig;

	UILabel *fLabel = MSHookIvar<UILabel *>(self, "_fromLabel");
	[fLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:15.5f]];
	UILabel *dLabel = MSHookIvar<UILabel *>(self, "_dateLabel");
	[dLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:12.0f]];
	UILabel *sLabel = MSHookIvar<UILabel *>(self, "_summaryLabel");
	[sLabel setFont:[UIFont fontWithName:@"Futura-Medium" size:13.5f]];

}


%end

%hook UIButtonLabel

-(void)setFont:(UIFont *)arg1{
	arg1 = [UIFont fontWithName:@"Futura-Medium" size:15.5f];
	%orig;
}

%end

%hook CKAvatarContactNameCollectionReusableView

-(void)layoutSubviews{
	%orig;
	[[self titleLabel] setFont:[UIFont fontWithName:@"Futura-Medium" size:12.0f]];
	[[self titleLabel] setTextColor:BLACKTEXT];
}

%end

%hook CKTranscriptLabelCell

-(void)layoutSubviewsForContents{
	[[self label] setFont:[UIFont fontWithName:@"Futura-Medium" size:10.0f]];
	%orig;
}

%end

%hook CKContactBalloonView

-(void)layoutSubviews{
	%orig;
	[[self nameLabel] setTextColor:BLACKTEXT];
}

%end

%hook CKTranscriptPluginBalloonView

-(void)layoutSubviews{
	%orig;
	[self setTintColor:SMSBUBBLE];
}

%end
