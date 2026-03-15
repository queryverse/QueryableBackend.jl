struct QueryableOrderBy <: Queryable
    source
    keySelector_func
    keySelector_expr
    descending::Bool
    getiterator
end

function QueryOperators.orderby(source::Queryable, f::Function, f_expr::Expr)
    return QueryableOrderBy(source, f, f_expr, false, source.getiterator)
end

function QueryOperators.orderby_descending(source::Queryable, f::Function, f_expr::Expr)
    return QueryableOrderBy(source, f, f_expr, true, source.getiterator)
end
