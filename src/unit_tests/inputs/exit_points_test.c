int f()
{
    int x = 3; // Not an exit point
    stmt1: x--;

    while (x > 0) 
    {
        if (x > 3)
            stmt2: x--;       // Not an exit point
        else
            stmt3: return 1;  // Exit point
    }
    stmt4: goto stmt5;        // Not an exit point
    stmt5: goto stmt6;        // Not an exit point, but theoretically could be...
    stmt6: x--;               // Not an exit point
    stmt7: return 0;          // Exit point

}

int main()
{	
    f();
    return 0;
}
