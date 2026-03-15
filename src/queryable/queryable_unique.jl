struct QueryableUnique <: Queryable
    source
    f_func
    f_expr
    getiterator
end

function QueryOperators.unique(source::Queryable, f::Function, f_expr::Expr)
    return QueryableUnique(source, f, f_expr, source.getiterator)
end
