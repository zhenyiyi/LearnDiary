//
//  metux.cpp
//  learnBoost
//
//  Created by fenglin on 2017/11/2.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#include <stdio.h>
#include <pthread.h>


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
