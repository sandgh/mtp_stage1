function [Fscore_micro] = find_FScore_micro(config, TP_micro, TN_micro, Theta_micro)

        Fscore_micro = ((1+config.BETA^2)*TP_micro)/(config.BETA^2+Theta_micro+TP_micro-Theta_micro*TN_micro);

end