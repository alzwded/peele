#ifndef MONOLITHIC_HXX
#define MONOLITHIC_HXX

class Monolithic
{
    int p;
    bool b;
public:
    Monolothic(int const& _p, bool const& _b)
        : p(_p), b(_b)
    {}
    void m1();
    void m2();
    void m3();
    void m4();
    ~Monolothic();
};

#endif
