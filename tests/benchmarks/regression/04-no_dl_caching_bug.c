//# Deadlock: False
//# Lockgraph:
//#   - lock1 -> lock2

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

/* Summary of fn should look like:
 *   fn, {} -> {{}}
 *
 *  Bug in Deadlock returned:
 *    fn, {} -> {{}, {lock2}}
 *  due to join of contexts at lines 21 and 25
 *  and introduced deadlock with edge lock1 -> lock2
 *  created later at line 34.
 * */

void fn(void *v)
{ 
    pthread_mutex_lock(&lock2);

    if (v == NULL) {
        int b = 3;
    }

    pthread_mutex_unlock(&lock2);

    return;
}

void *thread1(void *v)
{
    fn(v);

    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);

    return NULL;
}

void *thread2(void *v)
{
    pthread_mutex_lock(&lock1);
    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);
    pthread_mutex_unlock(&lock1);

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
