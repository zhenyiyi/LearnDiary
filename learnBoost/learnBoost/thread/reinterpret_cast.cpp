//
//  reinterpret_cast.cpp
//  learnBoost
//
//  Created by fenglin on 2017/11/2.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#include <stdio.h>
#include <stdint.h>

//reinterpret_cast运算符是用来处理无关类型之间的转换；它会产生一个新的值，这个值会有与原始参数（expressoin）有完全相同的比特位


class A {
public:
//    A():_magic(reinterpret_cast<uintptr_t>(this)){
//        printf("this-> %p\n",this);
//    }
    A():_magic((uintptr_t)this){
        printf("this-> %p\n",this);
    }
public:
    uintptr_t _magic;
};
int main(){
    
    A a;
    printf("%0lx\n",a._magic);
    return 0;
}
