"""
    QueryPlan

Holds the ordered list of Queryable nodes from source to final operation.
Returned by `queryplan(q)`.
"""
struct QueryPlan
    nodes::Vector{Queryable}
end

"""
    queryplan(q::Queryable) -> QueryPlan

Walk the query tree and return a `QueryPlan` showing the operations in order.
"""
function queryplan(q::Queryable)
    return QueryPlan(walk_tree(q))
end

# --- describe_node: extensible per-node-type description ---

describe_node(::QueryableSource) = "Source"

function describe_node(q::QueryableFilter)
    return "Filter: $(string(q.filter_expr))"
end

function describe_node(q::QueryableMap)
    return "Map: $(string(q.f_expr))"
end

function describe_node(q::QueryableOrderBy)
    dir = q.descending ? "DESC" : "ASC"
    return "OrderBy: $(string(q.keySelector_expr)) ($dir)"
end

function describe_node(q::QueryableThenBy)
    dir = q.descending ? "DESC" : "ASC"
    return "ThenBy: $(string(q.keySelector_expr)) ($dir)"
end

function describe_node(q::QueryableTake)
    return "Take: $(q.n)"
end

function describe_node(q::QueryableDrop)
    return "Drop: $(q.n)"
end

function describe_node(q::QueryableUnique)
    return "Unique"
end

function describe_node(q::QueryableGroupBy)
    return "GroupBy: $(string(q.elementSelector_expr))"
end

function describe_node(q::QueryableGroupByFull)
    return "GroupBy: $(string(q.elementSelector_expr)) => $(string(q.resultSelector_expr))"
end

function describe_node(q::QueryableJoin)
    return "Join: $(string(q.outerKeySelector_expr)) = $(string(q.innerKeySelector_expr)) => $(string(q.resultSelector_expr))"
end

function describe_node(q::QueryableGroupJoin)
    return "GroupJoin: $(string(q.outerKeySelector_expr)) = $(string(q.innerKeySelector_expr)) => $(string(q.resultSelector_expr))"
end

function describe_node(q::QueryableMapMany)
    return "MapMany: $(string(q.collectionSelector_expr)) => $(string(q.resultSelector_expr))"
end

function describe_node(q::QueryableLeftJoin)
    return "LeftJoin: $(string(q.outerKeySelector_expr)) = $(string(q.innerKeySelector_expr)) => $(string(q.resultSelector_expr))"
end

function describe_node(q::QueryableRightJoin)
    return "RightJoin: $(string(q.outerKeySelector_expr)) = $(string(q.innerKeySelector_expr)) => $(string(q.resultSelector_expr))"
end

function describe_node(q::QueryableFullJoin)
    return "FullJoin: $(string(q.outerKeySelector_expr)) = $(string(q.innerKeySelector_expr)) => $(string(q.resultSelector_expr))"
end

describe_node(::QueryableConcat) = "Concat"

describe_node(q::QueryableUnion) = _describe_setop("Union", q)

describe_node(q::QueryableExcept) = _describe_setop("Except", q)

describe_node(q::QueryableIntersect) = _describe_setop("Intersect", q)

# A `nothing` key selector is the plain form, which compares whole elements.
function _describe_setop(name, q)
    return q.f_expr === nothing ? name : "$(name)By: $(string(q.f_expr))"
end

describe_node(q::QueryableTakeWhile) = "TakeWhile: $(string(q.f_expr))"

describe_node(q::QueryableDropWhile) = "DropWhile: $(string(q.f_expr))"

describe_node(q::QueryableTakeLast) = "TakeLast: $(q.n)"

describe_node(q::QueryableDropLast) = "DropLast: $(q.n)"

describe_node(::QueryableReverse) = "Reverse"

describe_node(::QueryableShuffle) = "Shuffle"

describe_node(::QueryableIndex) = "Index"

describe_node(q::QueryableAppend) = "Append: $(repr(q.element))"

describe_node(q::QueryablePrepend) = "Prepend: $(repr(q.element))"

function describe_node(q::QueryableZip)
    return q.resultSelector_expr === nothing ? "Zip" : "Zip: $(string(q.resultSelector_expr))"
end

describe_node(q::QueryableCountBy) = "CountBy: $(string(q.f_expr))"

describe_node(q::QueryableAggregateBy) = "AggregateBy: $(string(q.f_expr))"

describe_node(q::QueryableChunk) = "Chunk: $(q.n)"

describe_node(q::QueryableOfType) = "OfType: $(q.T)"

describe_node(q::QueryableCast) = "Cast: $(q.T)"

describe_node(q::QueryableScalar) = "Scalar: $(q.op)"

# Fallback for unknown/extension types
describe_node(q::Queryable) = string(typeof(q))

# --- show methods ---

function Base.show(io::IO, ::MIME"text/plain", plan::QueryPlan)
    println(io, "Query Plan")
    println(io, "──────────")
    for (i, node) in enumerate(plan.nodes)
        println(io, " ", lpad(i, 2), ". ", describe_node(node))
    end
end

function Base.show(io::IO, plan::QueryPlan)
    descriptions = [describe_node(node) for node in plan.nodes]
    print(io, "QueryPlan(", join(descriptions, " → "), ")")
end
