# Raytracing-in-one-weekend

Implementation of "Raytracing in one weekend" by Peter Shirley (http://in1weekend.blogspot.com/2016/01/Ray-tracing-in-one-weekend.html)

## How to compile and run

Since this uses CUDA you will need nvcc.

`nvcc ./src/main.cu -I ./src -o test && time ./test 1920 1080 50 out.png && feh out.png`