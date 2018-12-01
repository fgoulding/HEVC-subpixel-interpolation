import random

def hex_matrix(start_value, rand=False, D=15):
	matrix = "";
	for i in xrange(D):
		for j in xrange(D):
			if (rand == False):
				hex_val = hex(D*i+start_value+j)[2:];
			else:
				hex_val = hex(random.randint(start_value, 255))[2:];
			matrix += str(hex_val).zfill(2) + " ";
		matrix += "\n";

	return matrix;


#print hex_matrix(31, True)
#print hex_matrix(0)

# with open("test_image_3.mem", "w") as output_image:
# 	output_image.write(hex_matrix(0)); 

matrix = "";
with open("image_array/test_image_4.txt", "r") as input_image:
	for line in input_image:
		for char in line.split(" "):
			matrix += str(hex(int(char))[2:]).zfill(2) + " ";
		matrix += "\n";

print matrix;

with open("image_array/test_image_4.mem", "w") as output_image:
	output_image.write(matrix); 
