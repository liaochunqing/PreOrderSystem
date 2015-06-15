//
//  PrintSearchingTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-4-24.
//
//

#import "PrintSearchingTableViewCell.h"
#import "StarIO/SMPort.h"
#import "PrinterFunctions.h"
#import "PSAlertView.h"

#define kCellHight 60

@implementation PrintSearchingTableViewCell 
{
    SMPort *_smPort;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updatePrinterInfo:(PortInfo *)info defaultSearchingPrinterArray:(NSArray*)array
{
    if (info)
    {
        NSString *portName = kLoc(info.portName);
        NSString *macAddress = kLoc(info.macAddress);
        NSString *modelName = kLoc(info.modelName);
        _printerInfo = [[PortInfo alloc] initWithPortName:portName macAddress:macAddress modelName:modelName];
        
        NSString *customName = nil;
        for (int i = 0; i < array.count; i++)
        {
            // 匹配mac地址
            NSDictionary* dict = array[i];
            
            if (dict)
            {
                NSString *macAddressFromOther = [dict objectForKey:@"printerMac"];
                
                if(NSOrderedSame == [macAddress compare:macAddressFromOther])
                {
                    customName = [dict objectForKey:@"printerName"];
                }
            }
        }

        if ([modelName compare:customName] == NSOrderedSame || [customName length] == 0)
        {
            self.infoLabel.text = [NSString stringWithFormat:@"%@", modelName];
        }
        else
        {
           self.infoLabel.text = [NSString stringWithFormat:@"%@:%@", customName,modelName];
        }
        
        NSString *ip = @"";
        if ([info.portName length] > 5)
        {
            ip = [info.portName substringFromIndex:4];
        }
        self.ipLabel.text = [NSString stringWithFormat:@"IP:%@", ip];
        
        [self setPrinterDisconnectStatus];
    }
}


// 默认主动连接外面已有的打印机，根据mac地址匹配
- (void)defaultConnected:(PortInfo *)info defaultSearchingPrinterArray:(NSArray*)array
{
    NSString *macAddress = info.macAddress;
  
    for (int i = 0; i < array.count; i++)
    {
        // 匹配mac地址
        NSDictionary* dict = array[i];
        
        if (dict)
        {
            NSString *macAddressFromOther = [dict objectForKey:@"printerMac"];
            
            if(NSOrderedSame == [macAddress compare:macAddressFromOther])
            {
                [self connectBtnClick:self.connectBtn];
            }
        }
    }
}


- (IBAction)connectBtnClick:(UIButton *)sender
{
    if (_connectedStatus == 0)
    {
        [self connectingPrinters];
    }
    else
    {
        if (_smPort)
        {
            [_smPort disconnect];
            [SMPort releasePort:_smPort];
        }
        
        [self setPrinterDisconnectStatus];
        
#if 0
        NSString *titleStr = [NSString stringWithFormat:@"%@%@(%@)%@",kLoc(@"sure_to_cancel_link_printer", nil), _printerInfo.modelName, _printerInfo.portName,kLoc(@"what", nil)];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr message:nil delegate:self cancelButtonTitle:kLoc(@"cancel", nil) otherButtonTitles:kLoc(@"confirm"), nil];
        alert.tag = 2;
        [alert show];
#endif
    }
    
}

-(void)connectingPrinters
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.delegate = self;
    [window addSubview:HUD];
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = kLoc(@"connecting_to_printer") ;
    [HUD showWhileExecuting:@selector(connectingPrintersInBackground) onTarget:self withObject:nil animated:YES];
}

-(void)connectingPrintersInBackground
{
    NSString *modelName = nil;
    NSString *portName = nil;

//    _smPort = [PrinterFunctions CheckStatusWithPortname:_printerInfo.portName portSettings:@"20000"];
    _smPort = [SMPort getPort:_printerInfo.portName :@"E":10000];
    
    
    if (_smPort)
    {
        [self setPrinterConnectStatus];
    }
    else
    {
        [self setPrinterDisconnectStatus];
        [self performSelectorOnMainThread:@selector(showConnectingFailPrompt) withObject:nil waitUntilDone:YES];
    }
        
    modelName = _printerInfo.modelName;
    portName = _printerInfo.portName;
}

- (void)setPrinterConnectStatus
{
    _connectedStatus = 1;
    [self.connectBtn setTitle:kLoc(@"disconnect") forState:UIControlStateNormal];
    [self.connectBtn setBackgroundImage:[UIImage imageNamed:@"strPrinterDisconnected.png"] forState:UIControlStateNormal];
    [self.connectStatus setTitle:kLoc(@"connected") forState:UIControlStateNormal];
    [self.connectStatus setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
}

- (void)setPrinterDisconnectStatus
{
    _connectedStatus = 0;
    [self.connectBtn setTitle:kLoc(@"connect") forState:UIControlStateNormal];
    [self.connectBtn setBackgroundImage:[UIImage imageNamed:@"more_longButton.png"] forState:UIControlStateNormal];
    [self.connectStatus setTitle:kLoc(@"not_connected") forState:UIControlStateNormal];
    [self.connectStatus setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

-(void)showConnectingSuccessPrompt
{
//    [PSAlertView showWithMessage:kLoc(@"票据打印机连接成功", nil)];
}

-(void)showConnectingFailPrompt
{
    [PSAlertView showWithMessage:kLoc(@"connect_to_printer_failed")];
}

-(void)showPromptForDisconnectPrinter
{
//    [PSAlertView showWithMessage:kLoc(@"己取消连接打印机", nil)];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1 && buttonIndex==1)
    {
        [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(connectingPrinters) userInfo:nil repeats:NO];
    }
    
    if (alertView.tag==2 && buttonIndex==1)
    {
        [self setPrinterDisconnectStatus];
    }
}

@end
