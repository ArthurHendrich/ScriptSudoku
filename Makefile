CC = gcc
CFLAGS = -Wall -g
TARGET = sudoku

all: $(TARGET)

$(TARGET): $(TARGET).c
    $(CC) $(CFLAGS) $(TARGET).c -o $(TARGET)

clean:
    rm -f $(TARGET) 
