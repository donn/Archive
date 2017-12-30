//make quicktest
#include <linux/init.h>      // included for __init and __exit macros
#include <linux/module.h>    // included for all kernel modules
#include <linux/kernel.h>    // included for KERN_INFO
#include <linux/sched.h>

#define _LISTP_TREE 0 // Set to 1 for DFS

static int nesting = -1;

static void task_print(struct task_struct *task)
{    
        const char* line;
        int i;
        char buffer[65];

        if (task->state) {
                if (task->state != -1) {
                        line = "Stopped";
                } else {
                        line = "Unrunnable";
                }
        } else {
                line = "Runnable";
        }
        
        for (i = 0; i < nesting; i++) {
                buffer[i] = '-';
        }
        buffer[nesting] = 0;

        if (nesting > 64 || nesting < 0) {
                return;
        }

        printk(KERN_INFO "[LISTP] %s %d: %s: %s\n", buffer, task->pid, task->comm, line);
}

#if _LISTP_TREE
static void depth_first_search_tasks(struct task_struct *head, void (*visit)(struct task_struct *))
{
        
        struct task_struct *task;
        struct list_head *list;
        
        nesting++;

        visit(head);
        list_for_each(list, &head->children) {
                task = list_entry(list, struct task_struct, sibling);
                depth_first_search_tasks(task, visit);
        }
        nesting--;
}
#endif

int listp_init(void)
{
#if !_LISTP_TREE
        struct task_struct *task;
#endif

        printk(KERN_INFO "[LISTP] Listing processes...\n");

#if _LISTP_TREE
        depth_first_search_tasks(&init_task, task_print);
#else
        nesting = 0;
        for_each_process(task) {
                task_print(task);
        }    
#endif
        return 0;    // Non-zero return means that the module couldn't be loaded.
}

void listp_cleanup(void) {}

module_init(listp_init);
module_exit(listp_cleanup);

MODULE_LICENSE("GPL\0except everything :^)");
MODULE_AUTHOR("Mohamed Gaber");
MODULE_DESCRIPTION("List processes.");