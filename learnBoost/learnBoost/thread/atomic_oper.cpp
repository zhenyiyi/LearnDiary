//
//  atomic_oper.cpp
//  learnBoost
//
//  Created by fenglin on 2017/11/2.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#include <stdio.h>
#include <stdint.h>
#include <sys/syscall.h>
#include <pthread.h>
#include <unistd.h>


inline uint32_t atomic_add32(volatile uint32_t*mem, uint32_t val){
    return __sync_fetch_and_add(const_cast<uint32_t *>(mem),val);
}

//! Atomically increment an uint32_t by 1
//! "mem": pointer to the object
//! Returns the old value pointed to by mem
inline uint32_t atomic_inc32(volatile uint32_t *mem){
    return  atomic_add32(mem, 1);
}

//! Atomically decrement an uint32_t by 1
//! "mem": pointer to the atomic value
//! Returns the old value pointed to by mem
inline uint32_t atomic_dec32(volatile uint32_t *mem)
{  return atomic_add32(mem, (uint32_t)-1);   }

//! Atomically read an uint32_t from memory
inline uint32_t atomic_read32(volatile uint32_t *mem){
    uint32_t old_val = *mem;
    __sync_synchronize();
    return old_val;
}

//! Atomically set an uint32_t in memory
//! "mem": pointer to the object
//! "param": val value that the object will assume
inline void atomic_write32(volatile uint32_t *mem, uint32_t val){
    __sync_synchronize();
    *mem = val;
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

static uint32_t seq = 0;
void print(){
   printf("seq %d\n",seq);
}

void* thread1(void *a){
    do {
        atomic_inc32(&seq);
        usleep(200);
        print();
    } while (seq < 100);
    print();
    atomic_read32(&seq);
    printf("thread1 ret-> %d\n",seq);
    pthread_exit(a);
}

void* thread2(void *b){
    while (1) {
        usleep(5000);
        atomic_dec32(&seq);
        printf("dec %d",seq);
        break;
    }
    atomic_read32(&seq);
    printf("thread2 ret-> %d\n",seq);
     pthread_exit(b);
    return b;
}

int main(){
    pthread_t t1,t2;
    
    pthread_create(&t1, NULL, thread1, &t1);
    pthread_create(&t2, NULL, thread2, &t1);
    
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    
    
   
    
    
    return 0;
}
