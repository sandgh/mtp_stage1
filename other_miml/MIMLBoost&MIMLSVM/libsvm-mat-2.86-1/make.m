% This make.m is used under Windows

% mex -O -c svm.cpp
% mex -O -c svm_model_matlab.c
% mex -O svmtrain.c svm.o svm_model_matlab.o
% mex -O svmpredict.c svm.o svm_model_matlab.o
% mex -O read_sparse.c
% mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims libsvmread.c
% mex CFLAGS="\$CFLAGS -std=c99" -largeArrayDims libsvmwrite.c
mex CFLAGS="\$CFLAGS -std=c99" -I.. -largeArrayDims svmtrain.c svm.cpp svm_model_matlab.c
mex CFLAGS="\$CFLAGS -std=c99" -I.. -largeArrayDims svmpredict.c svm.cpp svm_model_matlab.c
