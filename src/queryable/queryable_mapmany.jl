struct QueryableMapMany <: Queryable
    source
    collectionSelector_func
    collectionSelector_expr
    resultSelector_func
    resultSelector_expr
    getiterator
end

function QueryOperators.mapmany(source::Queryable, f_collectionSelector::Function, collectionSelector::Expr, f_resultSelector::Function, resultSelector::Expr)
    return QueryableMapMany(source, f_collectionSelector, collectionSelector, f_resultSelector, resultSelector, source.getiterator)
end
