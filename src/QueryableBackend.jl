module QueryableBackend

import IteratorInterfaceExtensions, TableTraits, QueryOperators

include("queryable/queryable.jl")
include("queryable/queryable_filter.jl")

include("source_queryable.jl")

include("example_source.jl")

end
