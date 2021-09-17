// More thread instances are created using single statement

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void *thread(void *v)
{
    pthread_mutex_lock(&lock1);
    sleep(1);
    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);
    pthread_mutex_unlock(&lock1);

    pthread_mutex_lock(&lock2);
    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);
    pthread_mutex_unlock(&lock2);
}

void f(pthread_t *t)
{
    pthread_create(t, NULL, thread, NULL);
}

void g(pthread_t *t)
{
    f(t);
}

void h(pthread_t *t1, pthread_t *t2)
{
    g(t1);
    g(t2);
}

int main()
{
    pthread_t t[2];
    h(&t[0], &t[1]);

    pthread_join(t[0], NULL);
    pthread_join(t[1], NULL);

    return 0;
}
