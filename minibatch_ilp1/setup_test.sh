export MOSEKLM_LICENSE_FILE=/home/apoorv/MTP/latentSVM_codesetup/mosek/mosek.lic
export LD_LIBRARY_PATH='/home/apoorv/MTP/latentSVM_codesetup/mosek/5/tools/platform/linux64x86/bin;/home/apoorv/MTP/Luna_Workspace/latentssvm_online.c/java/lib:/usr/lib/lp_solve'
ulimit -c unlimited
java -Xmx4G -cp java/lib/*:java/bin/:/usr/lib/lp_solve/ evaluation.ClassifyStructEgAllOnline temp_riedel_10p_1.model dataset/testSVM.pos_r.data dataset/reidel_mapping
java -Xmx4G -cp java/lib/*:java/bin/:/usr/lib/lp_solve/ evaluation.ReidelEval temp_riedel_10p_1.model.result 0.5
