abstract type Queryable end

IteratorInterfaceExtensions.isiterable(x::Queryable) = true
TableTraits.isiterabletable(x::Queryable) = true

function IteratorInterfaceExtensions.getiterator(x::Queryable)
    return x.getiterator(x)
end
