//# Deadlock: false
//# Terminates: true
//# Options:
//#   - eva-unroll-recursive-calls: 86

int f(int i)
{
    if (i == 0)
        return 1;
    else
        return i * g(i-1);
}

int g(int i)
{
    if (i == 0)
        return 1;
    else
        return i * f(i-1);
}

int main()
{
    f(42);
}
