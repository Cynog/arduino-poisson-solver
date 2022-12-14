# definitions
SRCS = main.c usart.c poisson_arduino.c extram.c
HDRS = usart.h poisson_arduino.h extram.h
GCCFLAGS = -Wall -g -Os -mmcu=atmega328


# select the first arduino connected to the computer by serial id
$(eval serialid=$(shell find /dev/serial/by-id/ -name "*Arduino*" | head -1))


# help
help:
	@echo "USAGE: make one of the following recipies"
	@echo "\nC Code:"
	@ls -1 *.c | sed -e "s/\.c//"
	@echo "\nTools:"
	@echo "screen"
	@echo "cu"


# connect to serial port using screen
screen:
	@echo "opening serial port with baud rate 9600"
	@screen -S serialmonitor $(serialid) 9600
	@screen -S serialmonitor -X "quit"
	@ echo "closed serial port"
	

# connect to serial port using cu
cu:
	@echo "opening serial port with baud rate 9600"
	@cu -l $(serialid) -s 9600
	@ echo "closed serial port"


# C: compiling and flashing
main: $(SRCS) $(HDRS)
	@echo "COMPILING..."
	avr-gcc $(GCCFLAGS) $^ -o $@.bin
	@echo "\n\n\nCONVERTING TO HEX..."
	avr-objcopy -j .text -j .data -O ihex $@.bin $@.hex
	@echo "\n\n\nFLASHING..."
	avrdude -v -p m328p -c arduino -P $(serialid) -D -U flash:w:$@.hex
	@echo "\n\n\nALL STEPS SUCCEDED!"


test_extram: test_extram.c usart.c extram.c $(HDRS)
	@echo "COMPILING..."
	avr-gcc $(GCCFLAGS) $^ -o $@.bin
	@echo "\n\n\nCONVERTING TO HEX..."
	avr-objcopy -j .text -j .data -O ihex $@.bin $@.hex
	@echo "\n\n\nFLASHING..."
	avrdude -v -p m328p -c arduino -P $(serialid) -D -U flash:w:$@.hex
	@echo "\n\n\nALL STEPS SUCCEDED!"


# clean
clean:
	rm -rf */**/*.hex
	rm -rf */**/*.bin
