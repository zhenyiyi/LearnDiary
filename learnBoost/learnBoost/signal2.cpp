//
//  signal2.cpp
//  learnBoost
//
//  Created by fenglin on 2017/10/31.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#include <stdio.h>
#include "boost/signals2.hpp"

static void app_event(bool isActice){
    printf("isActice == %d\n",isActice);
}
static void app_foreground(bool foreground){
    printf("foreground == %d\n",foreground);
}

static boost::signals2::signal<void (bool isActice)> sig;

static int boot_run(){
    sig.connect(&app_event);
    sig.connect(&app_foreground);
    return 0;
}

static int app_logic = boot_run();

int main(){
    sig(false);
    sleep(3);
    sig(true);
    return 0;
}
