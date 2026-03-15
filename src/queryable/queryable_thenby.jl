struct QueryableThenBy <: Queryable
    source
    keySelector_func
    keySelector_expr
    descending::Bool
    getiterator
end

function QueryOperators.thenby(source::Queryable, f::Function, f_expr::Expr)
    return QueryableThenBy(source, f, f_expr, false, source.getiterator)
end

function QueryOperators.thenby_descending(source::Queryable, f::Function, f_expr::Expr)
    return QueryableThenBy(source, f, f_expr, true, source.getiterator)
end
