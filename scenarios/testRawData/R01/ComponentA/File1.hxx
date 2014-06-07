#ifndef FILE1_HXX
#define FILE1_HXX
#include "File2.hxx"

class Class1
: public Class2
{
public:
    Class1() : Class2() {}
    virtual ~Class1();
    virtual void VMethod();
    Class1* Fluent(int const& x);
    int operator<<(int const& x) {}
private:
    void Extra();
};
#endif
