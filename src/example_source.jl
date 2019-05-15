struct ExampleSource
end

function QueryOperators.query(source::ExampleSource)
    return QueryableSource() do querytree
        return [(a=1, b=1), (a=2, b=2)]
    end
end
