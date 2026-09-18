struct QueryableConcat <: QueryableBinary
    outer
    inner
    getiterator
end

struct QueryableUnion <: QueryableBinary
    outer
    inner
    f_func
    f_expr
    getiterator
end

struct QueryableExcept <: QueryableBinary
    outer
    inner
    f_func
    f_expr
    getiterator
end

struct QueryableIntersect <: QueryableBinary
    outer
    inner
    f_func
    f_expr
    getiterator
end

function QueryOperators.concat(outer::Queryable, inner)
    return QueryableConcat(outer, inner, outer.getiterator)
end

# The plain and `_by` forms share a node: the plain form records a `nothing`
# key selector, which a backend reads as "compare whole elements".
for (op, op_by, node) in ((:union, :union_by, :QueryableUnion),
                          (:except, :except_by, :QueryableExcept),
                          (:intersect, :intersect_by, :QueryableIntersect))
    @eval function QueryOperators.$op(outer::Queryable, inner)
        return $node(outer, inner, nothing, nothing, outer.getiterator)
    end

    @eval function QueryOperators.$op_by(outer::Queryable, inner, f::Function, f_expr::Expr)
        return $node(outer, inner, f, f_expr, outer.getiterator)
    end
end
