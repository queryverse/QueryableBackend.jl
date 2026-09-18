struct QueryableCountBy <: Queryable
    source
    f_func
    f_expr
    getiterator
end

struct QueryableAggregateBy <: Queryable
    source
    f_func
    f_expr
    seed
    accumulator_func
    getiterator
end

struct QueryableChunk <: Queryable
    source
    n::Int
    getiterator
end

function QueryOperators.count_by(source::Queryable, f::Function, f_expr::Expr)
    return QueryableCountBy(source, f, f_expr, source.getiterator)
end

function QueryOperators.aggregate_by(source::Queryable, f::Function, f_expr::Expr, seed, accumulator::Function)
    return QueryableAggregateBy(source, f, f_expr, seed, accumulator, source.getiterator)
end

function QueryOperators.chunk(source::Queryable, n::Integer)
    return QueryableChunk(source, Int(n), source.getiterator)
end
