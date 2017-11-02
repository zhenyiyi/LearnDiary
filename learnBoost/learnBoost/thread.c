
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>

char buffer[128];
int has_data=0;
pthread_mutex_t mutex;
pthread_cond_t cond;
pthread_cond_t cond2;

void read_buf(void)
{
    do
    {
        printf("lock read_buf\n");
        pthread_mutex_lock(&mutex);//锁定互斥锁
        printf("read_buf\n");
        if(has_data==0)
        {
            printf("wait read data\n");
            /*阻塞线程,等待另外一个线程发送信号，同时为公共数据区解锁*/
            pthread_cond_wait(&cond,&mutex);
        }
        else if(has_data==1)
        {
            printf("the data : %s\n",buffer);
            has_data=0;
            pthread_cond_signal(&cond2);
        }
        pthread_mutex_unlock(&mutex);//打开互斥锁
        printf("unlock read_buf\n");
    }while(strcmp(buffer,"#")!=0);
    pthread_exit(NULL);
}

void write_buf(void)
{
    char input[128];
    do
    {
        printf("lock write_buf\n");
        pthread_mutex_lock(&mutex);
        printf("write_buf\n");
        if(has_data==0)
        {
            memset(input,'\0',128);
            printf("input data:\n");
            scanf("%s",input);
            sprintf(buffer,"%s",input);
            has_data=1;
            pthread_cond_signal(&cond);//条件改变，唤醒阻塞的线程
            
        }
        else if(has_data==1)
        {
            pthread_cond_wait(&cond2,&mutex);
        }
        pthread_mutex_unlock(&mutex);
        printf("unlock write_buf\n");
    }while(strcmp(input,"#")!=0);
    pthread_exit(NULL);
}
int main(int argc,char **argv)
{
    pthread_t id,id2;
    pthread_cond_init(&cond,NULL);
    pthread_cond_init(&cond2,NULL);
    pthread_mutex_init(&mutex,NULL);
    pthread_create(&id,NULL,(void *)read_buf,NULL);//返回值为0，创建成功
    pthread_create(&id2,NULL,(void *)write_buf,NULL);
    pthread_join(id,NULL);
    pthread_join(id2,NULL);
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&cond);
    pthread_cond_destroy(&cond2);
    return 0;
}
