@testsnippet ExprCompare begin
    # A quoted lambda carries a LineNumberNode pointing at wherever it was
    # written, so two structurally identical selectors are never `==`. Compare
    # them with the line information removed.
    strip_lines(x) = x
    strip_lines(e::Expr) = Expr(e.head, Any[strip_lines(a) for a in e.args if !(a isa LineNumberNode)]...)

    same_expr(a, b) = strip_lines(a) == strip_lines(b)
end

@testitem "outer joins build binary nodes" setup=[ExampleBackend] begin
    other = [(a = 1, c = "x")]

    for (op, node) in ((QueryOperators.left_join, QueryableBackend.QueryableLeftJoin),
                       (QueryOperators.right_join, QueryableBackend.QueryableRightJoin),
                       (QueryOperators.full_join, QueryableBackend.QueryableFullJoin))
        q = op(QueryOperators.query(source), other,
               i -> i.a, :(i -> i.a),
               i -> i.a, :(i -> i.a),
               (i, j) -> (b = i.b, c = j.c), :((i, j) -> (b = i.b, c = j.c)))

        @test q isa node
        @test q isa QueryableBackend.QueryableBinary
        @test q.inner === other
        @test QueryableBackend.get_source(q) isa QueryableBackend.QueryableSource
    end
end

@testitem "the tree walk follows the outer side of a binary node" setup=[ExampleBackend] begin
    q = QueryOperators.left_join(
        QueryOperators.query(source), [(a = 1, c = "x")],
        i -> i.a, :(i -> i.a),
        i -> i.a, :(i -> i.a),
        (i, j) -> (b = i.b, c = j.c), :((i, j) -> (b = i.b, c = j.c)))

    q = QueryOperators.take(q, 1)

    nodes = QueryableBackend.walk_tree(q)

    @test length(nodes) == 3
    @test nodes[1] isa QueryableBackend.QueryableSource
    @test nodes[2] isa QueryableBackend.QueryableLeftJoin
    @test nodes[3] isa QueryableBackend.QueryableTake
end

@testitem "set operators build nodes, with nothing marking the plain form" setup=[ExampleBackend, ExprCompare] begin
    other = [(a = 3, b = 3)]

    concat = QueryOperators.concat(QueryOperators.query(source), other)
    @test concat isa QueryableBackend.QueryableConcat
    @test concat isa QueryableBackend.QueryableBinary

    for (plain, by, node) in ((QueryOperators.union, QueryOperators.union_by, QueryableBackend.QueryableUnion),
                              (QueryOperators.except, QueryOperators.except_by, QueryableBackend.QueryableExcept),
                              (QueryOperators.intersect, QueryOperators.intersect_by, QueryableBackend.QueryableIntersect))
        q = plain(QueryOperators.query(source), other)
        @test q isa node
        @test q.f_expr === nothing

        q_by = by(QueryOperators.query(source), other, i -> i.a, :(i -> i.a))
        @test q_by isa node
        @test same_expr(q_by.f_expr, :(i -> i.a))
    end
end

@testitem "partitioning operators build nodes" setup=[ExampleBackend, ExprCompare] begin
    q = QueryOperators.take_while(QueryOperators.query(source), i -> i.a < 2, :(i -> i.a < 2))
    @test q isa QueryableBackend.QueryableTakeWhile
    @test same_expr(q.f_expr, :(i -> i.a < 2))

    q = QueryOperators.drop_while(QueryOperators.query(source), i -> i.a < 2, :(i -> i.a < 2))
    @test q isa QueryableBackend.QueryableDropWhile

    q = QueryOperators.take_last(QueryOperators.query(source), 3)
    @test q isa QueryableBackend.QueryableTakeLast
    @test q.n == 3

    q = QueryOperators.drop_last(QueryOperators.query(source), 2)
    @test q isa QueryableBackend.QueryableDropLast
    @test q.n == 2
end

@testitem "order reuses QueryableOrderBy with an identity selector" setup=[ExampleBackend, ExprCompare] begin
    q = QueryOperators.order(QueryOperators.query(source))

    @test q isa QueryableBackend.QueryableOrderBy
    @test q.descending == false
    @test same_expr(q.keySelector_expr, :(i -> i))

    q = QueryOperators.order_descending(QueryOperators.query(source))
    @test q isa QueryableBackend.QueryableOrderBy
    @test q.descending == true
    @test same_expr(q.keySelector_expr, :(i -> i))
end

@testitem "thenby can still follow order" setup=[ExampleBackend] begin
    q = QueryOperators.thenby(
        QueryOperators.order(QueryOperators.query(source)),
        i -> i.b, :(i -> i.b))

    @test q isa QueryableBackend.QueryableThenBy
    @test q.source isa QueryableBackend.QueryableOrderBy
end

@testitem "ordering and row-position operators build nodes" setup=[ExampleBackend] begin
    @test QueryOperators.reverse(QueryOperators.query(source)) isa QueryableBackend.QueryableReverse
    @test QueryOperators.index(QueryOperators.query(source)) isa QueryableBackend.QueryableIndex

    q = QueryOperators.shuffle(QueryOperators.query(source))
    @test q isa QueryableBackend.QueryableShuffle
    @test q.rng === nothing

    q = QueryOperators.shuffle(QueryOperators.query(source), 42)
    @test q isa QueryableBackend.QueryableShuffle
    @test q.rng == 42
