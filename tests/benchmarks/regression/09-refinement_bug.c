//# Deadlock: True
//# Lockgraph:
//#   - lock2 -> lock1
//#   - lock1 -> lock2

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

int do_locking = 0;

/* Due to conditional locking analysis of this function will be refined,
 * this process should not discard the edge lock1 -> lock2 and stmt summaries
 * of function fn 
 */
void fn() 
{
    if(!(do_locking == 0))
    {
        pthread_mutex_lock(&lock1);
        pthread_mutex_lock(&lock2);
    }
    
    if(!(do_locking == 0))
    {
        pthread_mutex_unlock(&lock2);
        pthread_mutex_unlock(&lock1);
    }
}

void *thread1(void *v)
{
    fn();
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

    do_locking = 1;

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
