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
