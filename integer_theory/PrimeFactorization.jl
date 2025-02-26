module PrimeFactorization

export SmallestFactor, isPrime, nthPrime, CanonicalPrimeFactorization
export generatePrimesUpTo, listFirstNPrimes, primeFactorizationBatch
export factorizeRange, clearCaches

const smallestFactorCache = Dict{Int, Int}()
const factorizationCache = Dict{Int, Vector{Tuple{Int, Int}}}()
const primeCache = Int[]
const isPrimeCache = Dict{Int, Bool}()

function getFromSmallestFactorCache(n::Int)
    haskey(smallestFactorCache, n) && return smallestFactorCache[n]
    return nothing
end

function isEven(n::Int)
    return n % 2 == 0
end

function saveToSmallestFactorCache(n::Int, factor::Int)
    smallestFactorCache[n] = factor
    return factor
end

function useKnownPrimesForFactorization(n::Int)
    if haskey(isPrimeCache, n) && isPrimeCache[n]
        return saveToSmallestFactorCache(n, n)
    end
    
    for p in primeCache
        if p > isqrt(n)
            break
        end
        
        if n % p == 0
            return saveToSmallestFactorCache(n, p)
        end
    end
    
    return nothing
end

function findFactorByTrialDivision(n::Int)
    for i in 3:2:isqrt(n)
        if n % i == 0
            return saveToSmallestFactorCache(n, i)
        end
    end
    
    return markAsPrime(n)
end

function markAsPrime(n::Int)
    isPrimeCache[n] = true
    return saveToSmallestFactorCache(n, n)
end

function SmallestFactor(n::Int)
    cached = getFromSmallestFactorCache(n)
    if cached !== nothing
        return cached
    end
    
    if n <= 1
        return n
    elseif isEven(n)
        return saveToSmallestFactorCache(n, 2)
    end
    
    if !isempty(primeCache)
        result = useKnownPrimesForFactorization(n)
        if result !== nothing
            return result
        end
    end
    
    return findFactorByTrialDivision(n)
end

function SmallestFactor(nums::AbstractArray{<:Integer})
    return map(SmallestFactor, nums)
end

function getFromPrimalityCache(n::Int)
    if haskey(isPrimeCache, n)
        return isPrimeCache[n]
    end
    return nothing
end

function saveToPrimalityCache(n::Int, isPrimeValue::Bool)
    isPrimeCache[n] = isPrimeValue
    return isPrimeValue
end

function determinePrimality(n::Int)
    result = SmallestFactor(n) == n
    return saveToPrimalityCache(n, result)
end

function isPrime(n::Int)
    cached = getFromPrimalityCache(n)
    if cached !== nothing
        return cached
    end
    
    if n <= 1
        return saveToPrimalityCache(n, false)
    end
    
    return determinePrimality(n)
end

function isPrime(nums::AbstractArray{<:Integer})
    return map(isPrime, nums)
end

function createSieve(n::Int)
    sieve = ones(Bool, n)
    sieve[1] = false
    return sieve
end

function applySieveOfEratosthenes(sieve::Array{Bool, 1})
    n = length(sieve)
    for i in 2:isqrt(n)
        if sieve[i]
            for j in i^2:i:n
                sieve[j] = false
            end
        end
    end
    return sieve
end

function extractPrimesFromSieve(sieve::Array{Bool, 1})
    return findall(sieve)
end

function updatePrimeCaches(sieve::Array{Bool, 1}, primes::Array{Int, 1})
    empty!(primeCache)
    append!(primeCache, primes)
    
    for i in 1:length(sieve)
        isPrimeCache[i] = sieve[i]
    end
    
    return primes
end

function getPrimesUpToFromCache(n::Int)
    if !isempty(primeCache) && primeCache[end] >= n
        return filter(p -> p <= n, primeCache)
    end
    return nothing
end

function generatePrimesUpTo(n::Int)
    if n < 2
        return Int[]
    end
    
    cached = getPrimesUpToFromCache(n)
    if cached !== nothing
        return cached
    end
    
    sieve = createSieve(n)
    applySieveOfEratosthenes(sieve)
    primes = extractPrimesFromSieve(sieve)
    return updatePrimeCaches(sieve, primes)
end

function initializePrimeCache()
    if isempty(primeCache)
        push!(primeCache, 2)
        isPrimeCache[2] = true
    end
end

function expandPrimeCacheToSize(n::Int)
    num = last(primeCache) + 1
    while length(primeCache) < n
        if isPrime(num)
            push!(primeCache, num)
        end
        num += 1
    end
    return primeCache[n]
end

function nthPrime(n::Int)
    n <= 0 && error("Input must be a positive integer")
    
    if length(primeCache) >= n
        return primeCache[n]
    end
    
    initializePrimeCache()
    return expandPrimeCacheToSize(n)
end

function getFromFactorizationCache(n::Int)
    if haskey(factorizationCache, n)
        return factorizationCache[n]
    end
    return nothing
end

function saveToFactorizationCache(n::Int, factorization::Vector{Tuple{Int, Int}})
    factorizationCache[n] = factorization
    return factorization
end

function createEmptyFactorization()
    return Tuple{Int, Int}[]
end

function factorizeNumber(n::Int)
    factorization = createEmptyFactorization()
    remaining = n
    
    while remaining > 1
        p = SmallestFactor(remaining)
        count = countFactorOccurrences(remaining, p)
        remaining = removeFactorNTimes(remaining, p, count)
        
        push!(factorization, (p, count))
    end
    
    return saveToFactorizationCache(n, factorization)
end

function countFactorOccurrences(n::Int, factor::Int)
    count = 0
    while n % factor == 0
        n ÷= factor
        count += 1
    end
    return count
end

function removeFactorNTimes(n::Int, factor::Int, count::Int)
    for _ in 1:count
        n ÷= factor
    end
    return n
end

function CanonicalPrimeFactorization(n::Int)
    cached = getFromFactorizationCache(n)
    if cached !== nothing
        return cached
    end
    
    n < 1 && error("Input must be a positive integer")
    
    if n == 1
        return saveToFactorizationCache(1, createEmptyFactorization())
    end
    
    return factorizeNumber(n)
end

function CanonicalPrimeFactorization(nums::AbstractArray{<:Integer})
    return map(CanonicalPrimeFactorization, nums)
end

function clearCaches()
    empty!(smallestFactorCache)
    empty!(factorizationCache)
    empty!(primeCache)
    empty!(isPrimeCache)
end

function prepareForRangeFactorization(maxValue::Int)
    generatePrimesUpTo(isqrt(maxValue))
end

function factorizeRange(start::Int, stop::Int)
    prepareForRangeFactorization(stop)
    
    numbers = collect(start:stop)
    return Dict(n => CanonicalPrimeFactorization(n) for n in numbers)
end

function primeFactorizationBatch(start::Int, stop::Int)
    prepareForRangeFactorization(stop)
    return CanonicalPrimeFactorization(collect(start:stop))
end

function ensurePrimeCacheSize(n::Int)
    if length(primeCache) < n
        for i in 1:n
            nthPrime(i)
        end
    end
end

function listFirstNPrimes(n::Int)
    if n <= 0
        return Int[]
    end
    
    ensurePrimeCacheSize(n)
    return primeCache[1:n]
end

end # module PrimeFactorization


