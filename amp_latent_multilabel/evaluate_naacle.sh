export LD_LIBRARY_PATH='/usr/lib/lp_solve'
ulimit -c unlimited
java -Xmx4G -cp java/lib/*:java/bin/:/usr/lib/lp_solve/ evaluation.ClassifyStructEgAll tmp1/inf_lat_var_all dataset/testSVM.pos_r.data1 dataset/reidel_mapping
#now=$(date +"%H_%M_%S_%d_%m_%Y")
#cp tmp1/inf_lat_var_all.result tmp1/inf_lat_var_all.result.$now
java -Xmx4G -cp java/lib/*:java/bin/:/usr/lib/lp_solve/ evaluation.ReidelEval tmp1/inf_lat_var_all.result 0.5 >> f_score_joint.txt
