//
//  condition.cpp
//  learnBoost
//
//  Created by fenglin on 2017/11/2.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#include <stdio.h>
#include <pthread.h>
#include <stdint.h>
#include <sys/syscall.h>
#include <unistd.h>

inline uint32_t atomic_add32(volatile uint32_t*mem, uint32_t val){
    return __sync_fetch_and_add(const_cast<uint32_t *>(mem),val);
}

//! Compare an uint32_t's value with "cmp".
//! If they are the same swap the value with "with"
//! "mem": pointer to the value
//! "with": what to swap it with
//! "cmp": the value to compare it to
//! Returns the old value of *mem
inline uint32_t atomic_cas32(volatile uint32_t *mem, uint32_t with, uint32_t cmp){
    return __sync_val_compare_and_swap(const_cast<uint32_t *>(mem), cmp, with);
}

class Metux {
    
public:
    Metux(bool recursive = false):_mutex(){
        pthread_mutexattr_init(&_mutexattr);
        pthread_mutexattr_settype(&_mutexattr,recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_ERRORCHECK );
        pthread_mutex_init(&_mutex, &_mutexattr);
    }
    ~Metux(){
        pthread_mutex_destroy(&_mutex);
        pthread_mutexattr_destroy(&_mutexattr);
    }
    void lock(){
        pthread_mutex_lock(&_mutex);
    }
    void unlock(){
        pthread_mutex_unlock(&_mutex);
    }
    bool islocked(){
        int ret = pthread_mutex_trylock(&_mutex);
        if (ret==0) unlock();
        return ret != 0;
    }
    pthread_mutex_t& internal(){
        return _mutex;
    }
private:
    pthread_mutexattr_t _mutexattr;
    pthread_mutex_t _mutex;
};




class Condition {
public:
    Condition(bool lock = false):_cond(),_anywayValue(0),_metux(){
        int ret = pthread_cond_init(&_cond, NULL);
        printf("ret = %d\n",ret);
        if (lock) _metux.lock();
    }
    ~Condition(){
        pthread_cond_destroy(&_cond);
    }
    void wait(){
        if (!atomic_cas32(&_anywayValue, 0, 1)) {
            printf("begin wait cond\n");
            pthread_cond_wait(&_cond, &_metux.internal());
        }
        _anywayValue = 0;
    }
    void notifyOne(){
        pthread_cond_signal(&_cond);
        _anywayValue = 0;
    }
public:
    Metux _metux;
private:
    pthread_cond_t _cond;
    uint32_t _anywayValue;
};



Condition cond;

static int seq = 0;

void* thread1(void *a){
    cond._metux.lock();
    printf("thread1 begin \n");
    cond.wait();
    printf("thread1 end\n");
    cond._metux.unlock();
    return a;
}

void* thread2(void *b){
    printf("thread2 begin\n");
    cond._metux.lock();
    while (1) {
        seq++;
        usleep(200);
        if (seq == 100) {
            printf("notify thread1 execute\n");
            cond.notifyOne();
            break;
        }
    }
    printf("thread2 end\n");
    cond._metux.unlock();
    return b;
}

int main(){
    
    pthread_t t1,t2;
    
    pthread_create(&t1, NULL, thread1, &t1);
    pthread_create(&t2, NULL, thread2, &t1);
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    
    
    
}
