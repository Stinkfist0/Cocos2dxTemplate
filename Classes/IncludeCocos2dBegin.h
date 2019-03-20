#ifdef _MSC_VER
#pragma warning(push)
// 4100 - unreferenced formal parameter
// 4201 - nonstandard extension used: nameless struct/union
#pragma warning(disable : 4100 4201)
#else
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wshadow"
#pragma GCC diagnostic ignored "-Wvariadic-macros"
// Suppress e.g. extra semicolon warnings (no dedicated switch for them, at least in older GCC)
// This doesn't disable "warning: ISO C++11 requires at least one argument for the "..." in a variadic macro",
// though, which is a -Wpedantic warning. This appears to be fixed in GCC 8.1.
#pragma GCC diagnostic ignored "-Wpedantic"
#endif

