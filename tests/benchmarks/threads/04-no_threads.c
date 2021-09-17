// No threads are created

//# Deadlock: false
//# Thread-graph: []

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void *thread(void *v)
{
    return NULL;
}

void f()
{
    return;
}

int main()
{	
    f();
    return 0;
}
