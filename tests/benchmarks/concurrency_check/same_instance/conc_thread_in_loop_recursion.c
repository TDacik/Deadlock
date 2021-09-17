#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

#define THREADS 1

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void f(int i);
void g(int i);

void *thread(void *v)
{
    pthread_mutex_lock(&lock1);
    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);
    pthread_mutex_unlock(&lock1);

    pthread_mutex_lock(&lock2);
    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);
    pthread_mutex_unlock(&lock2);
}

void f(int i)
{
    pthread_t t[5];

    for (int i = 0; i < THREADS; i++)
        pthread_create(&t[i], NULL, thread, NULL);

    for (int i = 0; i < THREADS; i++)
        pthread_join(t[i], NULL);

    g(--i);
}

void g(int i)
{
    if (i > 0)
        f(--i);
}

int main()
{
	g(2);
    return 0;
}
