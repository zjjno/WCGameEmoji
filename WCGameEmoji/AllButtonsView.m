
#define ButtonsCount 10
#define LineCount    5
#define ButtonsWidth 45
#define ButtonsSpace 10

#import "AllButtonsView.h"
#import "WeChatObject.h"
#import "objc/runtime.h"

@interface AllButtonsView ()
@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, assign) int m_uiGameContent;
@end
@implementation AllButtonsView

+ (instancetype)sharedInstance {
    
    static AllButtonsView *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[AllButtonsView alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    if(self = [super init]) {
        _buttonsArray = @[].mutableCopy;
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.userInteractionEnabled = YES;

        float maxy;
        float ox = (LTSWidth - (ButtonsSpace * (LineCount-1)) - ButtonsWidth * LineCount)/2;
        float oy = LTSHeight/2 - ButtonsWidth - ButtonsSpace/2;
        for (int i = 1; i < ButtonsCount; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(ox+(ButtonsSpace+ButtonsWidth)*(i%LineCount), oy+(ButtonsSpace+ButtonsWidth)*(i/LineCount), ButtonsWidth, ButtonsWidth);
            [button addTarget:self action:@selector(selectEmoji:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor lightGrayColor];
            if (i == 1) {
                [button setTitle:@"剪" forState:UIControlStateNormal];
            }else if (i == 2) {
                [button setTitle:@"石" forState:UIControlStateNormal];
            }else if (i == 3) {
                [button setTitle:@"布" forState:UIControlStateNormal];
            }else if (i == 4) {
                [button setTitle:[NSString stringWithFormat:@"%d",1] forState:UIControlStateNormal];
            }else if (i == 5) {
                [button setTitle:[NSString stringWithFormat:@"%d",2] forState:UIControlStateNormal];
            }else if (i == 6) {
                [button setTitle:[NSString stringWithFormat:@"%d",3] forState:UIControlStateNormal];
            }else if (i == 7) {
                [button setTitle:[NSString stringWithFormat:@"%d",4] forState:UIControlStateNormal];
            }else if (i == 8) {
                [button setTitle:[NSString stringWithFormat:@"%d",5] forState:UIControlStateNormal];
            }else if (i == 9) {
                [button setTitle:[NSString stringWithFormat:@"%d",6] forState:UIControlStateNormal];
            }
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [self addSubview:button];
            
            button.tag = 10+i;
            button.layer.cornerRadius = button.frame.size.width/2;
            button.layer.masksToBounds = YES;

            [_buttonsArray addObject:button];
            
            maxy = CGRectGetMaxY(button.frame);
        }

        UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sureButton.frame = CGRectMake((LTSWidth-200)/2, maxy + 15, 200, 35);
        [sureButton addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
        sureButton.backgroundColor = [UIColor lightGrayColor];
        [sureButton setTitle:@"发送" forState:UIControlStateNormal];
        [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:sureButton];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;

        self.frame = window.bounds;
        self.hidden = YES;
        
        [window addSubview:self];
        [window bringSubviewToFront:self];
    }
    
    return self;
}

- (void)selectEmoji:(UIButton *)btn {
    for (UIButton *button in _buttonsArray) {
        button.selected = NO;
    }
    btn.selected = YES;
    
    _m_uiGameContent = (int)btn.tag-10;
}

- (void)sure {
    if (_m_uiGameContent != 0 && _m_nsToUsr.length > 0) {
        
        CContactMgr *cMgr =  [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
        CContact *contact = [cMgr getSelfContact];
        
        CMessageMgr *messager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CMessageMgr") class]];
        MMNewSessionMgr *sessionMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("MMNewSessionMgr") class]];
        long long date = [sessionMgr GenSendMsgTime];
        //Emoji type 47
        CMessageWrap *wrap = [[objc_getClass("CMessageWrap") alloc] initWithMsgType:47];
        
        wrap.m_uiMessageType = 47;
        
        wrap.m_nsFromUsr = contact.m_nsUsrName;
        wrap.m_nsToUsr = _m_nsToUsr;
        wrap.m_uiCreateTime = date;
        wrap.m_uiStatus = 1;
        wrap.m_uiImgStatus = 1;
        
        if (_m_uiGameContent<=3) {
            //m_uiGameType:1 _m_uiGameContent 1-3:剪刀 石头 布
            wrap.m_nsEmoticonMD5 = @"F790E342A02E0F99D34B316547F9AEAB";
            wrap.m_uiGameType = 1;
        }else {
            //m_uiGameType:2 _m_uiGameContent 4-9:1-6
            wrap.m_nsEmoticonMD5 = @"9E3F303561566DC9342A3EA41E6552A6";
            wrap.m_uiGameType = 2;
        }
        wrap.m_uiGameContent = _m_uiGameContent;
        wrap.m_uiEmoticonType = 1;
        
        [messager AddEmoticonMsg:_m_nsToUsr MsgWrap:wrap];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}
@end
