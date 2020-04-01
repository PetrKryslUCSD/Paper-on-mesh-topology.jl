function usedbytes(v) 
    n = 0
    for i in 1:length(v)
        n += sizeof(v[i])
    end
    nv = sizeof(v)
    if nv == n 
        # we already accounted for the storage of the vectors v[i] and the
        # vector v because the elements of the vector v are stored in line
        return n
    else
        # the vectors v[i] are accounted for, but now we need to add the storage
        # for the vector v itself
        return n + nv
    end
end