struct QueryableGroupBy <: Queryable
    source
    elementSelector_func
    elementSelector_expr
    getiterator
end

struct QueryableGroupByFull <: Queryable
    source
    elementSelector_func
    elementSelector_expr
    resultSelector_func
    resultSelector_expr
    getiterator
end

function QueryOperators.groupby(source::Queryable, f_elementSelector::Function, elementSelector::Expr)
    return QueryableGroupBy(source, f_elementSelector, elementSelector, source.getiterator)
end

function QueryOperators.groupby(source::Queryable, f_elementSelector::Function, elementSelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    return QueryableGroupByFull(source, f_elementSelector, elementSelector, f_resultSelector, resultSelector, source.getiterator)
end
