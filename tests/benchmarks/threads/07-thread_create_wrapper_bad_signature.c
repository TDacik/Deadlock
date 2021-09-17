//# Thread-graph:
//#   - main -> thread1
//#   - main -> thread2

//# With-eva-only: true

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void *thread1(void)
{
    return NULL;
}

void *thread2(void)
{
    return NULL;
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
