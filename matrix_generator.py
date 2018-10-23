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


print hex_matrix(31, True)
# print hex_matrix(13)
