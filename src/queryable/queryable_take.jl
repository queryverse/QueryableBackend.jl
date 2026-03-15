struct QueryableTake <: Queryable
    source
    n::Int
    getiterator
end

function QueryOperators.take(source::Queryable, n::Integer)
    return QueryableTake(source, Int(n), source.getiterator)
end
