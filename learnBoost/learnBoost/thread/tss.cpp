//
//  tss.c
//  learnBoost
//
//  Created by fenglin on 2017/11/2.
//  Copyright © 2017年 fenglin. All rights reserved.
//


/*
 * 函数 pthread_key_create() 用来创建线程私有数据。
 该函数从 TSD 池中分配一项，将其地址值赋给 key 供以后访问使用。
 第 2 个参数是一个销毁函数，它是可选的，可以为 NULL，为 NULL 时，则系统调用默认的销毁函数进行相关的数据注销。
 如果不为空，则在线程退出时(调用 pthread_exit() 函数)时将以 key 锁关联的数据作为参数调用它，以释放分配的缓冲区，或是关闭文件流等。
 
 不论哪个线程调用了 pthread_key_create()，所创建的 key 都是所有线程可以访问的，但各个线程可以根据自己的需要往 key 中填入不同的值，相当于提供了一个同名而不同值的全局变量(这个全局变量相对于拥有这个变量的线程来说)。
 
 注销一个 TSD 使用 pthread_key_delete() 函数。该函数并不检查当前是否有线程正在使用该 TSD，也不会调用清理函数(destructor function)，而只是将 TSD 释放以供下一次调用 pthread_key_create() 使用。在 LinuxThread 中，它还会将与之相关的线程数据项设置为 NULL
 
 C++中的explicit关键字只能用于修饰只有一个参数的类构造函数, 它的作用是表明该构造函数是显示的, 而非隐式的, 跟它相对应的另一个关键字是implicit, 意思是隐藏的,类构造函数默认情况下即声明为implicit(隐式).
 [pthread_key_create]
 http://www.cnblogs.com/klcf0220/p/5807148.html
 http://www.jianshu.com/p/d52c1ebf808a
 [explicit]
 http://www.cnblogs.com/ymy124/p/3632634.html
 
 
 */


#include <stdio.h>

#ifndef TSS_H_
#define TSS_H_

#include <pthread.h>
#include <unistd.h>

typedef void (*cleanup_route)(void*);

class Tss {
public:
    explicit Tss(cleanup_route cleanup) {
        pthread_key_create(&_key, cleanup);
    }
    
    ~Tss() {
        pthread_key_delete(_key);
    }
    
    void* get() const {
        return pthread_getspecific(_key);
    }
    
    void set(void* value) {
        pthread_setspecific(_key, value);
    }
    
private:
    Tss(const Tss&);
    Tss& operator =(const Tss&);
    
private:
    pthread_key_t _key;
};

#endif


void cleanup(void *){
    
}

Tss tss(cleanup);

void* thread1(void* a){
    int b= 100;
    tss.set(&b);
    while (1) {
        usleep(200);
        printf("thread1_1 ret-> %d - %lu \n",*((int *)tss.get()),(unsigned long)pthread_self());
        sleep(2);
        printf("thread1_2 ret-> %d - %lu \n",*((int *)tss.get()),(unsigned long)pthread_self());
        pthread_exit(a);
    }
    return a;
}

void* thread2(void* a){
    int c =22;
    tss.set(&c);
    while (1) {
        usleep(200);
        printf("thread2_1 ret-> %d - %lu \n",*((int *)tss.get()),(unsigned long)pthread_self());
        sleep(2);
        printf("thread2_2 ret-> %d - %lu \n",*((int *)tss.get()),(unsigned long)pthread_self());
        pthread_exit(a);
    }
    
   return a;
}
int main(){
    
    pthread_t t1,t2;
    
    pthread_create(&t1, NULL, thread1, &t1);
    pthread_create(&t2, NULL, thread2, &t2);
    
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    
    return 0;
}








