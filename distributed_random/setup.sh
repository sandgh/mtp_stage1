#./svm_latent_learn_online -n 4 -f tmp3/ -w 0.5 -y 0.9 -z dataset/v.small.stats -o 0.0 -a 0 -b 1 -C 5 -c 5 -e 0.5 dataset/v.small.data temp-x.model >> abc.txt 2>>abc.txt & -- command to run online svm pre-version -- working without segfaults -- java code to split datasets
#./svm_latent_learn_online -n 4 -f tmp3/ -w 0.5 -y 0.9 -z dataset/v.small.stats -o 0.0 -a 0 -b 1 -C 5 -c 5 -e 0.5 -K 5 -E 2 dataset/v.small.data temp-y.model >> cdf.txt 2>>cdf.txt & -- online svm-version -- running without faults on the local m/c on a small dataset (change of vars, augmenting loss multiple epochs)

out_file=print.log
curr_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo $curr_time
new_out_file=$curr_time.$out_file
echo $new_out_file
export MOSEKLM_LICENSE_FILE=/home/sandip/sandip_mtp/mosek/mosek.lic
export LD_LIBRARY_PATH='/home/sandip/sandip_mtp/mosek/5/tools/platform/linux64x86/bin;/home/sandip/sandip_mtp/codebase/online_rewrite_random_chunk/java/lib:/home/sandip/sandip_mtp/lp_solve'
ulimit -c unlimited
./svm_latent_learn_online -n 10 -f tmp1/ -w 0.5 -y 0.9 -z dataset/train-riedel-10p.1.stats -o 0.0 -a 0 -b 1 -C 5 -c 5 -e 0.5 -M 10 -K 30 -E 40 dataset/reidel_trainSVM.data reidel_trainSVM.model > $new_out_file
