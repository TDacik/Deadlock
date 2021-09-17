//# Thread-graph:
//#   - main -> thread1
//#   - thread1 -> thread2
//#   - thread2 -> thread1

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

#define THREAD_LIMIT 1024

int i;

void f();
void *thread2(void *v);

void *thread1(void *v)
{
    if (i < THREAD_LIMIT)
    {
        i++;
        pthread_t t;
        pthread_create(&t, NULL, thread2, NULL);
        pthread_join(t, NULL);
    }

    return NULL;
}

void *thread2(void *v)
{
    if (i < THREAD_LIMIT)
    {
        i++;
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
