abstract type Judgment end

struct PairwiseComparison{T} <: Judgment
    former_id :: Int
    latter_id :: Int
    agent_id :: Int
    judgment :: T
end

Base.show(io::IO, z::PairwiseComparison) = print(io, "(",z.former_id,"→",z.latter_id,", ",z.agent_id,", ",z.judgment,")")

function pairwise_comparisons_extractor(R::Matrix)
    n_row,n_col = size(R)
    if n_row!=n_col
        throw(ErrorException("非方阵！"))
    else
        nA = n_row
    end
    prvector = Vector{PairwiseComparison}([])
    for i in 1:nA
        for j in (i+1):nA
            if !isnan(R[i,j])
                push!(prvector,PairwiseComparison{typeof(R[i,j])}(i,j,0,R[i,j]))
            end
        end
    end
    return prvector
end

function comparisons2regression(prvector::Vector{PairwiseComparison},nA::Int,link_functions::Vector{Function})
    nJ = length(prvector)
    X = zeros(Int,nJ,nA-1)
    y = empty(Any,nJ)
    for k in 1:nJ
        X[k,prvector[k].former_id] = 1
        X[k,prvector[k].latter_id] = -1
        y[k] = link_functions[prvector[k].agent](prvector[k].judgment)
    end
    return X,y
end