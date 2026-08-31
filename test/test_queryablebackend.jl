@testsnippet ExampleBackend begin
    import QueryOperators
    import IteratorInterfaceExtensions
    using Query

    struct ExampleSource
    end

    function QueryOperators.query(x::ExampleSource)
        return QueryableBackend.QueryableSource() do querytree
            return [(a = 1, b = 1), (a = 2, b = 2)]
        end
    end

    source = ExampleSource()
end

@testitem "filter + map builds correct tree" setup=[ExampleBackend] begin
    q = source |> @filter(_.a > 3) |> @map(_.a)

    @test q isa QueryableBackend.QueryableMap
    @test q.source isa QueryableBackend.QueryableFilter
    @test QueryableBackend.get_source(q) isa QueryableBackend.QueryableSource
end

@testitem "tree traversal" setup=[ExampleBackend] begin
    q = source |> @filter(_.a > 3) |> @map(_.a)

    nodes = QueryableBackend.walk_tree(q)
    @test length(nodes) == 3
    @test nodes[1] isa QueryableBackend.QueryableSource
    @test nodes[2] isa QueryableBackend.QueryableFilter
    @test nodes[3] isa QueryableBackend.QueryableMap
end

@testitem "getiterator still works" setup=[ExampleBackend] begin
    r = source |> @filter(_.a > 3) |> @map(_.a) |>
        IteratorInterfaceExtensions.getiterator |> collect

    @test r == [(a = 1, b = 1), (a = 2, b = 2)]
end

@testitem "orderby + take builds correct tree" setup=[ExampleBackend] begin
    q = source |> @orderby(_.a) |> @take(5)

    @test q isa QueryableBackend.QueryableTake
    @test q.n == 5
    @test q.source isa QueryableBackend.QueryableOrderBy
    @test q.source.descending == false
end

@testitem "orderby_descending" setup=[ExampleBackend] begin
    q = source |> @orderby_descending(_.a)

    @test q isa QueryableBackend.QueryableOrderBy
    @test q.descending == true
end

@testitem "drop" setup=[ExampleBackend] begin
    q = source |> @drop(3)

    @test q isa QueryableBackend.QueryableDrop
    @test q.n == 3
end

@testitem "unique" setup=[ExampleBackend] begin
    q = source |> @unique(_.a)

    @test q isa QueryableBackend.QueryableUnique
end

@testitem "thenby" setup=[ExampleBackend] begin
    q = source |> @orderby(_.a) |> @thenby(_.b)

    @test q isa QueryableBackend.QueryableThenBy
    @test q.descending == false
    @test q.source isa QueryableBackend.QueryableOrderBy
end
