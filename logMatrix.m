function matrixLogarithm = logMatrix(M) 

R=M(1:3,1:3);

fi = acos((trace(R)-1)/2);
w = fi/(2*sin(fi))*(R-R');
w1 = w(3,2);
w2 = w(1,3);
w3 = w(2,1);

matrixLogarithm = [w1; w2; w3];