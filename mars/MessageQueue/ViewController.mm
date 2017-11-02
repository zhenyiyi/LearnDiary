//
//  ViewController.m
//  MessageQueue
//
//  Created by fenglin on 2017/11/1.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#import "ViewController.h"
#include <mars/comm/messagequeue/message_queue.h>
#include <mars/comm/alarm.h>


@interface ViewController ()

@end

@implementation ViewController
static MessageQueue::MessageHandler msgHandler;



void fowardmessage(bool foreground){
   
}

void f(){
    printf("invoke");
}




static class App_logic{
public:
     // 1、绑定全局函数
//    App_logic():a(boost::bind(f)){
//        NSLog(@"App_logic constructor");
//    }
     // 2、绑定静态函数
//    App_logic():a(boost::bind(staticFunc,10)){
//        NSLog(@"App_logic constructor");
//    }
     // 3、绑定成员函数
//    App_logic():a(boost::bind(&App_logic::onActive,this)){
//        NSLog(@"App_logic constructor");
//    }
    // 4、绑定带参数的成员函数
    App_logic():a(boost::bind(&App_logic::onForeground,this,true)){
        NSLog(@"App_logic constructor");
    }
public:
    void onActive(){
        NSLog(@"active->");
    }
    void onForeground(bool foreground){
        NSLog(@"foreground->%d",foreground);
        NSLog(@"currentThread-> %@",[NSThread currentThread]);
        if (MessageQueue::GetDefMessageQueue() != MessageQueue::CurrentThreadMessageQueue()) {
            NSLog(@"");
            MessageQueue::AsyncInvoke(boost::bind(&App_logic::onForeground,this,foreground), (MessageQueue::MessageTitle_t)this,MessageQueue::DefAsyncInvokeHandler(MessageQueue::GetDefMessageQueue()));
            return;
        }
    }
    static void staticFunc(int a){
        NSLog(@"staticFunc a == %d",a);
    }
    void start(int _after){
        a.Start(_after);
    }
private:
    Alarm a;
}sg_App_logic;






- (void)viewDidLoad {
    [super viewDidLoad];

    
    NSLog(@"CurrentThreadMessageQueue-> %llu",MessageQueue::CurrentThreadMessageQueue());
    
    NSLog(@"GetDefMessageQueue-> %llu",MessageQueue::GetDefMessageQueue());
    
    NSLog(@"GetDefTaskQueue-> %llu",MessageQueue::GetDefTaskQueue());
    
    MessageQueue::MessageHandler_t handler = MessageQueue::InstallAsyncHandler(MessageQueue::GetDefMessageQueue());
    
    NSLog(@"handler_queue-> %llu",handler.queue);
    
    ///////////////////////////////////////////////////////
    sg_App_logic.start(1000);
    
    [self performSelector:@selector(testMessageQueue)];
    
    [self performSelector:@selector(testMessageQueue) withObject:nil afterDelay:2];
    
    
    int ret = pthread_kill(pthread_self(), 0);
}

- (void)testMessageQueue{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
