from pprint import pprint
# from skimage.measure import compare_ssim as ssim
from sklearn.metrics import mean_squared_error
import numpy as np
import matplotlib.pyplot as plt
# from skimage import measure
# print(dir(measure))
from PIL import Image

def process_output_array(filename):
    output_array = [];
    split = 2;
    with open(filename) as output:
        for line in output.readlines():
            pixels = [int(line[i:i+split], 16) for i in range(0, len(line)-1, split)][::-1];
            output_array.insert(0, pixels);
    return output_array;


def construct_image(subpixels, integer_pixels):
    dim = len(integer_pixels);
    image = np.zeros((dim*4, dim*4));
    count = 0;
    for i in xrange(dim):
        for j in xrange(dim):

            I = i*4;
            J = j*4;
            image[I][J] = integer_pixels[i][j];
            #horizontal
            image[I][J+1] = subpixels[0][i][j];
            image[I][J+2] = subpixels[1][i][j];
            image[I][J+3] = subpixels[2][i][j];

            #vertical
            image[I+1][J] = subpixels[0][i+8][j];
            image[I+2][J] = subpixels[1][i+8][j];
            image[I+3][J] = subpixels[2][i+8][j];

            # image[I+1][J+1] = subpixels[0][i+16][j];
            # image[I+2][J+1] = subpixels[1][i+16][j];
            # image[I+3][J+1] = subpixels[2][i+16][j];
            #
            # image[I+1][J+2] = subpixels[0][i+24][j];
            # image[I+2][J+2] = subpixels[1][i+24][j];
            # image[I+3][J+2] = subpixels[2][i+24][j];
            #
            # image[I+1][J+1] = subpixels[0][i+32][j];
            # image[I+2][J+1] = subpixels[1][i+32][j];
            # image[I+3][J+1] = subpixels[2][i+32][j];

    print count

    return image;


def construct_bigger_ogimage(integer_pixels):
    dim = len(integer_pixels);
    image = np.zeros((dim*4, dim*4));
    count = 0;
    for i in xrange(dim):
        for j in xrange(dim):

            I = i*4;
            J = j*4;
            image[I][J] = integer_pixels[i][j];
            image[I][J+1] = integer_pixels[i][j];
            image[I][J+2] = integer_pixels[i][j];
            image[I][J+3] = integer_pixels[i][j];

            image[I+1][J] = integer_pixels[i][j];
            image[I+2][J] = integer_pixels[i][j];
            image[I+3][J] = integer_pixels[i][j];
            #
            # image[I+1][J+1] = integer_pixels[i][j]
            # image[I+1][J+2] = integer_pixels[i][j]
            # image[I+1][J+3] = integer_pixels[i][j]
            #
            # image[I+2][J+1] = integer_pixels[i][j]
            # image[I+2][J+2] = integer_pixels[i][j]
            # image[I+2][J+3] = integer_pixels[i][j]
            #
            # image[I+3][J+1] = integer_pixels[i][j]
            # image[I+3][J+2] = integer_pixels[i][j]
            # image[I+3][J+3] = integer_pixels[i][j]

    print count

    return image;



def main():
    np.set_printoptions(threshold=np.nan)

    image_array = []
    with open("image_array/test_image_3.mem") as file:
        for line in file.readlines():
            image_array.append(list(reversed([int(i,16) for i in line.strip().split()][3:11])))
    #pprint(len(image_array[3:11]))
    image_array = np.array(image_array)
    # print image_array
    # out_og = Image.fromarray(image_array[3:11])
    # out_og.show()
    A = process_output_array("output/output_3_a.txt");
    B = process_output_array("output/output_3_b.txt");
    C = process_output_array("output/output_3_c.txt");

    out_verilog = [A, B, C];
    large_og = construct_bigger_ogimage(image_array[3:11]);
    out_og = Image.fromarray(large_og)
    out_og.show()

    image_actual = construct_image(out_verilog, image_array[3:11]);
    out_actual = Image.fromarray(image_actual)
    out_actual.show()
    A_loop = process_output_array("output/output_3_a_loop.txt");
    B_loop = process_output_array("output/output_3_b_loop.txt");
    C_loop = process_output_array("output/output_3_c_loop.txt");

    out_loop = [A_loop, B_loop, C_loop]
    image_pred = construct_image(out_loop, image_array[3:11]);
    # out_pred = Image.fromarray(image_pred)
    # out_pred.show()
    for b in ([list(a) for a in large_og]):
        print b
    print
    for b in ([list(a) for a in image_actual]):
        print b
    print
    # for b in ([list(a) for a in image_pred]):
    #     print b
    # print

    # out_loop = [A_loop, B_loop, C_loop]
    # for i in xrange(len(out_verilog)):
    #     print "Testing for output_" + chr(i + 65)
    #     actual = np.matrix(out_verilog[i]);
    #     pred = np.matrix(out_loop[i])
    #     #print mean_squared_error(actual, pred)
    #     print "Done testing for output_" + chr(i + 65)

    # s = ssim(image_actual, image_pred);
    # print s

if __name__ == '__main__':
    main()
