"""
    get_source(q::Queryable)

Follow the `.source` (or `.outer`) chain to the root `QueryableSource`.
"""
function get_source(q::QueryableSource)
    return q
end

function get_source(q::QueryableJoin)
    return get_source(q.outer)
end

function get_source(q::QueryableGroupJoin)
    return get_source(q.outer)
end

function get_source(q::Queryable)
    return get_source(q.source)
end

"""
    walk_tree(q::Queryable)

Return an ordered list of Queryable nodes from the root source to the final operation.
"""
function walk_tree(q::Queryable)
    nodes = Queryable[]
    _collect_nodes!(nodes, q)
    return reverse!(nodes)
end

function _collect_nodes!(nodes, q::QueryableSource)
    push!(nodes, q)
end

function _collect_nodes!(nodes, q::QueryableJoin)
    push!(nodes, q)
    _collect_nodes!(nodes, q.outer)
end

function _collect_nodes!(nodes, q::QueryableGroupJoin)
    push!(nodes, q)
    _collect_nodes!(nodes, q.outer)
end

function _collect_nodes!(nodes, q::Queryable)
    push!(nodes, q)
    _collect_nodes!(nodes, q.source)
end
