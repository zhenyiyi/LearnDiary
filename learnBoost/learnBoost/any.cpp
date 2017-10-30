//
//  any.cpp
//  learnBoost
//
//  Created by fenglin on 2017/10/30.
//  Copyright © 2017年 fenglin. All rights reserved.
//

#include <stdio.h>
#include "boost/any.hpp"
#include <iostream>
#include <string>
#include "boost/assert.hpp"




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


int main(int argc, const char * argv[]) {
    
    boost::any a = 1;
    
    std::cout << can_cast_to<std::string>(a) << std::endl; // 0;
    std::cout << can_cast_to<int>(a) << std::endl; // 1;
    
    std::cout << get_ref<int>(a) << std::endl;
//    std::cout << get_ref<float>(a) << std::endl;
    
    
    std::cout << get_pointer<int>(a) << std::endl;
//    std::cout << get_pointer<float>(a) << std::endl;
    
    return 0;
}
