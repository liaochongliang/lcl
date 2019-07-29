
- java进程的创建与销毁实时 
	- adb logcat -b events | grep proc
- 获取应用进程中组件详细信息
	- adb shell dumpsys activity p <packageName>
- 获取应用优先级信息
	- adb shell dumpsys activity o


# c++的函数调用过程中，是有传值和传引用的。

### 一个方法不能修改一个基本数据类型的参数（数值型和布尔型）。
### 一个方法可以修改一个引用所指向的对象状态，但这仍然是按值调用而非引用调用。
### 上面两种传递都进行了值拷贝的过程

这主要是由于string内部保存值方式的原因 string是通过一个final char[]数组进行保存的.
由于final类型的数组值不能够改变，所以在外部调用函数时将string地址的引用进行传递给函数的参数，函数内部再修改这个引用时.
由于final char[] 不可修改，所以在再给变量赋值新值时都会重新创建一个string实例

java中字符串存在常量池中。 java的内存分为堆，栈，方法区（包括常量池）。
方法区中主要存在类结构，静态变量。方法区又包含常量池，常量池保存字符串常量。

 
## 在java里面。涉及时传递时call by value
所以被调用函数,中获参数本质是一个值拷贝。
 
```
 public class CallByValue {
	private static int x=10;
	public static void updateValue(int value){
		value = 3 * value;
	}	
	public static void main(String[] args) {
		System.out.println("调用前x的值："+x);
		updateValue(x);
		System.out.println("调用后x的值："+x);
	}
  
调用前x的值：10
调用后x的值：10
```
结论是：
传递给方法A得参数，是基本数据类型（数字以及布尔值），方法A无法修改外层得数据，本质上是内部会拷贝一份。

传递时 除了基本类型，还有引用类型。在传递引用类型是，被调用方法A，获得是其值得拷贝（类似地址概念）。然后调用
其中得方法，修改其内部对象。

```
public class CallByValue {
	private static User user=null;
	private static User stu=null;
	public static void swap(User x,User y){
		User temp =x;
		x=y;
		y=temp;
	}
	public static void main(String[] args) {
		user = new User("user",26);
		stu = new User("stu",18);
		System.out.println("调用前user的值："+user.toString());
		System.out.println("调用前stu的值："+stu.toString());
		swap(user,stu);
		System.out.println("调用后user的值："+user.toString());
		System.out.println("调用后stu的值："+stu.toString());
	}
  
  调用前user的值：User [name=user, age=26]
  调用前stu的值：User [name=stu, age=18]
  调用后user的值：User [name=user, age=26]
  调用后stu的值：User [name=stu, age=18]
```
结论： 这里swap,交换得是2个拷贝得值，实际外部对象并不会收到影响。

