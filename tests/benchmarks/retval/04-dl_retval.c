//# Deadlock: true
//# Lockgraph:
//#   - lock1 -> lock2
//#   - lock2 -> lock1

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

int f()
{
    if (pthread_mutex_lock(&lock1) != 0) 
        return -1;

    return 0;
}

void *thread1(void *v)
{
    pthread_mutex_lock(&lock2);
    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);
    pthread_mutex_unlock(&lock2);

    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t thread;
    pthread_create(&thread, NULL, thread1, NULL);

    f();

    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);
    
    pthread_join(thread, NULL);
	
    return 0;
}
