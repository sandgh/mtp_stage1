function [Fscore_macro] = find_FScore_macro(config, TP_macro, TN_macro, Theta_macro)

        Fscore_macro = ((1+config.BETA^2)*TP_macro)/(config.BETA^2+Theta_macro+TP_macro-Theta_macro*TN_macro);

end