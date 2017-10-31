//
//  function.cpp
//  learnBoost
//
//  Created by fenglin on 2017/10/30.
//  Copyright © 2017年 fenglin. All rights reserved.
//  http://www.cnblogs.com/sld666666/archive/2010/12/16/1907591.html

#include <stdio.h>
#include <iostream>
#include "boost/function.hpp"
#include "boost/bind.hpp"
#include <string>
using namespace std;

typedef boost::function<void (int, int, const string&)> Callback_t;

void test(int n, Callback_t callback = Callback_t()){
    for (int i=0; i<n; i++) {
        if (callback) {
            callback(i,n,"");
        }
    }
}
void print(int index, int total,const string &info){
    cout << "index ==" << index << "  "<< "total ==" << total << " info == "
    << info << endl;
}

class X {
public:
    int foo(int a){
        cout << "foo a==" << a << endl;
        return a;
    }
    
public:
    
};


int main(int argc, const char * argv[]) {
    
    test(100,print);
    test(100,boost::bind(&print ,_1,_2,"compute->"));
    
    boost::function<int (X*,int) > f;
    
    f = &X::foo;
    
    X x1;
    
    f(&x1,5);
    

    
    return 0;
}

