#include <linux/mtd/mtd.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/err.h>

#ifndef MODULE
#error "Must be compiled as a module"
#endif

/*
 * All credit goes to dougg3@electronics.stackexchange.com:
 * https://electronics.stackexchange.com/a/116133/97342
 */

static int __init mtd_unlocker_init(void)
{
	struct mtd_info *mtd;
	int i;

	for (i = 0; true; ++i) {
		mtd = get_mtd_device(NULL, i);
		if (!IS_ERR(mtd) && !(mtd->flags & MTD_WRITEABLE)) {
			printk(KERN_INFO "mtd-unlocker: unlocking mtd%d\n", i);
			mtd->flags |= MTD_WRITEABLE;
			put_mtd_device(mtd);
		} else {
			break;
		}
	}

	printk(KERN_INFO "mtd-unlocker: %d device(s) unlocked\n", i);

	return 0;
}

module_init(mtd_unlocker_init);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Joseph C. Lehner <joseph.c.lehner@gmail.com>");
MODULE_DESCRIPTION("MTD unlocker");
MODULE_VERSION("1");
