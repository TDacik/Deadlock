// Tests whether CFA analysis correctly continues truough all instruction types


//# Deadlock: true
//# Lockgraph:
//#   - lock1 -> lock2
//#   - lock2 -> lock1

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t  cond  = PTHREAD_COND_INITIALIZER;

int f() {return 42;}

void *thread1(void *v)
{
    pthread_mutex_lock(&lock1);
  
    pthread_cond_wait(&cond, &lock1);   // Atomically analysed function
    print("");                          // External function
    int a = 3;                          // Local init -> Assign
    int b = printf("");                 // Local init -> external function
    int c = f();                        // Local init -> ConsInit
    if (a) ;                            // Guard
    
    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);
    pthread_mutex_unlock(&lock1);

    return NULL;
}

void *thread2(void *v)
{
    pthread_mutex_lock(&lock2);
    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);
    pthread_mutex_unlock(&lock2);

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
