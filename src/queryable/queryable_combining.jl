struct QueryableAppend <: Queryable
    source
    element
    getiterator
end

struct QueryablePrepend <: Queryable
    source
    element
    getiterator
end

struct QueryableZip <: QueryableBinary
    outer
    inner
    resultSelector_func
    resultSelector_expr
    getiterator
end

function QueryOperators.append(source::Queryable, element)
    return QueryableAppend(source, element, source.getiterator)
end

function QueryOperators.prepend(source::Queryable, element)
    return QueryablePrepend(source, element, source.getiterator)
end

# As with the set operators, a `nothing` result selector means the default:
# pair the two elements into a tuple.
function QueryOperators.zip(outer::Queryable, inner)
    return QueryableZip(outer, inner, nothing, nothing, outer.getiterator)
end

function QueryOperators.zip(outer::Queryable, inner, f_resultSelector::Function, resultSelector::Expr)
    return QueryableZip(outer, inner, f_resultSelector, resultSelector, outer.getiterator)
end
