abstract type Queryable end

"""
    QueryableBinary <: Queryable

Nodes that combine two sources — joins, set operations, `zip`. They carry
`outer` and `inner` fields, and the tree walk follows `outer`, so the query
plan reads as a chain hanging off the primary input with the secondary input
attached at the node.
"""
abstract type QueryableBinary <: Queryable end

QueryOperators.query(x::Queryable) = x

IteratorInterfaceExtensions.isiterable(x::Queryable) = true
TableTraits.isiterabletable(x::Queryable) = true

function IteratorInterfaceExtensions.getiterator(x::Queryable)
    return x.getiterator(x)
end
