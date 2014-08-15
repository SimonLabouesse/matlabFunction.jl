



function ramp(array::Array, dim::Integer, isSimilar::Bool = true)
    if(isSimilar)
        ret = similar(array);
    else
        ret = Array(Float64,array...);
    end
    stepBe = prod(size(ret)[1:dim-1]);
    sizeD = size(ret,dim);
    stepAf = prod(size(ret)[dim+1:end]);
    initVal=-div(sizeD,2);    
    ind=1;
    for i = 1:stepAf
        val=initVal;
        for j=1:sizeD
            for k=1:stepBe
                ret[ind]=val;
                ind+=1;
            end
            val+=1;
        end
    end
    return ret;
end
#
#
function xx(array::Array, isSimilar::Bool = true)
    return ramp(array,2,isSimilar);
end
#
function yy(array::Array, isSimilar::Bool = true)
    return ramp(array,1,isSimilar);
end
#
function zz(array::Array, isSimilar::Bool = true)
    return ramp(array,3,isSimilar);
end
#
#
function xx(array::Tuple, isSimilar::Bool = true)
    return ramp([array...],2,isSimilar);
end
#
function yy(array::Tuple, isSimilar::Bool = true)
    return ramp([array...],1,isSimilar);
end
#
function zz(array::Tuple, isSimilar::Bool = true)
    return ramp([array...],3,isSimilar);
end
#
#
#
#
#
macro boucle_dim(dimSize,add,ex)
    quote
        local i;
        for i = 1:$dimSize
            $(esc(ex));
            #$ex;
            offset += $add;
        end
    end;
end
#
#
#
#
#
function myRepmat(array::Array, n::Int...)
    #
    #
    #
    #array = rand(Int,2,3,2);
    #tp=[2,2,2]
    #array = xx(tp,false) .+ yy(tp,false);
    #array = [[ 1 2] ; [3 4]];
    #
    #n = (2,2,1);
    #
    #
    ad = ndims(array);
    nd = length(n);
    vmax = max(ad,nd);
    vmin = min(ad,nd);
    aSize = Array(Int,vmax+1);
    for i=1:ad
        aSize[i] = size(array,i);
    end
    aSize[vmax+1] = 0;
    retSize = Array(Int,vmax);
    nTab = Array(Int,vmax);
    #
    for i=1:nd
        nTab[i] = n[i];
    end
    #
    for i=1:vmin
        retSize[i] = aSize[i]*nTab[i];
    end
    if(ad == vmin)
        for i=vmin+1:vmax
            retSize[i] = nTab[i];
            aSize[i] = 1;
        end
    else
        for i=vmin+1:vmax
            retSize[i] = aSize[i];
            nTab[i]= 1;
        end
    end
    ret = Array(eltype(array),retSize...)
    #
    #
    ex = quote
        ret[offset] = array[id];
        id+=1;
    end;
    #
    addOffset = 1;
    offsetTot = 0;
    newOffset = 1;
    for i=1:ad
        curSize = aSize[i];
        ex = :( @boucle_dim($curSize,$addOffset,$ex))
        offsetTot = curSize*(addOffset+offsetTot);
        newOffset *= retSize[i];
        addOffset = newOffset - offsetTot;
        #println("$offsetTot       $newOffset\n");
    end
    #
    #
    ex = quote
        id=1;
        $ex;
    end;
    #
    #
    temp=1;
    newOffset = aSize[1];
    addOffset = newOffset - offsetTot;
    #println("resume : $offsetTot    $newOffset  $addOffset   \n");
    for i=1:nd
        curSize = nTab[i];
        ex = :( @boucle_dim($curSize,$addOffset,$ex))
        offsetTot = curSize*(addOffset+offsetTot);
        temp*=retSize[i];
        newOffset = temp*aSize[i+1];
        addOffset = newOffset - offsetTot;
        #println("$offsetTot       $newOffset   $addOffset  and  $curSize\n");
    end
    #
    #
    ex = quote
        local id=1;
        local offset=1;
        array = $array;
        ret = $ret;
        #$(esc(ex));
        $ex;
    end;    
    #println( macroexpand(ex));
    #eval(esc(ex))
    eval(ex)
    #
    #ret
    return ret
    #
end
#
#
function myRepmat(array::Array, n::Array)
    return myRepmat(array::Array, n...);
end
#
#
#myRepmat([1 2 ; 3 4 ],1,2)
#
#




#function fft2rft(in::Array)
#    #
#    if ndims(in) == 2
#        out=in[:,1:floor(size(in,2)/2)];
#    elseif ndims(in) == 3
#        out=in[:,1:floor(size(in,2)/2),:];
#    else
#        error("fft2rft only defined for 2d and 3d arrays.");
#    end
#    #
#end
##
##
#function rft2fft(in::Array)
#    
#end
