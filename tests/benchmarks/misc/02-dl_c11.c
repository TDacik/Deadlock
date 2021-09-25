//# Deadlock: true

//# Lockgraph:
//#   - lock2 -> lock1
//#   - lock1 -> lock2

//# Thread-graph:
//#   - thread1 -> thread2
//#   - thread2 -> thread1

//# Options:
//#   - deadlock-conc-model: c11_threads

//TODO: mtx is considered to be arithmetic type by CIL
//# With-eva-only: true 


//#include <threads.h>
#include <stdio.h>

typedef int mtx_t;
typedef int thrd_t;
int mtx_plain;

mtx_t lock1;
mtx_t lock2;

int thread1(void *v)
{
    mtx_lock(&lock1);
    mtx_lock(&lock2);
    mtx_unlock(&lock2);
    mtx_unlock(&lock1);

    return NULL;
}

int thread2(void *v)
{
    mtx_lock(&lock2);
    mtx_lock(&lock1);
    mtx_unlock(&lock1);
    mtx_unlock(&lock2);

    return NULL;
}

int main(int argc, char **argv)
{	
    mtx_init(&lock1, mtx_plain);
    mtx_init(&lock2, mtx_plain);

    thrd_t threads[2];

    thrd_create(&threads[0], thread1, NULL);
    thrd_create(&threads[1], thread2, NULL);

    thrd_join(threads[0], NULL);
    thrd_join(threads[1], NULL);

    mtx_destroy(&lock1);
    mtx_destroy(&lock2);
	
    return 0;
}
