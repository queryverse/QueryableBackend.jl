struct QueryableDrop <: Queryable
    source
    n::Int
    getiterator
end

function QueryOperators.drop(source::Queryable, n::Integer)
    return QueryableDrop(source, Int(n), source.getiterator)
end
