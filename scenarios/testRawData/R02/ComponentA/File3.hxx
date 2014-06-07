#ifndef FILE1_HXX
#define FILE1_HXX
#include "File2.hxx"

class Class3
: public Class2
{
public:
    Class3() : Class2() {}
    virtual ~Class3();
    virtual void VMethod();
protected:
    virtual InCase() const;
private:
    void Extra();
    void OtherExtra();
};
#endif