end

@testitem "combining operators build nodes" setup=[ExampleBackend, ExprCompare] begin
    q = QueryOperators.append(QueryOperators.query(source), (a = 9, b = 9))
    @test q isa QueryableBackend.QueryableAppend
    @test q.element == (a = 9, b = 9)

    q = QueryOperators.prepend(QueryOperators.query(source), (a = 0, b = 0))
    @test q isa QueryableBackend.QueryablePrepend

    q = QueryOperators.zip(QueryOperators.query(source), [1, 2])
    @test q isa QueryableBackend.QueryableZip
    @test q isa QueryableBackend.QueryableBinary
    @test q.resultSelector_expr === nothing

    q = QueryOperators.zip(QueryOperators.query(source), [1, 2], (x, y) -> (x, y), :((x, y) -> (x, y)))
    @test same_expr(q.resultSelector_expr, :((x, y) -> (x, y)))
end

@testitem "keyed aggregation operators build nodes" setup=[ExampleBackend] begin
    q = QueryOperators.count_by(QueryOperators.query(source), i -> i.a, :(i -> i.a))
    @test q isa QueryableBackend.QueryableCountBy

    q = QueryOperators.aggregate_by(QueryOperators.query(source), i -> i.a, :(i -> i.a), 0, (acc, cur) -> acc + cur.b)
    @test q isa QueryableBackend.QueryableAggregateBy
    @test q.seed == 0

    q = QueryOperators.chunk(QueryOperators.query(source), 2)
    @test q isa QueryableBackend.QueryableChunk
    @test q.n == 2
end

@testitem "type filtering operators build nodes" setup=[ExampleBackend] begin
    q = QueryOperators.of_type(QueryOperators.query(source), NamedTuple)
    @test q isa QueryableBackend.QueryableOfType
    @test q.T == NamedTuple

    q = QueryOperators.cast(QueryOperators.query(source), Any)
    @test q isa QueryableBackend.QueryableCast
    @test q.T == Any
end

@testitem "terminal operators fall back to the in-memory implementation" setup=[ExampleBackend] begin
    q = QueryOperators.query(source)

    # The example backend's getiterator yields [(a=1,b=1), (a=2,b=2)].
    @test QueryOperators.count(q) == 2
    @test QueryOperators.count(q, i -> i.a > 1, :(i -> i.a > 1)) == 1
    @test QueryOperators.any(q) == true
    @test QueryOperators.any(q, i -> i.a > 5, :(i -> i.a > 5)) == false
    @test QueryOperators.all(q, i -> i.a > 0, :(i -> i.a > 0)) == true
    @test QueryOperators.contains(q, (a = 1, b = 1)) == true
    @test QueryOperators.first(q) == (a = 1, b = 1)
    @test QueryOperators.last(q) == (a = 2, b = 2)
    @test QueryOperators.element_at(q, 2) == (a = 2, b = 2)
    @test QueryOperators.min_by(q, i -> i.a, :(i -> i.a)) == (a = 1, b = 1)
    @test QueryOperators.max_by(q, i -> i.a, :(i -> i.a)) == (a = 2, b = 2)
    @test QueryOperators.single(q, i -> i.a == 2, :(i -> i.a == 2)) == (a = 2, b = 2)
    @test QueryOperators.aggregate(q, 0, (acc, cur) -> acc + cur.a, :((acc, cur) -> acc + cur.a)) == 3
    @test QueryOperators.sequence_equal(q, [(a = 1, b = 1), (a = 2, b = 2)]) == true
    @test QueryOperators.sequence_equal(q, [(a = 1, b = 1)]) == false
end

@testitem "count on a Queryable used to have no method at all" setup=[ExampleBackend] begin
    # Regression: before QueryableScalar there was no QueryOperators.count
    # method taking a Queryable, so a query ending in @count() failed.
    @test hasmethod(QueryOperators.count, Tuple{QueryableBackend.Queryable})
    @test QueryOperators.count(QueryOperators.query(source)) == 2
end

@testitem "the query plan describes the new nodes" setup=[ExampleBackend] begin
    q = QueryOperators.index(
        QueryOperators.take_last(
            QueryOperators.reverse(QueryOperators.query(source)), 2))

    plan = QueryableBackend.queryplan(q)
    descriptions = [QueryableBackend.describe_node(n) for n in plan.nodes]

    @test descriptions == ["Source", "Reverse", "TakeLast: 2", "Index"]

    # None of the new nodes should be falling through to the type-name fallback.
    @test !any(d -> startswith(d, "QueryableBackend."), descriptions)
end

@testitem "the query plan distinguishes the plain and _by set operators" setup=[ExampleBackend] begin
    plain = QueryableBackend.describe_node(
        QueryOperators.except(QueryOperators.query(source), [(a = 1, b = 1)]))
    by = QueryableBackend.describe_node(
        QueryOperators.except_by(QueryOperators.query(source), [(a = 1, b = 1)], i -> i.a, :(i -> i.a)))

    @test plain == "Except"
    @test startswith(by, "ExceptBy:")
    @test occursin("i.a", by)
end
