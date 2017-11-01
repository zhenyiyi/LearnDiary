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
#include <vector>

using namespace std;

//非类方法 boost::bind(函数名，参数1,参数2,...);
//类方法 boost::bind(函数名,类实例指针,参数1,参数2,...);


int f(int a, int b){
    return a + b;
}

int g(int a, int b ,int c){
    return a + b*c;
}

typedef decltype(&f) f_type;
typedef decltype(&g) g_type;

void case1(){
    puts("case 1");
    std::cout << boost::bind(f, 1,2)() << std:: endl;
    std::cout << boost::bind(g,1,3,4)() << std:: endl;
    
    int x=1, y=2, z=3;
    cout << boost::bind(f,_1,9)(x) << endl;
    cout << boost::bind(f,_1,_2)(x,y) << endl;
    cout << boost::bind(f,_2,_1)(x,y) << endl;
    cout << boost::bind(f,10,_1)(x,y) << endl;
    puts("");
    cout << boost::bind(g,_2,_1,_3)(x,y,z) << endl;
    cout << boost::bind(g,10,_1,_2)(x,y) << endl;
    puts("");
    f_type pf = f;
    g_type pg = g;
    cout << boost::bind<int>(pf,_2,_1)(x,y,z) << endl;
    cout << boost::bind(pg,10,_1,_2)(x,y) << endl;
}

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

struct demo {
    int f(int a,int b){
        return a+b;
    }
};
struct point {
    int x,y;
    point(int a=0, int b=0):x(a),y(b){};
    void print(){
        cout << "(" << x << "," << y << ")" << endl;
    }
};

void case2(){
    puts("case 2");
    Query q;
    boost::bind(q.onStart,2)();
    boost::bind(&Query::onStart,1)();
    boost::bind(&Query::onEnd,&q)();
    boost::function<void(int,int)> f = boost::bind(&Query::test,&q,_1,_2);
    f(3,4);
    puts("");
    demo d;
    cout << boost::bind(&demo::f,d,_1,_2)(10,30) << endl;
    
    std::vector<point> v;
    v.push_back(point(1,1));
    v.push_back(point(1,2));
    v.push_back(point(1,3));
    v.push_back(point(1,4));
    
    std::for_each(v.begin(), v.end(), boost::bind(&point::print,_1));
}

void case3(){
    vector<point> v(10);
}

//////////////////////////////////////////

struct func {
    int operator()(int a, int b){
        return a + b;
    }
};

void case4(){
    puts("case4");
    cout << boost::bind<int>(func(),_1,_2)(10,4) << endl;
    cout << boost::bind<int>(func(),_1,_2)(10,8) << endl;
}





int main() {
    case1();
    case2();
    case4();
    
    return 0;
}
