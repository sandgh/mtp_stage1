function [] = writeWeightVector(filename, W, NO_OF_RELNS, max_feature)

    fid = fopen(filename, 'wt'); % Open for writing
    fprintf(fid,'%d\n',NO_OF_RELNS-1 );
    fprintf(fid,'%d\n',max_feature+1 );
    dlmwrite(filename, W,'-append', 'delimiter', ' ');
    fclose(fid);

end