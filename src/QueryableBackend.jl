module QueryableBackend

import IteratorInterfaceExtensions, TableTraits, QueryOperators

include("queryable/queryable.jl")
include("queryable/queryable_filter.jl")
include("queryable/queryable_map.jl")
include("queryable/queryable_groupby.jl")
include("queryable/queryable_orderby.jl")
include("queryable/queryable_thenby.jl")
include("queryable/queryable_join.jl")
include("queryable/queryable_groupjoin.jl")
include("queryable/queryable_mapmany.jl")
include("queryable/queryable_take.jl")
include("queryable/queryable_drop.jl")
include("queryable/queryable_unique.jl")

include("source_queryable.jl")
include("query_tree.jl")
include("query_plan.jl")

end
