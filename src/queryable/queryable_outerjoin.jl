struct QueryableLeftJoin <: QueryableBinary
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

struct QueryableRightJoin <: QueryableBinary
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

struct QueryableFullJoin <: QueryableBinary
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

for (op, node) in ((:left_join, :QueryableLeftJoin),
                   (:right_join, :QueryableRightJoin),
                   (:full_join, :QueryableFullJoin))
    @eval function QueryOperators.$op(outer::Queryable, inner, f_outerKeySelector::Function, outerKeySelector::Expr, f_innerKeySelector::Function, innerKeySelector::Expr, f_resultSelector::Function, resultSelector::Expr)
        return $node(outer, inner, f_outerKeySelector, outerKeySelector, f_innerKeySelector, innerKeySelector, f_resultSelector, resultSelector, outer.getiterator)
    end
end
