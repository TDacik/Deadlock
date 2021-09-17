#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

#define THREADS 5

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void *thread(void *v)
{
    pthread_mutex_lock(&lock1);
    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);
    pthread_mutex_unlock(&lock1);

    pthread_mutex_lock(&lock2);
    sleep(1);
    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);
    pthread_mutex_unlock(&lock2);
}

pthread_t f()
{
    pthread_t t;
    pthread_create(&t, NULL, thread, NULL);
    return t;
}

void g()
{
    pthread_t t;
    for (int i = 0; i < THREADS; i++)
        t = f();
    for (int i = 0; i < THREADS; i++)
        pthread_join(t, NULL);
}

int main()
{
	g();
    return 0;
}
