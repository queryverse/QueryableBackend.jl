struct QueryableOfType <: Queryable
    source
    T::Type
    getiterator
end

struct QueryableCast <: Queryable
    source
    T::Type
    getiterator
end

function QueryOperators.of_type(source::Queryable, ::Type{T}) where {T}
    return QueryableOfType(source, T, source.getiterator)
end

function QueryOperators.cast(source::Queryable, ::Type{T}) where {T}
    return QueryableCast(source, T, source.getiterator)
end
