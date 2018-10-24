from pprint import pprint

def FIR_A(inputPixels,numPixels):
    c1 = -1;
    c2 = 4;
    c3 = -10;
    c4 = 58;
    c5 = 17;
    c6 = -5;
    c7 = 1;
    subPixel = [0]*numPixels
    for i in xrange(numPixels):
        j = i+3
        subPixel[i] = (c1*inputPixels[j-3] + c2*inputPixels[j-2] + c3*inputPixels[j-1] + c4*inputPixels[j] + c5*inputPixels[1+j] + c6*inputPixels[2+j] + c7*inputPixels[3+j])/64;
        # print subPixel
    return subPixel

def FIR_B(inputPixels,numPixels):
    c1 = -1;
    c2 = 4;
    c3 = -11;
    c4 = 40;
    c5 = 40;
    c6 = -11;
    c7 = 4 ;
    c8 = -1;
    subPixel = [0]*numPixels
    for i in xrange(numPixels):
        j = i+3
        subPixel[i] = (c1*inputPixels[-3+i] + c2*inputPixels[-2+i] + c3*inputPixels[-1+i] + c4*inputPixels[i] +
                    c5*inputPixels[1+i] + c6*inputPixels[2+i] + c7*inputPixels[3+i] + c7*inputPixels[4+i])/64;
    return subPixel

def FIR_C(inputPixels,numPixels):
    c1 =  1;
    c2 = -5;
    c3 = 17;
    c4 = 58;
    c5 = -10;
    c6 = 4;
    c7 = -1;

    subPixel = [0]*numPixels
    for i in xrange(numPixels):
        j = i+3
        subPixel[i] = (c1*inputPixels[j-3] + c2*inputPixels[j-2] + c3*inputPixels[j-1] + c4*inputPixels[j] + c5*inputPixels[1+j] + c6*inputPixels[2+j] + c7*inputPixels[3+j])/64;
        # print subPixel
    return subPixel


def subPixelInterpolate(image_array):
    outputA = []
    outputB = []
    outputC = []
    A = []
    B = []
    C = []
    # print image_array
    for image_row in image_array:
        # print image_row
        subA = FIR_A(image_row,8);
        subB = FIR_B(image_row,8);
        subC = FIR_C(image_row,8);
        A.append(subA)
        B.append(subB)
        C.append(subC)
        outputA += [(subA)]
        outputB += [(subB)]
        outputC += [(subC)]
    for image_col in zip(*image_array)[3:11]:
        # print image_col
        subA = FIR_A(image_col,8);
        subB = FIR_B(image_col,8);
        subC = FIR_C(image_col,8);
        outputA += [(subA)]
        outputB += [(subB)]
        outputC += [(subC)]
    for image_col in zip(*A):
        subA = FIR_A(image_col,8);
        subB = FIR_B(image_col,8);
        subC = FIR_C(image_col,8);
        outputA += [(subA)]
        outputB += [(subB)]
        outputC += [(subC)]
    for image_col in zip(*B):
        subA = FIR_A(image_col,8);
        subB = FIR_B(image_col,8);
        # subC = FIR_C(image_col,8);
        outputA += [(subA)]
        outputB += [(subB)]
        outputC += [(subC)]
    for image_col in zip(*C):
        subA = FIR_A(image_col,8);
        subB = FIR_B(image_col,8);
        subC = FIR_C(image_col,8);
        outputA += [(subA)]
        outputB += [(subB)]
        outputC += [(subC)]
    return outputA,outputB,outputC
def main():
    image_array = []
    with open("test_image_2.mem") as file:
        for line in file.readlines():
            image_array.append([int(i,16) for i in line.strip().split()])
    A,B,C = subPixelInterpolate(image_array)
    pprint([map(hex, l) for l in A])


if __name__ == '__main__':
    main()