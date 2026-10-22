ull g(ull x)
{
    x^=salt;
    x^=(x<<((ull)13));
    x^=(x>>((ull)7));
    x^=(x<<((ull)17));
    x^salt;
    return x;
}
