# Sub-pixel Interpolation

The increasing demand for high-resolution digital video for many different types of applications stimulated the efforts to improve the performance in video coding. As a result, HEVC,a video compression/encoding algorithm, was developed to reduce code rate of the video streaming to 50% of H.264 standard. However, the standard is very computationally expensive. The most computationally intensive portion is the sub-pixel interpolation. 

Video encoders have different modules to explore each redundancy type present in visual information. HEVC interpolation filter is a finite impulse response (FIR) filter to interpolate subpixels using the surrounding pixels and subpixels to decide the current value. 

### Vanilla Implementation

First we will implement a standard hardware version of the algorithm define in the HEVC standard for sub-pixel interpolation. There will be natural design decisions that will inherently differ from a software implementation, but we will take no steps to optimize for power/area/performance.

### Improving the Implementation

We will use approximate computing techniques to improve power consumption. We will then analyze accuracy and performance vs power consumption.


## October 24 Update

We have developed a vanilla implementation of sub-pixel interpolation in Verilog. The hardware design uses a series of basic fir filters to execute all sub-pixels related to a single row in a 1 clock cycle. So each clock cycle, 24 sub pixels are calculated. 
