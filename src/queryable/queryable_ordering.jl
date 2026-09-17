struct QueryableReverse <: Queryable
    source
    getiterator
end

struct QueryableShuffle <: Queryable
    source
    rng
    getiterator
end

struct QueryableIndex <: Queryable
    source
    getiterator
end

# `order` and `order_descending` sort by the elements themselves, which is an
# orderby with an identity key selector. They reuse QueryableOrderBy rather
# than adding a node type, so `thenby` can still follow them and a backend can
# recognise the identity selector to sort by every column.
function QueryOperators.order(source::Queryable)
    return QueryOperators.orderby(source, identity, :(i -> i))
end

function QueryOperators.order_descending(source::Queryable)
    return QueryOperators.orderby_descending(source, identity, :(i -> i))
end

function QueryOperators.reverse(source::Queryable)
    return QueryableReverse(source, source.getiterator)
end

function QueryOperators.shuffle(source::Queryable)
    return QueryableShuffle(source, nothing, source.getiterator)
end

function QueryOperators.shuffle(source::Queryable, rng)
    return QueryableShuffle(source, rng, source.getiterator)
end

function QueryOperators.index(source::Queryable)
    return QueryableIndex(source, source.getiterator)
end
