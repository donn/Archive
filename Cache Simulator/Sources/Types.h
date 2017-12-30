/*
	Types.h
	A header file that makes C stdint.h and booleans slightly easier to type.
	Requires C++11.
*/

#pragma once
#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#include <stdbool.h>
#endif

#ifndef uint
#define uint unsigned int
#endif
#define int8 int8_t
#define uint8 uint8_t
#define int16 int16_t
#define uint16 uint16_t
#define int32 int32_t
#define uint32 uint32_t
#define int64 int64_t
#define uint64 int64_t