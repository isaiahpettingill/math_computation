include("PrimeFactorization.jl")

module PrimeFactorizationTests

using Test
using ..PrimeFactorization

function run_tests()
    @testset "PrimeFactorization Tests" begin
        # Clear caches for clean testing
        clearCaches()
        
        @testset "SmallestFactor" begin
            @test SmallestFactor(1) == 1
            @test SmallestFactor(2) == 2
            @test SmallestFactor(4) == 2
            @test SmallestFactor(9) == 3
            @test SmallestFactor(17) == 17
            @test SmallestFactor(25) == 5
            @test SmallestFactor(91) == 7  # 7 * 13
            
            # Vectorized version
            @test SmallestFactor([4, 9, 17]) == [2, 3, 17]
            
            # Caching
            # Call again to test cache
            @test SmallestFactor(91) == 7
        end
        
        @testset "isPrime" begin
            @test !isPrime(1)
            @test isPrime(2)
            @test isPrime(3)
            @test !isPrime(4)
            @test isPrime(5)
            @test !isPrime(6)
            @test isPrime(7)
            @test !isPrime(8)
            @test !isPrime(9)
            @test isPrime(11)
            @test isPrime(13)
            @test !isPrime(15)
            @test isPrime(17)
            @test isPrime(19)
            @test !isPrime(21)
            @test isPrime(23)
            @test !isPrime(25)
            @test isPrime(29)
            @test isPrime(31)
            @test !isPrime(121)  # 11^2
            
            # Vectorized version
            @test isPrime([2, 3, 4, 5]) == [true, true, false, true]
        end
        
        @testset "generatePrimesUpTo" begin
            primes = generatePrimesUpTo(20)
            @test length(primes) == 8
            @test primes == [2, 3, 5, 7, 11, 13, 17, 19]
            
            # Test caching
            primes_cached = generatePrimesUpTo(15)
            @test primes_cached == [2, 3, 5, 7, 11, 13]
            
            # Test larger set
            primes_100 = generatePrimesUpTo(100)
            @test length(primes_100) == 25
            @test primes_100[end] == 97
        end
        
        @testset "nthPrime" begin
            clearCaches()  # Reset for this test
            
            @test nthPrime(1) == 2
            @test nthPrime(2) == 3
            @test nthPrime(3) == 5
            @test nthPrime(4) == 7
            @test nthPrime(5) == 11
            @test nthPrime(6) == 13
            @test nthPrime(10) == 29
            
            # This should use cache
            @test nthPrime(1) == 2
            
            # Test a higher prime
            @test nthPrime(20) == 71
        end
        
        @testset "CanonicalPrimeFactorization" begin
            @test CanonicalPrimeFactorization(1) == []
            @test CanonicalPrimeFactorization(2) == [(2, 1)]
            @test CanonicalPrimeFactorization(3) == [(3, 1)]
            @test CanonicalPrimeFactorization(4) == [(2, 2)]
            @test CanonicalPrimeFactorization(6) == [(2, 1), (3, 1)]
            @test CanonicalPrimeFactorization(8) == [(2, 3)]
            @test CanonicalPrimeFactorization(12) == [(2, 2), (3, 1)]
            @test CanonicalPrimeFactorization(15) == [(3, 1), (5, 1)]
            @test CanonicalPrimeFactorization(16) == [(2, 4)]
            @test CanonicalPrimeFactorization(18) == [(2, 1), (3, 2)]
            @test CanonicalPrimeFactorization(60) == [(2, 2), (3, 1), (5, 1)]
            @test CanonicalPrimeFactorization(100) == [(2, 2), (5, 2)]
            
            # Test caching
            # Call again to verify cache usage
            @test CanonicalPrimeFactorization(60) == [(2, 2), (3, 1), (5, 1)]
            
            # Vectorized version
            factorizations = CanonicalPrimeFactorization([6, 10, 15])
            @test factorizations[1] == [(2, 1), (3, 1)]
            @test factorizations[2] == [(2, 1), (5, 1)]
            @test factorizations[3] == [(3, 1), (5, 1)]
        end
        
        @testset "listFirstNPrimes" begin
            clearCaches()  # Reset for this test
            
            @test listFirstNPrimes(5) == [2, 3, 5, 7, 11]
            @test listFirstNPrimes(10) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
            
            # Test empty case
            @test listFirstNPrimes(0) == []
        end
        
        @testset "factorizeRange" begin
            clearCaches()  # Reset for this test
            
            range_result = factorizeRange(10, 15)
            @test range_result[10] == [(2, 1), (5, 1)]
            @test range_result[11] == [(11, 1)]
            @test range_result[12] == [(2, 2), (3, 1)]
            @test range_result[13] == [(13, 1)]
            @test range_result[14] == [(2, 1), (7, 1)]
            @test range_result[15] == [(3, 1), (5, 1)]
        end
        
        @testset "primeFactorizationBatch" begin
            clearCaches()  # Reset for this test
            
            batch_result = primeFactorizationBatch(7, 12)
            @test batch_result[1] == [(7, 1)]
            @test batch_result[2] == [(2, 3)] # 8
            @test batch_result[3] == [(3, 2)] # 9
            @test batch_result[4] == [(2, 1), (5, 1)] # 10
            @test batch_result[5] == [(11, 1)] # 11
            @test batch_result[6] == [(2, 2), (3, 1)] # 12
        end
        
        @testset "Edge cases" begin
            # Test error handling
            @test_throws ErrorException CanonicalPrimeFactorization(0)
            @test_throws ErrorException CanonicalPrimeFactorization(-5)
            @test_throws ErrorException nthPrime(0)
            @test_throws ErrorException nthPrime(-1)
            
            # Test very large factorization
            large_num = 123456789
            factorization = CanonicalPrimeFactorization(large_num)
            # 123456789 = 3^2 * 3607 * 3803
            @test factorization == [(3, 2), (3607, 1), (3803, 1)]
            
            # Verify cache is working for large number
            # Second call should be fast
            @test CanonicalPrimeFactorization(large_num) == [(3, 2), (3607, 1), (3803, 1)]
        end
        
        @testset "Cache management" begin
            clearCaches()
            
            # Fill some cache data
            SmallestFactor(100)
            isPrime(17)
            CanonicalPrimeFactorization(60)
            
            # Check caches are not empty
            @test !isempty(PrimeFactorization.smallestFactorCache)
            @test !isempty(PrimeFactorization.isPrimeCache)
            @test !isempty(PrimeFactorization.factorizationCache)
            
            # Clear caches
            clearCaches()
            
            # Verify caches are empty
            @test isempty(PrimeFactorization.smallestFactorCache)
            @test isempty(PrimeFactorization.isPrimeCache)
            @test isempty(PrimeFactorization.factorizationCache)
            @test isempty(PrimeFactorization.primeCache)
        end
    end
    
    println("All tests passed!")
end

end # module PrimeFactorizationTests

using .PrimeFactorizationTests
PrimeFactorizationTests.run_tests()