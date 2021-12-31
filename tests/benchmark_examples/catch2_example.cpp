#ifdef CATCH3
    #include <catch2/catch_test_macros.hpp>
    #include <catch2/benchmark/catch_benchmark.hpp>
#else
    #define CATCH_CONFIG_MAIN
    #define CATCH_CONFIG_ENABLE_BENCHMARKING
    #include <catch2/catch.hpp>
#endif

unsigned int Factorial( unsigned int number ) {
    return number <= 1 ? number : Factorial(number-1)*number;
}


TEST_CASE("Factorial benchmark") {
    REQUIRE(Factorial(12) == 479001600);

    BENCHMARK("factorial 12") {
        return Factorial(12);
    };
}
