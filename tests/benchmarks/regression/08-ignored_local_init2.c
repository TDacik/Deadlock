// Similar to 07-ignored_local_init.c, but locking functions are used as local initializers.

//# Deadlock: true
//# Lockgraph:
//#   - lock1 -> lock2
//#   - lock2 -> lock1

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

int fn1()
{
    // Locking functions used as local inits
    int a = pthread_mutex_lock(&lock1);
    int b = pthread_mutex_lock(&lock2);
    int c = pthread_mutex_unlock(&lock2);
    int d = pthread_mutex_unlock(&lock1);

    return 1;
}

int fn2()
{
    // Locking functions used as local inits
    int w = pthread_mutex_lock(&lock2);
    int x = pthread_mutex_lock(&lock1);
    int y = pthread_mutex_unlock(&lock1);
    int z = pthread_mutex_unlock(&lock2);

    return 2;
}

void *thread1(void *v)
{
    int x = fn1();
    return NULL;
}

void *thread2(void *v)
{
    int x = fn2();
    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
