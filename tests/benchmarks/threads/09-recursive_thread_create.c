//# Thread-graph:
//#   - main -> thread1
//#   - thread1 -> thread1

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

#define THREAD_LIMIT 1024

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
int i;

void f();

void *thread1(void *v)
{
    printf("%d\n", i);
    if (i < THREAD_LIMIT)
    {
        pthread_mutex_lock(&mutex);
        i++;
        pthread_mutex_unlock(&mutex);
        pthread_t t;
        pthread_create(&t, NULL, thread1, NULL);
        pthread_join(t, NULL);
    }

    return NULL;
}

void f()
{
    pthread_t t;
    pthread_create(&t, NULL, thread1, NULL);
    pthread_join(t, NULL);
}

int main()
{	
    thread1(NULL);
    return 0;
}
