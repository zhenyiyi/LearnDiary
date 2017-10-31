//
//  any.cpp
//  learnBoost
//
//  Created by fenglin on 2017/10/30.
//  Copyright © 2017年 fenglin. All rights reserved.
//
// http://blog.csdn.net/morning_color/article/details/48681077

// > fatal error: 'boost/any.hpp' file not found

#include <stdio.h>
#include <boost/any.hpp>
#include <iostream>
#include <string>
#include "boost/assert.hpp"
#include <vector>
#include "boost/make_shared.hpp"
#include "boost/function.hpp"


typedef boost::function<void()> AsyncInvokeFunction;

template <typename T>
bool can_cast_to(const boost::any &a) {
    return a.type() == typeid(T);
}
// 获取对象的引用
template <typename T>
T& get_ref(boost::any &a) {
    BOOST_ASSERT_MSG(can_cast_to<T>(a), "a 不能转换成类型T");
    return boost::any_cast<T&>(a);
}
// 获取对象的指针
template <typename T>
T* get_pointer(boost::any &a) {
    BOOST_ASSERT_MSG(can_cast_to<T>(a), "a 不能转换成类型T");
    return boost::any_cast<T>(&a);
}

#define PRINT(xxx) ( std::cout << boost::format("%-20s = ") % (#xxx) << (xxx) << std::endl)

using namespace std;

void printMsg(boost::any &a){
    if (int ret = boost::any_cast<int>(a)) {
        cout << ret << endl;
    }
    
    try {
        cout << boost::any_cast<int>(a) << endl;
    }
    catch (boost::bad_any_cast &e) {
        cout << e.what() << endl;
    }
    
    try {
        cout << boost::any_cast<string>(a) << endl;
    } catch (boost::bad_any_cast &e) {
         cout << e.what() << endl;
    }
}

struct Message {
public:
    template <class F>
    Message(F& _func):body1(make_shared<AsyncInvokeFunction>()) {
        *( boost::any_cast<shared_ptr<AsyncInvokeFunction> >(body1) ) = _func;
    }
public:
    boost::any body1;
};

class Person {
    
    
public:
    static void foo(){
        printf("foo \n");
    }
    
    void g(){
        printf("ggg \n");
    }
};

void f(){
    printf("invoke f function\n");
}

int main(int argc, const char * argv[]) {
    
    boost::any a = 3;
    
    std::cout << can_cast_to<std::string>(a) << std::endl; // 0;
    std::cout << can_cast_to<int>(a) << std::endl; // 1;
    
    std::cout << get_ref<int>(a) << std::endl;
//    std::cout << get_ref<float>(a) << std::endl;
    
    
    std::cout << get_pointer<int>(a) << std::endl;
//    std::cout << get_pointer<float>(a) << std::endl;
    
    
    /********************************************************/
    
    puts("1、boost any的基本用法");
    
    boost::any str("fenglin");
    
    std::cout << &str << std:: endl;
    
    boost::any b(4);
    
    // 获取原对象
    
    cout << "b == "<< boost::any_cast<int &>(b) << endl;
    
    cout << "b == "<< boost::any_cast<int>(b) << endl;
    
    // 修改b的值
    boost::any_cast<int &>(b) = 200;
    
    cout << "修改的 b == "<< boost::any_cast<int &>(b) << endl;
    
    // 获取原对象的指针
    cout << boost::any_cast<int>(&b) << endl;
    
    int * p = (boost::any_cast<int>(&b));
    
    cout << "*p ==" << *p << endl;
    
    cout << b.type().name() << endl;
    
    cout << b.empty() << endl;
    
    puts("");
    
    /**************************************************************************/
    /*二，智能指针。 不能用any保存堆上的原始的指针，会造成内存泄露,应使用智能指针*/
    
    //下面这样做会造成内存泄露
    int* p2 = new int(2);
    boost::any ptr_any(p2);
    int* tmp = boost::any_cast<int*>(ptr_any);
    cout << *tmp << endl;
    
    //应当使用智能指针，而且只能使用shared_ptr,因为scoped_ptr不能被复制
    //这样在any析构时，会调用shared_ptr的析构函数，释放其持有的资源
    
    boost::any shared_any = shared_ptr<int>(new int(10));
    
    shared_ptr<int>p_shared  = boost::any_cast<shared_ptr<int> >(shared_any);
    
    cout << *p_shared << endl;
    
    
    shared_ptr<int> p3 = shared_ptr<int>(new int(20));
    
    cout << *p3 << endl;
    
    
    puts("");
    /**************************************************************************/
    //三，辅助函数：
    puts("三，辅助函数");
    string s3 = "hello";
    boost::any bs(s3);
    
    get_ref<string>(bs) = "world";
    
    cout << boost::any_cast<string>(bs) << endl;
    
    /**************************************************************************/
    //四，用于容器:
    
    std::vector<boost::any> vec;
    
    vec.push_back(1);
    
    vec.push_back("const_reference __x");
    
    vec.push_back(1.4);
    
    vec.push_back(shared_ptr<int>(new int(20)));
    /**************************************************************************/
    // 五, make_shared shared_ptr很好地消除了显式的delete调用，如果读者掌握了它的用法，可以肯定delete将会在你的编程字典中彻底消失 。
    // 但这还不够，因为shared_ptr的构造还需要new调用，这导致了代码中的某种不对称性。虽然shared_ptr很好地包装了new表达式，但过多的显式new操作符也是个问题，它应该使用工厂模式来解决。
    //因此，shared_ptr在头文件<boost/make_shared.hpp> 中提供了一个自由工厂函数（位于boost名字空间）make_shared<T>()，来消除显式的new调用，它的名字模仿了标准库的 make_pair()，声明如下：
//    template<class T, class... Args>
//    shared_ptr<T> make_shared( Args && ... args );
//    make_shared()函数可以接受最多10个参数，然后把它们传递给类型T的构造函数，创建一个shared_ptr<T>的对 象并返回。make_shared()函数要比直接创建shared_ptr对象的方式快且高效，因为它内部仅分配一次内存，消除了shared_ptr 构造时的开销。
    
    shared_ptr<string> sp = make_shared<string>("caoxiaoying");
    
    cout << *sp << endl;
    
    shared_ptr<string> sp2 = shared_ptr<string>( new string("fenglin"));
    
    cout << *sp2 << endl;
    
    
    vector<int> v;
    v.push_back(1);
    v.push_back(3);
    v.push_back(4);
    
    /**************************************************************************/
    
    shared_ptr<vector<int> > vp = make_shared<vector<int> >(v);
    
    cout << (*vp).size() << endl;
    
    Person per;
    Message m(f);
    shared_ptr<AsyncInvokeFunction> f = boost::any_cast<shared_ptr<AsyncInvokeFunction> >(m.body1);
    (*f)();
    
    Message m2(per.foo);
    (*boost::any_cast<shared_ptr<AsyncInvokeFunction> >(m2.body1))();
    
    return 0;
}
