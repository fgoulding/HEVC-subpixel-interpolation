from pprint import pprint

# 199 135 85 235 250 41 245

def FIR_A(inputPixels,numPixels):
    c1 = -1;
    c2 = 4;
    c3 = -10;
    c4 = 58;
    c5 = 17;
    c6 = -5;
    c7 = 1;
    subPixel = [0]*numPixels
    #print "YAAAAAAA", inputPixels
    for i in xrange(numPixels):
        j = i+3
        subPixel[i] = ((c1*inputPixels[j-3] + c2*inputPixels[j-2] + c3*inputPixels[j-1] +
                          c4*inputPixels[j] + c5*inputPixels[1+j] + c6*inputPixels[2+j] + c7*inputPixels[3+j])/64) & 0b11111111;

        # if (subPixel[i] > 255):
        #     print "bruh you cant do math."
        #     print "{}".format(hex(subPixel[i]))
        #     print inputPixels[j-3],inputPixels[j-2],inputPixels[j-1],inputPixels[j],inputPixels[1+j],inputPixels[2+j],inputPixels[3+j]
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
        subPixel[i] = min(((c1*inputPixels[j-3] + c2*inputPixels[j-2] + c3*inputPixels[j-1] + c4*inputPixels[j] +
                    c5*inputPixels[1+j] + c6*inputPixels[2+j] + c7*inputPixels[3+j] + c8*inputPixels[4+j])/64), 255);
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
        subPixel[i] = ((c1*inputPixels[j-3] + c2*inputPixels[j-2] + c3*inputPixels[j-1] + c4*inputPixels[j] +
                       c5*inputPixels[1+j] + c6*inputPixels[2+j] + c7*inputPixels[3+j])/64) & 0b11111111;

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

        #print image_row
        subA = FIR_A(image_row,8);
        subB = FIR_B(image_row,8);
        subC = FIR_C(image_row,8);
        A.append(subA)
        B.append(subB)
        C.append(subC)
        outputA += [(subA)]
        outputB += [(subB)]
        outputC += [(subC)]
    outputA = outputA[3:11]
    outputB = outputB[3:11]
    outputC = outputC[3:11]
    for image_col in zip(*image_array)[3:11]:
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
        subC = FIR_C(image_col,8);
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
    #print("ya boi done")
    temp_A = ([map(hex, l) for l in zip(*A)])
    return outputA,outputB,outputC
def main():
    image_array = []
    with open("test_image_2.mem") as file:
        for line in file.readlines():
            image_array.append([int(i,16) for i in line.strip().split()])
    #pprint(image_array)

    A,B,C = subPixelInterpolate(image_array)
    A_hex = [map(lambda x:"0x"+format(x,'02x'), l) for l in A]

    split = 2;
    A_verilog = []
    with open("output_1.txt") as verilog_output:
    	for line in verilog_output.readlines():
    		digits = ['0x'+line[i:i+split] for i in range(0, len(line)-1, split)][::-1];
    		A_verilog.insert(0, digits);

    pprint(A_verilog)
    pprint(A_hex)

    count = 0;
    for x in xrange(len(A_verilog)):
    	for char_x, char_y in zip(A_verilog[x],A_hex[x]):
    		if ((char_x != char_y) and (char_y != '0xff')):
    			count += 1;
    			print x
    			print A_hex[x]
    			print A_verilog[x]
    			break
    	 		#print int(char_x,0), int(char_y,0);



if __name__ == '__main__':
    main()
