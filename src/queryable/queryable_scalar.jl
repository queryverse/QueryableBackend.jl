"""
    QueryableScalar <: Queryable

A terminal operator — one that returns a value rather than another sequence.

Unlike every other node this is never left sitting in a tree: the
`QueryOperators` method that builds it immediately hands it to
[`execute_scalar`](@ref). It exists so that a backend has something to inspect
when it wants to push the operator down instead of materialising the source.
"""
struct QueryableScalar <: Queryable
    source
    op::Symbol
    f
    args::Tuple
    getiterator
end

"""
    execute_scalar(q::QueryableScalar)

Produce the value of a terminal operator.

Dispatches on the type of the root source, so a backend can specialise
`_execute_scalar` for its own source type and translate the operator instead.
The fallback materialises the source and delegates to the in-memory
`QueryOperators` implementation, which every backend gets for free.
"""
execute_scalar(q::QueryableScalar) = _execute_scalar(get_source(q.source), q)

_execute_scalar(::QueryableSource, q::QueryableScalar) = _execute_scalar_fallback(q)

"""
    _execute_scalar_fallback(q::QueryableScalar)

Materialize the source and run the in-memory implementation. A backend that
translates only some terminal operators calls this for the rest, so that
correctness never depends on its coverage being complete.
"""
_execute_scalar_fallback(q::QueryableScalar) = q.f(_materialize(q.source), q.args...)

_materialize(source) = QueryOperators.query(IteratorInterfaceExtensions.getiterator(source))

# Builds the node and runs it in one step, which is all the QueryOperators
# methods below need to do.
function _scalar(source::Queryable, op::Symbol, f, args...)
    return execute_scalar(QueryableScalar(source, op, f, args, source.getiterator))
end

# --- The terminal operators ---

QueryOperators.count(source::Queryable) =
    _scalar(source, :count, QueryOperators.count)

QueryOperators.count(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :count, QueryOperators.count, f, f_expr)

QueryOperators.any(source::Queryable) =
    _scalar(source, :any, QueryOperators.any)

QueryOperators.any(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :any, QueryOperators.any, f, f_expr)

QueryOperators.all(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :all, QueryOperators.all, f, f_expr)

QueryOperators.contains(source::Queryable, value) =
    _scalar(source, :contains, QueryOperators.contains, value)

QueryOperators.min_by(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :min_by, QueryOperators.min_by, f, f_expr)

QueryOperators.max_by(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :max_by, QueryOperators.max_by, f, f_expr)

QueryOperators.aggregate(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :aggregate, QueryOperators.aggregate, f, f_expr)

QueryOperators.aggregate(source::Queryable, seed, f::Function, f_expr::Expr) =
    _scalar(source, :aggregate, QueryOperators.aggregate, seed, f, f_expr)

QueryOperators.first(source::Queryable) =
    _scalar(source, :first, QueryOperators.first)

QueryOperators.first(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :first, QueryOperators.first, f, f_expr)

QueryOperators.last(source::Queryable) =
    _scalar(source, :last, QueryOperators.last)

QueryOperators.last(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :last, QueryOperators.last, f, f_expr)

QueryOperators.single(source::Queryable) =
    _scalar(source, :single, QueryOperators.single)

QueryOperators.single(source::Queryable, f::Function, f_expr::Expr) =
    _scalar(source, :single, QueryOperators.single, f, f_expr)

QueryOperators.element_at(source::Queryable, n::Integer) =
    _scalar(source, :element_at, QueryOperators.element_at, n)

# sequence_equal compares two sequences, so the second one is materialized
# alongside the first rather than being pushed down.
function QueryOperators.sequence_equal(a::Queryable, b)
    return _scalar(a, :sequence_equal, QueryOperators.sequence_equal, _materialize_operand(b))
end

_materialize_operand(x::Queryable) = _materialize(x)
_materialize_operand(x) = QueryOperators.query(x)
