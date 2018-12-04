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
    dim_x = len(integer_pixels)#.shape[0];
    dim_y = len(integer_pixels[0])#.shape[1];
    image = np.zeros((dim_x*4, dim_y*4));
    for i in xrange(dim_x):
        for j in xrange(dim_y):
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

            image[I+1][J+1] = subpixels[0][i+16][j];
            image[I+2][J+1] = subpixels[1][i+16][j];
            image[I+3][J+1] = subpixels[2][i+16][j];

            image[I+1][J+2] = subpixels[0][i+24][j];
            image[I+2][J+2] = subpixels[1][i+24][j];
            image[I+3][J+2] = subpixels[2][i+24][j];

            image[I+1][J+3] = subpixels[0][i+32][j];
            image[I+2][J+3] = subpixels[1][i+32][j];
            image[I+3][J+3] = subpixels[2][i+32][j];

    return image;


def construct_image_large(subpixels, integer_pixels):
    block_size = 8;
    num_entries = 40;
    decompress_rate = 4;
    print len(integer_pixels)
    dim_x = len(integer_pixels)/8*8 
    dim_y = len(integer_pixels[0])/8*8 
    num_sub_images = len(subpixels[0])/num_entries;
    print num_sub_images
    num_col_blocks = dim_y/block_size;
    num_row_blocks = dim_x/block_size;
    print num_col_blocks, num_row_blocks
    print dim_x
    image = np.zeros((dim_x*decompress_rate, dim_y*decompress_rate)); #should be 96x64
    print image.shape
    for step_x in xrange(num_col_blocks):
        col_jump = step_x*block_size;

        for step_y in xrange(num_row_blocks):
            input_jump = step_y*num_entries + step_x*(num_row_blocks)*num_entries;
            row_jump = step_y*block_size;

            for i in xrange(block_size):
                I = (i + row_jump)*decompress_rate;
                half_horz_i = i+input_jump;
                half_vert_i = half_horz_i + 8;
                quarter_1_i = half_horz_i + 16;
                quarter_2_i = half_horz_i + 24;
                quarter_3_i = half_horz_i + 32;

                for j in xrange(block_size):
                    J = (j + col_jump)*decompress_rate;
                    print i, j, col_jump, row_jump
                    image[I][J] = integer_pixels[i+row_jump][j+col_jump]

                    image[I][J+1] = subpixels[0][half_horz_i][j];
                    image[I][J+2] = subpixels[1][half_horz_i][j];
                    image[I][J+3] = subpixels[2][half_horz_i][j];

                    image[I+1][J] = subpixels[0][half_vert_i][j];
                    image[I+2][J] = subpixels[1][half_vert_i][j];
                    image[I+3][J] = subpixels[2][half_vert_i][j];

                    image[I+1][J+1] = subpixels[0][quarter_1_i][j];
                    image[I+2][J+1] = subpixels[1][quarter_1_i][j];
                    image[I+3][J+1] = subpixels[2][quarter_1_i][j];

                    image[I+1][J+2] = subpixels[0][quarter_2_i][j];
                    image[I+2][J+2] = subpixels[1][quarter_2_i][j];
                    image[I+3][J+2] = subpixels[2][quarter_2_i][j];

                    image[I+1][J+3] = subpixels[0][quarter_3_i][j];
                    image[I+2][J+3] = subpixels[1][quarter_3_i][j];
                    image[I+3][J+3] = subpixels[2][quarter_3_i][j];

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
            image[I+1][J+1] = integer_pixels[i][j]
            image[I+1][J+2] = integer_pixels[i][j]
            image[I+1][J+3] = integer_pixels[i][j]

            image[I+2][J+1] = integer_pixels[i][j]
            image[I+2][J+2] = integer_pixels[i][j]
            image[I+2][J+3] = integer_pixels[i][j]

            image[I+3][J+1] = integer_pixels[i][j]
            image[I+3][J+2] = integer_pixels[i][j]
            image[I+3][J+3] = integer_pixels[i][j]

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
    #np.set_printoptions(threshold=np.nan)

    image_array = []
    image_array_large = []
    with open("image_array/test_image_4.mem") as file:
        for line in file.readlines():
            data = line.strip().split()
            entry = [int(i,16) for i in data][3:len(data)-4]
            image_array.append(entry)
            image_array_large.append(entry + entry)
            image_array_large.append(entry + entry)


    #regular interpolation without optimization
    A_large = process_output_array("output/output_4_16x24.txt");
    B_large = process_output_array("output/output_4_16x24.txt");
    C_large = process_output_array("output/output_4_16x24.txt");

    out_verilog_l = [A_large, B_large, C_large];
    image_large = construct_image_large(out_verilog_l, image_array_large[6:len(image_array_large)-8]);
    pprint(image_large)
    out_large = Image.fromarray((image_large * 255).astype(np.uint8))
    plt.figure(1)
    plt.imshow(out_large)
    plt.xlabel("actual interpolated image large!");

    image_array = np.array(image_array)
    length = len(image_array);

    # original image without interpolation
    out_og = Image.fromarray(image_array[3:length-4])
    plt.figure(2)
    plt.imshow(out_og)
    plt.xlabel("original image (no interpolation)");

    # regular interpolation without optimization
    A = process_output_array("output/output_4_a.txt");
    B = process_output_array("output/output_4_b.txt");
    C = process_output_array("output/output_4_c.txt");

    out_verilog = [A, B, C];
    image_actual = construct_image(out_verilog, image_array[3:length-4]);
    out_actual = Image.fromarray((image_actual).astype(np.uint8))
    plt.figure(3)
    plt.imshow(out_actual)
    plt.xlabel("actual interpolated image");

    # loop perforation
    A_loop = process_output_array("output/output_4_a_loop.txt");
    B_loop = process_output_array("output/output_4_b_loop.txt");
    C_loop = process_output_array("output/output_4_c_loop.txt");

    out_loop = [A_loop, B_loop, C_loop]
    image_pred = construct_image(out_loop, image_array[3:length-4]);
    out_pred = Image.fromarray((image_pred).astype(np.uint8))
    plt.figure(4);
    plt.imshow(out_pred)
    plt.xlabel("approximately interpolated image (loop perforation)");

    # approximate multiplierless
    A_multiplierless = process_output_array("output/output_4_a_approx_multiplierless.txt");
    B_multiplierless = process_output_array("output/output_4_b_approx_multiplierless.txt");
    C_multiplierless = process_output_array("output/output_4_c_approx_multiplierless.txt");

    out_multiplierless = [A_multiplierless, B_multiplierless, C_multiplierless]
    image_pred_2 = construct_image(out_multiplierless, image_array[3:length-4]);
    out_pred_2 = Image.fromarray((image_pred_2).astype(np.uint8))
    plt.figure(5);
    plt.imshow(out_pred_2)
    plt.xlabel("approximately interpolated image (approx multiplierless)");

    #pprint(image_actual)
    #pprint(image_pred)

    # approximate multiplierless + loop perforation (hybrid)
    A_hybrid = process_output_array("output/output_4_a_hybrid.txt");
    B_hybrid = process_output_array("output/output_4_b_hybrid.txt");
    C_hybrid = process_output_array("output/output_4_c_hybrid.txt");

    out_hybrid = [A_hybrid, B_hybrid, C_hybrid]
    image_pred_3 = construct_image(out_hybrid, image_array[3:length-4]);
    out_pred_3 = Image.fromarray((image_pred_3).astype(np.uint8))
    plt.figure(6);
    plt.imshow(out_pred_3)
    plt.xlabel("approximately interpolated image (hybrid)");

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

    #calculate for accuracy
    mse_loop = 0;
    mse_mult = 0;
    mse_hybrid = 0;
    for i in xrange(len(out_verilog)):
        print "Testing for output_" + chr(i + 65)
        actual = np.matrix(out_verilog[i]);
        pred_1 = np.matrix(out_loop[i])
        print "MSE (loop):  " , mean_squared_error(actual, pred_1)
        mse_loop += mean_squared_error(actual, pred_1)
        pred_2 = np.matrix(out_multiplierless[i])
        print "MSE (multiplierless):  " , mean_squared_error(actual, pred_2)
        mse_mult += mean_squared_error(actual, pred_2)
        pred_3 = np.matrix(out_hybrid[i])
        print "MSE (multiplierless):  " , mean_squared_error(actual, pred_3)
        mse_hybrid += mean_squared_error(actual, pred_3)

    s_loop = ssim(image_actual, image_pred);
    s_mult = ssim(image_actual, image_pred_2);
    s_hybrid = ssim(image_actual, image_pred_3);

    print
    print "Full image results (loop)"
    print "ssim accuracy measure (-1 to 1): " , s_loop
    print "mse accuracy measure (unbounded): ", mse_loop
    print
    print "Full image results (multiplierless)"
    print "ssim accuracy measure (-1 to 1): " , s_mult
    print "mse accuracy measure (unbounded): ", mse_mult
    print
    print "Full image results (hybrid)"
    print "ssim accuracy measure (-1 to 1): " , s_hybrid
    print "mse accuracy measure (unbounded): ", mse_hybrid
    print

if __name__ == '__main__':
    main()
