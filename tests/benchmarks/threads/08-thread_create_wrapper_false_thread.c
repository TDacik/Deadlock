// Function not_thread has a thread signature, but is never created nor called
// and should therefore be ignored

//# Deadlock: false
//# Thread-graph:
//#   - main -> thread1
//#   - main -> thread2

//# With-eva-only: true

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void *thread1(void *v)
{
    return NULL;
}

void *thread2(void *v)
{
    return NULL;
}

// Is never created nor called
void *not_thread(void *v)
{
    return NULL;
}

void thread_create_wrapper(pthread_t *thread, void * (*not_thread)(void *))
{
    pthread_create(thread, NULL, not_thread, NULL);
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
