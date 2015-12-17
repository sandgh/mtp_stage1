export MOSEKLM_LICENSE_FILE=/home/sandip/sandip_mtp/mosek/mosek.lic
export LD_LIBRARY_PATH='/home/sandip/sandip_mtp/mosek/5/tools/platform/linux64x86/bin;/home/sandip/sandip_mtp/codebase/online_rewrite_random_chunk/java/lib:/home/sandip/sandip_mtp/lp_solve'
java -Xmx1G -cp java/bin:java/lib/*  javaHelpers.splitDatasetILP dataset/reidel_trainSVM.data 30
