struct QueryableGroupJoin <: Queryable
    outer
    inner
    outerKeySelector_func
    outerKeySelector_expr
    innerKeySelector_func
    innerKeySelector_expr
    resultSelector_func
    resultSelector_expr
    getiterator
end

function QueryOperators.groupjoin(outer::Queryable, inner, f_outerKeySelector::Function, outerKeySelector::Expr, f_innerKeySelector::Function, innerKeySelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    return QueryableGroupJoin(outer, inner, f_outerKeySelector, outerKeySelector, f_innerKeySelector, innerKeySelector, f_resultSelector, resultSelector, outer.getiterator)
end
