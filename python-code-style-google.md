本人摘自[runoob.com](http://www.runoob.com/w3cnote/google-python-styleguide.html)

Python风格规范(Google)，Google官方英文版，请参考[Google Style Guide](https://google.github.io/styleguide/pyguide.html)
以下代码中**Yes**表示推荐，**No**表示不推荐

---
### 分号
不要在行尾加分号，也不要用分号将两条命令放在同一行
### 行长度
每行不超过80个字符
以下情况除外：
- 长的导入模块语句
- 注释里的URL

不要使用反斜杠连接行。
Python会将[圆括号，中括号和花括号中的行隐式的连接起来](https://docs.python.org/3.7/reference/lexical_analysis.html#implicit-line-joining),如果需要，你可以在表达式外围增加一对额外的圆括号。
```
推荐: foo_bar(self, width, height, color='black', design=None, x='foo',
              emphasis=None, highlight=0)
       
      if (width == 0 and height == 0 and
         color == 'red' and emphasis == 'strong'):
```
如果一个文本字符创在一行放不下，可以使用圆括号来实现隐式换行
```
x = ('这是一个非常长非常长非常长非常长 '
     '非常长非常长非常长非常长非常长非常长的字符串')
```

在注释中，如果必要，将长的URL放在一行上。
```
Yes:  # See details at
      # http://www.example.com/us/developer/documentation/api/content/v2.0/csv_file_name_extension_full_specification.html
```

```
No:  # See details at
     # http://www.example.com/us/developer/documentation/api/content/\
     # v2.0/csv_file_name_extension_full_specification.html
```
### 括号
宁缺毋滥的使用括号
除非是用于实现行连接，否则不要在返回语句或条件语句中使用括号，不过在元组两边使用括号是可以的
```
Yes: if foo:
         bar()
     while x:
         x = bar()
     if x and y:
         bar()
     if not x:
         bar()
     return foo
     for (x, y) in dict.items(): ...
```
```
No:  if (x):
         bar()
     if not(x):
         bar()
     return (foo)
```
### 缩进
用4个空格来缩进代码
绝对不要用tab, 也不要tab和空格混用. 对于行连接的情况, 你应该要么垂直对齐换行的元素(见 :ref:`行长度 <line_length>` 部分的示例), 或者使用4空格的悬挂式缩进(这时第一行不应该有参数):
```
Yes:   # 与起始变量对齐
       foo = long_function_name(var_one, var_two,
                                var_three, var_four)

       # 字典中与起始值对齐
       foo = {
           long_dictionary_key: value1 +
                                value2,
           ...
       }

       # 4 个空格缩进，第一行不需要
       foo = long_function_name(
           var_one, var_two, var_three,
           var_four)

       # 字典中 4 个空格缩进
       foo = {
           long_dictionary_key:
               long_dictionary_value,
           ...
       }
```
```
No:    # 第一行有空格是禁止的
      foo = long_function_name(var_one, var_two,
          var_three, var_four)

      # 2 个空格是禁止的
      foo = long_function_name(
        var_one, var_two, var_three,
        var_four)

      # 字典中没有处理缩进
      foo = {
          long_dictionary_key:
              long_dictionary_value,
              ...
      }
```

### 空行
顶级定义之间空两行，方法定义之间空一行
定级定义之间空两行，比如函数或者类定义，方法定义，类定义与第一个方法之间，都应该空一行。函数或方法中，某些地方钥匙觉得合适，就空一行

### 空格
按照标准的排版规范来使用标点两边的空格
括号内不要有空格.
按照标准的排版规范来使用标点两边的空格
```
Yes: spam(ham[1], {eggs: 2}, [])
```
```
No:  spam( ham[ 1 ], { eggs: 2 }, [ ] )
```
不要在逗号, 分号, 冒号前面加空格, 但应该在它们后面加(除了在行尾).
```
Yes: if x == 4:
         print x, y
     x, y = y, x
```
```
No:  if x == 4 :
         print x , y
     x , y = y , x
```
参数列表, 索引或切片的左括号前不应加空格.
```
Yes: spam(1)
Yes: dict['key'] = list[index]
```
```
no: spam (1)
No:  dict ['key'] = list [index]
```
在二元操作符两边都加上一个空格, 比如赋值(=), 比较(==, <, >, !=, <>, <=, >=, in, not in, is, is not), 布尔(and, or, not). 至于算术操作符两边的空格该如何使用, 需要你自己好好判断. 不过两侧务必要保持一致.
```
Yes: x == 1
```
```
No:  x<1
```
当'='用于指示关键字参数或默认参数值时, 不要在其两侧使用空格.
```
Yes: def complex(real, imag=0.0): return magic(r=real, i=imag)
```
```
No:  def complex(real, imag = 0.0): return magic(r = real, i = imag)
```
不要用空格来垂直对齐多行间的标记, 因为这会成为维护的负担(适用于:, #, =等):
```
Yes:
     foo = 1000  # 注释
     long_name = 2  # 注释不需要对齐

     dictionary = {
         "foo": 1,
         "long_name": 2,
         }
```
```
No:
     foo       = 1000  # 注释
     long_name = 2     # 注释不需要对齐

     dictionary = {
         "foo"      : 1,
         "long_name": 2,
         }
```
### Shebang
大部分.py文件不必以#!作为文件的开始. 根据 PEP-394 , 程序的main文件应该以 #!/usr/bin/python2或者 #!/usr/bin/python3开始.

(译者注: 在计算机科学中, Shebang (也称为Hashbang)是一个由井号和叹号构成的字符串行(#!), 其出现在文本文件的第一行的前两个字符. 在文件中存在Shebang的情况下, 类Unix操作系统的程序载入器会分析Shebang后的内容, 将这些内容作为解释器指令, 并调用该指令, 并将载有Shebang的文件路径作为该解释器的参数. 例如, 以指令#!/bin/sh开头的文件在执行时会实际调用/bin/sh程序.)

#!先用于帮助内核找到Python解释器, 但是在导入模块时, 将会被忽略. 因此只有被直接执行的文件中才有必要加入#!.
### 注释
确保对模块, 函数, 方法和行内注释使用正确的风格
**文档字符串**
```
Python有一种独一无二的的注释方式: 使用文档字符串. 文档字符串是包, 模块, 类或函数里的第一个语句. 这些字符串可以通过对象的__doc__成员被自动提取, 并且被pydoc所用. (你可以在你的模块上运行pydoc试一把, 看看它长什么样). 我们对文档字符串的惯例是使用三重双引号"""( PEP-257 ). 一个文档字符串应该这样组织: 首先是一行以句号, 问号或惊叹号结尾的概述(或者该文档字符串单纯只有一行). 接着是一个空行. 接着是文档字符串剩下的部分, 它应该与文档字符串的第一行的第一个引号对齐. 下面有更多文档字符串的格式化规范.
```
