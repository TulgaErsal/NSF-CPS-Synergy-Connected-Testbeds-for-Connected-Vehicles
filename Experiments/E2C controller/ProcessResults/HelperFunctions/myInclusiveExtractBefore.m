function [out] = myInclusiveExtractBefore(char_vec, pattern)

if contains(char_vec, pattern)
    out = [char(extractBefore(char_vec, pattern)), pattern];
else
    out = [];
end


end