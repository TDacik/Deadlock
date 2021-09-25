//# Deadlock: true

//# Lockgraph:
//#   - lock2 -> lock1
//#   - lock1 -> lock2

//# Thread-graph:
//#   - thread1 -> thread2
//#   - thread2 -> thread1

//# Options:
//#   - deadlock-conc-model: win32_threads

//# Todo: true

//#include <Windows.h>
#include <stdio.h>

#define INFINITE 999
#define FALSE 0

typedef int HANDLE;
typedef int DWORD;
typedef void * LPVOID;

HANDLE lock1;
HANDLE lock2;

DWORD thread1(LPVOID v)
{
    WaitForSingleObject(lock1, INFINITE);
    WaitForSingleObject(lock2, INFINITE);
    ReleaseMutex(lock2);
    ReleaseMutex(lock1);

    return 0;
}

DWORD thread2(LPVOID v)
{
    WaitForSingleObject(lock2, INFINITE);
    WaitForSingleObject(lock1, INFINITE);
    ReleaseMutex(lock1);
    ReleaseMutex(lock2);

    return 0;
}

int main(int argc, char **argv)
{
    lock1 = CreateMutex(NULL, FALSE, NULL);
    lock2 = CreateMutex(NULL, FALSE, NULL);

    HANDLE t1 = CreateThread(NULL, 0, thread1, NULL, 0, NULL);
    HANDLE t2 = CreateThread(NULL, 0, thread2, NULL, 0, NULL);

    WaitForSingleObject(t1, INFINITE);
    WaitForSingleObject(t2, INFINITE);

    CloseHandle(t1);
    CloseHandle(t2);

    CloseHandle(lock1);
    CloseHandle(lock2);	

    return 0;
}
