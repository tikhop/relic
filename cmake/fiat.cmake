set(TEST_FP "${CMAKE_BINARY_DIR}/../bin/test_fp")
set(FIAT_LOW "${CMAKE_SOURCE_DIR}/../../src/low/fiat/")
set(FIAT_FP "${FIAT_LOW}/fiat_fp.c")
set(MONT "src/ExtractionOCaml/word_by_word_montgomery")

execute_process(COMMAND "${TEST_FP}" OUTPUT_VARIABLE OUTPUT)
string(REGEX MATCHALL "[(0-9)|(A-F)]+[ \n]" MATCHES ${OUTPUT})

set(LONGEST "0")
foreach(MATCH ${MATCHES})
	STRING(STRIP "${MATCH}" MATCH)
	STRING(LENGTH "${MATCH}" LEN)
	if (${LEN} GREATER_EQUAL ${LONGEST})
		set(LONGEST ${LEN})
	endif()
endforeach()

math(EXPR WSIZE "4 * ${LONGEST}")

foreach(MATCH ${MATCHES})
	STRING(STRIP "${MATCH}" MATCH)
	STRING(LENGTH "${MATCH}" LEN)
	if (${LEN} EQUAL ${LONGEST})
		set(PRIME "${PRIME}${MATCH}")
	endif()
endforeach()

execute_process(COMMAND bash "-c" "echo 'ibase=16; ${PRIME}' | BC_LINE_LENGTH=0 bc" OUTPUT_VARIABLE PRIME)
execute_process(COMMAND $ENV{FIAT_CRYPTO}/${MONT} "--static" fp 64 ${PRIME} OUTPUT_FILE ${FIAT_FP})

configure_file(${FIAT_LOW}/relic_fp_add_low.tmpl ${FIAT_LOW}/relic_fp_add_low.c COPYONLY)
configure_file(${FIAT_LOW}/relic_fp_mul_low.tmpl ${FIAT_LOW}/relic_fp_mul_low.c COPYONLY)
configure_file(${FIAT_LOW}/relic_fp_sqr_low.tmpl ${FIAT_LOW}/relic_fp_sqr_low.c COPYONLY)
configure_file(${FIAT_LOW}/relic_fp_inv_low.tmpl ${FIAT_LOW}/relic_fp_inv_low.c COPYONLY)
