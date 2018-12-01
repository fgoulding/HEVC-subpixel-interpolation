from pprint import pprint
from skimage.measure import compare_ssim as ssim
from sklearn.metrics import mean_squared_error
import numpy as np
import matplotlib.pyplot as plt
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
    for i in xrange(dim):
        for j in xrange(dim):
            I = i*4;
            J = j*4;
            image[I][J] = integer_pixels[i][j];
            image[I][J+1] = subpixels[0][i][j];
            image[I][J+2] = subpixels[1][i][j];
            image[I][J+3] = subpixels[2][i][j];

            image[I+1][J] = subpixels[0][i+8][j];
            image[I+2][J] = subpixels[1][i+8][j];
            image[I+3][J] = subpixels[2][i+8][j];

            image[I+1][J+1] = subpixels[0][i+16][j];
            image[I+1][J+2] = subpixels[1][i+16][j];
            image[I+1][J+3] = subpixels[2][i+16][j];

            image[I+2][J+1] = subpixels[0][i+24][j];
            image[I+2][J+2] = subpixels[1][i+24][j];
            image[I+2][J+3] = subpixels[2][i+24][j];

            image[I+3][J+1] = subpixels[0][i+32][j];
            image[I+3][J+2] = subpixels[1][i+32][j];
            image[I+3][J+3] = subpixels[2][i+32][j];

    return image;

def construct_frame(subpixels, integer_pixels):
    dim = len(integer_pixels);
    image_array = [];
    for i in xrange(16):
        image = np.zeros((dim, dim));
        image_array.append(image);
    for i in xrange(dim):
        for j in xrange(dim):
            image_array[0][i][j] = integer_pixels[i][j];
            image_array[1][i][j] = subpixels[0][i][j];
            image_array[2][i][j] = subpixels[1][i][j];
            image_array[3][i][j] = subpixels[2][i][j];

            image_array[4][i][j] = subpixels[0][i+8][j];
            image_array[5][i][j] = subpixels[1][i+8][j];
            image_array[6][i][j] = subpixels[2][i+8][j];

            image_array[7][i][j] = subpixels[0][i+16][j];
            image_array[8][i][j] = subpixels[1][i+16][j];
            image_array[9][i][j] = subpixels[2][i+16][j];

            image_array[10][i][j] = subpixels[0][i+24][j];
            image_array[11][i][j] = subpixels[1][i+24][j];
            image_array[12][i][j] = subpixels[2][i+24][j];

            image_array[13][i][j] = subpixels[0][i+32][j];
            image_array[14][i][j] = subpixels[1][i+32][j];
            image_array[15][i][j] = subpixels[2][i+32][j];

    return image_array;

def main():

    image_array = []
    with open("image_array/test_image_4.mem") as file:
        for line in file.readlines():
            data = line.strip().split()
            image_array.append([int(i,16) for i in data][3:len(data)-4])

    image_array = np.array(image_array)
    length = len(image_array);
    
    # original image without interpolation
    out_og = Image.fromarray(image_array[3:length-4])
    plt.imshow(out_og)
    plt.xlabel("original image (no interpolation)");

    # regular interpolation without optimization 
    A = process_output_array("output/output_4_a.txt");
    B = process_output_array("output/output_4_b.txt");
    C = process_output_array("output/output_4_c.txt");

    out_verilog = [A, B, C];
    image_actual = construct_image(out_verilog, image_array[3:11]);
    out_actual = Image.fromarray((image_actual).astype(np.uint8))
    plt.figure(2)
    plt.imshow(out_actual)
    plt.xlabel("actual interpolated image");

    # loop perforation
    A_loop = process_output_array("output/output_4_a_loop.txt");
    B_loop = process_output_array("output/output_4_b_loop.txt");
    C_loop = process_output_array("output/output_4_c_loop.txt");

    out_loop = [A_loop, B_loop, C_loop]
    image_pred = construct_image(out_loop, image_array[3:11]);
    out_pred = Image.fromarray((image_pred).astype(np.uint8))
    plt.figure(3);
    plt.imshow(out_pred)
    plt.xlabel("approximately interpolated image (loop perforation)");

    # approximate multiplierless
    A_multiplierless = process_output_array("output/output_4_a_approx_multiplierless.txt");
    B_multiplierless = process_output_array("output/output_4_b_approx_multiplierless.txt");
    C_multiplierless = process_output_array("output/output_4_c_approx_multiplierless.txt");

    out_multiplierless = [A_multiplierless, B_multiplierless, C_multiplierless]
    image_pred_2 = construct_image(out_multiplierless, image_array[3:11]);
    out_pred_2 = Image.fromarray((image_pred_2).astype(np.uint8))
    plt.figure(4);
    plt.imshow(out_pred_2)
    plt.xlabel("approximately interpolated image (approx multiplierless)");

    #pprint(image_actual)
    #pprint(image_pred)

    # regular interpolation without optimization as frames
    # image_frame = construct_frame(out_verilog, image_array[3:11]);
    # fig = plt.figure(figsize=(7, 7))
    # columns = 4
    # rows = 4
    # for i in range(1, columns*rows +1):
    #     img = Image.fromarray((image_frame[i-1]).astype(np.uint8))
    #     fig.add_subplot(rows, columns, i)
    #     plt.imshow(img)

    plt.show()

    # calculate for accuracy
    mse_loop = 0;
    mse_mult = 0;
    for i in xrange(len(out_verilog)):
        print "Testing for output_" + chr(i + 65)
        actual = np.matrix(out_verilog[i]);
        pred_1 = np.matrix(out_loop[i])
        print "MSE (loop):  " , mean_squared_error(actual, pred_1)
        mse_loop += mean_squared_error(actual, pred_1)
        pred_2 = np.matrix(out_multiplierless[i])
        print "MSE (multiplierless):  " , mean_squared_error(actual, pred_2)
        mse_mult += mean_squared_error(actual, pred_2)

    s_loop = ssim(image_actual, image_pred);
    s_mult = ssim(image_actual, image_pred_2);

    print
    print "Full image results (loop)"
    print "ssim accuracy measure (-1 to 1): " , s_loop
    print "mse accuracy measure (unbounded): ", mse_loop
    print 
    print "Full image results (multiplierless)"
    print "ssim accuracy measure (-1 to 1): " , s_mult
    print "mse accuracy measure (unbounded): ", mse_mult
    print 

if __name__ == '__main__':
    main()
