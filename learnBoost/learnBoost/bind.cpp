//
//  bind.cpp
//  TestBoost
//
//  Created by fenglin on 2017/10/30.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#include <stdio.h>
#include <iostream>
#include "boost/function.hpp"
#include "boost/bind.hpp"
#include <string>
using namespace std;

//非类方法 boost::bind(函数名，参数1,参数2,...);
//类方法 boost::bind(函数名,类实例指针,参数1,参数2,...);

class Query {
public:
    static void onStart(int a){
        cout << "onStart" << a << endl;
    }
    
    void onEnd(){
        cout << "onEnd" << endl;
    }
    
    void test(int a, int b){
        cout << "test a==" << a << " b==" << b  << endl;
    }
};

int main(int argc, const char * argv[]) { 
    Query q;
    boost::bind(q.onStart,2)();
    boost::bind(&Query::onStart,1)();
    boost::bind(&Query::onEnd,&q)();
    boost::function<void(int,int)> f = boost::bind(&Query::test,&q,_1,_2);
    f(3,4);
    return 0;
}
