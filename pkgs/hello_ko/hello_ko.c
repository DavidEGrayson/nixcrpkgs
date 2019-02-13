#include <linux/module.h>
#include <linux/init.h>

#include <stdbool.h>

void my_func(void);
EXPORT_SYMBOL_GPL(my_func);

int test_val = 300;
void my_func()
{
  printk("This is my_func()\n");
  printk("test_val = %d", test_val);
  printk("End of my_func()\n");
}

static int my_init()
{
  printk("module loaded\n");
  return 0;
}

static void my_exit()
{
  printk("module unloaded\n");
}

module_init(my_init);
module_exit(my_exit);
MODULE_AUTHOR("LEARNING LINUX KERNEL");
MODULE_DESCRIPTION("EXPORTING SYMBOLS");
MODULE_LICENSE("GPL");
