CC=nvcc
CFLAGS=-I./src
MAIN=./src/main.cu
EXECUTABLE=raytracing

$(EXECUTABLE):
	$(CC) $(MAIN) -o $@ $^ $(CFLAGS)

run: $(EXECUTABLE)
	./$(EXECUTABLE) 1280 720 400 out.png

show: run
	feh out.png