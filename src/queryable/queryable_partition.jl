struct QueryableTakeWhile <: Queryable
    source
    f_func
    f_expr
    getiterator
end

struct QueryableDropWhile <: Queryable
    source
    f_func
    f_expr
    getiterator
end

struct QueryableTakeLast <: Queryable
    source
    n::Int
    getiterator
end

struct QueryableDropLast <: Queryable
    source
    n::Int
    getiterator
end

function QueryOperators.take_while(source::Queryable, f::Function, f_expr::Expr)
    return QueryableTakeWhile(source, f, f_expr, source.getiterator)
end

function QueryOperators.drop_while(source::Queryable, f::Function, f_expr::Expr)
    return QueryableDropWhile(source, f, f_expr, source.getiterator)
end

function QueryOperators.take_last(source::Queryable, n::Integer)
    return QueryableTakeLast(source, Int(n), source.getiterator)
end

function QueryOperators.drop_last(source::Queryable, n::Integer)
    return QueryableDropLast(source, Int(n), source.getiterator)
end
