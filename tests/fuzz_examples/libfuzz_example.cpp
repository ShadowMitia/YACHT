#include <stddef.h>
#include <stdint.h>

size_t first_idx_of_negative(const int* arr, const size_t& size) {
    size_t idx = 0;

    // early return for empty array, to avoid fuzzer returning [] as it is the first thing it tries.
    if (size == 0) {
        return 0;
    }

    // Subtle error here, the check condition for the size should be first.
    //     idx will be out of bounds by 1 if no negative value has been found.
    while (arr[idx] >= 0 && idx < size) {
        idx++;
    }

    return idx;
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
    // volatile to avoid optimizing return away, because we are not using it.
    volatile auto ret = first_idx_of_negative(reinterpret_cast<const int*>(data), size / sizeof(int));
    // call with void to avoid unused warning.
    (void)(ret);
    return 0;
}
