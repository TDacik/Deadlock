//# Deadlock: true

//# Lockgraph:
//#   - lock1 -> lockA
//#   - lock2 -> lockA
//#   - lock3 -> lockA
//#   - lock4 -> lockA
//#   - lockA -> lock1

//# Thread-graph:
//#   - main -> thread1
//#   - main -> thread2

// Thread initial states are not computed without EVA
//# With-eva-only: true


#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lockA = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock3 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock4 = PTHREAD_MUTEX_INITIALIZER;

void *thread1(void *v)
{
    pthread_mutex_t *lock = (pthread_mutex_t *) v;

    pthread_mutex_lock(lock);
    pthread_mutex_lock(&lockA);
    pthread_mutex_unlock(&lockA);
    pthread_mutex_unlock(lock);

    return NULL;
}

void *thread2(void *v)
{
    pthread_mutex_lock(&lockA);
    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);
    pthread_mutex_unlock(&lockA);

    return NULL;
}

void f()
{
    pthread_t threads[5];
	
    pthread_create(&threads[0], NULL, thread1, (void *) &lock1);
    pthread_create(&threads[1], NULL, thread1, (void *) &lock2);
    pthread_create(&threads[2], NULL, thread1, (void *) &lock3);
    pthread_create(&threads[3], NULL, thread1, (void *) &lock4);
    pthread_create(&threads[4], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
    pthread_join(threads[2], NULL);
    pthread_join(threads[3], NULL);
    pthread_join(threads[4], NULL);
}

int main()
{	
    f();
    return 0;
}
