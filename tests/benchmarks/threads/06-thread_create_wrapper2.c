// All threads are created using wrapper function

//# Deadlock: false
//# Threadgraph:
//#   - main -> thread1
//#   - main -> thread2
//#   - thread1 -> thread3
//#   - thread2 -> thread4

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void *thread3(void *v)
{
    return NULL;
}

void *thread4(void *v)
{
    return NULL;
}

void *thread1(void *v)
{
    pthread_t t;
    pthread_create(&t, NULL, thread3, NULL);
    pthread_join(t, NULL);
}

void *thread2(void *v)
{
    pthread_t t;
    pthread_create(&t, NULL, thread4, NULL);
    pthread_join(t, NULL);
}

void thread_create_wrapper(pthread_t *thread, void * (*fn)(void *))
{
    pthread_create(thread, NULL, fn, NULL);
}

void f()
{
    pthread_t threads[2];
	
    thread_create_wrapper(&threads[0], thread1);
    thread_create_wrapper(&threads[1], thread2);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

}

int main()
{	
    f();
    return 0;
}
