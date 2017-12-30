obj-m += listp.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	sudo rmmod listp.ko  || true
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

.PHONY: quicktest
quicktest:
	@make clean
	@make
	@sudo rmmod listp.ko  || true
	@sudo insmod listp.ko
	@sudo rmmod listp.ko
	@dmesg | grep "\\[LISTP\\]"